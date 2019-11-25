# #####################################################
library(promises)
library(future)
library(Rook)
library(filesstrings)

source('./EpiClockR_CheckFile.R')
source('./EpiClockR_MoveFile.R')
source('./EpiClockR_Run.R')
source('./EpiClockR_FetchResult.R')
source('./EpiClockR_FetchSampleResult.R')
source('./EpiClockR_FetchSummaryResult.R')

future::plan("multicore") # use all available cores
# #####################################################

AnalysisRunning <- FALSE

# #####################################################

#' @filter cors
cors <- function(req, res) {
  
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200 
    return(list())
  } else {
    plumber::forward()
  }
  
}

#* @assets ./build /
list()

#* @get /api/entry
function(){
  list(msg = paste0("This is Entry Endpoint."))
}

#' @json(auto_unbox = TRUE)
#' @get /api/sync
function() {
  # print route, time, and worker pid
  paste0("/sync; ", Sys.time(), "; pid:", Sys.getpid())
}

#' @contentType list(type = "text/html")
#' @json(auto_unbox = TRUE)
#' @get /api/future
function() {

  future({
    # perform large computations
    Sys.sleep(10)

    # print route, time, and worker pid
    paste0("/future; ", Sys.time(), "; pid:", Sys.getpid())
  })
}


#* @post /api/upload
upload <- function(req, res){
  future({
  message("\n==== New Upload Request ====")
  formContents = Rook::Multipart$parse(req)
  stamp <- names(formContents)
  fileInfo <- formContents[[1]]
  tmpfileName <- tail(strsplit(fileInfo$tempfile,split="/")[[1]],n=1)
  fileName <- fileInfo$filename
  file.move(fileInfo$tempfile, "./upload_files/")
  file.rename(paste("./upload_files/",tmpfileName,sep=""), paste0("./upload_files/", stamp, '___',fileName))
  message("Server has received ", fileName, ' in ./upload_files folder.')
  list(formContents)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      print(error$message)
      print(error)
      stop(error)
    })
}

#* @get /api/checkfile
#* @json(auto_unbox = TRUE)
function(stamp) {
  future({
    # result <- CheckFile(stamp)
    result = tryCatch({
      CheckFile(stamp)
    }, error = function(e) {
      message("Error when checking data.")
      list(msg="error")
    })
    return(result)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      list(msg="error")
    }) %>%
    promises::then( function(res) {
      list(data = res)
      }
    )
}

#* @get /api/checkconfirm
#* @json(auto_unbox = TRUE)
function(email,code,type,time,valid,novalid) {
  future({
    result = tryCatch({
      MoveFile(email,code,type,time,valid,novalid)
    }, error = function(e) {
      message("Error when moving data.")
      list(msg="error")
    })
    return(result)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      list(msg="error")
    }) %>%
    promises::then( function(res) {
      list(data = res)
      }
    )
}

#* @get /api/fetchresult
#* @json(auto_unbox = TRUE)
function(email,code) {
  future({
    result = tryCatch({
      FetchResult(email,code)
    }, error = function(e) {
      message("Error when fetching data.")
      list(msg="error")
    })
    return(result)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      list(msg="error")
    }) %>%
    promises::then( function(res) {
      list(data = res)
      }
    )
}

#* @get /api/fetchsampleresult
#* @json(auto_unbox = TRUE)
function(valid) {
  future({
    result = tryCatch({
      FetchSampleResult(valid)
    }, error = function(e) {
      message("Error when fetching sample result.")
      list(msg="error")
    })
    return(result)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      message("[Plumber]: Error in future /fetchsampleresult")
      list(msg="error")
    }) %>%
    promises::then( function(res) {
      list(data = res)
      }
    )
}

#* @get /api/fetchsummaryresult
#* @json(auto_unbox = TRUE)
function(email,code,time) {
  future({
    result = tryCatch({
      FetchSummaryResult(email,code,time)
    }, error = function(e) {
      message("Error when fetching sample result.")
      list(msg="error")
    })
    return(result)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      message("[Plumber]: Error in future /fetchsummaryresult")
      list(msg="error")
    }) %>%
    promises::then( function(res) {
      list(data = res)
      }
    )
}


#* @get /api/trigger
#* @json(auto_unbox = TRUE)
function() {

  if(AnalysisRunning) {
    message("The ClockR is Runing already...")
    list(msg="success",status="Already Running")
  } else {
    message("Starting the ClockR...")
    AnalysisRunning <<- TRUE
    future({
      result = tryCatch({
        RunFile()
    }, error = function(e) {
      message("Error when running file.")
      list(msg="error")
    })
      return(result)
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      print(error)

      AnalysisRunning <<- FALSE
      message("The ClockR is stopped.")
    }) %>%
    promises::then( function(res) {
      print(res)

      AnalysisRunning <<- FALSE
      message("The ClockR is stopped.")
      }
    )
  }  
}

#' @get /api/divide
#' @json(auto_unbox = TRUE)
function(a = NA, b = NA) {
  future({
    a <- as.numeric(a)
    b <- as.numeric(b)
    if (is.na(a)) stop("a is missing")
    if (is.na(b)) stop("b is missing")
    if (b == 0) stop("Cannot divide by 0")

    return(list(result=a/b,up=a,down=b))
  }) %>%
    # Handle `future` errors
    promises::catch(function(error) {
      print(error$message)
      print(str(error))
      # handle error here!
      if (error$message == "b is missing") {
        return(Inf)
      }

      # rethrow original error
      stop(error)
    }) %>%
    promises::then( function(res) {
      list(msg = res$result)
      }
    )
}
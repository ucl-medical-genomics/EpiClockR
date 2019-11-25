library(RSQLite)
library(filesstrings)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")

EpiClockR.run <- function(record)
{
    fileName <- record[1,5]
    arraytype <- record[1,3]
    idatName <- tail(strsplit(fileName,split="___")[[1]],n=1)
    
    message("\n--------------------")
    message("Load IDAT File")
    source("./Functions/import.R")
    myImport <- EpiClockR.import(fileName,arraytype)
    
    message("\n--------------------")
    message("Filter Detect P")
    source("./Functions/filter.R")
    myFilter <- EpiClockR.filter(myImport$beta,myImport$detP)
    
    message("\n--------------------")
    message("Normalization")
    source("./Functions/norm.R")
    myNorm <- EpiClockR.norm(myFilter$beta,arraytype)
#    myNorm = tryCatch({
#        EpiClockR.norm(myFilter$beta,arraytype)
#    }, error = function(e) {
#      message("Error when running file.")
#      'Failed'
#    })
    
    message("\n--------------------")
    message("Run Gender Prediction")
    source("./Functions/gender.R")
    myGender <- EpiClockR.gender(myImport$beta,myImport$detP)
    
    message("\n--------------------")
    message("Run Hannum Clocks and EpiToc")
    source("./Functions/ageR.R")
    myAgeR <- EpiClockR.ageR(myNorm$beta)

    message("\n--------------------")
    message("Run Horvath Clocks")
    source("./Functions/horvath.R")
    myHorvath <- EpiClockR.horvath(myNorm$beta)

    message("\nSuccess\n")
    
    
    myInsert <- cbind(record,
                      myGender=myGender,
                      myHorvath=myHorvath,
                      myHannum=myAgeR$Hannum,
                      myEpiToc=myAgeR$EpiToc
                      )

    
    myInsert$status = "Done"

    return(myInsert)
}

RunFile <- function(){
    while(TRUE)
{
    message("\n--------------------")
    message("Fetch One Record from FileList")

    record <- dbGetQuery(mydb, 'SELECT * FROM FileList WHERE "status" = "Queueing" LIMIT 1 ')
    if(nrow(record) == 0) break
    
    record <- record[1,]
    fileName <- record[1,5]

    judge <- TRUE
    # myInsert <- EpiClockR.run(record)

    myInsert = tryCatch({
      EpiClockR.run(record)
    }, error = function(e) {
      judge = FALSE
      message("Error with ",fileName)
    })

    if(judge) {
      dbWriteTable(mydb, "ResultList", myInsert , overwrite = FALSE, append = TRUE)
      update_query <- paste('UPDATE FileList ',
                            'SET status = "Done" ',
                            'WHERE "valid.name" = "',fileName,'"',
                            sep="")
            
    } else {
            update_query <- paste('UPDATE FileList ',
                            'SET status = "Error" ',
                            'WHERE "valid.name" = "',fileName,'"',
                            sep="")
    }

    dbSendQuery(mydb, update_query)

    toRemove <- c(paste("./preprocess_files/",fileName,"_Grn.idat",sep=""),paste("./preprocess_files/",fileName,"_Red.idat",sep=""))
    file.remove(toRemove)
    # break
}

  currentQueneing = tryCatch({
    dbGetQuery(mydb, 'SELECT Count(*) FROM FileList WHERE "status" = "Queueing"')[1,1]
}, warning = function(w) {
    'Error'
}, error = function(e) {
    message("No queueing in FileList yet.")
    0
})

return(list(msg="success", currentQueneing=currentQueneing))
}



# dbDisconnect(mydb)

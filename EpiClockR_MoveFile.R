library(filesstrings)
library(RSQLite)
library(jsonlite)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")

# dbRemoveTable(mydb, "ReadyList")
# dbRemoveTable(mydb, "FileList")

MoveFile <- function(email,code,type,time,valid,novalid){

  valid <- fromJSON(valid)
  novalid <- fromJSON(novalid)

  message("Moving Valid Files to ./preprocess_files folder.")

  if(length(valid) > 0){
      valid.name <- paste(email,code,type,time,valid,sep="___")
      
      toMoveFile <- c(paste(valid.name,"_Grn.idat",sep=""),paste(valid.name,"_Red.idat",sep=""))

      toMoveFile <- paste("./upload_files/",toMoveFile,sep="")
      file.move(toMoveFile, "./preprocess_files")

  } else {
      valid.name <- vector()
      stop('There is no valid sample.')
  }

  message("Removing Invalid Files from Server.")

  if(length(novalid) > 0) {
      novalid.name <- paste(email,code,type,time,novalid,sep="___")
      novalid.name <- c(paste(novalid.name,"_Grn.idat",sep=""),paste(novalid.name,"_Red.idat",sep=""))

      toRemoveFile <- paste("./upload_files/",novalid.name,sep="")
      file.remove(toRemoveFile)

  } else {
      novalid.name <- vector()
      message("Great! There is no invalid samples.")
  }

  record <- data.frame(email=email,code=code,type=type,time=time)
  FileList <- data.frame(record,valid.name, status="Queueing")


  message("Get Current Queueing Status.")
  currentQueneing = tryCatch({
    dbGetQuery(mydb, 'SELECT Count(*) FROM FileList WHERE "status" = "Queueing"')[1,1]
}, warning = function(w) {
    'Error'
}, error = function(e) {
    message("No data in FileList yet.")
    0
})

  message("Inserting Record into SQLite database.")
  
  dbWriteTable(mydb, "ReadyList", record, overwrite = FALSE, append = TRUE)
  dbWriteTable(mydb, "FileList", FileList, overwrite = FALSE, append = TRUE)

  return(list(msg="success", currentQueneing=currentQueneing))
}

library(filesstrings)
library(RSQLite)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")
#dbRemoveTable(mydb, "ReadyList")

CheckFile <- function(stamp){

message("Breakdown Stamp.")

stamp_breakdown <- strsplit(stamp,split="___")[[1]]

email <- stamp_breakdown[1]
code <- stamp_breakdown[2]
type <- stamp_breakdown[3]
time <- stamp_breakdown[4]

message("Find Stamp-Associated Files. ")

files <- as.data.frame(t(sapply(dir("./upload_files/"),function(x) strsplit(x,split="___")[[1]])))
colnames(files) <- c("email","code","type","time","idat")

index <- which(files$email == email & files$code == code & files$type == type & files$time == time)
TargetFiles <- files[index,]

message("Check Red/Green Channel Match.")

idats_channal <- as.character(TargetFiles$idat)
idats <- sapply(idats_channal,function(x) paste(strsplit(x,split="_")[[1]][1:2],collapse="_"))
twoFiles <- names(table(idats))

valid <- twoFiles[paste(twoFiles,"_Grn.idat",sep="") %in% idats_channal & paste(twoFiles,"_Red.idat",sep="") %in% idats_channal]
novalid <- setdiff(twoFiles,valid)

idats_valid <- c(paste(valid,"_Grn.idat",sep=""),paste(valid,"_Red.idat",sep=""))
message("Totally, there are ",length(valid)," sample to be run for stamp ", stamp)

toMove <- rownames(TargetFiles)[files$email == email & files$code == code & files$type == type & files$time == time & idats_channal %in% idats_valid]

toMoveFile <- paste("./upload_files/",toMove,sep="")

#file.move(toMoveFile, "./preprocess_files")

message("Valid files are moved for queueing anlaysis.")

record <- data.frame(email=email,code=code,type=type,time=time)

FileList <- data.frame(record,toMove, status="Queueing")

currentQueneing = tryCatch({
    dbGetQuery(mydb, 'SELECT Count(*) FROM FileList WHERE "status" = "Queueing"')[1,1]
}, warning = function(w) {
    'Error'
}, error = function(e) {
    message("No data in FileList yet.")
    0
})

# dbWriteTable(mydb, "ReadyList", record, overwrite = FALSE, append = TRUE)
# dbWriteTable(mydb, "FileList", FileList, overwrite = FALSE, append = TRUE)

message("Added Stamp and FileList into RSQLite, will process them one by one.")

#dbGetQuery(mydb, 'SELECT * FROM ReadyList LIMIT 5')

if(length(valid) == 1) valid <- list(valid)
if(length(novalid) == 1) novalid <- list(novalid)

return(
    list(
        msg="success",
        validNumber=length(valid),
        email=email,
        code=code,
        type=type,
        time=time,
        currentQueneing=currentQueneing,
        valid=valid,
        novalid=novalid
        )
)
}

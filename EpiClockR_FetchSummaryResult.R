library(filesstrings)
library(RSQLite)
library(jsonlite)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")

FetchSummaryResult <- function(email,code,time){

  Result = tryCatch({
    tmp <- dbGetQuery(mydb, paste('SELECT * FROM ResultList WHERE "email" = "' , email , '" AND "code" = "' , code , '" AND "time" = "',time,'"',sep=""))
    record <- dbGetQuery(mydb, paste('SELECT * FROM ReadyList WHERE "email" = "' , email , '" AND "code" = "' , code , '" AND "time" = "',time,'"',sep=""))
    list(result=tmp,record=record)
}, warning = function(w) {
    '[Plumber]: Warning when fetching summary result.'
}, error = function(e) {
    message("[Plumber]: Error when fetching summary result.")
    return()
})

  return(list(msg="success", Result=Result))
}

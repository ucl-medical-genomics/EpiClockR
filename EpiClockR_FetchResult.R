library(filesstrings)
library(RSQLite)
library(jsonlite)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")

FetchResult <- function(email,code){

  Result = tryCatch({
    tmp <- dbGetQuery(mydb, paste('SELECT * FROM FileList WHERE "email" = "' , email , '" AND "code" = "' , code , '"',sep=""))
}, warning = function(w) {
    '[Plumber]: Error when fetching data.'
}, error = function(e) {
    message("[Plumber]: Error when feteching data.")
    return()
})

  return(list(msg="success", Result=Result))
}

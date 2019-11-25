library(filesstrings)
library(RSQLite)
library(jsonlite)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")

FetchSampleResult <- function(valid){

  Result = tryCatch({
    tmp <- dbGetQuery(mydb, paste('SELECT * FROM ResultList WHERE "valid.name" = "' , valid , '"',sep=""))
}, warning = function(w) {
    '[Plumber]: Warning when fetching sample result.'
}, error = function(e) {
    message("[Plumber]: Error when fetching sample result.")
    return()
})

  return(list(msg="success", Result=Result))
}

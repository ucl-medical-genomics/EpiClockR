library(RSQLite)
mydb <- dbConnect(RSQLite::SQLite(), "mydb.sqlite")

print(dbGetQuery(mydb, 'SELECT * FROM ReadyList '))
print(dbGetQuery(mydb, 'SELECT * FROM FileList '))
print(dbGetQuery(mydb, 'SELECT * FROM ResultList '))

# dbRemoveTable(mydb, "ReadyList")
# dbRemoveTable(mydb, "FileList")
# dbRemoveTable(mydb, "ResultList")

# update_query <- paste('UPDATE FileList ',
#                       'SET status = "Queueing" ',
#                       sep="")
# dbSendQuery(mydb, update_query)
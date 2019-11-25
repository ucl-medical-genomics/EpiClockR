# EpiClockR.ageR <- function(beta)
# {
#     library("cgageR")
#     df <- data.frame(mySample=beta,waste=0.5)
#     AgeR <- getAgeR(df,epitoc=TRUE, horvath = TRUE, hannum = TRUE)
#     myHorvath <- AgeR$HorvathClock.output$Horvath.Est[1,1]
#     myHannum <- AgeR$HannumClock.output$Hannum.Clock.Est[1,1]
#     myEpiToc <- AgeR$EpiTOC.output[[1]][1,1]

#     return(list(Horvath=myHorvath,Hannum=myHannum,EpiToc=myEpiToc))
# }


EpiClockR.ageR <- function(beta)
{
    library("cgageR")
    df <- data.frame(mySample=beta,waste=0.5)
    AgeR <- getAgeR(df,epitoc=TRUE, horvath = FALSE, hannum = TRUE)
    myHorvath <- AgeR$HorvathClock.output$Horvath.Est[1,1]
    myHannum <- AgeR$HannumClock.output$Hannum.Clock.Est[1,1]
    myEpiToc <- AgeR$EpiTOC.output[[1]][1,1]

    return(list(Hannum=myHannum,EpiToc=myEpiToc))
}
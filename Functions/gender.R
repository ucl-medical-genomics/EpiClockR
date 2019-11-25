EpiClockR.gender <- function(beta,detP)
{
    library("sest")
    myGender <- estimateSex(beta.value=beta,detecP=detP)[[1]]$predicted
    return(myGender)
}

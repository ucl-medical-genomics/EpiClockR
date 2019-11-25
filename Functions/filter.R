EpiClockR.filter <- function(beta,detP,detPcut=0.01)
{
    FailedProbe <- sum(detP > detPcut)
    beta <- beta[detP <= detPcut]
    detP <- detP[detP <= detPcut]
    return(list(beta=beta,FailedProbe=FailedProbe,detP=detP))
}

EpiClockR.norm <- function(beta,arraytype)
{
    source("./Functions/champ.BMIQ.R")
    print(getwd())

    if(arraytype=="EPIC") load("./Annotation/probeInfoALL.epic.lv.rda") else load("./Annotation/probeInfoALL.lv.rda")

    design.v <- as.numeric(lapply(probeInfoALL.lv,function(x) x)$Design[match(names(beta),probeInfoALL.lv$probeID)])

    normed <- champ.BMIQ(beta,design.v,plots=FALSE)$nbeta

    FailedNorm <- sum(is.na(normed))

    return(list(beta=normed,FailedNorm=FailedNorm,design.v=design.v))
}

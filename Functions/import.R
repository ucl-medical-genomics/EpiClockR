EpiClockR.import <- function(fileName,arraytype,offset=100)
{
  library(illuminaio)
  G.idats <- readIDAT(paste("./preprocess_files/",fileName,"_Grn.idat",sep=""))
R.idats <- readIDAT(paste("./preprocess_files/",fileName,"_Red.idat",sep=""))

G.Load <- G.idats$Quants[,"Mean"]
R.Load <- R.idats$Quants[,"Mean"]

if(arraytype == "EPIC") load("./Annotation/AnnoEPIC.rda") else load("./Annotation/Anno450K.rda")

control_probe <- rownames(Anno$ControlProbe)[which(Anno$ControlProbe[,1]=="NEGATIVE")]
control_probe <- control_probe[control_probe %in% names(R.Load)]

rMu <- median(R.Load[control_probe])
rSd <- mad(R.Load[control_probe])
gMu <- median(G.Load[control_probe])
gSd <- mad(G.Load[control_probe])

names(G.Load) <- paste("G",names(G.Load),sep="-")
names(R.Load) <- paste("R",names(R.Load),sep="-")

IDAT <- c(G.Load,R.Load)

M.check <- Anno$Annotation[,"M.index"] %in% names(IDAT)
M <- IDAT[Anno$Annotation[,"M.index"][M.check]]

U.check <- Anno$Annotation[,"U.index"] %in% names(IDAT)
U <- IDAT[Anno$Annotation[,"U.index"][U.check]]

if(!identical(M.check,U.check))
{
    stop("  Meth Matrix and UnMeth Matrix seems not paried correctly.")
} else {
    CpG.index <- Anno$Annotation[,"CpG"][M.check]
}

names(M) <- CpG.index
names(U) <- CpG.index

BetaValue <- M / (M + U + offset)
#MValue <- log2(M/U)
intensity <-  M + U

detP <- rep(NA,length(intensity))
names(detP) <- names(intensity)

type_II <- rownames(Anno$Annotation)[Anno$Annotation[,"Channel"] == "g+r"]
type_II <- type_II[type_II %in% names(detP)]
type_I.red <- rownames(Anno$Annotation)[Anno$Annotation[,"Channel"] == "r"]
type_I.red <- type_I.red[type_I.red %in% names(detP)]
type_I.grn <- rownames(Anno$Annotation)[Anno$Annotation[,"Channel"] == "g"]
type_I.grn <- type_I.grn[type_I.grn %in% names(detP)]

detP[type_II] <- 1 - pnorm(intensity[type_II], mean=rMu+gMu, sd=rSd+gSd)
detP[type_I.red] <- 1 - pnorm(intensity[type_I.red], mean=rMu*2, sd=rSd*2)
detP[type_I.grn] <- 1 - pnorm(intensity[type_I.grn], mean=gMu*2, sd=gSd*2)

#NBeads <- R.idats$Quants[, "NBeads"]
#Mbead <- NBeads[substr(Anno$Annotation$M.index[M.check],3,100)]
#Ubead <- NBeads[substr(Anno$Annotation$U.index[U.check],3,100)]
#Ubead[Ubead < 3 | Mbead < 3] <- NA
#names(Ubead) <- names(intensity)

#return(list("beta"=BetaValue,"M"=MValue,"intensity"=intensity,"detP"=detP,"beadcount"=Ubead))
return(list("beta"=BetaValue,"detP"=detP,"intensity"=intensity))
}

EpiClockR.horvath <- function(beta)
{
    load("./Annotation/Horvath_coef.rda")
    coeff <- coef

    betas <- data.frame(mySample=beta,waste=0.5)
    anti.trafo <- function(x,adult.age=20) { ifelse(x<0, (1+adult.age)*exp(x)-1, (1+adult.age)*x+adult.age) }

    miss <- names(coeff)[-1]%in%names(na.omit(beta))
    coef2 <- coeff[-1][miss]
    data <- beta[names(coef2)]
    pre <- data %*% coef2 + coeff[1]
    anti.trafo(pre, adult.age=20)
}

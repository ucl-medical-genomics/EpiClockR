# EpiClockR

This is the R part and build-version of Front-end.

To run EpiClockR in any server, in R session:
```
library(plumber)
plumb("entry")$run(port=1234)
```

Note that you need install the latest un-officially release version plumber:
```
library(devtools)
install_github("trestletech/plumber")
library(plumber)
```

The other R package should be just normal install stages.

Then you should be able to see the EpiClockR running in http://127.0.0.1:1234

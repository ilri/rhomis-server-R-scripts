# Setup to install the base packages needed to run these scripts

install.packages("devtools")
install.packages("renv")


library(devtools)
library(renv)

renv::hydrate()

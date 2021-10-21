# Setup to install the base packages needed to run these scripts
# Stops R from asking the user whether to aggree

install.packages("devtools")
install.packages("renv")


library(devtools)
library(renv)

# renv::hydrate()
renv::restore()
library(devtools)
library(renv)

devtools::install_github("https://github.com/l-gorman/rhomis-R-package",force=T)

renv::snapshot()

library(devtools)
library(renv)

renv::load()
devtools::install_github("https://github.com/l-gorman/rhomis-R-package", force = T)
renv::snapshot()
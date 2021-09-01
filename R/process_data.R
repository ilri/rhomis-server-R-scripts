library(rhomis)


fileConn <- file("test_output.txt")
writeLines(c("Hello","World"), fileConn)
close(fileConn)

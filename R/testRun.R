
test_run <- function() {
    test_df <- data.frame(list(
        "a" = c("xyz", "nuaelknwfkm"),
        "b" = c("123", "456")
    ))
    file_path <- tempfile(fileext = ".csv")
    write.csv(test_df, file_path)
    temp_result <- read.csv(file_path)
    unlink(file_path)
    print(temp_result)
}
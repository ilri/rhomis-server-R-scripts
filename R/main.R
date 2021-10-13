#!/bin/env Rscript
# Quick how-to  -----------------------------------------------------------


#' This is a script to run calculations on a server for RHoMIS 2.0. The script can be run in
#' two ways, you can run the script interactively (e.g. from Rstudio). Or you can run the
#' script from the command line. If running from the command line you will need to
#' enter the command:
#'
#' "Rscript path/to/file.R --arg1 firstargument --arg2 second argument ..."
#'
#' If you would like guidance on how to run this script from the command line, please
#' enter:
#'
#' "Rscript path/to/file.R --help"
#'
#' Some short documentation will appear, showing which arguments need to be passed and providing
#' a brief description. In both cases, "path/to/file.R" must reflect where the file is
#' located on your system

####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
# SETUP
####################################################################################################################
###################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################

# Setup for interactive script running  -------------------------------------------------------------------

# Checking if R running from GUI
if (interactive()) {
  renv::load()
  # Loading environment variables

  # Setting options for script run interactively.
  # These should be set manually if you are running the script interactively
  opt <- list()
  opt$projectName <- FALSE
  opt$formName <- FALSE
  opt$dataBase <- FALSE
  opt$formVersion <- FALSE
  opt$numberOfResponses <- FALSE
  opt$centralURL <- FALSE
  opt$centralEmail <- FALSE
  opt$centralPassword <- FALSE
}

# Setup for running from command line -------------------------------------
# Checking if script has been run from the command line
if (!interactive()) {
  # Directory setup in the .Rprofile
  # Identifying the file path to this script

  # Arguments passed to the script
  initial_options <- commandArgs(trailingOnly = FALSE)
  file_option <- initial_options[grep("--file", initial_options)]
  file_option <- gsub("--file=", "", file_option, fixed = T)

  project_path <- gsub("R/main.R", "", file_option, fixed = T)

  # Making sure scripts can deal with running from within the project directory
  if (grepl("home/", project_path == F) | project_path == "") {
    project_path <- paste0("./", project_path)
  }

  #' Ensures that all warnings are
  #' send to stdout rather than stderr
  sink(stdout(), type = "message")

  # Loading virtual environment
  # loading .env file

  library(optparse, warn.conflicts = F)
  #' Setting up options for calling this script from
  #' the terminal or the command line
  option_list <- list(
    optparse::make_option(
      opt_str = c("--commandType"),
      help = "The type of command you would like to execute",
    ),
    optparse::make_option(
      opt_str = c("--projectName"),
      help = "The name for the project you would like to process on ODK central",
    ),
    optparse::make_option(
      opt_str = c("--formName"),
      help = "The name of the form you would like to process on ODK central",
    ),
    optparse::make_option(
      opt_str = c("--formVersion"),
      help = "The version of the form you would like to process on ODK central",
    ),
    optparse::make_option(
      opt_str = c("--dataBase"),
      help = "The database you would like to write to",
    ),
    optparse::make_option(
      opt_str = c("--numberOfResponses"),
      help = "The number of responses you would like to generate and submit to ODK central",
    ),
    optparse::make_option(
      opt_str = c("--centralURL"),
      help = "The URL of the ODK central server",
    ),
    optparse::make_option(
      opt_str = c("--centralEmail"),
      help = "Your ODK central email",
    ),
    optparse::make_option(
      opt_str = c("--centralPassword"),
      help = "Your ODK central password",
    )
  )

  # Extracting arguments
  opt_parser <- optparse::OptionParser(option_list = option_list)
  opt <- optparse::parse_args(opt_parser)

  if (length(opt) == 0) {
    optparse::print_help(opt_parser)
    stop("At least one argument must be supplied (input file).n", call. = FALSE)
  }
}

####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
# EXECUTE SCRIPTS
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
library(rhomis, warn.conflicts = F)
print(getwd())
print(opt$commandType)

# Getting the necessary functions
source("./R/testRun.R")
source("./R/generateData.R")
source("./R/processData.R")

if (opt$commandType == "test") {
  test_run()
}

if (opt$commandType == "process") {
  processData(
    central_url = central_url,
    central_email = central_email,
    central_password = central_password,
    project_name = opt$projectName,
    form_name = opt$formName,
    form_version = form_version,
    database = opt$dataBase
  )
}

if (opt$commandType == "generate") {
  generateData(
    central_url = central_url,
    central_email = central_email,
    central_password = central_password,
    project_name = opt$projectName,
    form_name = opt$formName,
    number_of_responses = opt$numberOfResponses
  )
}
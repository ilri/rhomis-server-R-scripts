#!/bin/env Rscript

# Quick how-to  -----------------------------------------------------------


#' This is a script to generate data for a particular project. The script can be run in
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

#' Example of how to run from the command line:
#' Rscript ~/projects/rhomis-2/rhomis-server-R-scripts/R/generateData.R --projectName test_project_from_server --formName "RHoMIS 1.6" --numberOfResponses 10

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


#' Loading the virtual environment library
library(renv, warn.conflicts = F)

# Setup for interactive script running  -------------------------------------------------------------------

# stop(interactive())


# Checking if R running from GUI
if (interactive()) {
  renv::load()

  # Loading environment variables
  readRenviron(".env")

  # Setting options for script run interactively.
  # These should be set manually if you are running the script interactively
  opt <- list()
  opt$projectName <- "test_project_from_server"
  opt$formName <- "RHoMIS 1.6"
  opt$formVersion <- 1
  opt$numberOfResponses <- 10
}

# Setup for running from command line -------------------------------------
# Checking if script has been run from the command line
if (!interactive()) {
  # Directory setup in the .Rprofile
  # Identifying the file path to this script

  # Arguments passed to the script
  initial.options <- commandArgs(trailingOnly = FALSE)
  file_option <- initial.options[grep("--file", initial.options)]
  file_option <- gsub("--file=", "", file_option, fixed = T)


  # project_path <- gsub("/R/process_data.R", "",file_option, fixed=T)
  project_path <- gsub("R/generateData.R", "", file_option, fixed = T)


  # Making sure scripts can deal with running from within the project directory

  if (grepl("home/", project_path == F) | project_path == "") {
    project_path <- paste0("./", project_path)
  }

  # print(project_path)


  #' Ensures that all warnings are
  #' send to stdout rather than stderr
  sink(stdout(), type = "message")

  # Loading virtual environment
  # loading .env file
  readRenviron(paste0(project_path, ".env"))

  renv::load(project_path)

  # Ensuring that the
  library(optparse, warn.conflicts = F) # Library for parsing flags when the R-script is call

  #' Setting up options for calling this script from
  #' the terminal or the command line
  option_list <- list(
    optparse::make_option(
      opt_str = c("--projectName"),
      type = "character",
      help = "The name for the project you would like to process on ODK central",
      metavar = "character"
    ),
    optparse::make_option(
      opt_str = c("--formName"),
      type = "character",
      help = "The name of the form you would like to process on ODK central",
      metavar = "character"
    ),
    optparse::make_option(
      opt_str = c("--formVersion"),
      type = "character",
      help = "The version of the form which you would like",
      metavar = "character"
    ),
    optparse::make_option(
      opt_str = c("--numberOfResponses"),
      type = "integer",
      help = "The number of responses you would like to generate and submit to ODK central",
      metavar = "character"
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
# Generating Data
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################


# Loading Packages and Environment Variables  --------------------------------------------------------

#' Loading libraries. Suppress masking
#' warnings so they do not get passed to
#' stdout
library(rhomis, warn.conflicts = F)

central_url <- Sys.getenv("CENTRALURL")
central_url <- paste0("https://", central_url)

# Accessing the environemnt variables
central_email <- Sys.getenv("CENTRALEMAIL")
central_password <- Sys.getenv("CENTRALPASSWORD")


library(rhomis)


# Get central projectID
project_name <- opt$projectName
form_name <- opt$formName

# Finding project information from the API
projects <- get_projects(
  central_url,
  central_email,
  central_password
)
projectID <- projects$id[projects$name == project_name]


# Get central formID
forms <- get_forms(
  central_url,
  central_email,
  central_password,
  projectID
)
formID <- forms$xmlFormId[forms$name == form_name]
print(opt$formVersion)
xls_form <- rhomis::get_xls_form(
  central_url = central_url,
  central_email = central_email,
  central_password = central_password,
  projectID = projectID,
  formID = formID,
  # file_destination=form_destination,
  form_version = opt$formVersion
)


# Get number of responses to generate
number_of_responses <- opt$numberOfResponses

for (response_index in 1:number_of_responses)
{
  mock_response <- rhomis::generate_mock_response(survey = xls_form$survey, choices = xls_form$choices, metadata = xls_form$settings)
  mock_response <- gsub(">\n", ">\r\n", mock_response, fixed = T)

  submit_xml_data(mock_response,
    central_url,
    central_email,
    central_password,
    projectID = projectID,
    formID = formID
  )
}

# Delete the xls file
write("Success from Rscript", stdout())
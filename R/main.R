#!/bin/env Rscript

# Quick how-to  -----------------------------------------------------------


#' This is a script to run calculations on RHoMIS data. The script can be run in
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


#' Loading the virtual environment library
library(renv, warn.conflicts = F)

# Setup for interactive script running  -------------------------------------------------------------------

#stop(interactive())


# Checking if R running from GUI
if (interactive()){
  renv::load()
  # Loading environment variables 
  readRenviron(".env")
  
  # Setting options for script run interactively.
  # These should be set manually if you are running the script interactively
  opt <- list()
  opt$projectName <- FALSE
  opt$formName <- FALSE
  opt$dataBase <- FALSE
  opt$formVersion <- FALSE
    opt$numberOfResponses <- FALSE

  
}

# Setup for running from command line -------------------------------------
# Checking if script has been run from the command line 
if (!interactive()){
  # Directory setup in the .Rprofile
  # Identifying the file path to this script
  
  #Arguments passed to the script
  initial.options <- commandArgs(trailingOnly = FALSE)
  file_option <- initial.options[grep("--file",initial.options)]
  file_option <- gsub("--file=", "",file_option, fixed=T)


  #project_path <- gsub("/R/process_data.R", "",file_option, fixed=T)
  project_path <- gsub("R/process_data.R", "",file_option, fixed=T)


  #Making sure scripts can deal with running from within the project directory

  if (grepl("home/",project_path==F) | project_path==""){

    project_path <- paste0("./",project_path)
  }
  
  print(project_path)
  
  
  #' Ensures that all warnings are 
  #' send to stdout rather than stderr
  sink(stdout(), type="message")
  
  # Loading virtual environment
  #loading .env file
  readRenviron(paste0(project_path,".env"))
  
  renv::load(project_path)
  
  # Ensuring that the 
  library(optparse, warn.conflicts = F) # Library for parsing flags when the R-script is call
  
  #' Setting up options for calling this script from
  #' the terminal or the command line
  option_list <- list(
    optparse::make_option(opt_str = c( "--projectName"),
                          type = "character",
                          # default = "hello",
                          help="The name for the project you would like to process on ODK central",
                          metavar="character"),
    optparse::make_option(opt_str = c("--formName"),
                          type = "character",
                          # default = "world",
                          help="The name of the form you would like to process on ODK central",
                          metavar="character"),
    optparse::make_option(opt_str = c("--formVersion"),
                          type = "character",
                          # default = "world",
                          help="The version of the form you would like to process on ODK central",
                          metavar="character"),
    optparse::make_option(opt_str = c("--dataBase"),
                          type = "character",
                          # default = "world",
                          help="The database you would like to write to",
                          metavar="character"),
    optparse::make_option(opt_str = c("--numberOfResponses"),
                          type = "integer",
                          help="The number of responses you would like to generate and submit to ODK central",
                          metavar="character")    
  )
  
  # Extracting arguments
  opt_parser <- optparse::OptionParser(option_list = option_list)
  opt <- optparse::parse_args(opt_parser)
  
  if (length(opt)==0){
    optparse::print_help(opt_parser)
    stop("At least one argument must be supplied (input file).n", call.=FALSE)
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

source('./R/import_functions.R')
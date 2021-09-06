#!/bin/env Rscript

# Quick how-to  -----------------------------------------------------------

#' This script is used to obtain data from ODK central. So we have a list of all
#' of the projects available, and all of the submissions. 


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
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################


#' Loading the virtual environment library
library(renv, warn.conflicts = F)
library(jsonlite, warn.conflicts = F)
# Setup for interactive script running  -------------------------------------------------------------------

#stop(interactive())


# Checking if R running from GUI
if (interactive()){
  renv::load()
  
  # Loading environment variables 
  readRenviron(".env")
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
  project_path <- gsub("R/getMetaData.R", "",file_option, fixed=T)
  
  
  #Making sure scripts can deal with running from within the project directory
  
  if (grepl("home/",project_path==F) | project_path==""){
    
    project_path <- paste0("./",project_path)
  }
  
  #' Ensures that all warnings are 
  #' send to stdout rather than stderr
  sink(stdout(), type="message")
  
  
  
  # Loading virtual environment
  #loading .env file
  readRenviron(paste0(project_path,".env"))
  
  renv::load(project_path)
  
}

####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
# DATA PROCESSING
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################
####################################################################################################################


# Loading Packages and Environment Variables  --------------------------------------------------------

#' Loading libraries. Suppress masking
#' warnings so they do not get passed to
#' stdout
#' 
library(rhomis, warn.conflicts = F)
library(dplyr)

central_url <- Sys.getenv("CENTRALURL")
central_url <- paste0("https://",central_url)

# Accessing the environemnt variables
central_email <- Sys.getenv("CENTRALEMAIL")
central_password <- Sys.getenv("CENTRALPASSWORD")

projects <- rhomis::get_projects(central_url = central_url,
                     central_email = central_email,
                     central_password = central_password)


projects <- projects[c("id", "name","createdAt", "updatedAt")]
colnames(projects) <- c("projectId", "projectName", "createdAt", "updatedAt")

projectIDs <- projects$projectId

forms <- sapply(projectIDs, function(projectID){
  
  tryCatch(
    {
      # This is the try part
    rhomis::get_forms(central_url = central_url,
                        central_email = central_email,
                        central_password = central_password,
                        projectID = projectID
                        
      )
      
      
      
    },
    error= function(cond){
      message(paste0("Was not able to obtain form information for project: ", projectID))
      return()
      
    },
    warning=function(cond){
      message("Got a warning obtaining information for project: ", projectID)
      return()
    }
  )
  
}, simplify = F)

forms <- dplyr::bind_rows(forms)
forms <- forms[c("version", "enketoId", "publishedAt", "projectId", "xmlFormId", "state", "name", "enketoOnceId", "createdAt", "updatedAt")]



database_connection <- rhomis::connect_to_db(collection = "metaData")


projects_json <- jsonlite::toJSON(projects, pretty=T, na="null")


forms_json <- jsonlite::toJSON(forms, pretty=T, na="null")

metadata_json <- paste0('{"projects":',projects_json,',"forms":',forms_json,'}')
metadata_json <- gsub("\n","",metadata_json, fixed=T)
metadata_json <- gsub('\\"','"',metadata_json, fixed=T)
metadata_json <- gsub('"\\','"',metadata_json, fixed=T)

database_connection$insert(metadata_json)

message("Projects metadata written to database")




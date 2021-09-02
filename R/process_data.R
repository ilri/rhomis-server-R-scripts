#!/bin/env Rscript

# Quick how-to  -----------------------------------------------------------


#' This is a script to run calculations on RHoMIS data. The script can be run in
#' two ways, you can run the script interactively (e.g. from Rstudio). Or you can run the
#' script from the command line. If running from the command line you will need to 
#' enter the command: 
#' 
#' "Rscript path/to/file.R --arg1 firstargument --arg2 second argument ...
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
# Setup for interactive script running  -------------------------------------------------------------------

stop(interactive())


# Checking if R running from GUI
if (interactive()){
  renv::load()
  
  # Loading environment variables 
  readRenviron(".env")
  
  # Setting options for script run interactively.
  # These should be set manually if you are running the script interactively
  opt <- list()
  opt$projectName <- "demo_project_1"
  opt$formName <- "project_1_form_1"
}


# Setup for running from command line -------------------------------------
# Checking if script has been run from the command line 
if (!interactive()){
  
  # Identifying the file path to this script
  
  # Arguments passed to the script
  initial.options <- commandArgs(trailingOnly = FALSE)
  file_option <- initial.options[grep("--file",initial.options)]
  file_option <- gsub("--file=", "",file_option, fixed=T)
  
  
  #project_path <- gsub("/R/process_data.R", "",file_option, fixed=T)
  project_path <- gsub("R/process_data.R", "",file_option, fixed=T)
  
  
  #Making sure scripts can deal with running from within the project directory
  
  if (grepl("home/",project_path==F)){
    
    project_path <- paste0("./",project_path)
  }
  
  
  
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
library(rhomis, warn.conflicts = F)

central_url <- Sys.getenv("CENTRALURL")
central_url <- paste0("https://",central_url)

# Accessing the environemnt variables
central_email <- Sys.getenv("CENTRALEMAIL")
central_password <- Sys.getenv("CENTRALPASSWORD")


survey_builder_url <- Sys.getenv("SURVEYBUILDERURL")
survey_builder_url <- paste0("https://",survey_builder_url)
survey_builder_access_token <- Sys.getenv("SURVEYBUILDERACCESSTOKEN")

# Test example ------------------------------------------------------------
# Write a file containing two arguments passed vis 
# central_email <- Sys.getenv("RHOMIS_CENTRAL_EMAIL")
# #Calling R functions
# fileConn <- file(paste0(opt$dir,"/test_output.txt"))
# writeLines(c(opt$arg1,opt$arg2, central_email), fileConn)
# close(fileConn)
#------------------------------------------------------------------------

# Linkning to ODK Central -------------------------------------------------

project_name <- opt$projectName
form_name <- opt$formName

# Finding project information from the API
projects <-get_projects(central_url,
                        central_email,
                        central_password)
projectID <- projects$id[projects$name==project_name]

# Finding form information from the API
forms <- get_forms(central_url,
                   central_email,
                   central_password,
                   projectID)
formID <- forms$xmlFormId[forms$name==form_name]

rhomis_data <- get_submission_data(central_url,
                                   central_email,
                                   central_password,
                                   projectID,
                                   formID )

## Cleaning Data and Extracting All Units/Column names present in the survey
rhomis_data <-rhomis_data %>%
  remove_extra_central_columns() %>%
  convert_all_columns_to_lower_case()


all_new_values <- extract_units_data_frames(rhomis_data)

## Household Information
hh_size_members <- calculate_household_size_members(rhomis_data)
hh_size_MAE <- calculate_MAE(rhomis_data)



household_type <- rhomis_data[["household_type"]]
head_education_level <- rhomis_data[["education_level"]]

## Land Variables
land_sizes <- land_size_calculation(rhomis_data)

## Livestock Holdings
# NOT YET CALCULATED



#FoodSecMonths
worst_food_security_month <- rhomis_data[["food_worst_month"]]
best_food_security_month <- rhomis_data[["food_best_month"]]


#ppi_score <- ppi_score(rhomis_data, country_code_column = rhomis_data$iso_country_code)
food_security <- food_security_calculations(rhomis_data)

# HDDS scores
hdds_data <-  hdds_calc(rhomis_data)

# Crop Calculations
rhomis_data <- crop_calculations_all(rhomis_data,
                                     crop_yield_units_all = crop_yield_units$unit,
                                     crop_yield_unit_conversions_all = crop_yield_units$conversion,
                                     crop_income_units_all = crop_price_units$unit,
                                     crop_income_unit_conversions_all = crop_price_units$conversion)

#Livestock Calculaions
rhomis_data <- livestock_calculations_all(rhomis_data,
                                          livestock_weights_names = livestock_weights$animal,
                                          livestock_weights_conversions = livestock_weights$weight_kg,
                                          eggs_amount_units_all = eggs_amount_units$unit,
                                          eggs_amount_unit_conversions_all = eggs_amount_units$conversion_factor,
                                          eggs_price_time_units_all = eggs_price_time_units$unit,
                                          eggs_price_time_unit_conversions_all = eggs_price_time_units$conversion_factor,
                                          honey_amount_units_all = honey_amount_units$units,
                                          honey_amount_unit_conversions_all = honey_amount_units$conversion_factors,
                                          milk_amount_units_all = milk_amount_units$unit,
                                          milk_amount_unit_conversions_all = milk_amount_units$conversion_factor,
                                          milk_price_time_units_all = milk_price_time_units$unit,
                                          milk_price_time_unit_conversions_all = milk_price_time_units$conversion_factor)



# Total Income Calculations
crop_income <- total_crop_income(rhomis_data)
livestock_income <- total_livestock_income(rhomis_data)
total_and_off_farm_income <- total_and_off_farm_incomes(rhomis_data,
                                                        total_crop_income = crop_income,
                                                        total_livestock_income = livestock_income)
total_income <- total_and_off_farm_income$total_income
off_farm_income <- total_and_off_farm_income$off_farm_income

rhomis_data <- gendered_off_farm_income_split(rhomis_data)


# Extra Outputs

crop_prefixes <- c("crop_harvest_kg_per_year",
                   "crop_consumed_kg_per_year",
                   "crop_sold_kg_per_year",
                   "crop_income_per_year",
                   "crop_price"
)
data_types <- c("num",
                "num",
                "num",
                "num",
                "num")
crop_data <- map_to_wide_format(data = rhomis_data,
                                name_column = "crop_name",
                                column_prefixes =crop_prefixes,
                                types = data_types)

livestock_prefixes <- c("livestock_sold",
                        "livestock_sale_income",
                        "livestock_price_per_animal",
                        
                        "meat_kg_per_year",
                        "meat_consumed_kg_per_year",
                        "meat_sold_kg_per_year",
                        "meat_sold_income",
                        "meat_price_per_kg",
                        
                        "milk_collected_litres_per_year",
                        "milk_consumed_litres_per_year",
                        "milk_sold_litres_per_year",
                        "milk_sold_income_per_year",
                        "milk_price_per_litre",
                        
                        "eggs_collected_kg_per_year",
                        "eggs_consumed_kg_per_year",
                        "eggs_sold_kg_per_year",
                        "eggs_income_per_year",
                        "eggs_price_per_kg")


data_types <- c("num",
                "num",
                "num",
                
                "num",
                "num",
                "num",
                "num",
                "num",
                
                "num",
                "num",
                "num",
                "num",
                "num",
                
                "num",
                "num",
                "num",
                "num",
                "num")

livestock_data <- map_to_wide_format(data = rhomis_data,
                                     name_column = "livestock_name",
                                     column_prefixes =livestock_prefixes,
                                     types = data_types)

# off_farm_prefixes <- c("")
# data_types <- c("")
#
# off_farm_data <- map_to_wide_format(data = rhomis_data,
#                                      name_column = "offfarm_income_name",
#                                      column_prefixes =off_farm_prefixes,
#                                      types = data_types)




# write_new_collection(data_to_write = rhomis_data,
#                      collection = "processedData",
#                      database = "rhomis",
#                      url = "mongodb://localhost")





#---------------------------------------
indicator_data <- tibble::as_tibble((list(hh_size_members=hh_size_members,
                                          hh_size_MAE=hh_size_MAE,
                                          household_type=household_type,
                                          head_education_level=head_education_level,
                                          worst_food_security_month=worst_food_security_month,
                                          best_food_security_month=best_food_security_month,
                                          
                                          crop_income=crop_income,
                                          livestock_income=livestock_income,
                                          total_income=total_income,
                                          off_farm_income=off_farm_income)))
indicator_data <- tibble::as_tibble(cbind(indicator_data,food_security,hdds_data,land_sizes))

add_data_to_project_list(data = rhomis_data,
                         collection = "processedData",
                         database = "rhomis",
                         url = "mongodb://localhost",
                         overwrite=T,
                         projectID=project_name,
                         formID=form_name)

add_data_to_project_list(data = indicator_data,
                         collection = "indicatorData",
                         database = "rhomis",
                         url = "mongodb://localhost",
                         overwrite=T,
                         projectID=project_name,
                         formID=form_name)

crop_harvested <- map_to_wide_format(rhomis_data,"crop_name","crop_harvest_kg_per_year",types = "num")
add_data_to_project_list(data = crop_harvested$crop_harvest_kg_per_year,
                         collection = "cropData",
                         database = "rhomis",
                         url = "mongodb://localhost",
                         overwrite=T,
                         projectID=project_name,
                         formID=form_name)

livestock_sold <- map_to_wide_format(rhomis_data,"livestock_name","livestock_sold",types = "num")
add_data_to_project_list(data = livestock_sold$livestock_sold,
                         collection = "livestockData",
                         database = "rhomis",
                         url = "mongodb://localhost",
                         overwrite=T,
                         projectID=project_name,
                         formID=form_name)


adding_project_to_list(database = "rhomis",
                       url = "mongodb://localhost",
                       projectID=project_name,
                       formID=form_name)


# survey_builder_metadata <- get_survey_builder_projects(survey_builder_url,
#                                                        survey_builder_access_token)
# 
# add_data_to_project_list(data = survey_builder_metadata,
#                          collection = "metaData",
#                          database = "rhomis",
#                          url = "mongodb://localhost",
#                          overwrite=T,
#                          projectID=project_name,
#                          formID=form_name)



# Finishing whole process
write("Success from Rscript", stdout())
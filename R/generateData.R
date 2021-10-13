generateData <- function(central_url,
                         central_email,
                         central_password,
                         project_name,
                         form_name) {


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
  for (response_index in 1:number_of_responses)
  {
    mock_response <- rhomis::generate_mock_response(
      survey = xls_form$survey,
      choices = xls_form$choices,
      metadata = xls_form$settings
    )
    mock_response <- gsub(">\n", ">\r\n", mock_response, fixed = T)

    submit_xml_data(
      mock_response,
      central_url,
      central_email,
      central_password,
      projectID = projectID,
      formID = formID
    )
  }
  # Delete the xls file
  write("Success from Rscript", stdout())
}
# Helpful tutorials: 
# https://www.r-bloggers.com/2019/02/running-your-r-script-in-docker/
# https://www.youtube.com/watch?v=bi0cKgmRuiA
# https://environments.rstudio.com/docker

RUN apt-get -y update
RUN apt-get -y install libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev libsasl2-dev

# Tidyverse image https://hub.docker.com/r/rocker/tidyverse
FROM rocker/tidyverse:latest

# Copying necessary files
COPY ./R/
COPY ./.env ./.env
COPY  ./renv.lock ./renv.lock

# Creating R environment
RUN R -e 'install.packages("renv")'
RUN R -e 'renv::restore()'
RUN Rscript './R/updateRHoMIS.R'

# Environment Variables for Running script
ENV SCRIPT = "test"
ENV PROJECTNAME="FALSE"
ENV FORMNAME="FALSE"
ENV FORMVERSION="FALSE"
ENV DATABASE="FALSE"
ENV NUMBEROFRESPONSES="FALSE"


#
CMD Rscript /02_code/myScript.R ${CLUSTER} ${ENVIRONMENT}
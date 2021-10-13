# Helpful tutorials: 
# https://www.r-bloggers.com/2019/02/running-your-r-script-in-docker/
# https://www.youtube.com/watch?v=bi0cKgmRuiA
# https://environments.rstudio.com/docker
# Tidyverse image https://hub.docker.com/r/rocker/tidyverse
FROM rocker/tidyverse

RUN apt-get -y update
RUN apt-get -y install libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev libsasl2-dev

WORKDIR /rhomis-server-R-scripts


# Copying necessary files
COPY ./R/ /rhomis-server-R-scripts/R/
# COPY ./.env /rhomis-server-R-scripts/.env
# COPY  ./renv.lock /rhomis-server-R-scripts/renv.lock


# Creating R environment
# RUN R -e 'install.packages("devtools")'
RUN Rscript /rhomis-server-R-scripts/R/setup.R
# RUN R -e 'renv::restore()'
# RUN R -e 'renv::update("rhomis")'

# Environment Variables for Running script
ENV COMMANDTYPE=test
ENV PROJECTNAME=NULL
ENV FORMNAME=NULL
ENV FORMVERSION=NULL
ENV DATABASE=NULL
ENV NUMBEROFRESPONSES=NULL

ENV CENTRALURL=NULL
ENV CENTRALEMAIL=NULL
ENV CENTRALPASSWORD=NULL


# The command to 
CMD Rscript /rhomis-server-R-scripts/R/main.R --commandType "${COMMANDTYPE}"\
    --projectName "${PROJECTNAME}"\
    --formName "${FORMNAME}"\
    --formVersion "${FORMVERSION}"\
    --dataBase "${DATABASE}"\
    --numberOfResponses "${NUMBEROFRESPONSES}"\
    --centralURL "${CENTRALURL}"\
    --centralEmail "${CENTRALEMAIL}"\
    --centralPassword "${CENTRALPASSWORD}"\

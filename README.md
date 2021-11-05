# Server functions for R-scripts

R scripts to be run on the RHoMIS surver.

## Setup

*Note: There is also a method for running this with docker in the devel branch!*

To install all the dependencies enter the command (This may take a while!):

```
sudo Rscript R/setup.R
```

Then create a `.env` file in the main directory. The contents should include:

```
CENTRALURL=odkcentralurl.com
CENTRALEMAIL=myemail@domain.com
CENTRALPASSWORD=mypassword
```

For current RHoMIS setup, the `CENTRALURL` should be `central.rhomis.cgiar.org`. 
The email and password should match those of your ODK central account.

Finally, if you want to store the results in the database (as is done in the scripts)
you will need to [install mongodDB community](https://docs.mongodb.com/manual/administration/install-on-linux/).

If at any point you need to update the RHoMIS R package:

```
sudo Rscript R/updateRHoMIS.R
```

## Using the Scripts

### Generating Data

The main two scripts you will be using are `R/generateData.R` and `process_data.R` 
(I realise the inconsistent naming :( ). I have tried to set them up in a way which would
make it easy to run them both from the command line or from within Rstudio.

To generate some fake data for a particular survey, run the command:

```
Rscript R/generateData.R --projectName XXXXXXXXXX --formName XXXXXXXXXX --formVersion XXXXXXXXXX --numberOfResponses XXXXXXXXXX
```

You can find the projectName, formName, and formVersion by going into ODK central and selecting the form you are working with. 

If you want more explanation on the flags enter `Rscript R/generateData.R --help`.

### Processing Data

To process the data you will need to enter the command:

```
Rscript R/generateData.R --projectName XXXXXXXXXX --formName XXXXXXXXXX --formVersion XXXXXXXXXX --database XXXXXXXXXX
```

If you want more explanation on the flags enter `Rscript R/process_data.R --help`.
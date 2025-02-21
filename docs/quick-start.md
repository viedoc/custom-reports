# Quick-start guide for creating a custom report
[return to root README](../README.md)

This, combined with the [development guide](./dev-guide.md), contains information previously found in the [eLearning Designer User Guide](https://help.viedoc.net/c/e311e6/) article entitled "Creating custom reports".
## Pre-requisits
- access to Viedoc Reports and Viedoc Designer 
- an implemented study in Viedoc clinic (training or production)
- [R](https://cran.rstudio.com/) version 4.04 or later optionally with an R IDE such as [R Studio](https://posit.co/products/open-source/rstudio/)

## Downloading the package
A .zip package for creating custom reports is downloaded from the Settings menu, found in the upper right corner of Viedoc Reports. This package is only available for users with access to the Reports page.

![reports_settings_menu](./assets/settings_menu_4_72.png?raw=true)

By clicking Download data for custom reports, and following the instructions on the screen, the .zip package is downloaded to your computer.

![reports_settings_menu](./assets/custom_reports_4_72.png?raw=true)

The .zip package consists of the following files that are to be used as support when writing your custom reports:

|file|description|
|-|-|
|edcData.rds| This file contains sample data from the study, including CRF data and operational data, such as queries, processedqueries, reviews, signature, database lock, timelapse, and so on.| 
| params.rds | **- Date of download:** the date and time at which the data was pulled from Viedoc to the Reports server   <br> **- Study Name**  <br>  **- Study Type**  <br>  **- Study Level Data:** ExpectedNumberOfScreenedSubjects, expectedNumberOfEnrolledSubjects,  expectedDateOfCompleteEnrollment, totalNumberOfStudySites, totalNumberOfUniqueCountries  <br> **- Site Level Data:** siteNumber, siteCode, siteName, countryCode, country, timeZone, timezoneOffset, siteType, expectedNumberOfSubjectsScreened, expectedNumberOfSubjectsEnrolled, maximumNumberOfSubjectsScreened <br>  <br> The list of sites in the "Site Level Data" is based on the user’s access to the study.|
| SampleReportCode.R | This is a sample report with explanations of the report structure. The code is a sample to give an idea to the user on how to write a report code, its corresponding inputs, and the structure of the output. This file also contains a list of R packages available for the user.<br><br> For information and a code snippit for available R packages, open this file, scroll down to find a section called "Sample Code". This code snippit can be used to generate a custom report which identifies available R packages and versions supported by custom reports.|
| utilityFunctions.R | This file contains various functions that are provided in the runtime environment and can be used when writing the custom report.|

More detailed descriptions of the data objects and utility objects can be found in the [development guide](./dev-guide.md)

## Setting up a local coding environment
Ensure that you have R installed on your computer. An IDE such as R Studio can streamline the development process.

Unzip the folder that was downloaded.

The following code downloads and installs the packages that are available for use in the Viedoc Reports runtime environment. This only needs to be done once. It can be run in a script or directly in the R terminal. Once the packages have been installed onto the local machine, they will not need to be reinstalled until the files are deleted. 

```
install.packages(c( "vctrs", "R6", "generics", "glue", "lifecycle", "magrittr", "tibble", "ellipsis", "pillar", "crayon", "pkgconfig", "tidyselect", "purrr", "Rcpp", "tidyr", "dplyr", "rlang", "lubridate", "stringr", "stringi", "plotly", "survival", "xml2"))
```

In your R development environment (e.g. R Studio), open a new file for your report code and save it to the same folder as the downloaded files.

The code below must be included in your custom report script while working locally as it loads the installed packages into the local working environment, sets a working directory, imports the utility functions, and reads in the data from the demo study. It needs to be run every time a new environment is created (every time the terminal is refreshed). However, this code cannot be included in the script uploaded to Viedoc, so it is important to delete or comment out these lines (using '#' at the start of every line)


<details><summary> Local environment setup code </summary>

```
library(vctrs)
library(R6)
library(generics)
library(glue)
library(lifecycle)
library(magrittr)
library(tibble)
library(ellipsis)
library(pillar)
library(crayon)
library(pkgconfig)
library(tidyselect)
library(purrr)
library(Rcpp)
library(tidyr)
library(dplyr)
library(rlang)
library(lubridate)
library(stringr)
library(stringi)
library(plotly)
library(survival)
library(xml2)

setwd("C:\\Users\\SvenSvensson\\Downloads\\SampleForCustomReports")
source("utilityFunctions.R", local = T)
edcData <- readRDS("edcData.rds")
params <- readRDS("params.rds")
metadata <- readRDS("metadata.rds")
```

> [!IMPORTANT] 
> Make sure to change the file path in `setwd` to point to the folder where your custom report is stored.

</details>

The script can then be developed as per the guidelines provided in the [dev guide](dev-guide.md)

## Uploading the script
After developing the script, the R file must be uploaded in the study's Global design settings of Viedoc Designer. For more information, see [Configuring Viedoc Reports](https://help.viedoc.net/c/e311e6/326d81/en/). The custom report is then visible for users with permissions to see it in Viedoc Reports.


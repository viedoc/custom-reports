## Viedoc Custom Report - Ongoing AEs

# This report serves as an example on how to select data that fulfills certain criteria (in this case, adverse events 
# that were recorded as ongoing) and how to sort the data. It also illustrates how to create a report consisting of two
# sub-reports.

# This custom report will generate the following output:
# Sub-report “Ongoing AEs”: A table of all AEs that are ongoing, sorted with the oldest start date at the top.
# Sub-report "Start Date > 30 days": A table of ongoing AEs that started more than 30 days ago.


# Load required data and functions.
# The following lines of code can be used to load the sample data downloaded from Viedoc Reports.
# Download the sample data, unzip the files and enter the path within the setwd() function below.
# Note! Remove or comment (type a # in front) the following lines before uploading to Viedoc.
#setwd("Insert file path here")
# source("utilityFunctions.R", local = T)
# edcData <- readRDS("edcData.rds")
# params <- readRDS("params.rds")
# metadata <- readRDS("metadata.rds")

# Loading of required package. Delete (or comment) the next line of code before uploading the file to Viedoc.
# library(dplyr)


# Pull the AE dataset and store it as "ae":
ae <- edcData$Forms$AE

# To avoid errors when no AEs have been entered yet, first a check for null is implemented.
# Filter for Ongoing AEs:
if(!is.null(ae)){
ong <- filter(ae, AEONGOCD == 1)}

# Sort by Start Date:
sortong <- arrange(ong, AESTDAT)

# Select the necessary columns to exclude code list values and other IDs:
ongcolumns <- select(sortong, SiteName, SubjectId, AESPID, AETERM, AESTDAT, AEONGO, AEREL, AEACN, AESEV, AESER, 
                     AESERCAT1, AESERCAT2, AESERCAT3, AESERCAT4, AESERCAT5, AESERCAT6, AEDTHDAT, AECONTRT, AEOUT)


# Filter for AEs that are ongoing for more than 30 days:
aeong30 <- filter(ongcolumns, as.Date(AESTDAT) < as.Date(params$dateOfDownload) - 30)

# Prepare Data For Display per Utility Functions for both reports:
ongcolumns <- prepareDataForDisplay(ongcolumns)
aeong30 <- prepareDataForDisplay(aeong30)

# Set labels per Utility Functions for both reports:
ongcolumns <- setLabel(ongcolumns,
                      labels=as.list(c(
                        "Site Name", "Subject ID", "Sequence number", "Description", "Start Date", "Ongoing?", 
                        "Relationship to the study treatment", "Action taken with study treatment", "Severity", 
                        "Serious?", "Seriousness criteria 1", "Seriousness criteria 2", "Seriousness criteria 3", 
                        "Seriousness criteria 4", "Seriousness criteria 5", "Seriousness criteria 6", "Date of Death", 
                        "Concomitant or additional treatment given", "Outcome")))

aeong30 <- setLabel(aeong30,
                   labels=as.list(c(
                     "Site Name", "Subject ID", "Sequence number", "Description", "Start Date", "Ongoing?", 
                     "Relationship to the study treatment", "Action taken with study treatment", "Severity", "Serious?", 
                     "Seriousness criteria 1", "Seriousness criteria 2", "Seriousness criteria 3", 
                     "Seriousness criteria 4", "Seriousness criteria 5", "Seriousness criteria 6", "Date of Death", 
                     "Concomitant or additional treatment given", "Outcome")))

# Output of the sub-reports:
# The variable must be called "reportOutput". It is a list of lists. Specify "data" for tables; "plot" for plots.
reportOutput <- list(
  "Ongoing AEs" = list("data" = ongcolumns),
  "Start Date > 30 days" = list ("data" = aeong30))

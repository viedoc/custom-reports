## AE Ongoing Report
# “Ongoing AEs” A list of all AEs that are ongoing=Yes, sorted with the oldest start date at the top (i.e. the longest ongoing AE at the top)
# A sub-report with AEs that started more than 30 days ago to easily highlight old ongoing AEs.

## Load required data and functions
# setwd("Insert file path here")
# source("utilityFunctions.R", local = T)
# edcData <- readRDS("edcData.rds")
# params <- readRDS("params.rds")
# metadata <- readRDS("metadata.rds")

##Pull the AE dataset
ae <- edcData$Forms$AE


##Filter for Ongoing AEs
ong <- filter(ae, AEONGOCD==1)


##Sort by Start Date
sortong <- arrange(ong, AESTDAT)


##Select the necessary columns to exclude code list values and other IDs
ongcolumns <- select(sortong, SiteName, SubjectId, AESPID, AETERM, AESTDAT, 
                     AEONGO, AEREL, AEACN, AESEV, AESER, AESERCAT1, AESERCAT2, 
                     AESERCAT3, AESERCAT4, AESERCAT5, AESERCAT6, AEDTHDAT, 
                     AECONTRT, AEOUT)


##Filter for AEs Ongoing for more than 30 days
aeong30 <- filter(ongcolumns, as.Date(AESTDAT) < as.Date(params$dateOfDownload) - 30)

##Prepare Data For Display per Utility Functions for both reports
ongcolumns <- prepareDataForDisplay(ongcolumns)

aeong30 <- prepareDataForDisplay(aeong30)

##Set labels per Utility Functions for both reports
ongcolumns <- setLabel(ongcolumns,
                      labels=as.list(c(
                        "Site Name", "Subject ID", "Sequence number", "Description",
                        "Start Date", "Ongoing?", "Relationship to the study treatment",
                        "Action taken with study treatment", "Severity", "Serious?",
                        "Seriousness criteria 1", "Seriousness criteria 2", 
                        "Seriousness criteria 3", "Seriousness criteria 4", 
                        "Seriousness criteria 5", "Seriousness criteria 6", 
                        "Date of Death", "Concomitant or additional treatment given", 
                        "Outcome")))

aeong30 <- setLabel(aeong30,
                   labels=as.list(c(
                     "Site Name", "Subject ID", "Sequence number", "Description",
                     "Start Date", "Ongoing?", "Relationship to the study treatment",
                     "Action taken with study treatment", "Severity", "Serious?", 
                     "Seriousness criteria 1", "Seriousness criteria 2", 
                     "Seriousness criteria 3", "Seriousness criteria 4", 
                     "Seriousness criteria 5", "Seriousness criteria 6", 
                     "Date of Death", "Concomitant or additional treatment given",
                     "Outcome")))

##Output of the report and subreport
reportOutput <- list(
  "Ongoing AEs" = list("data" = ongcolumns),
  "Start Date > 30 days" = list ("data" = aeong30))

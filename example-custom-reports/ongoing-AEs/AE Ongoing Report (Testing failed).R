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
ae = edcData$Forms$AE


##Filter for Ongoing AEs
ong = filter(ae, AEONGOCD==1)


##Sort by Start Date
sortong = ong[order(as.Date(ong$AESTDAT, format = "%Y-%m-%d")),]


##Select the necessary columns to exclude code list values and other IDs
ongcolumns = select(sortong, SiteName, SubjectId, AESPID, AETERM, AESTDAT, AEONGO, AEREL, AEACN, AESEV, AESER, AESERCAT1, AESERCAT2, AESERCAT3, AESERCAT4, AESERCAT5, AESERCAT6, AEDTHDAT, AECONTRT, AEOUT)


##Filter for AEs Ongoing for more than 30 days
aeong30 = filter(ongcolumns, AESTDAT < today() - 30)

##Rename columns for both reports
colnames(ongcolumns)[colnames(ongcolumns) %in% c("SiteName", "SubjectId", "AESPID", "AETERM", "AESTDAT", "AEONGO", "AEREL", "AEACN", "AESEV", "AESER", "AESERCAT1", "AESERCAT2", "AESERCAT3", "AESERCAT4", "AESERCAT5", "AESERCAT6", "AEDTHDAT", "AECONTRT", "AEOUT")] <- c(attr(edcData$Forms$AE$SiteName, "label"), attr(edcData$Forms$AE$SubjectId, "label"), attr(edcData$Forms$AE$AESPID, "label" ), attr(edcData$Forms$AE$AETERM, "label"), attr(edcData$Forms$AE$AESTDAT, "label"), attr(edcData$Forms$AE$AEONGO, "label"), attr(edcData$Forms$AE$AEREL, "label"), attr(edcData$Forms$AE$AEACN, "label"), attr(edcData$Forms$AE$AESEV, "label"), attr(edcData$Forms$AE$AESER, "label"), attr(edcData$Forms$AE$AESERCAT1, "label"), attr(edcData$Forms$AE$AESERCAT2, "label"), attr(edcData$Forms$AE$AESERCAT3, "label"), attr(edcData$Forms$AE$AESERCAT4, "label"), attr(edcData$Forms$AE$AESERCAT5, "label"), attr(edcData$Forms$AE$AESERCAT6, "label"), attr(edcData$Forms$AE$AEDTHDAT, "label"), attr(edcData$Forms$AE$AECONTRT,"label"), attr(edcData$Forms$AE$AEOUT, "label"))

colnames(aeong30)[colnames(aeong30) %in% c("SiteName", "SubjectId", "AESPID", "AETERM", "AESTDAT", "AEONGO", "AEREL", "AEACN", "AESEV", "AESER", "AESERCAT1", "AESERCAT2", "AESERCAT3", "AESERCAT4", "AESERCAT5", "AESERCAT6", "AEDTHDAT", "AECONTRT", "AEOUT")] <- c(attr(edcData$Forms$AE$SiteName, "label"), attr(edcData$Forms$AE$SubjectId, "label"), attr(edcData$Forms$AE$AESPID, "label" ), attr(edcData$Forms$AE$AETERM, "label"), attr(edcData$Forms$AE$AESTDAT, "label"), attr(edcData$Forms$AE$AEONGO, "label"), attr(edcData$Forms$AE$AEREL, "label"), attr(edcData$Forms$AE$AEACN, "label"), attr(edcData$Forms$AE$AESEV, "label"), attr(edcData$Forms$AE$AESER, "label"), attr(edcData$Forms$AE$AESERCAT1, "label"), attr(edcData$Forms$AE$AESERCAT2, "label"), attr(edcData$Forms$AE$AESERCAT3, "label"), attr(edcData$Forms$AE$AESERCAT4, "label"), attr(edcData$Forms$AE$AESERCAT5, "label"), attr(edcData$Forms$AE$AESERCAT6, "label"), attr(edcData$Forms$AE$AEDTHDAT, "label"), attr(edcData$Forms$AE$AECONTRT,"label"), attr(edcData$Forms$AE$AEOUT, "label"))

##Prepare Data For Display per Utility Functions for both reports
ongcolumns = prepareDataForDisplay(ongcolumns)

aeong30 = prepareDataForDisplay(aeong30)

##Set labels per Utility Functions for both reports
ongcolumns = setLabel(ongcolumns,labels=as.list(c("Site Name", "Subject ID", "Sequence number", "Description", "Start Date", "Ongoing?", "Relationship to the study treatment", "Action taken with study treatment", "Severity", "Serious?", "Seriousness criteria 1", "Seriousness criteria 2", "Seriousness criteria 3", "Seriousness criteria 4", "Seriousness criteria 5", "Seriousness criteria 6", "Date of Death", "Concomitant or additional treatment given", "Outcome")))

aeong30 = setLabel(aeong30,labels=as.list(c("Site Name", "Subject ID", "Sequence number", "Description", "Start Date", "Ongoing?", "Relationship to the study treatment", "Action taken with study treatment", "Severity", "Serious?", "Seriousness criteria 1", "Seriousness criteria 2", "Seriousness criteria 3", "Seriousness criteria 4", "Seriousness criteria 5", "Seriousness criteria 6", "Date of Death", "Concomitant or additional treatment given", "Outcome")))

##Output of the report and subreport
reportOutput = list(
  "Ongoing AEs" = list("data" = ongcolumns),
  "Start Date > 30 days" = list ("data" = aeong30))

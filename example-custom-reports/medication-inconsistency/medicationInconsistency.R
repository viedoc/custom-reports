## Viedoc custom report template - Medication Inconsistency
#
# This report will generate two tables showing inconsistencies regarding 
# medications. Specifically, it will show Concomitant Medication entries that
# are linked to Adverse Events entries for which it was reported that no
# treatments/medications were prescribed. The second table will show the
# opposite, Adverse Events entries for which it was reported that treatments/
# medications were prescribed, but for which no corresponding Concomitant 
# Medications entry exists. 

# Loading of required packages. Remember to delete the lines of code starting
# with "library" before uploading this file to Viedoc.
# library(tidyr)
# library(dplyr)

# Loading of the data. This is only needed for offline testing of the script. 
# Remember to delete the following five lines before uploading this file to 
# Viedoc. The path within the setwd() function should be changed to the path 
# where you have saved the unzipped data downloaded from Viedoc Reports.
# setwd("C:/Users/TomKimkes/OneDrive - VIEDOC TECHNOLOGIES AB/Documents/CustomReportData/2")
# source("utilityFunctions.R", local = T)
# edcData <- readRDS("edcData.rds")
# params <- readRDS("params.rds")
# metaData <- readRDS("metadata.rds")

# In the below lines of code, we are creating a data.frame called CM. This
# data.frame will contain the data from the CM form (which is found within the
# edcData dataset). The data is filtered to include only those rows where the
# FormLink item CMINDCAE has a value, i.e. where it is not equal to NA (Not 
# Available). CMINDCAE is a FormLink item on the CM form that links to the 
# corresponding Adverse Event.
# Each selection in a FormLink item appears in two columns in the data, one 
# column with the full text displayed in Viedoc, and one column with the format 
# EventId-EventSeq-ActivityId-FormId-FormSeq. The second column will have the 
# Viedoc ItemID suffixed with "ID". Each selection in the FormLink item adds a
# sequence number to the itemID, so if two selections are made, we will have
# CMINDCAE1, CMINDCAE1ID, CMINDCAE2, CMINDCAE2ID.
# To facilite the further data handling, we will need to tidy the data by 
# pivoting such that we will have one row per FormLink selection. Firstly, we
# rename the columns without the "ID" suffix, to append the letters "FL" so that
# we can use in a pattern in the pivot_longer function.
# After pivoting the data, We will continue the "ID" column, which we are 
# splitting for convenience into five different columns using the separate() 
# function. We keep (select) only those columns that we will need later on.
# Note that we are accounting for the possibility that no CM forms exist within
# the dataset, i.e. we start by checking equality to null. If there are no CM 
# forms, we may get errors later on, so we create an empty data.frame with the 
# same column names. All columns in the created data.frame are set to character
# data type, which is needed in later calls to the left_join() function.
if(!is.null(edcData$Forms$CM) && nrow(edcData$Forms$CM)>0){
CM <- edcData$Forms$CM %>%
  rename_with(~paste(.x,"FL",sep=""),starts_with("CMINDCAE")&!ends_with("ID")) %>%
  pivot_longer(starts_with("CMINDCAE"),names_to=c("FLNR",".value"),names_pattern="([0-9])([A-Z]+)",values_drop_na = T) %>%
  separate(ID,sep="-",into=c("EventId","EventSeq","ActivityId","FormId","FormSeq")) %>%
  select(SubjectId,SiteName,EventId,EventSeq,ActivityId,FormId,FormSeq,CMSPID,CMTRT,CMSTDAT,FL)
}else{
  CM <- data.frame(matrix(ncol = 11, nrow = 0)) %>%
    mutate(across(everything(), as.character))
  colnames(CM) <- c("SubjectId","SiteName","EventId","EventSeq","ActivityId","FormId","FormSeq","CMSPID","CMTRT","CMSTDAT","FL")
}

# For the next step, it is important that also AE data exists, so an empty data
# frame is created if it was missing.
AE <- edcData$Forms$AE
if(is.null(AE)){
  AE <- data.frame(matrix(ncol = 11, nrow = 0)) %>%
    mutate(across(everything(), as.character))
  colnames(AE) <- c("SubjectId","SiteName","EventId","EventSeq","ActivityId","FormId","FormSeq","AESPID","AETERM","AESTDAT","AECONTRT")
}

# Next, we will identify the Concomitant Medication entries that are linked to 
# an Adverse Event via FormLink item CMINDCAE1, but where the Adverse Event 
# does not have the answer Yes for item AECONTRT, meaning that no medication/
# treatment was prescribed for this AE.
# We start by joining together the previously created CM data.frame with the AE
# data from the edcData dataset. Rows in both data.frames are joined together 
# based on matching SubjectId, EventId, EventSeq, ActivityId, and FormSeq. Note
# that in the CM data.frame, these columns were taken from the CMINDCAE1ID
# FormLink item, thus they specify the linked AE.
# After joining the data together, we filter it such that we only keep the rows
# where AECONTRT was not answered with Yes. Finally, we choose which columns we
# want to keep and set the labels that should be shown in Reports and in 
# exports.
CMmissingAE <- CM %>%
  left_join(AE,by=c("SubjectId","EventId","EventSeq","ActivityId","FormSeq")) %>%
  filter(AECONTRT != "Yes") %>%
  select(SubjectId,SiteName.x,CMSPID,CMTRT,CMSTDAT,FL) %>%
  setLabel(labels=as.list(c("SubjectID","Site Name","Con. Med. #","Medication/Treatment","CM Start Date","Linked to AE")))

# Next, we will create the second table. Here we will show the Adverse Events
# entries that have the answer Yes for AECONTRT, meaning that medication/
# treatment was prescribed for the AE, but where no Concomitant Medication entry
# is linked to the AE via the CMINDCAE1 FormLink item.
# We start with the AE data.frame from the edcData dataset. We filter it to keep
# only the rows where AECONTRT equals Yes. We add a column with the FormId AE to
# use in the next step, which is the joining of the AE data with the CM 
# data.frame. This joining is done based on SubjectId, EventSeq, ActivityId, 
# FormId, and FormSeq. AEs that did not have a matching CM will have NA (Not
# Available) in all the joined columns from CM. These are the ones we are 
# interested in, so we filter for NA values. Next, we choose which columns to
# keep. Finally, we set the labels for all columns.

AEmissingCM <- AE %>%
  filter(AECONTRT == "Yes") %>%
  mutate(FormId = "AE") %>%
  left_join(CM,by=c("SubjectId","EventSeq","ActivityId","FormId","FormSeq")) %>%
  filter(is.na(FL)) %>%
  select(SubjectId,SiteName.x,AESPID,AETERM,AESTDAT) %>%
  setLabel(labels=as.list(c("SubjectID","Site Name","AE #","AE Term","AE Start Date")))


# In the last few lines of the script, the output is created. This must be 
# called reportOutput. It is a list of lists. Within the reportOutput list,
# we define the subreports. The name given to the subreports will appear in 
# Viedoc only if the report contains at least two subreports. Each subreport is
# a list, where it should be defined if it is a table ("data") or a graph 
# ("plot"), and which variable within the R script contains the data.
reportOutput <- list(
  "CMs linked to AEs where no meds were prescribed" = list("data" = CMmissingAE),
  "AEs where meds were prescribed not linked to CMs" = list("data" = AEmissingCM))

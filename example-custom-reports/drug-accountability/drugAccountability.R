## Viedoc custom report template - Drug Accountability

# Loading of required packages. Remember to delete all lines of code starting
# with "library" before uploading this file to Viedoc.
# library(tidyr)
# library(dplyr)
# library(lubridate)

# Loading of the data. This is only needed for offline testing of the script. 
# Remember to delete the following five lines before uploading this file to 
# Viedoc. The path within the setwd() function should be changed to the path 
# where you have saved the unzipped data downloaded from Viedoc Reports.
# setwd("C:/Users/TomKimkes/OneDrive - VIEDOC TECHNOLOGIES AB/Documents/CustomReportData")
# source("utilityFunctions.R", local = T)
# edcData <- readRDS("edcData.rds")
# params <- readRDS("params.rds")
# metaData <- readRDS("metadata.rds")

# Get CRF data. Data.frame kt will contain the data for the kit allocation form 
# in edcData, and da will contain the drug accountability form data.
kt <- edcData$Forms$KIT
da <- edcData$Forms$DA

# If the edcData dataset does not contain data for the kt and da forms, then 
# empty data.frames are created with the same column names. 
if(is.null(kt) || nrow(kt)==0){
  kt <- data.frame(matrix(ncol = 6, nrow = 0)) %>%
    mutate(across(!X6, as.character))
  colnames(kt) <- c("SubjectId","SiteName","KITNO","EventName.x","EventDate.x","KITTABNO")
}
if(is.null(da) || nrow(da)==0){
  da <- data.frame(matrix(ncol = 5, nrow = 0)) %>%
    mutate(across(!X5, as.character))
  colnames(da) <- c("SubjectId","SiteName","RETAMT_DAREFID","RETAMT_DADAT","RETAMT_DAORRES")
}

# Combine the kt and da data.frames and evaluate the data
# The two data.frames are combined via the left_join() function. Then, using
# the mutate function, three new columns are added:
# daysBetween: the number of days between allocating and returning the kit
# expectedTablets: allocated number of tablets minus daysBetween (this assumes
# that one tablet should be taken per day)
# discrepancyTablets: returned nr of tablets minus expectedTablets
# Also using the mutate function, missing values for "date kit returned" are 
# replaced with "Not yet returned".
# Finally, the needed columns are selected and labels are set for them.
kt_da <- kt %>%
  left_join(da, by=c("SubjectId","SiteName","KITNO"="RETAMT_DAREFID")) %>%
  mutate(daysBetween = as.numeric(as.Date(RETAMT_DADAT) - as.Date(EventDate.x)),
         expectedTablets = KITTABNO - daysBetween,
         discrepancyTablets = RETAMT_DAORRES - expectedTablets,
         RETAMT_DADAT = if_else(is.na(RETAMT_DADAT),"Not yet returned",RETAMT_DADAT)) %>%
  select(SubjectId,SiteName,KITNO,EventName.x,EventDate.x,RETAMT_DADAT,daysBetween,KITTABNO,expectedTablets,RETAMT_DAORRES,discrepancyTablets) %>%
  setLabel(labels=as.list(c("Subject ID","Site Name","Kit Number","Allocation Event","Date allocated","Date returned","Days in between","#Tablets allocated","Expected #tablets returned","Actual #tablets returned","Discrepancy")))

# Addition of a descriptive footer
reportFooter = "Discrepancy: difference between expected and actual returned tablets. Positive if too many tablets were returned, negative if too few were returned."

# Creation of the reportOutput
reportOutput <- list(
  "Drug accountability" = list("data" = kt_da, footer = list(text = reportFooter, displayOnly = TRUE)))

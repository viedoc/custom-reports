## Viedoc custom report template - Serious AEs combined with DM data

# This report template serves as an example on how to select data that fulfills
# certain criteria (in this case, adverse events that were recorded as serious)
# and how to combine this with data from a different form (in this case, a few
# data points from the Demographics form).
# The output of this report will be a table with the following columns:
# Column Header - where the data is found
# Subject ID - edcData$Forms$AE$SubjectId and edcData$Forms$DM$SubjectId *
# Site Name - edcData$Forms$AE$SiteName
# AE nr - edcData$Forms$AE$AESPID
# AE Term - edcData$Forms$AE$AETERM
# AE Start Date - edcData$Forms$AE$AESTDAT
# AE Outcome - edcData$Forms$AE$AEOUT
# AE Seriousness Criteria - edcData$Forms$AE$AESERCAT
# Sex - edcData$Forms$DM$SEX
# Age - edcData$Forms$DM$AGE
# * The SubjectId is found in both AE and DM datasets and is therefore used for 
# joining them together (i.e. matching the correct rows with each other).

# Loading of required package. Remember to delete (or comment) the next line of 
# code before uploading this file to Viedoc.
# library(dplyr)

# Loading of the data. This is only needed for offline testing of the script. 
# Remember to delete the following five lines before uploading this file to 
# Viedoc. The path within the setwd() function should be changed to the path 
# where you have saved the unzipped data downloaded from Viedoc Reports.
# setwd("C:/Users/TomKimkes/OneDrive - VIEDOC TECHNOLOGIES AB/Documents/CustomReportData")
# source("utilityFunctions.R", local = T)
# edcData <- readRDS("edcData.rds")
# params <- readRDS("params.rds")
# metaData <- readRDS("metadata.rds")

# Get CRF data. Data.frame ae will contain the data for the AE form in edcData,
# and dm will contain the DM form data.
ae <- edcData$Forms$AE
dm <- edcData$Forms$DM

# Next, we take the data.frame "ae" and filter it to keep only the serious 
# Adverse Events, i.e. those entries where AESER was answered with Yes. We then
# sort (arrange) the data according to SubjectId, AE Start Date, and AE Term.
# Using the mutate() function, we combine the different checkbox selections for 
# the Seriousness Criteria. Within the mutate() function, we first define the 
# column to which we are writing (AESERCAT), followed by the data that we are
# writing, which looks somewhat complicated in this case. To explain, we are
# creating a data.frame with the different columns that we want to combine:
# "data.frame(AESERCAT1,AESERCAT2,AESERCAT3,AESERCAT4,AESERCAT5,AESERCAT6)".
# To this data.frame, we apply a function over all rows (dimension 1). This
# function pastes all values into one string, separated by commas and leaving
# out NA values.
# Finally, we select the needed data columns, and set the data type for the AE#
# to numeric, so it can be filtered differently in the Reports application.
# If there are no AEs, i.e. if ae equals null, then we instead create an empty
# data.frame with the same number of columns and same column names, so that the
# remainder of the script runs without errors.
# Finally, the data type of the SubjectId column is set to character to allow
# for joining with the dm data.frame later.
if(!is.null(ae)){
  sae <- filter(ae, AESER == "Yes") %>%
    arrange(SubjectId,AESTDAT,AETERM) %>%
    mutate(AESERCAT = apply(data.frame(AESERCAT1,AESERCAT2,AESERCAT3,AESERCAT4,AESERCAT5,AESERCAT6),1,function(x) paste(na.omit(x),collapse=", "))) %>%
    select(SubjectId,SiteName,AESPID,AETERM,AESTDAT,AEOUT,AESERCAT)
  sae$AESPID <- as.numeric(sae$AESPID)
} else{
  sae <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(sae) <- c("SubjectId","SiteName","AESPID","AETERM","AESTDAT","AEOUT","AESERCAT")
}
sae$SubjectId <- as.character(sae$SubjectId)

# Next, we take the dm data.frame and select the needed columns. If there is no
# DM data, then we create an empty data.frame with the same column names.
# Finally, we set the data type for the SubjectId to character, to allow joining
# with the sae data.frame based on matching SubjectId.
if(!is.null(dm)){
  dm <- dm %>% select(SubjectId,SEX,AGE)
} else{
  dm <- data.frame(matrix(ncol = 3, nrow = 0))
  colnames(dm) <- c("SubjectId","SEX","AGE")
}
dm$SubjectId <- as.character(dm$SubjectId)

## Join the two data.frames
# There are several functions available in R to join two data.frames.
# Let's say we have the following data.frame X:
# SubjectId   Result1
# 001         10
# 002         11
# 003         12
#
# And the second data.frame Y:
# SubjectId   Result2
# 001         20
# 002         21
# 004         22
#
# If we use the function left_join(X,Y,by="SubjectId") we keep all data in X and
# only the matching data in Y. This will be the result:
# SubjectId   Result1   Result2
# 001         10        20
# 002         11        21
# 003         12        NA
# Subject 003 got NA (Not Available) as Result2, because Y has no data for this
# subject. Subject 004 is missing, because it does not exist in X.
#
# If we use the function right_join(X,Y,by="SubjectId"), we keep all data in Y
# and only the matching data in X. This will be the result:
# SubjectId   Result1   Result2
# 001         10        20
# 002         11        21
# 004         NA        22
# Subject 003 is missing, because it does not exist in Y. Subject 004 got NA as 
# Result1, because X has no data for this subject.
#
# If we use the function inner_join(X,Y,by="SubjectId"), we keep only the data
# with a match in the other data.frame. This will be the result:
# SubjectId   Result1   Result2
# 001         10        20
# 002         11        21
# Subjects 003 and 004 are missing because they don't exist in both data.frames.
#
# # If we use the function full_join(X,Y,by="SubjectId"), we keep all data.
# This will be the result:
# SubjectId   Result1   Result2
# 001         10        20
# 002         11        21
# 003         12        NA
# 004         NA        22
# All subjects are present. Subjects 003 and 004 have NA for missing data.
#
# What happens if there are multiple matches? By default, all matches are kept,
# but you can control this with an option.
# Let's again say that we have two data.frames. This is X:
# SubjectId   Result1
# 001         10
# 002         11
# 003         12
#
# And this is Y:
# SubjectId   Result2
# 001         20
# 002         21
# 002         100
# 004         22
# Note how data.frame Y has two rows for subject 002.
#
# If we use left_join(X,Y,by="SubjectId"), this is the output:
# SubjectId   Result1   Result2
# 001         10        20
# 002         11        21
# 002         11        100
# 003         12        NA
# There are now two rows for subject 002. Both have the same Result1 value, but
# they have different Result2 values, taken from the different matches in Y.
#
# To prevent this, we could use left_join(X,Y,by="SubjectId",multiple="first"):
# SubjectId   Result1   Result2
# 001         10        20
# 002         11        21
# 003         12        NA
# Now only the first match in Y is considered. Similarly, you could use "last".
#
# In our case, we have a data.frame with SAEs and another data.frame with DM
# data. We want to keep all SAEs, so we should either use left_join or full_join.
# Here, we choose left_join so that subjects without SAEs will not be part of 
# the report. We don't have to worry about multiple matches in the second 
# data.frame, as the DM data will be present on a single form for each subject.
# In contrast, the SAE data can contain multiple rows for a subject. By default
# each will be joined with the matching data in DM.
SAE_DM <- left_join(sae,dm,by="SubjectId")

##################
## Set the output
# Use the Viedoc-provided function to set NA to blank. Then re-label the columns
# and create a descriptive footer.
SAE_DM <- SAE_DM %>%
  setNAtoBlank() %>%
  setLabel(labels=as.list(c("Subject ID","Site Name","AE nr","AE Term","AE Start Date","AE Outcome","AE Seriousness Criteria","Sex","Age")))

report_footer <- paste("This report only contains subjects for which SAEs have been reported. Data last synced: ",as.character(format(as.Date(params$dateOfDownload),format="%d %b %Y")),".",sep="")

# The final output of the R script must be a list called "reportOutput". In this
# case, it contains a single report called "SAE combined with DM". This name 
# won't show in Viedoc; it only shows if a report contains more than one sub-
# report. Because this is a table (not a graph), we specify "data" and then the
# variable which holds the data (SAE_DM). We include the footer and specify that
# it is displayOnly, meaning that it will show in Reports, but won't be included
# when the report is downloaded.
reportOutput <- list(
  "SAE combined with DM" = list("data" = SAE_DM, footer = list(text = report_footer, displayOnly = TRUE)))

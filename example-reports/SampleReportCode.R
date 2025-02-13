# -- Sample custom report code --
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Purpose: 
#   1. Explain the input variables (edcData, params, metadata) and utility functions that are available for the programmer
#   2. Explain the appropriate output (reportOutput) expected for a error-free rendering in the UI
#   3. Explain the additional features available for the programmer to customize the reports (like double header, footer, and column width)
#
# INPUT VARIABLES
# ^^^^^^^^^^^^^^^
# The two input variables will be available in the memory when the custom report code will be executed in the reports server. 
# As a programmer you NEED NOT read these variables from disk.
# 
# edcData - This variable is a list that contains the CRF data and operational data.
#           edcData$Forms$<<form id>> will be a data.frame that contains the CRF data of that particular form. For eg. edcData$Forms$DM will have the data from Demographics form
#           edcData$<<operational data name>> will be data.frames that contain operational data. Below is the list of operational data available.
#           - edcData$EventDates - Contains one record per visit and its corresponding dates for each subject
#           - edcData$Queries - Contains one record per query per status along with its status remarks and dates
#           - edcData$ProcessedQueries - Contains one record per query (processed across the status)
#           - edcData$ReviewStatus - Contains one record per visit and form and has the statuses for DM Review, Clinical Review, Signature, and Lock
#           - edcData$SubjectStatus - Contains one record per subject along with the screening, enrollment, withdrawal status
#           - edcData$PendingForms - Contains one record per pending form
#           - edcData$TimeLapse - Contains one record per form with lapse days (number of days between the event date and the data entry start date)
#           - edcData$Items - Contains one record per item with ID, label, datatype, content length and other details.
#           - edcData$CodeLists - Contains one record per code text with format name, datatype and code value.
#
# params - This variable is a list that contains the below listed study and user parameters
#          params$dateOfDownload - Contains date and time at which the data was pulled from Viedoc Clinic.
#          params$UserDetails$studyinfo - Contains the studyName and studyType
#          params$UserDetails$studysettings - Contains the study level parameters:
#                                             expectedNumberOfScreenedSubjects - Expected number of subjects to be screened
#                                             expectedNumberOfEnrolledSubjects - Expected number of subjects to be enrolled 
#                                             expectedDateOfCompleteEnrollment - Expected date of 100% enrollment
#                                             totalNumberOfStudySites - Total number of sites
#                                             totalNumberOfUniqueCountries - Total number of countries
#          params$UserDetails$sites - Contains a data.frame with one record per site and includes the site level parameters:
#                                     expectedNumberOfSubjectsScreened - Expected number of subjects to be screened
#                                     expectedNumberOfSubjectsEnrolled - Expected number of subjects to be enrolled
#                                     maximumNumberOfSubjectsScreened - Maximum number of subjects that can be screened
# metadata - This variable is a list that contains the ODM elements information.
#            - metadata$MDVOIDs - Contains the design versions applied in the study.
#            - metadat$GlobalVariables - A data.frame that has the information on StudyName, StudyDescription and ProtocolName.
#            - metadata$BasicDefinitions - A data.frame that has information on any definitions used in the study(Columns: Definition, OID and Name).
#            - metadata$StudyEventRef - Contains the order of a Study Event present across the design versions(Data.frame with columns MDVOID, StudyEventOID, OrderNumber and Mandatory).
#            - metadata$StudyEventDef - Contains Study Event Definitions applied across the design versions(Data.frame with columns MDVOID, OID, Name, Repeating, Type and Category).
#            - metadata$FormRef - Contains details on the Forms added in an Event across the design versions(Data.frame with columns MDVOID, StudyEventOID and FormOID).
#            - metadata$FormDef - Contains Form Definitions applied across the design versions of a study (Data.frame with columns MDVOID, OID, Name, Repeating, Sdv and Hidden).
#            - metadata$ItemGroupRef - Contains details of the ItemGroups inside a form across design versions(Data.frame with columns MDVOID, FormOID and ItemGroupOID.
#            - metadata$ItemGroupDef - Contains details of ItemGroup definitions applied across design versions(Data.frame with columns MDVOID, OID, Name, Repeating, IsReferenceData, SASDatasetName, Domain, Origin, Purpose and Comment).
#            - metadata$ItemRef - Contains details of the Items within an ItemGroup(Data.frame with columns MDVOID, ItemGroupOID and ItemOID).
#            - metadata$ItemDef - Contains the Item definitions applied across design versions(Data.frame with columns MDVOID, OID, Name, DataType, Length, SignificantDigits, SASFieldName, SDSVarName, Origin, Comment, Question, MeasurementUnitOID, CodeListOID, HtmlType and Sdv.
#            - metadata$CodeList - Contains the CodeList information as a data.frame with columns MDVOID, OID, Name, DataType, SASFormatName, CodeListType, CodedValue, DecodedValue, Rank and OrderNumber.
#            - metadata$RolesDef - Contains the Roles defined in the study across design versions and their permissions(Data.frame with columns MDVOID, OID, Name and Permissions).
#            - metadata$SDVSettings - Contains details about the SDVScope set across design versions as a data.frame with columns MDVOID and SDVScope.
#            - metadata$formitems - Contains summarized information of Form and Item information(Data.frame with columns OID, FormOID, FormName, Hidden, ItemGroupOID, ItemOID, Name, DataType, Length, SignificantDigits, SASFieldName, SDSVarName, Origin, Comment, Question, MeasurementUnitOID, CodeListOID, HtmlType and Sdv).
#
# UTILITY FUNCTIONS
# ^^^^^^^^^^^^^^^^^
# Please refer to the utilityFunctions.R to explore the functions that are provided for usage in building custom reports
#
# OUTPUT VARIABLE
# ^^^^^^^^^^^^^^^
# reportOutput - This variable should contain the final output that needs to be displayed in the screen
#                This variable is a list. There should be one or more entry in the list.
#                Each entry will be made available via a drop-down menu (Similar to "by Country", "by Site', "by Subject" drop-down in the Enrollment Status report)
# Example:
# (1) Below is an example of one output
#     reportOutput <- list("Name of output" = list("data" = data.frame()))
#     The "Name of output" will be displayed in the screen via a drop-down menu (incase of more than one entry). On selecting that output, the data.frame in the above entry will be displayed in the screen.
# (2) Below is an example of two outputs
#     reportOutput <- list(
#                       "Name of first output" = list("data" = data.frame()),
#                       "Name of second output" = list("data" = data.frame())
#                     )
# (3) Below is an example of two outputs (one data frame and another plotly)
#     reportOutput <- list(
#                       "Name of first output" = list("data" = data.frame()),
#                       "Name of second output" = list("plot" = plot_ly())
#                     )
# NOTE: The name of the list entry containing the data.frame should be named "data" and the plot should be named "plot", as given in above examples.
#       Custom report supports only plot_ly plots. Please refer to https://plotly.com/r/reference/ for help on plotly plots.
#
# OPTIONAL FEATURES
# ^^^^^^^^^^^^^^^^^
# (1) ADD A FOOTER
#     A footer to the output table can be included as given in the below example:
#     reportOutput <- list("by Country" = list("data" = data.frame(), footer = list(text = "Additional notes to the table", displayOnly = TRUE)))
#     The footer text can include HTML tags. For eg. "This footer text <strong>emphasises</strong> a word"
#     displayOnly - a logical variable. If TRUE, the footer will be displayed but ignored when the report is downloaded. If FALSE, the footer will be included in the download.
#     If "displayOnly" is not mentioned, by default it is considered to be FALSE
#     For a plot output, if "displayOnly = FALSE", then please use plotly bottom margin (refer the example code below) to sufficiently display the note in the plot
#
# (2) SET A HEADER
#     Normally, the data.frame column labels will be used as table header. However, the column labels can be overridden using the header feature as given below:
#     newHeader <- list(firstLevel = c("Study", "Country", "Site Code", "Site Name", "Subject", "Screened", "Enrolled", "Candidate", "Ongoing", "Completed", "Withdrawn"))
#     reportOutput <- list("by Country" = list("data" = data.frame(), header = newHeader))
#
# (3) SET A SECOND LEVEL HEADER
#     Two levels of header can be set for a table as given below:
#     twoLevelHeader <- list(
#       firstLevel = c("Column 1", "Column 2", rep("Covers Columns 3, 4, 5", 3), "Column 6, "Column 7", rep("Covers Columns 8, 9", 2)),
#       secondLevel = c("Column 3", "Column 4", "Column 5", "Column 8", "Column 9")
#     )
#     reportOutput <- list("by Country" = list("data" = data.frame(), header = twoLevelHeader))
#    The above code will render a header as shown below:
#    --------------------------------------------------------------------------------------------------
#                        |     Covers Columns 3, 4, 5     |                     | Covers Columns 8, 9 | 
#    --------------------------------------------------------------------------------------------------
#    Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 | Column 9 | 
#    --------------------------------------------------------------------------------------------------
# (4) DEFINE COLUMN WIDTHS
#     The column width can be defined for all or selected columns as give below:
#     outputdata <- data.frame() # Output data
#     widths <- rep(0, ncol(outputdata)) # set all columns to auto width
#     widths[2] <- 105 # Set 2nd column to 105 px
#     widths[5] <- 90 # Set 5th column to 90 px
#     widths[6:11] <- 60 # Set columns 6 to 11 to 60 px
#     newcolumnDefs <- getColumnDefs(colwidths = widths)
#     reportOutput <- list("by Country" = list("data" = outputdata, columnDefs = newcolumnDefs))
#
# Actions to avoid
# ^^^^^^^^^^^^^^^^
# Please exercise caution to avoid below scenarios in your code:
# - Infinite loops
# - Data manipulation that might yield huge incorrect data ending up taking unnecessary disk space
# - Any tampering with the host system properties and performance
# - Below list of functions are blocked:
#   system,system2,dir.create,library,require,Sys.sleep,unlink,file.remove,file.rename,tempdir,detach,file.copy,file.create,file.append,setwd
#
# Sample Code
# ^^^^^^^^^^^
# The packages that are available at the server while executing the report code are listed below:
#   - vctrs,R6,generics,glue,lifecycle,magrittr,tibble,ellipsis,pillar,crayon,pkgconfig,tidyselect,purrr,Rcpp,tidyr,dplyr,rlang,lubridate,stringr,stringi,plotly,survival,xml2
# The available packages and versions supported by custom reports can be identified by generating a custom report using the code snippet provided below:
#     packagesInstalled <- installed.packages()
#     packageVersions <- data.frame(Package = packagesInstalled[,"Package"],
#                                   Version = packagesInstalled[,"Version"],
#                                   stringsAsFactors = FALSE)
#     reportOutput <- list("Packages" = list("data" = packageVersions))
#
# Below given is a sample program that uses all the above features and generates an output based on Demographics (DM) data
# There will be two outputs:
# 1. dmOut_1 - few fields from DM CRF with twoLevelHeader, footerText and columnDefs
# 2. dmOut_2 - Average age for each site. By default, the data.frame's column labels will be used as table header
# Custom report code is executed in a standalone sandboxed environment and only the final reportOutput is transferred back to the server, hence local variables if used are to be included within the data as they will be lost outside of the R code. Please refer the code used to plot output 'Subjects per Site' for better understanding.

# IMPORTANT NOTE:
# While preparing the custom report, you have to include the below lines to get the edcData, params, metadata and utilityFunctions.
# However, before uploading the code to Viedoc, please remove the below lines. They will be taken care of by the Viedoc Reports while executing the custom report code
##### DELETE THE BELOW LINES BEFORE UPLOADING TO DESIGNER -- START -- 
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
source("utilityFunctions.R", local = T)
edcData <- readRDS("edcData.rds")
params <- readRDS("params.rds")
metadata <- readRDS("metadata.rds")
##### DELETE THE ABOVE LINES BEFORE UPLOADING TO DESIGNER -- END -- 

# Get CRF data
dm <- edcData$Forms$DM
ae <- edcData$Forms$AE
vs <- edcData$Forms$VS
subjects <- edcData$SubjectStatus
# Declare Local variable for use in code
LABEL <- "Count"

# Calculate number of events for each subject
aeSubject <- ae %>% group_by(SubjectId) %>% summarize(AECOUNT = n())
# Get the baseline SYS and DIA BP
vsSubject <- vs %>% filter(EventName == "Baseline") %>% select(SubjectId, VSSYS, VSDIA)
# Join the Average Age and AE Count
dmOut_1 <- dm %>% 
  left_join(aeSubject, by = c("SubjectId")) %>% 
  left_join(vsSubject, by = c("SubjectId")) %>% 
  select(SubjectId, Country, SiteName, DMSEX, DMAGE, DMDOB, VSSYS, VSDIA, DMIC, AECOUNT)
# Prepare data for dislay (please refer to utilityFunctions.R for details on this function)
dmOut_1 <- prepareDataForDisplay(dmOut_1)
# Prepare header
twoLevelHeader <- list(
  firstLevel = c("Subject", "Country","Site Name", "Gender", "Age", "Date of birth", rep("Baseline Vitals", 2), "Informed consent date", "Count of Adverse Events"),
  secondLevel = c("Systolic BP", "Diastolic BP")
)
# Prepare footer text
footerText <- "NOTE: Baseline Vitals might be missing for Subjects on Protocol Version 1.5 or earlier"
# Set a wider column for Site Name (3rd column)
widths <- rep(0, ncol(dmOut_1)) # Set all columns to auto width
widths[3] <- 200 # Set third column to 200 px
columnDefs <- getColumnDefs(colwidths = widths)

# Calculate Average Age
dmOut_2 <- dm %>% 
  group_by(Country, SiteCode, SiteName) %>% 
  summarise(SiteAvgAge = round(mean(as.numeric(DMAGE), na.rm = T),0))
dmOut_2 <- prepareDataForDisplay(dmOut_2)
dmOut_2 <- setLabel(dmOut_2, list("Country", "Site Code", "Site Name", "Average Age"))

# Plot on AGE field grouped by GENDER
pl <- plot_ly(data = dmOut_1, x = ~DMSEX, y = ~DMAGE, type = "box")
plfooterText <- "This is a sample note for plot"

# Plot on AGE field grouped by GENDER - footer with displayOnly FALSE
pl2 <- plot_ly(data = dmOut_1, x = ~DMSEX, y = ~DMAGE, type = "box") %>% layout(margin = list(b = 100)) # Add bottom margin to display footer

# Plot for 'Subjects per Site'
# * INCORRECT USE OF LOCAL VARIABLE *
# Avoid using the local variable LABEL as below, as it will not be available outside of this R code. Only the reportOutput shall be passed to the server to be displayed on the UI.
# subjects_by_site <- subjects %>%
#   group_by(SiteName) %>%
#   summarise(Subjects = n())
# pl3 <- plot_ly(data = subjects_by_site, x = ~SiteName, y = ~Subjects, type = "bar",
#                hoverinfo = "text",
#                hovertext = ~paste0(LABEL,":",Subjects))

# * CORRECT USAGE OF LOCAL VARIABLE *
# Below is an example of the right way to use the local variables by including them in the data to plot.
# Calculate count of subjects per site
subjects_by_site <- subjects %>%
  group_by(SiteName) %>%
  summarise(Subjects = n()) %>%
  mutate(label_count = paste0(LABEL,":",Subjects))
pl3 <- plot_ly(data = subjects_by_site, x = ~SiteName, y = ~Subjects, type = "bar",
                hoverinfo = "text",
                hovertext = ~label_count)

# Display the order of Scheduled Events in the study
visitOrder <- metadata$StudyEventRef %>%
  rename(EventId = StudyEventOID) %>% 
  inner_join(metadata$StudyEventDef %>% select(MDVOID, EventId = OID, EventName = Name, Type), by = c("MDVOID","EventId")) %>% 
  filter(Type == "Scheduled") %>%
  mutate(OrderNumber = ifelse(!is.na(OrderNumber), as.numeric(OrderNumber), max(as.numeric(OrderNumber), na.rm = T) + 1)) %>% 
  distinct(MDVOID, OrderNumber, EventId, EventName) %>% 
  group_by(EventId) %>% 
  arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
  filter(row_number() == 1) %>%
  select(EventId, EventName, OrderNumber) %>% 
  arrange(as.numeric(OrderNumber))

# Set the output
reportOutput <- list(
  "by Subject" = list("data" = dmOut_1, footer = list(text = footerText, displayOnly = TRUE), header = twoLevelHeader, columnDefs = columnDefs),
  "by Site" = list("data" = dmOut_2),
  "Age by Gender" = list("plot" = pl, footer = list(text = plfooterText, displayOnly = TRUE)),
  "Age by Gender (footer)" = list("plot" = pl2, footer = list(text = plfooterText, displayOnly = FALSE)),
  "Subjects per Site" = list("plot" = pl3),
  "Order of Scheduled Events" = list("data" = visitOrder)
)


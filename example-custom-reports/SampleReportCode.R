
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


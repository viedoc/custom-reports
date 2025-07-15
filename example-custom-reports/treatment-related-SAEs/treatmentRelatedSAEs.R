## Viedoc Custom Report - Treatment-related SAEs

# This report serves as an example on how to select data that fulfills certain criteria (in this case, adverse events 
# that were recorded as (possibly) treatment-related and serious) and how to summarize the data by site.

# This custom report will generate the following output:
# Sub-report "by Subject": A table of all AEs entered as (Possibly) Related to the study treatment and as Serious.
# Sub-report "by Site": A table of the number of AEs fulfilling the above criteria per site.


# Get CRF data
ae <- edcData$Forms$AE

# Prepare the first report (all treatment-related SAEs)

# Filtering Treatment related SAEs
aeSubject <- ae %>% 
  filter((AEREL == "Possibly related" | AEREL == "Related") & AESER == "Yes") %>% 
  select(SubjectId, Country, SiteName, AETERM, AEREL, AESER)

# Prepare data for display (please refer to utilityFunctions.R for details on this function)
aeOut_1 <- prepareDataForDisplay(aeSubject)

# Prepare header
newHeader <- list(firstLevel = c("Subject", "Country", "Site Name", "Description", "Relationship to the study treatment", "Serious?"))

# Prepare footer text
footerText <- "NOTE: Example note"

# Set a wider column for Site Name (3rd column)
widths <- rep(0, ncol(aeOut_1)) # Set all columns to auto width
widths[3] <- 200 # Set third column to 200 px
columnDefs <- getColumnDefs(colwidths = widths)


# Prepare the second report (count of treatment-related SAEs per site)

# Group by site, filter treatment-related SAEs, and get the count per site:
aeOut_2 <- ae %>% 
  group_by(Country, SiteCode, SiteName) %>% 
  filter(AEREL == "Possibly related" | AEREL == "Related") %>% 
  filter(AESER == "Yes") %>% 
  summarise(TRTSAE = n())

# Prepare data for display
aeOut_2 <- prepareDataForDisplay(aeOut_2)

# Set labels
aeOut_2 <- setLabel(aeOut_2, list("Country", "Site Code", "Site Name", "Number of Treatment Related SAEs"))

# Set the output
reportOutput <- list(
  "by Subject" = list("data" = aeOut_1, footer = list(text = footerText, displayOnly = TRUE), header = newHeader, columnDefs = columnDefs),
  "by Site" = list("data" = aeOut_2)
)
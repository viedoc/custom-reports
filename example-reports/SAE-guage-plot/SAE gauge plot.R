#written by Lyle Wiemerslage

ae <- edcData$Forms$AE

#list all SAEs
sae = ae %>% filter(AESERCD==1)
saeOut = sae %>% select(SubjectId, Country, SiteName, EventDate, AESEQ, AESER, AETERM, AESTDAT, AEENDAT, AESEV, AEOUT, AEREL, AEACN, LastEditedDate)
saeOut = prepareDataForDisplay(saeOut)
saeOut = setLabel(saeOut, list("Subject", "Country","Site Name", "Event Date", "AE Number", "Serious?", "Description", "Start Date", "Stop Date", "Severity", "Outcome", "Relation to Study Drug", "Action taken with Study Drug", "Last Edited"))

# Calculate number of SAEs per site
saeOut2 = sae %>% group_by(Country, SiteCode, SiteName) %>% summarize(AESERCD = n())
saeOut2 = prepareDataForDisplay(saeOut2)
saeOut2 = setLabel(saeOut2, list("Country", "Site Code", "Site Name", "Number of SAEs"))

#Count old AEs and SAEs
oldAE = count(ae %>% filter(((as.Date(InitiatedDate)-(as.Date(params[["dateOfDownload"]])-7) <= 1))))
oldSAE = count(sae %>% filter(((as.Date(InitiatedDate)-(as.Date(params[["dateOfDownload"]])-7) <= 1))))

#Gauge Figure for AEs
aeGaugefig <- plot_ly(
  domain = list(x = c(0, 1), y = c(0, 1)),
  value = nrow(ae),
  title = list(text = "Adverse Events"),
  type = "indicator",
  mode = "gauge+number+delta",
  delta = list(reference = oldAE[1,1]),
  gauge = list(
    axis =list(range = list(NULL, 100)),
    steps = list(
      list(range = c(60, 80), color = "pink"),
      list(range = c(80, 100), color = "darkred")),
    threshold = list(
      line = list(color = "darkgray", width = 4),
      thickness = 0.75,
      value = 60)))  
aeGaugefig <- aeGaugefig %>%
  layout(margin = list(l=20,r=30))



#Gauge Figure for SAEs
saeGaugefig <- plot_ly(
  domain = list(x = c(0, 1), y = c(0, 1)),
  value = nrow(sae),
  title = list(text = "Serious AEs"),
  type = "indicator",
  mode = "gauge+number+delta",
  delta = list(reference = oldSAE[1,1]),
  gauge = list(
    axis =list(range = list(NULL, 20)),
    steps = list(
      list(range = c(12, 16), color = "pink"),
      list(range = c(16, 20), color = "darkred")),
    threshold = list(
      line = list(color = "darkgray", width = 4),
      thickness = 0.75,
      value = 12)))  
saeGaugefig <- saeGaugefig %>%
  layout(margin = list(l=20,r=30))

# Set a wider column for Site Name (3rd column)
widths = rep(0, ncol(saeOut)) # Set all columns to auto width
widths[3] = 200 # Set third column to 200 px
columnz = getColumnDefs(colwidths = widths)

# Prepare footer text
footr = "NOTE: See plots"
plfooterText = "NOTE: Delta is from previous seven days."


reportOutput = list(
  "by Subject" = list("data" = saeOut, footer = list(text = footr, displayOnly = TRUE), columnDefs = columnz),
  "by Site" = list("data" = saeOut2))

# Set the output
reportOutput <- list(
  "by Subject" = list("data" = saeOut, footer = list(text = footr, displayOnly = TRUE), columnDefs = columnz),
  "by Site" = list("data" = saeOut2),
  "AE Plot" = list("plot" = aeGaugefig, footer = list(text = plfooterText, displayOnly = TRUE)),
  "SAE Plot" = list("plot" = saeGaugefig, footer = list(text = plfooterText, displayOnly = FALSE))
)

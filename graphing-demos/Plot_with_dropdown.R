# This custom report is an example of how to create a plotly graph with a dropdown list to filter the data.

# Create vs dataframe from Vital Signs form data; remove unscheduled visits from vs data frame;
# keep only needed columns
vs <- edcData$Forms$VS %>%
  filter(EventId != "E98_UNS") %>%
  select(SubjectId, EventName, SYSBP_VSORRES, DIABP_VSORRES, SiteCode)

# Read the order of events from the metadata
studyEvents <- metadata$StudyEventDef %>%
  filter(Type == "Scheduled" & Name %in% vs$EventName) %>%
  select(Name) %>%
  distinct()

# Set the EventName as a factor, and use the levels argument to fix the ordering
vs$EventName <- factor(vs$EventName, levels = studyEvents$Name)

# Sort the data
vs <- arrange(vs, SiteCode, SubjectId)

# Get all unique sites
allSites <- unique(vs$SiteCode)

# Create a dropdown list to filter the plot by site
# In the args list, a vector is needed for all subjects indicating if their data should be visible or not,
# depending on whether the subject exists at the selected site.
dropdowns <- lapply(c("Show All", allSites), function(site) {
  if(site == "Show All") {
    list(
      args = list(list(visible = TRUE)),
      label = site,
      method = "update"
    )
  } else {
    list(
      args = list(
        list(
          visible = sapply(unique(vs$SubjectId), function(subj) subj %in% vs$SubjectId[vs$SiteCode == site])
          )
        ),
      label = site,
      method = "update"
    )
  }
})

# Create the plots
sysPlot <- plot_ly(
  data = vs,
  x = ~EventName,
  y = ~SYSBP_VSORRES,
  type = 'scatter',
  mode = 'lines+markers',
  color = ~SubjectId) %>%
  layout(
    title = "Systolic Blood Pressure over Time",
    xaxis = list(title = "Visit"),
    yaxis = list(title = "Blood Pressure (mm Hg)"),
    updatemenus = list(
      list(
        type = 'dropdown',
        buttons = dropdowns
      )
    )
  )

diaPlot <- plot_ly(
  data = vs,
  x = ~EventName,
  y = ~DIABP_VSORRES,
  type = 'scatter',
  mode = 'lines+markers',
  color = ~SubjectId) %>%
  layout(
    title = "Diastolic Blood Pressure over Time",
    xaxis = list(title = "Visit"),
    yaxis = list(title = "Blood Pressure (mm Hg)"),
    updatemenus = list(
      list(
        type = 'dropdown',
        buttons = dropdowns
      )
    )
  )

# Final output
reportOutput = list(
  "Systolic Pressure" = list("plot" = sysPlot),
  "Diastolic Pressure" = list("plot" = diaPlot)
  )
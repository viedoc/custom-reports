## Viedoc Custom Report - Blood Pressure plot

# This report serves as an example on how to create simple scatter plots using the plotly package.

# This custom report will generate the following output:
# Sub-report "Mean Arterial Pressure": A plot of the calculated MAP
# Sub-report "Systolic only": A plot of the systolic blood pressure
# Sub-report "Diastolic only": A plot of the diastolic blood pressure


# If VS dataset is missing, then most of the code is skipped and the else-statement 
# near the end of the script is executed.
if(!is.null(edcData$Forms$VS)){

# Create vs data frame from Vital Signs form data
vs <- edcData$Forms$VS

# Remove unscheduled visits from vs data frame
vs <- filter(vs, vs$EventId != "E98_UNS")

# Parse the data frame for the sake of computational efficiency
vs <- select(vs, SubjectId, EventName, SYSBP_VSORRES, DIABP_VSORRES)

# Order EventName properly
visit_order <- c("Screening", "Baseline", "Week 1", "Week 2", "Week 4", "Week 8", "Follow-up")
vs$EventName <- factor(vs$EventName, levels = visit_order, ordered = TRUE)

# Calculate mean arterial pressure (MAP) and add to the vs data frame
vs <- mutate(vs, MAP = ((SYSBP_VSORRES + (2*DIABP_VSORRES))/3))

# Create the plots with a trace for each subject. X-axis is event name and y axis is measured blood pressure
mapPlot <- plot_ly(data = vs, x = ~EventName, y = ~MAP, type = 'scatter', mode = 'lines+markers', color = ~SubjectId) %>%
  layout(title = "Mean Arterial Pressure over Time", xaxis = list(title = "Visit"), yaxis = list(title = "Blood Pressure (mm Hg)"))

sysPlot <- plot_ly(data = vs, x = ~EventName, y = ~SYSBP_VSORRES, type = 'scatter', mode = 'lines+markers', color = ~SubjectId) %>%
  layout(title = "Systolic Blood Pressure over Time", xaxis = list(title = "Visit"), yaxis = list(title = "Blood Pressure (mm Hg)"))

diaPlot <- plot_ly(data = vs, x = ~EventName, y = ~DIABP_VSORRES, type = 'scatter', mode = 'lines+markers', color = ~SubjectId) %>%
  layout(title = "Diastolic Blood Pressure over Time", xaxis = list(title = "Visit"), yaxis = list(title = "Blood Pressure (mm Hg)"))

#final output: 3 plots total, one for each measurement type
reportOutput <- list(
  "Mean Arterial Pressure" = list("plot" = mapPlot),
  "Systolic only" = list("plot" = sysPlot),
  "Diastolic only" = list("plot" = diaPlot))

} else{
    # These lines of code run only if the VS data is empty:
  emptyOutput <- data.frame(EmptyOutput = "No data available. Have any vital signs forms been saved? If so, has the data been synchronised recently?")
  SCfooter = paste("This data was last synchronized on ",as.character(format(as.Date(params$dateOfDownload),format="%d-%b-%Y")),".",sep="")
  reportOutput <- list(
    "Survival Curve" = list("data" = emptyOutput,footer = list(text = SCfooter, displayOnly = TRUE)))
}

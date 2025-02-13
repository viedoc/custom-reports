# Viedoc Custom Report - Survival Curve

# This report serves as an example on how to perform a survival analysis using the Survival package, as well as how to
# create a more complicated plot using the plotly package.

# This custom report will generate the following output:
# Sub-report "Survival Curve": A plot of the Kaplan-Meier model, with 95% confidence intervals.
# Sub-report "Survival Table": A table with the plotted values.

# Get data from the DM and DS forms. If a dataset is missing, then most of the code is skipped and the else-statement 
# near the end of the script is executed.
if(!is.null(edcData$Forms$DM) && !is.null(edcData$Forms$DS)){
  dm <- edcData$Forms$DM %>%
    select(SubjectId,RFICDAT)
  ds <- edcData$Forms$DS %>%
    select(SubjectId,DTHDAT,DSSTDAT)
  
  # Prepare the data to be used as input for the Kaplan-Meier function: The dates of informed consent, study 
  # discontinuation, and death are combined. The studyTime column is created, which indicates how long a subject has
  # been in the study. This is the difference between informed consent date and either death date, discontinuation date 
  # or the date of data synchronization (if the subject is still in the study). And the lifeDeathStatus is populated 
  # with a 1 for alive or 2 for dead. The data is sorted by the studyTime column.
  subjData <- left_join(dm, ds, by = "SubjectId") %>%
    mutate(DateOfSync = params$dateOfDownload,
           studyTime = if_else(!is.na(DTHDAT), as.numeric(as.Date(DTHDAT) - as.Date(RFICDAT)),
                               if_else(!is.na(DSSTDAT), as.numeric(as.Date(DSSTDAT) - as.Date(RFICDAT)),
                                       as.numeric(as.Date(DateOfSync) - as.Date(RFICDAT)))),
           lifeDeathStatus = if_else(!is.na(DTHDAT),2,1)) %>%
    arrange(studyTime)
  
  # The Kaplan-Meier model is fitted to the data
  modelFit <- survfit(Surv(studyTime, lifeDeathStatus) ~ 1,data = subjData)
  
  # The outcome of the Kaplan-Meier function is edited slightly before the data will be plotted: A time point zero with 
  # 100% survival is added as starting point for the plot, and the survival probabilities and confidence intervals
  # are multiplied by 100 to show them as percentages.
  plotData <- data.frame(
    time  = c(0, modelFit$time),
    surv  = c(1, modelFit$surv) * 100,
    upper = replace_na(c(1, modelFit$upper) * 100, 0),
    lower = replace_na(c(1, modelFit$lower) * 100, 0)
    )
  
  # Prepare the plot. First a plotly object is created and the dataset plotData is specified. Next, the confidence 
  # intervals are plotted using the add_polygons() function. On the x-axis, a vector of the time and its reverse is 
  # used. On the y-axis, a vector of the upper confidence intervals and the reverse vector of the lower confidence 
  # intervals is used. The line to connect all data points first moves horizontally and then vertically for a stepwise 
  # effect (shape = "hv"). The connected data points will form an enclosed area. This shape is filled with blue color 
  # with a 0.2 opacity.
  # The add_lines() function is used to plot the line of survival probability: time on the x-axis and survival on the 
  # y-axis. The type is set to scatter and the mode to lines, to get a line without markers. Also here, the shape is set
  # to hv for the stepwise appearance. A hovertext is created to show the survival and confidence interval when hovering
  # the mouse cursor over the plot.
  # Finally, the layout() function is used to customize the x- and y-axes.
  survCurve <- plot_ly(plotData) %>%
    add_polygons(
      x       = ~c(time, rev(time)),
      y       = ~c(upper, rev(lower)),
      line    = list(shape = "hv"),
      color   = I("blue"),
      opacity = 0.2,
      name    = "95% Confidence Interval") %>%
    add_lines(
      x         = ~time,
      y         = ~surv,
      type      = "scatter",
      mode      = "lines",
      line      = list(shape = "hv"),
      color     = I("blue"),
      name      = "Survival Probability (Kaplan-Meier)",
      hovertext = ~paste(round(surv, 1), " (", round(lower, 1), " - ", round(upper, 1), ")", sep = ""),
      hoverinfo = "text") %>%
    layout(
      xaxis = list(
        title = "Time (days)",
        range = c(0, max(plotData$time) + 1)),
      yaxis = list(
        title = "Survival (%)",
        range = c(0, 101)))
  
  # Create a table with the plotted values:
  survTable <- round(plotData, 1) %>%
    setLabel(labels = as.list(c("Time (days)", "Survival Probability (%)", "Upper 95% Conf.Int.", "Lower 95% Conf.Int.")))
  
  # Create the output:
  reportOutput = list(
    "Survival Curve" = list("plot" = survCurve),
    "Survival Table" = list("data" = survTable))
  
} else{
  # These lines of code run only if the DM and/or DS data is empty:
  emptyOutput <- data.frame(EmptyOutput = "No data available. Have any Demographics and End Of Study forms been saved? If so, has the data been synchronised recently?")
  SCfooter = paste("This data was last synchronized on ",as.character(format(as.Date(params$dateOfDownload),format="%d-%b-%Y")),".",sep="")
  reportOutput <- list(
    "Survival Curve" = list("data" = emptyOutput,footer = list(text = SCfooter, displayOnly = TRUE)))
}
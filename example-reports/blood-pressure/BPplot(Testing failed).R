#create vs dataframe from Vital Signs form data
vs <- edcData$Forms$VS

#remove unscheduled visits from vs data frame
vs <- filter(vs, vs$EventId != E98_UNS)

#parse the data frame for the sake of computational efficiency
vs <- select(vs, SubjectId, EventName, SYSBP_VSORRES, DIABP_VSORRES)

#calculate mean arterial pressure (MAP) and add to the vs data frame
vs <- mutate(vs, MAP = ((SYSBP_VSORRES + (2*DIABP_VSORRES))/3))

#create the plots with a trace for each subject. X-axis is event name and y axis is measured blood pressure
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
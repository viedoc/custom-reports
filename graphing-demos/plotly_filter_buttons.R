# This custom report is an example of how to create a plotly graph with buttons to filter the data.

# Create some fake data.
df <- data.frame(
  cohort = c(rep("A", 20), rep("B", 20), rep("C", 10)), 
  x = c(sample(1:10, 20, T), sample(11:20, 20, T), sample(21:30, 10, T)), 
  y = c(sample(1:15, 20, T), sample(11:25, 20, T), sample(16:30, 10, T))
  ) %>%
  arrange(cohort) # Important to sort by the filtering factor if working with multiple traces!!

# Create the buttons.
filterButtons <- lapply(c("All",unique(df$cohort)), function(x){
  if(x == "All") return(
    list(
      method = "restyle", 
      args = list("transforms[0].value", list(unique(df$cohort))),
      label = x
    )
  )
  else return(
    list(
      method = "restyle", 
      args = list("transforms[0].value", x),
      label = x
    )
  )
})

# Create the plotly object, using the filterButtons in the layout function.
fig <- plot_ly(data = df,
        x = ~x, 
        y = ~y, 
        type = 'scatter',
        mode = 'markers',
        text = ~cohort, 
        color = ~cohort,
        transforms = list(
          list(
            type = 'filter', 
            target = ~cohort, 
            operation = '{}', 
            value = unique(df$cohort)
            )
          )
        )  %>% 
  layout(title = "Example of filter buttons", 
         xaxis = list(title = "x"),
         yaxis = list(title = "y"),
         updatemenus = list(
           list(
             type = 'buttons',
             buttons = filterButtons
             )
           )
         )

reportOutput <- list(
  report = list(plot = fig)
)
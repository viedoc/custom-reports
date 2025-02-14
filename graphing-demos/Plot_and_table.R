# Example R script to generate a plotly object containing a plot and table side-by-side.

# library(dplyr)
# library(plotly)

dm <- edcData$Forms$DM %>%
  select(SubjectId, SiteCode, AGE)

fig1 <- dm %>%
  group_by(SiteCode) %>%
  summarise(mean_age = mean(AGE, na.rm = TRUE)) %>%
  plot_ly(type = "bar",
          x = ~SiteCode,
          y = ~mean_age)

fig2 <- dm %>%
  plot_ly(
    type = "table",
    domain = list(x = c(0.5, 1), y = c(0, 1)),
    header = list(
      values = getLabel(dm),
      align = "center",
      line = list(width = 1, color = "black"),
      fill = list(color = "grey"),
      font = list(family = "Arial", size = 14, color = "white")
    ),
    cells = list(
      values = t(unname(dm)),
      align = "center",
      line = list(color = "black", width = 1),
      font = list(family = "Arial", size = 12, color = "black")
    )
  )

fig3 <- subplot(fig1, fig2, nrows = 1) %>% 
  layout(
    xaxis = list(domain = c(0, 0.5), title = "Site Code"),
    xaxis2 = list(domain = c(0.5, 1)),
    yaxis = list(title = "Mean age"),
    showlegend = FALSE)

reportOutput <- list(
  report = list(plot = fig3)
)

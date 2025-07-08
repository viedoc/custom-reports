library(tidyverse)
library(survival)

survFit <- survfit(Surv(time, status) ~ 1, data = lung)
survFit <- rbind(
  c(0, 100, 100, 100),
  data.frame(
    time = survFit$time,
    surv = round(100 * survFit$surv, 1), 
    upper = round(100 * survFit$upper, 1), 
    lower = round(100 * survFit$lower, 1)))
write.csv2(survFit, "SurvivalLungDataSetR.csv", row.names = F)
paste("Output saved: ", getwd(), "/SurvivalLungDataSetR.csv", sep = "")
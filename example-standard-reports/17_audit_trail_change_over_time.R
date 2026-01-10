#----------Audit Trail (AT) Report - Change Over Time----------


# Get unique event name
if ("StudyEventDef" %in% names(metadata)) {
  visitOrderDF <<- metadata$StudyEventRef %>%
    rename(EventId = StudyEventOID) %>% 
    inner_join(metadata$StudyEventDef %>% select(MDVOID, EventId = OID, EventName = Name), by = c("MDVOID","EventId")) %>% 
    distinct(MDVOID, OrderNumber, EventId, EventName) %>% 
    group_by(EventId) %>% 
    arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
    filter(row_number() == 1) %>% 
    select(-MDVOID) %>% 
    data.frame() %>% 
    group_by(EventName) %>% 
    arrange(as.numeric(OrderNumber), .by_group = TRUE) %>% 
    mutate(count = n(), seq = row_number()) %>% 
    data.frame() %>% 
    mutate(EventName = ifelse(count == 1, EventName, paste0(EventName,"_",seq))) %>%
    select(-count, -seq)
}
color1 <<- "#000000"
color1Fade <<- "#0000000d"
color2 <<- "#7b4dff"
color2Fade <<- "#7b4dff26"
auditData <<- auditData$data %>% select(-EventName) %>% left_join(visitOrderDF %>% select(EventId, EventName), by = "EventId") # Getting the updated Event Name

# Get Country Name
ld <- params$UserDetails$sites %>% select(SiteCode = siteCode, SiteName = siteName, Country = country, CountryCode = countryCode)
ld$SiteCode <- as.character(ld$SiteCode)
auditData$SiteCode <- as.character(auditData$SiteCode)
auditData <- auditData %>%
  left_join(ld, by = c("SiteName", "SiteCode"))

#----------Filter that can be customized------------
country <- unique(auditData$Country) # pass the list of Countries
site <- unique(auditData$SiteCode) # pass the list of Sites
visit <- unique(auditData$EventName) # pass the list of Events
form <- unique(auditData$FormName) # pass the list of Forms
systemUpdates <- "Include" # pass System Updates value

excludeSystemUpdates <- FALSE
if (systemUpdates == "Exclude") excludeSystemUpdates <- TRUE

auditData <- auditData %>% filter(Country %in% country & SiteCode %in% site & EventName %in% visit & FormName %in% form & OperationType != "")
if (excludeSystemUpdates) auditData <- auditData %>% filter(OperationType == "Insert" | !SystemUpdates)

#----------Filter that can be customized------------
accumulateBy <- "Week" # accumulateBy can be "Month" or "Week"
data <- auditData

# Missing months
if (accumulateBy == "Month") {
  date1 <- floor_date(as.Date(min(data$EditDateTime, na.rm = T)), unit = "month")
  date2 <- floor_date(as.Date(max(data$EditDateTime, na.rm = T)), unit = "month")
  accumulate_ends <- expand.grid(EditDateTime_End = seq(date1, date2, by = "month"), OperationType = c("Insert", "Update"))
  accumulate_ends$EditDateTime_End <- ceiling_date(accumulate_ends$EditDateTime_End, unit = "month") - 1
  data <- data %>% mutate(EditDateTime_End = ceiling_date(as.Date(EditDateTime), unit = "month") - 1)
}
if (accumulateBy == "Week") {
  date1 <- ceiling_date(as.Date(min(data$EditDateTime, na.rm = T)), unit = "week", change_on_boundary = F)
  date2 <- ceiling_date(as.Date(max(data$EditDateTime, na.rm = T)), unit = "week", change_on_boundary = F)
  accumulate_ends <- expand.grid(EditDateTime_End = seq(date1, date2, by = "week"), OperationType = c("Insert", "Update"))
  data <- data %>% mutate(EditDateTime_End = ceiling_date(as.Date(EditDateTime), unit = "week", change_on_boundary = F))
}
data <- data %>%
  group_by(EditDateTime_End, OperationType) %>%
  count() %>%
  data.frame() %>%
  full_join(accumulate_ends) %>%
  mutate(n = ifelse(is.na(n), 0, n)) %>%
  group_by(OperationType) %>%
  arrange(OperationType, EditDateTime_End) %>%
  mutate(cumn = cumsum(n)) %>%
  data.frame()

# * Render number of data operations over time ----
pl <- plot_ly(data, x = ~EditDateTime_End, y = ~n, color = ~OperationType, colors = c(color1, color2), type = 'scatter', mode = 'markers+lines+text', hovertemplate= "%{y}<extra></extra>", text = ~n, textposition = 'top center', fill = 'tozeroy') %>% 
  layout(
    title = paste("Number of data operations by",accumulateBy),
    xaxis = list(
      title = "",
      range = list(head(tail(data$EditDateTime_End, 12), 1), tail(data$EditDateTime_End, 1)),
      rangeselector = list(
        buttons = list(
          list(count = 3, label = "3 mo", step = "month", stepmode = "backward"),
          list(count = 6, label = "6 mo", step = "month", stepmode = "backward"),
          list(count = 1, label = "1 yr", step = "year", stepmode = "backward"),
          list(count = 1, label = "YTD", step = "year", stepmode = "todate"),
          list(step = "all")
        )
      ),
      rangeslider = list(type = "date")
    ),
    yaxis = list(title = "", fixedrange = FALSE, ticklen = 4, tickcolor = "transparent"),
    font = globalFont
  )

# * Render cumulative number of data operations over time ----
pl_2 <- plot_ly(data, x = ~EditDateTime_End, y = ~cumn, color = ~OperationType, colors = c(color1, color2), type = 'scatter', mode = 'markers+lines+text', hovertemplate= "%{y}<extra></extra>", text = ~cumn, textposition = 'top center', fill = 'tozeroy') %>% 
  layout(
    title = paste("Cumulative number of data operations by",accumulateBy),
    xaxis = list(
      title = "",
      range = list(head(tail(data$EditDateTime_End, 12), 1), tail(data$EditDateTime_End, 1)),
      rangeselector = list(
        buttons = list(
          list(count = 3, label = "3 mo", step = "month", stepmode = "backward"),
          list(count = 6, label = "6 mo", step = "month", stepmode = "backward"),
          list(count = 1, label = "1 yr", step = "year", stepmode = "backward"),
          list(count = 1, label = "YTD", step = "year", stepmode = "todate"),
          list(step = "all")
        )
      ),
      rangeslider = list(type = "date")
    ),
    yaxis = list(title = "", fixedrange = FALSE, ticklen = 4, tickcolor = "transparent"),
    font = globalFont
  )

reportOutput <- list("Number of data operations" = list("plot" = pl),
                     "Cumulative number of data operations" = list("plot" = pl_2)
)

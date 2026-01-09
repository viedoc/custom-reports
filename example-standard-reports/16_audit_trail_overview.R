#----------Audit Trail Report - Overview----------

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

prepareAuditPlots <- function(data, plotFor, plotBy, countBy, rateBy) {
  # Calculate counts and rates at item and study level
  if ("CountryCode" %in% plotFor) groupByFields <- c("SubjectSeq", "SubjectId", plotFor)
  if ("SiteCode" %in% plotFor) groupByFields <- c("SubjectSeq", "SubjectId", plotFor)
  if ("EventName" %in% plotFor) groupByFields <- c("SubjectSeq", "SubjectId", "EventId", "EventSeq", plotFor)
  if ("FormName" %in% plotFor) groupByFields <- c("SubjectSeq", "SubjectId", "EventId", "EventSeq", "FormId", "FormSeq", plotFor)
  if ("ItemId" %in% plotFor) groupByFields <- c("SubjectSeq", "SubjectId", "EventId", "EventSeq", "FormId", "FormSeq", "ItemGroupId", "ItemGroupSeq", plotFor)
  itemLevel <- data %>% group_by_at(c(plotFor, "OperationType")) %>% summarize(StudyCount = n(), .groups = "keep") %>% spread("OperationType", "StudyCount") %>% data.frame()
  itemLevel[is.na(itemLevel)] <- 0
  if (!has_name(itemLevel, 'Insert')) itemLevel$Insert <- 0
  if (!has_name(itemLevel, 'Update')) itemLevel$Update <- 0
  rateByCount <- data %>% distinct_at(groupByFields) %>% group_by_at(c(plotFor)) %>% summarize(rateByCount = n(), .groups = "keep") %>% data.frame()
  itemLevel <- itemLevel %>% mutate(Both = Insert + Update) %>% left_join(rateByCount, by = plotFor)
  studyLevel <- itemLevel %>% summarize(Insert = sum(Insert, na.rm = T), Update = sum(Update, na.rm = T), Both = sum(Both, na.rm = T), rateByCount = sum(rateByCount, na.rm = T))
  studyLevel[is.na(studyLevel)] <- 0
  itemLevel <- itemLevel %>% mutate(rateByItem = round(Update/Insert, 2), rateByOther = round(Update/rateByCount, 2))
  itemLevel[is.na(itemLevel)] <- 0
  studyLevel <- studyLevel %>% mutate(rateByItem = round(Update/Insert, 2), rateByOther = round(Update/rateByCount, 2))
  studyLevel[is.na(studyLevel)] <- 0
  
  # Get the result col
  if (plotBy == "Count" && countBy == "Insert") resultCol <- "Insert"
  if (plotBy == "Count" && countBy == "Update") resultCol <- "Update"
  if (plotBy == "Count" && countBy == "Both") resultCol <- "Both"
  if (plotBy == "Rate" && rateBy == "Item") resultCol <- "rateByItem"
  if (plotBy == "Rate" && rateBy != "Item") resultCol <- "rateByOther"
  
  itemLevel$result <- itemLevel[[resultCol]]
  studyLine <- studyLevel[[resultCol]]
  
  # Annots and Shapes
  studyLevelAnnots <- list()
  studyLevelShapes <- list()
  if (plotBy == "Rate") {
    studyLevelAnnots <- list(showarrow = F, text = studyLine, x = 1, xref = "paper", y = studyLine, yshift = 10)
    studyLevelShapes <- list(type = "line", x0 = 0, x1 = 1, xref = "paper", y0 = studyLine, y1 = studyLine, line = list(color = "#ff9b00"))
  }
  
  # y-axis label
  ylabel <- ""
  if (plotBy == "Rate") {
    updtext <- "Updates"
    if (rateBy != "Item") {
      if ("CountryCode" %in% plotFor) ylabel <- paste0(updtext, " per Subject")
      if ("SiteCode" %in% plotFor) ylabel <- paste0(updtext, " per Subject")
      if ("EventName" %in% plotFor) ylabel <- paste0(updtext, " per Subject Event")
      if ("FormName" %in% plotFor) ylabel <- paste0(updtext, " per Subject Form")
    }
    else ylabel <- paste0(updtext, " per Item")
  }
  if (plotBy == "Count") {
    if (countBy == "Insert") ylabel <- "# of Inserts"
    if (countBy == "Update") ylabel <- "# of Updates"
    if (countBy == "Both") ylabel <- "# of Inserts and Updates"
  }
  
  # Plot title
  title <- ""
  if (plotBy == "Rate") {
    updtext <- "Data updates"
    if ("CountryCode" %in% plotFor) title <- paste0(updtext, " (by Country)")
    if ("SiteCode" %in% plotFor) title <- paste0(updtext, " (by Site)")
    if ("EventName" %in% plotFor) title <- paste0(updtext, " (by Event)")
    if ("FormName" %in% plotFor) title <- paste0(updtext, " (by Form)")
  }
  if (plotBy == "Count") {
    updtext <- "Data operations"
    if ("CountryCode" %in% plotFor) title <- paste0(updtext, " (by Country)")
    if ("SiteCode" %in% plotFor) title <- paste0(updtext, " (by Site)")
    if ("EventName" %in% plotFor) title <- paste0(updtext, " (by Event)")
    if ("FormName" %in% plotFor) title <- paste0(updtext, " (by Form)")
    if ("ItemId" %in% plotFor) title <- paste0(updtext, " (by top 20 Items)")
  }
  
  return(list(itemLevel, studyLevelAnnots, studyLevelShapes, ylabel, title))
}

#----------Filter that can be customized------------
plotBy <- "Count" # plotBy can be "Count" or "Rate"
# When plotBy == "Count", countBy can be "Insert", "Update" or "Both" and rateBy should be "" (empty)
# When plotBy == "Rate", rateBy can be "Subject" or "Item" and countBy should be "" (empty)
countBy <- "Insert"
rateBy <- ""
sortBy <- "Alphabetical" # sortBy can be "Descending" or "Alphabetical"

# * Render Rate of Data Change per Country ----
data <- auditData
plotFor <- c("CountryCode", "Country")

preparedData <- prepareAuditPlots(data, c("CountryCode", "Country"), plotBy, countBy, rateBy)
data <- preparedData[[1]]
annots <- preparedData[[2]]
shapes <- preparedData[[3]]
ylabel <- preparedData[[4]]
title <- preparedData[[5]]

# Sort the data
if (sortBy == "Alphabetical") {countryOrder <- sort(unique(data$Country))} else
  { countryOrder <- unlist(data %>% arrange(desc(result)) %>% distinct(Country), use.names = F) }
data$Country <- factor(data$Country, levels = countryOrder)
data <- data %>% arrange(Country)

pl_1 <- plot_ly(data, x = ~Country, y = ~result, type = 'bar', text = ~result, textposition = "outside", cliponaxis = FALSE, customdata = ~Country, hovertemplate = "%{customdata}<extra></extra>") %>%
  layout(
    title = paste(ylabel,"by",plotBy),
    annotations = annots, shapes = shapes,
    xaxis = list(tickangle = 45, title = ""),
    yaxis = list(title = "", ticklen = 4, tickcolor = "transparent"),
    margin = list(t = 50),
    bargap = 0.009,
    font = globalFont
  )

# * Render Rate of Data Change per Site ----
data <- auditData
plotFor <- c("SiteCode", "SiteName")

preparedData <- prepareAuditPlots(data, c("SiteCode", "SiteName"), plotBy, countBy, rateBy)
data <- preparedData[[1]]
annots <- preparedData[[2]]
shapes <- preparedData[[3]]
ylabel <- preparedData[[4]]
title <- preparedData[[5]]

# Sort the data
if (sortBy == "Alphabetical") siteOrder <- sort(unique(data$SiteCode)) else
  { siteOrder <- unlist(data %>% arrange(desc(result)) %>% distinct(SiteCode), use.names = F) }
data$SiteCode <- factor(data$SiteCode, levels = siteOrder)
data <- data %>% arrange(SiteCode)

pl_2 <- plot_ly(data, x = ~SiteCode, y = ~result, type = 'bar', text = ~result, textposition = "outside", cliponaxis = FALSE, customdata = ~SiteName, hovertemplate = "%{customdata}<extra></extra>") %>%
  layout(
    title = paste(ylabel,"by",plotBy),
    annotations = annots, shapes = shapes,
    xaxis = list(tickangle = 45, title = ""),
    yaxis = list(title = "", ticklen = 4, tickcolor = "transparent"),
    margin = list(t = 50),
    bargap = 0.009,
    font = globalFont
  )

# * Render Rate of Data Change per Event ----
data <- auditData
plotFor <- c("EventName")

preparedData <- prepareAuditPlots(data, c("EventName"), plotBy, countBy, rateBy)
data <- preparedData[[1]]
annots <- preparedData[[2]]
shapes <- preparedData[[3]]
ylabel <- preparedData[[4]]
title <- preparedData[[5]]

# Sort the data
if (sortBy == "Alphabetical") visitOrder <- sort(unique(data$EventName)) else
  {visitOrder <- unlist(data %>% arrange(desc(result)) %>% distinct(EventName), use.names = F)}
data$EventName <- factor(data$EventName, levels = visitOrder)
data <- data %>% arrange(EventName)

pl_3 <- plot_ly(data, x = ~EventName, y = ~result, type = 'bar', text = ~result, textposition = "outside", cliponaxis = FALSE, customdata = ~EventName, hovertemplate = "%{customdata}<extra></extra>") %>%
  layout(
    title = paste(ylabel,"by",plotBy),
    annotations = annots, shapes = shapes,
    xaxis = list(tickangle = 45, title = "", tickmode = "array", tickvals = visitOrder, ticktext = str_trunc(visitOrder, 34)),
    yaxis = list(title = "", ticklen = 4, tickcolor = "transparent"),
    margin = list(t = 50),
    bargap = 0.009,
    font = globalFont
  )

# * Render Rate of Data Change per Form ----
data <- auditData
plotFor <- c("FormName")

preparedData <- prepareAuditPlots(data, c("FormName"), plotBy, countBy, rateBy)
data <- preparedData[[1]]
annots <- preparedData[[2]]
shapes <- preparedData[[3]]
ylabel <- preparedData[[4]]
title <- preparedData[[5]]
# Sort the data 
if (sortBy == "Alphabetical") formOrder <- sort(unique(data$FormName)) else formOrder <- unlist(data %>% arrange(desc(result)) %>% distinct(FormName), use.names = F)
data$FormName <- factor(data$FormName, levels = formOrder)
data <- data %>% arrange(FormName)

pl_4 <- plot_ly(data, x = ~FormName, y = ~result, type = 'bar', text = ~result, textposition = "outside", cliponaxis = FALSE, customdata = ~FormName, hovertemplate = "%{customdata}<extra></extra>") %>% 
  layout(
    title = paste(ylabel,"by",plotBy),
    annotations = annots, shapes = shapes,
    xaxis = list(tickangle = 45, title = "", tickmode = "array", tickvals = formOrder, ticktext = str_trunc(formOrder, 34)),
    yaxis = list(title = "", ticklen = 4, tickcolor = "transparent"),
    margin = list(t = 50),
    bargap = 0.009,
    font = globalFont
  )

# * Render Rate of Data Change per Item ----
if (plotBy == "Count") {
  data <- auditData
  plotFor <- c("ItemId")
  
  data <- data %>% mutate(ItemId = paste0(FormId, ".", ItemId))
  preparedData <- prepareAuditPlots(data, c("ItemId"), plotBy, countBy, rateBy)
  data <- preparedData[[1]]
  annots <- preparedData[[2]]
  shapes <- preparedData[[3]]
  ylabel <- preparedData[[4]]
  title <- preparedData[[5]]
  
  # Get the top 20 items
  data <- data %>% arrange(desc(result)) %>% slice_head(n = 20)
  
  # Sort the data
  if (sortBy == "Alphabetical") itemOrder <- sort(unique(data$ItemId)) else itemOrder <- unlist(data %>% arrange(desc(result)) %>% distinct(ItemId), use.names = F)
  data$ItemId <- factor(data$ItemId, levels = itemOrder)
  data <- data %>% arrange(ItemId)
  
  pl_5 <- plot_ly(data, x = ~ItemId, y = ~result, type = 'bar', text = ~result, textposition = "outside", cliponaxis = FALSE, customdata = ~ItemId, hovertemplate = "%{customdata}<extra></extra>") %>%
    layout(
      title = paste(ylabel,"by",plotBy),
      annotations = annots, shapes = shapes,
      xaxis = list(tickangle = 45, title = ""),
      yaxis = list(title = "", ticklen = 4, tickcolor = "transparent"),
      margin = list(t = 50),
      bargap = 0.009,
      font = globalFont
    )
}

reportOutput <- list("Plot by Country" = list("plot" = pl_1),
                     "Plot by Site" = list("plot" = pl_2),
                     "Plot by Event" = list("plot" = pl_3),
                     "Plot by Form" = list("plot" = pl_4)
                     )
if(exists("pl_5")){
  reportOutput[["Plot by Item"]] <- list("plot" = pl_5)
}

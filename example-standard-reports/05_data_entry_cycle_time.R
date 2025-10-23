# ----------Data Entry Cycle Time----------

# Get data ----
output <- data.frame(Empty = "No Data")
tl <- edcData$TimeLapse
if (ncol(tl) == 0 || nrow(tl) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  missingACT <- FALSE
  if (!has_name(tl, "ActivityId")) missingACT <- TRUE
  # Filter only valid events
  visitOrder <- c()
  if ("StudyEventDef" %in% names(metadata)) {
    validVisits <- unlist(
      metadata$StudyEventDef %>% 
        group_by(Name) %>% 
        arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>% 
        filter(row_number() == 1) %>% 
        data.frame() %>% 
        filter(Type == "Scheduled" & toupper(Category) != "ADDEVENT" & toupper(Category) != "SUBJECT") %>% 
        select(Name),
      use.names = F)
    tl <- tl %>% filter(EventName %in% validVisits)
    visitOrder <- unlist(
      metadata$StudyEventRef %>%
        rename(EventId = StudyEventOID) %>% 
        filter(!is.na(OrderNumber)) %>% 
        inner_join(metadata$StudyEventDef %>% filter(Type == "Scheduled" & toupper(Category) != "ADDEVENT" & toupper(Category) != "SUBJECT") %>% select(MDVOID, EventId = OID, EventName = Name), by = c("MDVOID","EventId")) %>% 
        distinct(MDVOID, OrderNumber, EventId, EventName) %>% 
        group_by(EventName) %>% 
        arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
        filter(row_number() == 1) %>% 
        data.frame() %>% 
        arrange(as.numeric(OrderNumber)) %>% 
        select(EventName), 
      use.names = F)
    visitOrder <- visitOrder[visitOrder %in% tl$EventName]
    missingVisits <- setdiff(sort(unique(tl$EventName)), visitOrder)
    visitOrder <- c(visitOrder, missingVisits)
  }
  
  # Get Study Name
  tl$SiteCode <- as.character(tl$SiteCode)
  tl <- tl %>%
    mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
  
  if (missingACT) tl <- tl %>% mutate(ActivityId = "", ActivityName = "")
  
  # Form level ----
  formLevel <- tl %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, ActivityId, ActivityName, FormName, FormSeq, EventDate, InitiatedDate, LapseDays)
  formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq", "FormSeq"))
  if (!is.na(visitOrder)) {
    formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
    formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "Event", "Event Sequence", "Activity Id", "Activity Name", "Form", "Form Sequence", "Event Date", "Initiated Date", "Data Entry Cycle Time (days)"))
  if (missingACT) formLevel <- formLevel %>% select(-ActivityId, -ActivityName)
  widths <- rep(0, ncol(formLevel))
  widths[2] <- 105
  widths[5] <- 90
  if (missingACT) {
    formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7, 9:11))
  } else {
    formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7, 11:13))}
  
  # Event level ----
  eventLevel <- tl %>% group_by(StudyName, Country, SiteCode, SiteName, EventName, EventSeq) %>% summarize(LapseDays = round(mean(LapseDays, na.rm = T),1), FormCount = n())
  eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName", "EventSeq"))
  if (!is.na(visitOrder)) {
    eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
    eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site name", "Event", "Event Sequence", "Data Entry Cycle Time (days)", "# Forms"))
  widths <- rep(0, ncol(eventLevel))
  widths[2] <- 105
  eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6))
  
  # Subject level ----
  subjectLevel <- tl %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% summarize(LapseDays = round(mean(LapseDays, na.rm = T),1), FormCount = n())
  subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq"))
  subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "Data Entry Cycle Time (days)", "# Forms"))
  widths <- rep(0, ncol(subjectLevel))
  widths[2] <- 105
  widths[5] <- 90
  subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Site level ----
  siteLevel <- tl %>% group_by(StudyName, Country, SiteCode, SiteName) %>% summarize(LapseDays = round(mean(LapseDays, na.rm = T),1), FormCount = n())
  siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
  siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site name", "Data Entry Cycle Time (days)", "# Forms"))
  widths <- rep(0, ncol(siteLevel))
  widths[2] <- 105
  siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Country level ----
  countryLevel <- tl %>% group_by(StudyName, Country) %>% summarize(LapseDays = round(mean(LapseDays, na.rm = T),1), FormCount = n())
  countryLevel <- prepareDataForDisplay(countryLevel)
  countryLevel <- setLabel(countryLevel, list("Study", "Country", "Data Entry Cycle Time (days)", "# Forms"))
  widths <- rep(0, ncol(countryLevel))
  widths[2] <- 105
  countryLevelColumnDefs <- getColumnDefs(colwidths = widths)
  
  reportOutput <- list(
    "by Country" = list("data" = countryLevel, "columnDefs" = countryLevelColumnDefs),
    "by Site" = list("data" = siteLevel, "columnDefs" = siteLevelColumnDefs),
    "by Event" = list("data" = eventLevel, "columnDefs" = eventLevelColumnDefs),
    "by Subject" = list("data" = subjectLevel, "columnDefs" = subjectLevelColumnDefs),
    "by Form" = list("data" = formLevel, "columnDefs" = formLevelColumnDefs)
  )
}

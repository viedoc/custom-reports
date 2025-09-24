# ----------Pending Forms----------

# Get data ----
output <- data.frame(Empty = "No Data")
pf <- edcData$PendingForms
if (ncol(pf) == 0 || nrow(pf) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  # Get visit order
  visitOrder <- c()
  if ("StudyEventDef" %in% names(metadata)) {
    visitOrder <- unlist(
      metadata$StudyEventRef %>%
        rename(EventId = StudyEventOID) %>% 
        filter(!is.na(OrderNumber)) %>% 
        inner_join(metadata$StudyEventDef %>% select(MDVOID, EventId = OID, EventName = Name), by = c("MDVOID","EventId")) %>% 
        distinct(MDVOID, OrderNumber, EventName) %>% 
        group_by(EventName) %>% 
        arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
        filter(row_number() == 1) %>% 
        data.frame() %>% 
        arrange(as.numeric(OrderNumber)) %>% 
        select(EventName), 
      use.names = F)
    visitOrder <- visitOrder[visitOrder %in% pf$EventName]
    missingVisits <- setdiff(sort(unique(pf$EventName)), visitOrder)
    visitOrder <- c(visitOrder, missingVisits)
  }
  
  # Get Study Name
  pf$SiteCode <- as.character(pf$SiteCode)
  pf <- pf %>%
    mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
  
  pf <- pf %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, ActivityId, ActivityName, FormName, PendingSince) %>% filter(!is.na(PendingSince)) %>% mutate(PendingSince = substr(as.character(PendingSince), 1, 10))
  
  # Form level ----
  formLevel <- pf %>% mutate(DaysPending = difftime(Sys.Date(), PendingSince, units = "days"))
  formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% formLevel$EventName]
    formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
    formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "Event", "Event Sequence", "Activity Id", "Activity Name", "Form", "Pending since", "Days pending"))
  widths <- rep(0, ncol(formLevel))
  widths[2] <- 105
  widths[5] <- 90
  formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7, 11))
  
  # Subject level ----
  subjectLevel <- pf %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% summarize(FormCount = n(), PendingSince = min(PendingSince, na.rm = T), DaysPending = difftime(Sys.Date(), PendingSince, units = "days"))
  subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq"))
  subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "# Forms pending", "Pending since", "Days pending"))
  widths <- rep(0, ncol(subjectLevel))
  widths[2] <- 105
  widths[5] <- 90
  subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7))
  
  # Event level ----
  eventLevel <- pf %>% group_by(StudyName, Country, SiteCode, SiteName, EventName, EventSeq) %>% summarize(FormCount = n(), PendingSince = min(as.character(PendingSince), na.rm = T), DaysPending = difftime(Sys.Date(), PendingSince, units = "days"), SubjectCount = length(unique(interaction(SubjectSeq, SubjectId))))
  eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName", "EventSeq"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% eventLevel$EventName]
    eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
    eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site name", "Event", "Event Sequence", "# Forms pending", "Pending since", "Days pending", "# Subjects"))
  widths <- rep(0, ncol(eventLevel))
  widths[2] <- 105
  eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6, 8))
  
  # Site level ----
  siteLevel <- subjectLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% summarize(FormCount = sum(FormCount), PendingSince = min(as.character(PendingSince), na.rm = T), DaysPending = difftime(Sys.Date(), PendingSince, units = "days"), SubjectCount = n())
  siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
  siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site name", "# Forms pending", "Pending since", "Days pending", "# Subjects"))
  widths <- rep(0, ncol(siteLevel))
  widths[2] <- 105
  siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6))
  
  # Country level ----
  countryLevel <- siteLevel %>% group_by(StudyName, Country) %>% summarize(FormCount = sum(FormCount), PendingSince = min(as.character(PendingSince), na.rm = T), DaysPending = difftime(Sys.Date(), PendingSince, units = "days"), SiteCount = n(), SubjectCount = sum(SubjectCount))
  countryLevel <- prepareDataForDisplay(countryLevel)
  countryLevel <- setLabel(countryLevel, list("Study", "Country", "# Forms pending", "Pending since", "Days pending", "# Sites", "# Subjects"))
  widths <- rep(0, ncol(countryLevel))
  widths[2] <- 105
  countryLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(4))
  
  reportOutput <-  list(
    "by Country" = list(data = countryLevel, columnDefs = countryLevelColumnDefs),
    "by Site" = list(data = siteLevel, columnDefs = siteLevelColumnDefs),
    "by Event" = list(data = eventLevel,columnDefs = eventLevelColumnDefs),
    "by Subject" = list(data = subjectLevel,columnDefs = subjectLevelColumnDefs),
    "by Form" = list(data = formLevel, columnDefs = formLevelColumnDefs)
  )
  }

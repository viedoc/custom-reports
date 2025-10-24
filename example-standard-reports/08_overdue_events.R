# ----------Overdue Events----------

# Get data ----
output <- data.frame(Empty = "No Data")
ss <- edcData$SubjectStatus
ed <- edcData$EventDates
if (ncol(ss) == 0 || nrow(ss) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  # Get Visit order ----
  visitOrder <- c()
  if ("StudyEventDef" %in% names(metadata)) {
    validVisits <- unlist(
      metadata$StudyEventDef %>%
        group_by(Name) %>%
        arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
        filter(row_number() == 1) %>%
        data.frame() %>%
        filter(Type == "Scheduled" & toupper(Category) != "SUBJECT") %>%
        select(Name),
      use.names = F)
    ed <- ed %>% filter(EventName %in% validVisits)
    visitOrder <- metadata$StudyEventRef %>%
      rename(EventId = StudyEventOID) %>%
      filter(!is.na(OrderNumber)) %>%
      inner_join(metadata$StudyEventDef %>% filter(Type == "Scheduled" & toupper(Category) != "SUBJECT") %>% select(MDVOID, EventId = OID, EventName = Name), by = c("MDVOID","EventId")) %>%
      distinct(MDVOID, OrderNumber, EventId, EventName) %>%
      group_by(EventId) %>%
      arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
      filter(row_number() == 1) %>%
      data.frame() %>%
      group_by(EventName) %>%
      arrange(as.numeric(OrderNumber), .by_group = TRUE) %>%
      mutate(count = n(), seq = row_number()) %>%
      data.frame() %>%
      mutate(EventName = ifelse(count == 1, EventName, paste0(EventName,"_",seq))) %>%
      arrange(as.numeric(OrderNumber))
    ed <- ed %>% 
      left_join(visitOrder %>% select(EventId, NewEventName = EventName), by = "EventId") %>%
      mutate(
        EventName = coalesce(NewEventName, EventName),
      ) %>% 
      select(-EventId, -NewEventName)
    visitOrder <- visitOrder %>% 
      arrange(as.numeric(OrderNumber), EventName) %>% 
      distinct(EventName) %>% 
      unlist(use.names = F)
    visitOrder <- visitOrder[visitOrder %in% ed$EventName]
    missingVisits <- setdiff(sort(unique(ed$EventName)), visitOrder)
    visitOrder <- c(visitOrder, missingVisits)
  }
  
  # Get Study Name ----
  ed$SiteCode <- as.character(ed$SiteCode)
  ed <- ed %>%
    mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
  
  # Get Subject Status ----
  ss$SiteCode <- as.character(ss$SiteCode)
  ss <- ss %>%
    mutate(
      SubjectStatus = ifelse(
        !ScreenedState & !CompletedState & !WithdrawnState, "Candidate",
        ifelse(ScreenedState & !CompletedState & !WithdrawnState, "Ongoing",
               ifelse(CompletedState, "Completed",
                      ifelse(WithdrawnState, "Withdrawn", "")
               )
        )
      )
    ) %>%
    select(SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus)
  ssOrder <- c("Candidate", "Ongoing", "Completed", "Withdrawn")
  
  # Calculate the overdue in days
  dod <- substr(params$dateOfDownload, 1, 10)
  eventLevel <- ed %>% 
    left_join(ss, by = c("SiteCode", "SiteName", "SubjectSeq", "SubjectId")) %>% 
    filter(!is.na(EventWindowEndDate) & is.na(EventInitiatedDate) & is.na(EventPlannedDate) & !is.na(EventProposedDate)) %>%
    mutate(
      overdueSince = as.integer(difftime(dod, EventWindowEndDate, units = "days")),
      EventProposedDate = substr(EventProposedDate, 1, 10),
      EventWindowStartDate = substr(EventWindowStartDate, 1, 10),
      EventWindowEndDate = substr(EventWindowEndDate, 1, 10)
    ) %>% 
    filter(EventProposedDate <= dod) %>%
    select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus, EventName, EventRepeatKey, EventProposedDate, EventWindowStartDate, EventWindowEndDate, overdueSince)
  
  # Event (Overdue Events - past) ----
  eventLevelOverdue <- eventLevel %>% filter(overdueSince >= 0)
  eventLevelOverdue <- prepareDataForDisplay(eventLevelOverdue, c("SiteCode", "SiteName", "SubjectSeq", "EventRepeatKey"))
  ssOrder_ <- ssOrder[ssOrder %in% eventLevelOverdue$SubjectStatus]
  eventLevelOverdue$SubjectStatus <- factor(eventLevelOverdue$SubjectStatus, levels = ssOrder_)
  
  visitOrder_ <- visitOrder[visitOrder %in% eventLevelOverdue$EventName]
  eventLevelOverdue$EventName <- factor(eventLevelOverdue$EventName, levels = visitOrder_)
  eventLevelOverdue <- eventLevelOverdue %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, .by_group = TRUE)
  
  eventLevelOverdue <- setLabel(eventLevelOverdue, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Subject Status", "Event", "Event Sequence", "Event Proposed Date", "Event Window Start Date", "Event Window End Date", "Overdue since (days)"))
  widths <- rep(0, ncol(eventLevelOverdue))
  eventLevelOverdueColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 8, 9, 10, 11))
  
  # Event (Overdue Events - future) ----
  eventLevelOverdueFuture <- eventLevel %>% filter(overdueSince < 0) %>% mutate(overdueIn = -1 * overdueSince) %>% select(-overdueSince)
  eventLevelOverdueFuture <- prepareDataForDisplay(eventLevelOverdueFuture, c("SiteCode", "SiteName", "SubjectSeq", "EventRepeatKey"))
  ssOrder_ <- ssOrder[ssOrder %in% eventLevelOverdueFuture$SubjectStatus]
  eventLevelOverdueFuture$SubjectStatus <- factor(eventLevelOverdueFuture$SubjectStatus, levels = ssOrder_)
  
  visitOrder_ <- visitOrder[visitOrder %in% eventLevelOverdueFuture$EventName]
  eventLevelOverdueFuture$EventName <- factor(eventLevelOverdueFuture$EventName, levels = visitOrder_)
  eventLevelOverdueFuture <- eventLevelOverdueFuture %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, .by_group = TRUE)
  
  eventLevelOverdueFuture <- setLabel(eventLevelOverdueFuture, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Subject Status", "Event", "Event Sequence", "Event Proposed Date", "Event Window Start Date", "Event Window End Date", "Overdue in (days)"))
  widths <- rep(0, ncol(eventLevelOverdueFuture))
  eventLevelOverdueFutureColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 8, 9, 10, 11))
  
  # Subject level ----
  subjectLevel <- eventLevelOverdue %>%
    group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus) %>%
    summarise(numEventsOverdue = n()) %>% 
    data.frame()
  subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq"))
  ssOrder_ <- ssOrder[ssOrder %in% subjectLevel$SubjectStatus]
  subjectLevel$SubjectStatus <- factor(subjectLevel$SubjectStatus, levels = ssOrder_)
  subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Subject Status", "# of overdue events"))
  widths <- rep(0, ncol(subjectLevel))
  subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Site level ----
  siteLevel <- eventLevelOverdue %>% 
    group_by(StudyName, Country, SiteCode, SiteName) %>% 
    summarise(numEventsOverdue = n()) %>% 
    data.frame()
  siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
  siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site Name", "# of overdue events"))
  widths <- rep(0, ncol(siteLevel))
  siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Country level ----
  countryLevel <- eventLevelOverdue %>% 
    group_by(StudyName, Country) %>% 
    summarise(numEventsOverdue = n()) %>% 
    data.frame()
  countryLevel <- prepareDataForDisplay(countryLevel)
  countryLevel <- setLabel(countryLevel, list("Study", "Country", "# of overdue events"))
  widths <- rep(0, ncol(countryLevel))
  countryLevelColumnDefs <- getColumnDefs(colwidths = widths)
  
  reportOutput <- list(
    "by Country" = list("data" = countryLevel, "columnDefs" = countryLevelColumnDefs),
    "by Site" = list("data" = siteLevel, "columnDefs" = siteLevelColumnDefs),
    "by Subject" = list("data" = subjectLevel, "columnDefs" = subjectLevelColumnDefs),
    "by Event" = list("data" = eventLevelOverdue, "columnDefs" = eventLevelOverdueColumnDefs),
    "Past proposed date" = list("data" = eventLevelOverdueFuture, "columnDefs" = eventLevelOverdueFutureColumnDefs)
  )
}

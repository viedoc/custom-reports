# ----------Missing Data----------

# Get data ----
output <- data.frame(Empty = "No Data")
qry <- edcData$ProcessedQueries
ed <- edcData$EventDates
if (ncol(qry) == 0 || nrow(qry) == 0) {
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
    visitOrder <- visitOrder[visitOrder %in% qry$EventName]
    missingVisits <- setdiff(sort(unique(qry$EventName)), visitOrder)
    visitOrder <- c(visitOrder, missingVisits)
  }
  
  # Get all the unconfirmed and not-closed missing data
  qry <- qry %>% filter(QueryType == "Unconfirmed missing data" | QueryType == "Missing data")
  # Get Study Name
  qry$SiteCode <- as.character(qry$SiteCode)
  qry <- qry %>%
    mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
  
  # Item Level
  itemLevel <- qry %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, EventDate, ActivityId, ActivityName, FormName, FormSeq, ItemName, QueryType, QueryStatus, QueryResolutionHistory)
  itemLevel$QueryResolutionHistory <- sapply(as.character(itemLevel$QueryResolutionHistory), function(x) unlist(strsplit(x, "QueryResolved:"))[2])
  itemLevel <- prepareDataForDisplay(itemLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq", "FormSeq"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% itemLevel$EventName]
    itemLevel$EventName <- factor(itemLevel$EventName, levels = visitOrder)
    itemLevel <- itemLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  itemLevel <- setLabel(itemLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "Event", "Event Sequence", "Event Date", "Activity Id", "Activity Name", "Form", "Form Sequence", "Item", "Query Type", "Query Status", "Query Resolution History"))
  widths <- rep(0, ncol(itemLevel))
  widths[2] <- 105
  widths[5] <- 90
  itemLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7, 8, 12))
  
  # Form Level
  formLevel <- qry 
  if (nrow(ed) > 0) {
    # Get event's Initiated date for Form level MAX Days calculation
    ed <- ed %>% 
      select(SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq = EventRepeatKey, EventDate = EventInitiatedDate, InitiatedDate) %>% 
      mutate(EventDate = substr(EventDate, 1, 10), InitiatedDate = substr(InitiatedDate, 1, 10), EventSeq = as.character(EventSeq))
    formLevel <- formLevel %>% 
      left_join(ed) %>% 
      mutate(
        InitiatedDate = ifelse(is.na(InitiatedDate), EventDate, InitiatedDate),
        MAXDAYS = as.integer(difftime(as.character(params$dateOfDownload), InitiatedDate, units = "days"))
      ) %>% 
      mutate(
        MAXDAYS = ifelse(is.na(MAXDAYS) | QueryType != "Unconfirmed missing data", 0, MAXDAYS),
        InitiatedDate = ifelse(is.na(MAXDAYS) | QueryType != "Unconfirmed missing data", "", InitiatedDate)
      )
  } else {
    formLevel <- formLevel %>% mutate(MAXDAYS = NA, InitiatedDate = "")
  }
  formLevel <- formLevel %>%
    group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, EventDate, ActivityId, ActivityName, FormName, FormSeq, InitiatedDate, MAXDAYS, QueryType) %>%
    summarize(Freq = n()) %>%
    ungroup() %>%
    spread(QueryType, Freq)
  if (!has_name(formLevel, "Missing data")) formLevel[["Missing data"]] <- rep(0, nrow(formLevel))
  if (!has_name(formLevel, "Unconfirmed missing data")) formLevel[["Unconfirmed missing data"]] <- rep(0, nrow(formLevel))
  formLevel[["Missing data"]][is.na(formLevel[["Missing data"]])] <- 0
  formLevel[["Unconfirmed missing data"]][is.na(formLevel[["Unconfirmed missing data"]])] <- 0
  formLevel <- formLevel %>% rename(CONFMISS = `Missing data`, UNCONFMISS = `Unconfirmed missing data`) %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, EventDate, ActivityId, ActivityName, FormName, FormSeq, InitiatedDate, MAXDAYS, UNCONFMISS, CONFMISS)
  formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq", "FormSeq"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% formLevel$EventName]
    formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
    formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "Event", "Event Sequence", "Event Date", "Activity Id", "Activity Name", "Form", "Form Sequence", "Missing since", "Days missing", "# Unconfirmed <br>missing items", "# Confirmed <br>missing items"))
  widths <- rep(0, ncol(formLevel))
  widths[2] <- 105
  widths[5] <- 90
  formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7, 8, 12, 13))
  
  # Event Level
  eventLevel <- formLevel %>%
    group_by(StudyName, Country, SiteCode, SiteName, EventName, EventSeq) %>%
    summarize(FreqSubjects = length(unique(interaction(SubjectSeq, SubjectId))), FreqForms = n(), UNCONFMISS = sum(UNCONFMISS), CONFMISS = sum(CONFMISS))
  eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% eventLevel$EventName]
    eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
    eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site name", "Event", "Event Sequence", "# Subjects with <br>missing items", "# Forms with <br>missing items", "# Unconfirmed <br>missing items", "# Confirmed <br>missing items"))
  widths <- rep(0, ncol(eventLevel))
  widths[2] <- 105
  eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6))
  
  # Subject Level
  subjectLevel <- formLevel %>%
    group_by(StudyName, Country, SiteCode, SiteName,SubjectSeq, SubjectId) %>%
    summarize(FreqForms = n(), UNCONFMISS = sum(UNCONFMISS), CONFMISS = sum(CONFMISS))
  subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq"))
  subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site name", "Subject Seqeuence", "Subject", "# Forms with <br>missing items", "# Unconfirmed <br>missing items", "# Confirmed <br>missing items"))
  widths <- rep(0, ncol(subjectLevel))
  widths[2] <- 105
  widths[5] <- 90
  subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Site Level
  siteLevel <- subjectLevel %>%
    group_by(StudyName, Country, SiteCode, SiteName) %>%
    summarize(FreqSubjects = n(), FreqForms = sum(FreqForms), UNCONFMISS = sum(UNCONFMISS), CONFMISS = sum(CONFMISS))
  siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
  siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site name", "# Subjects with <br>missing items", "# Forms with <br>missing items", "# Unconfirmed <br>missing items", "# Confirmed <br>missing items"))
  widths <- rep(0, ncol(siteLevel))
  widths[2] <- 105
  siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Country Level
  countryLevel <- subjectLevel %>%
    group_by(StudyName, Country) %>%
    summarize(FreqSubjects = n(), FreqForms = sum(FreqForms), UNCONFMISS = sum(UNCONFMISS), CONFMISS = sum(CONFMISS))
  countryLevel <- prepareDataForDisplay(countryLevel)
  countryLevel <- setLabel(countryLevel, list("Study", "Country", "# Subjects with <br>missing items", "# Forms with <br>missing items", "# Unconfirmed <br>missing items", "# Confirmed <br>missing items"))
  widths <- rep(0, ncol(countryLevel))
  widths[2] <- 105
  countryLevelColumnDefs <- getColumnDefs(colwidths = widths)
  
  reportOutput <- list(
    "by Country" = list("data" = countryLevel, "columnDefs" = countryLevelColumnDefs),
    "by Site" = list("data" = siteLevel, "columnDefs" = siteLevelColumnDefs),
    "by Event" = list("data" = eventLevel, "columnDefs" = eventLevelColumnDefs),
    "by Subject" = list("data" = subjectLevel, "columnDefs" = subjectLevelColumnDefs),
    "by Form" = list("data" = formLevel, "columnDefs" = formLevelColumnDefs),
    "by Item" = list("data" = itemLevel, "columnDefs" = itemLevelColumnDefs)
  )
  }

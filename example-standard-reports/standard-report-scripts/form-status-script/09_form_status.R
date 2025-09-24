# ----------Form Status----------

# Get data ----
output <- data.frame(Empty = "No Data")
ss <- edcData$SubjectStatus
rs <- edcData$ReviewStatus
pf <- edcData$PendingForms
qry <- edcData$ProcessedQueries

if ((ncol(ss) == 0 || nrow(ss) == 0) || ((ncol(rs) == 0 || nrow(rs) == 0) && (ncol(pf) == 0 || nrow(pf) == 0))) {
  reportOutput <- list("data" = list("data" = output))
} else {
  # Prepare report data ----
  if (nrow(rs) > 0) {
    rs <- rs %>% 
      filter(ReviewedItem == "Form") %>% mutate(EventSeq = as.character(EventSeq))
    if (nrow(qry) > 0) {
      qry <- qry %>% 
        filter(QueryType =="Unconfirmed missing data" | QueryStatus == "Query Raised") %>% 
        select(Country, SiteName, SiteCode, SubjectSeq, SubjectId, EventSeq, EventId, EventName, ActivityId, ActivityName, FormName, FormSeq) %>%
        mutate(QueryStatus = "Query Raised", EventSeq = as.character(EventSeq)) %>% distinct()
      rs <- rs %>% left_join(qry, by =c("Country","SiteName", "SiteCode", "SubjectSeq", "SubjectId","EventSeq","EventId", "EventName", "ActivityId", "ActivityName", "FormName", "FormSeq"))
    }
    else {
      rs <- rs %>% mutate(QueryStatus = NA)
    }
    rs <- rs %>%  
      mutate(
        Initiated = "Yes",
        Completed = ifelse(is.na(SignBy) | SignBy != "N/A", ifelse(is.na(QueryStatus), "Yes", "No"), "N/A"),
        Signed = ifelse(Completed == "Yes", 
                        ifelse(!is.na(SignBy), "Yes", "No"),
                        ifelse(SignBy == "N/A", "N/A", ""))
      ) %>% 
      select(Country, SiteName, SiteCode, SubjectSeq, SubjectId, EventSeq, EventId, EventName, ActivityId, ActivityName, FormName, FormSeq, Initiated, Completed, Signed)
  }
  if(nrow(pf) > 0) {
    pf <- pf %>% 
      select(Country, SiteName, SiteCode, SubjectSeq, SubjectId, EventSeq, EventId, EventName, ActivityId, ActivityName, FormName) %>% 
      mutate(EventSeq = as.character(EventSeq), Initiated = "No", Completed = "", Signed = "", FormSeq = NA)
  }
  fs <- rbind(rs, pf) %>% mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
  
  # Get visit order ----
  visitOrder <- c()
  if (nrow(fs) > 0) {
    if ("StudyEventDef" %in% names(metadata)) {
      visitOrder <- metadata$StudyEventRef %>%
        rename(EventId = StudyEventOID) %>% 
        inner_join(metadata$StudyEventDef %>% select(MDVOID, EventId = OID, EventName = Name, Type), by = c("MDVOID","EventId")) %>% 
        mutate(OrderNumber = ifelse(!is.na(OrderNumber) & Type == "Scheduled", as.numeric(OrderNumber), max(as.numeric(OrderNumber), na.rm = T) + 1)) %>% 
        distinct(MDVOID, OrderNumber,EventId, EventName) %>% 
        group_by(EventId) %>% 
        arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
        filter(row_number() == 1) %>% 
        data.frame() %>% 
        group_by(EventName) %>%
        arrange(as.numeric(OrderNumber), .by_group = TRUE) %>%
        mutate(count = n(), seq = row_number()) %>%
        data.frame() %>%
        mutate(EventName = ifelse(count == 1, EventName, paste0(EventName,"_",seq))) %>%
        arrange(as.numeric(OrderNumber)) %>% 
        distinct(EventId, OrderNumber, EventName)
      fs <- fs %>% 
        left_join(visitOrder %>% select(EventId, NewEventName = EventName), by = "EventId") %>%
        mutate(
          EventName = coalesce(NewEventName, EventName),
        ) %>% 
        select(-EventId, -NewEventName)
      visitOrder <- visitOrder %>% 
        arrange(as.numeric(OrderNumber), EventName) %>% 
        distinct(EventName) %>% 
        unlist(use.names = F)
      visitOrder <- visitOrder[visitOrder %in% fs$EventName]
      missingVisits <- setdiff(sort(unique(fs$EventName)), visitOrder)
      visitOrder <- c(visitOrder, missingVisits)
    }
  }
  
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
    select(Country, SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus)
  ssOrder <- c("Candidate", "Ongoing", "Completed", "Withdrawn")
  
  # Form level ----
  formLevel <- fs %>% 
    left_join(ss, by = c("Country", "SiteCode", "SiteName", "SubjectSeq", "SubjectId")) %>% 
    select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus, EventName, EventSeq, ActivityId, ActivityName, FormName, FormSeq, Initiated, Completed, Signed)
  formLevel$SubjectStatus <- factor(formLevel$SubjectStatus, levels = ssOrder)
  formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq", "FormSeq"), retainFactor = c("EventName","SubjectStatus"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% formLevel$EventName]
    formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
    formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Subject Status", "Event", "Event Sequence", "Activity Id", "Activity Name", "Form", "Form Sequence", "Initiated", "Completed", "Signed"))
  widths <- rep(0, ncol(formLevel))
  formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 8, 12))
  
  # Event level ----
  eventLevel <- formLevel %>% 
    group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus, EventName, EventSeq) %>% 
    summarize(
      Triggered = n(),
      countInitiated = sum(Initiated == "Yes"),
      Pending = sum(Initiated == "No"),
      countCompleted = sum(Completed == "Yes"),
      savedWithIssues = sum(Completed == "No"),
      countSigned = sum(Signed == "Yes"),
      notSigned = sum(Signed == "No"),
      initiationProgress = round(countInitiated*100/Triggered, 2)
    ) %>% 
    data.frame()
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% eventLevel$EventName]
    eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
    eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  eventLevel$SubjectStatus <- factor(eventLevel$SubjectStatus, levels = ssOrder)
  eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq"), retainFactor = c("EventName","SubjectStatus"))
  eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Subject Status", "Event", "Event Sequence", "Triggered", "Initiated", "Pending","Completed", "Saved with issues", "Signed", "Not signed", "Form initiation progress (%)"))
  headerEvent <- list(
    firstLevel = c("Study", "Country", "Site Code", "Site Name", "Subject", "Subject Status", "Event","Event Sequence", "Triggered", rep("Triggered ",2), rep("Initiated",2), rep("Completed",2),"Form initiation progress (%)"),
    secondLevel = c("Initiated", "Pending", "Completed", "Saved with issues", "Signed", "Not signed")
  )
  widths <- rep(0, ncol(eventLevel))
  eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 8))
  
  # Subject level ----
  subjectLevel <- formLevel %>% 
    group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus) %>% 
    summarize(
      Triggered = n(),
      countInitiated = sum(Initiated == "Yes"),
      Pending = sum(Initiated == "No"),
      countCompleted = sum(Completed == "Yes"),
      savedWithIssues = sum(Completed == "No"),
      countSigned = sum(Signed == "Yes"),
      notSigned = sum(Signed == "No"),
      initiationProgress = round(countInitiated*100/Triggered, 2)
    ) %>% 
    data.frame()
  subjectLevel$SubjectStatus <- factor(subjectLevel$SubjectStatus, levels = ssOrder)
  subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq"), retainFactor = c("SubjectStatus"))
  subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Subject Status", "Triggered", "Initiated", "Pending","Completed", "Saved with issues", "Signed", "Not signed", "Form initiation progress (%)"))
  headerSubject <- list(
    firstLevel = c("Study", "Country", "Site Code", "Site Name", "Subject", "Subject Status", "Triggered", rep("Triggered ",2), rep("Initiated",2), rep("Completed",2),"Form initiation progress (%)"),
    secondLevel = c("Initiated", "Pending", "Completed", "Saved with issues", "Signed", "Not signed")
  )
  widths <- rep(0, ncol(subjectLevel))
  subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Site level ----
  siteLevel <- formLevel %>% 
    group_by(StudyName, Country, SiteCode, SiteName) %>% 
    summarize(
      Triggered = n(),
      countInitiated = sum(Initiated == "Yes"),
      Pending = sum(Initiated == "No"),
      countCompleted = sum(Completed == "Yes"),
      savedWithIssues = sum(Completed == "No"),
      countSigned = sum(Signed == "Yes"),
      notSigned = sum(Signed == "No"),
      initiationProgress = round(countInitiated*100/Triggered, 2)
    ) %>% 
    data.frame()
  siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
  siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site Name", "Triggered", "Initiated", "Pending", "Completed", "Saved with issues", "Signed", "Not signed", "Form initiation progress (%)"))
  headerSite <- list(
    firstLevel = c("Study", "Country", "Site Code", "Site Name", "Triggered", rep("Triggered ",2), rep("Initiated",2), rep("Completed",2),"Form initiation progress (%)"),
    secondLevel = c("Initiated", "Pending", "Completed", "Saved with issues", "Signed", "Not signed")
  )
  widths <- rep(0, ncol(siteLevel))
  siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
  # Country level ----
  countryLevel <- formLevel %>% 
    group_by(StudyName, Country) %>% 
    summarize(
      Triggered = n(),
      countInitiated = sum(Initiated == "Yes"),
      Pending = sum(Initiated == "No"),
      countCompleted = sum(Completed == "Yes"),
      savedWithIssues = sum(Completed == "No"),
      countSigned = sum(Signed == "Yes"),
      notSigned = sum(Signed == "No"),
      initiationProgress = round(countInitiated*100/Triggered, 2)
    ) %>% 
    data.frame()
  countryLevel <- prepareDataForDisplay(countryLevel)
  countryLevel <- setLabel(countryLevel, list("Study", "Country", "Triggered", "Initiated", "Pending","Completed", "Saved with issues", "Signed", "Not signed", "Form initiation progress (%)"))
  headerCountry <- list(
    firstLevel = c("Study", "Country", "Triggered", rep("Triggered ",2), rep("Initiated",2), rep("Completed",2), "Form initiation progress (%)"),
    secondLevel = c("Initiated", "Pending", "Completed", "Saved with issues", "Signed", "Not signed")
  )
  widths <- rep(0, ncol(countryLevel))
  countryLevelColumnDefs <- getColumnDefs(colwidths = widths)
  
  reportOutput <- list(
    "by Country" = list("data" = countryLevel, "columnDefs" = countryLevelColumnDefs, header = headerCountry),
    "by Site" = list("data" = siteLevel, "columnDefs" = siteLevelColumnDefs, header = headerSite),
    "by Subject" = list("data" = subjectLevel, "columnDefs" = subjectLevelColumnDefs, header = headerSubject),
    "by Event" = list("data" = eventLevel, "columnDefs" = eventLevelColumnDefs, header = headerEvent),
    "by Form" = list("data" = formLevel, "columnDefs" = formLevelColumnDefs)
  )
}

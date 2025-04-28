
qry <- edcData$ProcessedQueries
if (ncol(qry) == 0 || nrow(qry) == 0) {
  reportOutput <-(list("data" = list("data" = data.frame(NoData = "There is no query data available."))))
} else{
  
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
  
  # Get all the queries except missing data
  qry <- qry %>% filter(QueryType != "Unconfirmed missing data" & QueryType != "Missing data")
  if (nrow(qry) == 0){
    reportOutput <- (list("data" = list("data" = data.frame(NoData = "There is no query data available."))))
  } else{
    qry <- qry %>% mutate(QueryAge = replace_na(OpenQueryAge, 0) + replace_na(ResolvedQueryAge, 0),
                          StudyName = params$UserDetails$studyinfo$studyName,
                          QueryStatus = case_when(
                            QueryStatus == "Query Raised" ~ "Open",
                            QueryStatus == "Query Rejected" ~ "Closed",
                            QueryStatus == "Query Approved" ~ "Closed",
                            QueryStatus == "Query Closed" ~ "Closed",
                            QueryStatus == "Query Removed" ~ "Removed",
                            QueryStatus == "Query Resolved" ~ "Resolved",
                            T ~ "")
                          ) %>%
      select(StudyName, Country, SiteCode, SiteName, QueryStudySeqNo, SubjectId, EventName, EventSeq, ActivityId, ActivityName, FormName, FormSeq, ItemName, QueryType, QueryStatus, QueryText, QueryRaisedBy = UserName, QueryRaised, QueryResolution, TimeToResolution, TimeToApproval, TimeofQueryCycle, TimeToRemoval, QueryAge)
    qry <- prepareDataForDisplay(qry, c("SiteCode", "SiteName", "QueryStudySeqNo", "EventSeq", "FormSeq"))
    visitOrder <- visitOrder[visitOrder %in% qry$EventName]
    qry$EventName <- factor(qry$EventName, levels = visitOrder)
    qry <- qry %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
    qry <- setLabel(qry, list("Study", "Country", "Site Code", "Site name", "Query Sequence", "Subject", "Event", "Event Sequence", "Activity Id", "Activity Name", "Form", "Form Sequence", "Item", "Query Type", "Query Status", "Query Text", "Raised By", "Raised On", "History", "Open to Resolved Days", "Resolved to Closed Days", "Open to Closed Days", "Open to Removed Days", "Age of Query"))
    widths <- rep(0, ncol(qry))
    widths[2] <- 105
    widths[6] <- 90
    widths[12:13] <- 105
    columnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 5, 8, 12, 18))
    
    reportOutput <- (list("data" = list("data" = qry, "columnDefs" = columnDefs)))
  }
}

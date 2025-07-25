#----------Manual Queries----------

# Get data ----
output <- data.frame(Empty = "No Data")
crf <- edcData$Forms
qry <- edcData$ProcessedQueries
ss <- edcData$SubjectStatus
ed <- edcData$EventDates

if (ncol(qry) == 0 || nrow(qry) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  # Get count and average duration of queries for each subreport ----
  countManualQueries <- function(query, groupby_cols) {
    qryValue <- query %>%
      group_by(across(all_of(groupby_cols))) %>%
      summarise(
        totalQueries = n(),
        openQueries = sum(QueryStatus == "Query Raised"),
        resolvedQueries = sum(QueryStatus == "Query Resolved"),
        rejectedQueries = sum(QueryStatus == "Query Rejected"),
        approvedQueries = sum(QueryStatus == "Query Approved"),
        closedQueries = sum(QueryStatus == "Query Closed"),
        removedQueries = sum(QueryStatus == "Query Removed"),
        updatedQueries = sum(ClosedByDataEdit == "Yes", na.rm = T),
        qriesOpenGrt7 =  sum(!is.na(OpenQueryAge) & OpenQueryAge > 7 & !OpenQueryAge > 14),
        qriesOpenGrt14 =  sum(!is.na(OpenQueryAge) & OpenQueryAge > 14 & !OpenQueryAge > 21),
        qriesOpenGrt21 = sum(!is.na(OpenQueryAge) & OpenQueryAge > 21), 
        avgResolutionTime = round(mean(TimeToResolution, na.rm = T), 2),
        avgApprovalTime = round(mean(TimeToApproval, na.rm = T), 2),
        .groups = "drop"
      )
    return(qryValue)
  }
  # Get visit order ----
  visitOrder <- c()
  if ("StudyEventDef" %in% names(metadata)) {
    eventNames <- metadata$StudyEventRef %>%
      rename(EventId = StudyEventOID) %>% 
      inner_join(metadata$StudyEventDef %>% select(MDVOID, EventId = OID, EventName = Name), by = c("MDVOID", "EventId")) %>% 
      distinct(MDVOID, OrderNumber, EventId, EventName) %>% 
      group_by(EventId) %>% 
      arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
      filter(row_number() == 1) %>% 
      data.frame() %>% 
      arrange(as.numeric(OrderNumber))
    visitOrder <- eventNames %>% filter(!is.na(OrderNumber))
    ed <- ed %>%
      left_join(visitOrder %>% select(EventId, NewEventName = EventName), by = "EventId") %>%
      mutate(
        EventName = coalesce(NewEventName, EventName),
      ) %>% 
      select(-NewEventName)
    visitOrder <- visitOrder %>% select(EventName) %>% unlist(use.names = FALSE)
    visitOrder <- visitOrder[visitOrder %in% qry$EventName]
    missingVisits <- setdiff(sort(unique(qry$EventName)), visitOrder)
    visitOrder <- c(visitOrder, missingVisits) %>% unique
  }
  
  # Get all the Manual queries ----
  manualQry <- qry %>% filter((QueryType == "Manual") & !grepl("^Prequery", QueryStatus))  
  if (nrow(manualQry) == 0) reportOutput <- list("data" = list("data" = output))
  else {
    # Get Study Name ----
    manualQry$SiteCode <- as.character(manualQry$SiteCode)
    manualQry <- manualQry %>%
      mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
    ed <- ed %>%
      filter(!is.na(EventInitiatedDate)) %>%
      select(Country, SiteName, SiteCode, SubjectId, EventSeq = EventRepeatKey, EventId) %>%
      mutate(StudyName = params$UserDetails$studyinfo$studyName[1], FormId = NA, FormSeq = NA, Total_filled = 1)
    ss <- ss %>%
      mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
    
    # Get the number of entered items in the CRF ----
    edcRecords <- getCRFitems(crf, params)
    edcRecords <- rbind(edcRecords, ed) %>% left_join(eventNames %>% select(EventId, EventName), by ="EventId")
    
    manualQry <- manualQry %>%
      select(-EventName) %>%
      left_join(eventNames %>% select(EventId, EventName), by ="EventId") #To get latest EventName
    
    # Form Level ----
    formDetails <- manualQry %>%
      select(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, SubjectId, FormId, FormName, FormSeq) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName", "EventSeq", "SubjectId", "FormId", "FormSeq")) %>%
      group_by(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, SubjectId, FormId, FormName, FormSeq) %>%
      summarise(TotalValues = sum(Total_filled)) # To calculate number of entered items in all the Forms
    
    formLevel <- countManualQueries(manualQry, c('StudyName', 'Country', 'SiteCode', 'SiteName', 'EventName', 'EventSeq', 'SubjectId', 'FormId', 'FormName', 'FormSeq')) %>%
      data.frame() %>%
      mutate(
        processedQries = rowSums(across(c(resolvedQueries, rejectedQueries, approvedQueries, closedQueries))),
        updatesRatio = ifelse(processedQries != 0, round(updatedQueries * 100  / processedQries, 2), 0),
        avgResolutionTime = ifelse(is.nan(avgResolutionTime), NA, avgResolutionTime),
        avgApprovalTime = ifelse(is.nan(avgApprovalTime), NA, avgApprovalTime)
      ) %>%
      left_join(formDetails, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName", "EventSeq", "SubjectId", "FormId", "FormName", "FormSeq")) %>% # To get the TotalValues column
      mutate(
        QueryRatio = ifelse(!is.na(TotalValues), round(totalQueries * 100 / TotalValues, 2), 0),
        FormName = as.character(FormName)
      )
    formLevel[is.na(formLevel$FormName), "FormName"] <- "Event Date"
    formLevel$QueryRatio <- gsub("NA", "0", formLevel$QueryRatio)
    
    formLevel <- formLevel %>% select(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, SubjectId, FormName, FormSeq, totalQueries, openQueries, resolvedQueries, rejectedQueries, approvedQueries, closedQueries, removedQueries, updatedQueries, updatesRatio, QueryRatio, qriesOpenGrt7, qriesOpenGrt14, qriesOpenGrt21, avgResolutionTime, avgApprovalTime)
    formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "FormSeq"))
    if (!is.na(visitOrder)) {
      visitOrder <- visitOrder[visitOrder %in% formLevel$EventName]
      formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
      formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
    }
    formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site Name", "Event", "Event Sequence", "Subject", "Form", "Form Sequence", "Total", "# of Manual Queries (Raised)", "# of Manual Queries (Resolved)", "# of Manual Queries (Rejected)", "# of Manual Queries (Approved)", "# of Manual Queries (Closed)", "# of Manual Queries (Removed)", "Resulting in Data Changes", "Updates / Query %", "Queries / Item %", "# of Queries Open > 7 days", "# of Queries Open > 14 days", "# of Queries Open > 21 days", "Average Time to Resolution (days)", "Average Time to Approval (days)"))
    headerForm <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Event", "Event Sequence", "Subject", "Form", "Form Sequence", "Total", rep("# of Manual Queries", 6), "Resulting in Data Changes", rep("Ratio (%)", 2), rep("# of Queries Open", 3), rep("Average time to (days)", 2)),
      secondLevel = c("Raised", "Resolved", "Rejected", "Approved", "Closed", "Removed", "Updates / Query", "Queries / Item", "> 7 days", "> 14 days", "> 21 days", "Resolution", "Approval")
    )
    widths <- rep(0, ncol(formLevel))
    widths[2] <- 105
    widths[7] <- 90
    formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6, 9:24))
    
    # Subject Level ----
    subjectDetails <- manualQry %>%
      select(StudyName, Country, SiteCode, SiteName, SubjectId) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName", "SubjectId")) %>%
      group_by(StudyName, Country, SiteCode, SiteName, SubjectId) %>%
      summarise(TotalValues = sum(Total_filled)) # To calculate number of entered items in all the Forms for respective subjects
    
    subjectLevel <- countManualQueries(manualQry, c('StudyName', 'Country', 'SiteCode', 'SiteName', 'SubjectId')) %>%  
      data.frame() %>%
      mutate(
        processedQries = rowSums(across(c(resolvedQueries, rejectedQueries, approvedQueries, closedQueries))),
        updatesRatio = ifelse(processedQries != 0, round(updatedQueries * 100  / processedQries, 2), 0),
        avgResolutionTime = ifelse(is.nan(avgResolutionTime), NA, avgResolutionTime),
        avgApprovalTime = ifelse(is.nan(avgApprovalTime), NA, avgApprovalTime)
      ) %>%
      left_join(subjectDetails, by = c("StudyName", "Country", "SiteCode", "SiteName", "SubjectId")) %>% # To get the TotalValues column
      mutate(QueryRatio = ifelse(!is.na(TotalValues), round(totalQueries * 100 / TotalValues, 2), 0))
    subjectLevel$QueryRatio <- gsub("NA", "0", subjectLevel$QueryRatio)
    
    subjectLevel <- subjectLevel %>% select(StudyName, Country, SiteCode, SiteName, SubjectId, totalQueries, openQueries, resolvedQueries, rejectedQueries, approvedQueries, closedQueries, removedQueries, updatedQueries, updatesRatio, QueryRatio, qriesOpenGrt7, qriesOpenGrt14, qriesOpenGrt21, avgResolutionTime, avgApprovalTime)
    subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectId"))
    subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site Name", "Subject", "Total", "# of Manual Queries (Raised)", "# of Manual Queries (Resolved)", "# of Manual Queries (Rejected)", "# of Manual Queries (Approved)", "# of Manual Queries (Closed)", "# of Manual Queries (Removed)", "Resulting in Data Changes", "Updates / Query %", "Queries / Item %", "# of Queries Open > 7 days", "# of Queries Open > 14 days", "# of Queries Open > 21 days", "Average Time to Resolution (days)", "Average Time to Approval (days)"))
    headerSubject <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Subject", "Total", rep("# of Manual Queries", 6), "Resulting in Data Changes", rep("Ratio (%)", 2), rep("# of Queries Open", 3), rep("Average time to (days)", 2)),
      secondLevel = c("Raised", "Resolved", "Rejected", "Approved", "Closed", "Removed", "Updates / Query", "Queries / Item", "> 7 days", "> 14 days", "> 21 days", "Resolution", "Approval")
    )
    widths <- rep(0, ncol(subjectLevel))
    widths[2] <- 105
    widths[5] <- 90
    subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:20))
    
    # Event Level ----
    eventDetails <- manualQry %>%
      select(StudyName, Country, SiteCode, SiteName, EventName) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName")) %>%
      group_by(StudyName, Country, SiteCode, SiteName, EventName) %>%
      summarise(TotalValues = sum(Total_filled)) # To calculate number of entered items in all the Forms in respective event
    
    eventLevel <- countManualQueries(manualQry, c('StudyName', 'Country', 'SiteCode', 'SiteName', 'EventName')) %>%
      data.frame() %>%
      mutate(
        processedQries = rowSums(across(c(resolvedQueries, rejectedQueries, approvedQueries, closedQueries))),
        updatesRatio = ifelse(processedQries != 0, round(updatedQueries * 100  / processedQries, 2), 0),
        avgResolutionTime = ifelse(is.nan(avgResolutionTime), NA, avgResolutionTime),
        avgApprovalTime = ifelse(is.nan(avgApprovalTime), NA, avgApprovalTime)
      ) %>%
      left_join(eventDetails, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName")) %>% # To get the TotalValues column
      mutate(QueryRatio = ifelse(!is.na(TotalValues), round(totalQueries * 100 / TotalValues, 2), 0))
    eventLevel$QueryRatio <- gsub("NA", "0", eventLevel$QueryRatio)
    
    eventLevel <- eventLevel %>% select(StudyName, Country, SiteCode, SiteName, EventName, totalQueries, openQueries, resolvedQueries, rejectedQueries, approvedQueries, closedQueries, removedQueries, updatedQueries, updatesRatio, QueryRatio, qriesOpenGrt7, qriesOpenGrt14, qriesOpenGrt21, avgResolutionTime, avgApprovalTime)
    eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName"))
    if (!is.na(visitOrder)) {
      visitOrder <- visitOrder[visitOrder %in% eventLevel$EventName]
      eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
      eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, .by_group = TRUE)
    }
    eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site Name", "Event", "Total", "# of Manual Queries (Raised)", "# of Manual Queries (Resolved)", "# of Manual Queries (Rejected)", "# of Manual Queries (Approved)", "# of Manual Queries (Closed)", "# of Manual Queries (Removed)", "Resulting in Data Changes", "Updates / Query %", "Queries / Item %", "# of Queries Open > 7 days", "# of Queries Open > 14 days", "# of Queries Open > 21 days", "Average Time to Resolution (days)", "Average Time to Approval (days)"))
    headerEvent <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Event", "Total", rep("# of Manual Queries", 6), "Resulting in Data Changes", rep("Ratio (%)", 2), rep("# of Queries Open", 3), rep("Average time to (days)", 2)),
      secondLevel = c("Raised", "Resolved", "Rejected", "Approved", "Closed", "Removed", "Updates / Query", "Queries / Item", "> 7 days", "> 14 days", "> 21 days", "Resolution", "Approval")
    )
    widths <- rep(0, ncol(eventLevel))
    widths[2] <- 105
    eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:20))
    
    # Site Level ----
    siteNames <- ss %>% group_by(StudyName, Country, SiteCode, SiteName) %>% summarize(SubjectCount = n()) %>% data.frame()
    siteDetails <- manualQry %>%
      select(StudyName, Country, SiteCode, SiteName) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName")) %>%
      group_by(StudyName, Country, SiteCode, SiteName) %>%
      summarise(TotalValues = sum(Total_filled)) %>% # To calculate number of entered items in all the Forms for respective sites
      left_join(siteNames, by = c("StudyName", "Country", "SiteCode", "SiteName")) # To get the number of subjects in the site
    
    siteLevel <- countManualQueries(manualQry, c('StudyName', 'Country', 'SiteCode', 'SiteName')) %>% 
      data.frame() %>%
      mutate(
        processedQries = rowSums(across(c(resolvedQueries, rejectedQueries, approvedQueries, closedQueries))),
        updatesRatio = ifelse(processedQries != 0, round(updatedQueries * 100  / processedQries, 2), 0),
        avgResolutionTime = ifelse(is.nan(avgResolutionTime), NA, avgResolutionTime),
        avgApprovalTime = ifelse(is.nan(avgApprovalTime), NA, avgApprovalTime)
      )
    siteLevel <- siteLevel %>%
      left_join(siteDetails, by = c("StudyName", "Country", "SiteCode", "SiteName")) %>% # To get the TotalValues column
      mutate(
        QueryRatio = ifelse(!is.na(TotalValues), round(totalQueries * 100 / TotalValues, 2), 0),
        percentTrial = round(totalQueries * 100 / sum(totalQueries), 2),
        avgQriesperSubject = round(totalQueries / SubjectCount, 2)
      ) %>%
      group_by(StudyName, Country) %>%
      mutate(percentCountry = round(totalQueries * 100 / sum(totalQueries), 2),
             .groups= "drop") %>%
      data.frame()
    siteLevel$QueryRatio <- gsub("NA", "0", siteLevel$QueryRatio)
    
    siteLevel <- siteLevel %>% select(StudyName, Country, SiteCode, SiteName, totalQueries, openQueries, resolvedQueries, rejectedQueries, approvedQueries, closedQueries, removedQueries, updatedQueries, updatesRatio, QueryRatio, qriesOpenGrt7, qriesOpenGrt14, qriesOpenGrt21, avgResolutionTime, avgApprovalTime, SubjectCount, avgQriesperSubject, percentTrial, percentCountry)
    siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
    siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site Name", "Total", "# of Manual Queries (Raised)", "# of Manual Queries (Resolved)", "# of Manual Queries (Rejected)", "# of Manual Queries (Approved)", "# of Manual Queries (Closed)", "# of Manual Queries (Removed)", "Resulting in Data Changes", "Updates / Query %", "Queries / Item %","# of Queries Open > 7 days", "# of Queries Open > 14 days", "# of Queries Open > 21 days", "Average Time to Resolution (days)", "Average Time to Approval (days)", "Number of Subjects", "Queries / Subject", "% of Queries in Trial", "% of Queries in Country"))
    headerSite <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Total", rep("# of Manual Queries", 6), "Resulting in Data Changes", rep("Ratio (%)", 2), rep("# of Queries Open", 3), rep("Average time to (days)", 2), "Number of Subjects", "Queries / Subject", "% of Queries in Trial", "% of Queries in Country"),
      secondLevel = c("Raised", "Resolved", "Rejected", "Approved", "Closed", "Removed", "Updates / Query", "Queries / Item", "> 7 days", "> 14 days", "> 21 days", "Resolution", "Approval")
    )
    widths <- rep(0, ncol(siteLevel))
    widths[2] <- 105
    siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 5:23))
    
    # Country Level ----
    countryNames <- ss %>% group_by(StudyName, Country) %>% summarize(SubjectCount = n()) %>% data.frame()
    countryDetails <- manualQry %>%
      select(StudyName, Country) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country")) %>%
      group_by(StudyName, Country) %>%
      summarise(TotalValues = sum(Total_filled)) %>% # To calculate number of entered items in all the Forms in respective country
      left_join(countryNames, by = c("StudyName", "Country")) # To get the number of subjects in the country
    
    countryLevel <- countManualQueries(manualQry, c('StudyName', 'Country')) %>% 
      data.frame() %>%
      mutate(
        processedQries = rowSums(across(c(resolvedQueries, rejectedQueries, approvedQueries, closedQueries))),
        updatesRatio = ifelse(processedQries != 0, round(updatedQueries * 100  / processedQries, 2), 0),
        avgResolutionTime = ifelse(is.nan(avgResolutionTime), NA, avgResolutionTime),
        avgApprovalTime = ifelse(is.nan(avgApprovalTime), NA, avgApprovalTime)
      ) %>%
      left_join(countryDetails, by = c("StudyName", "Country")) %>% # To get the TotalValues column and subject count
      mutate(
        QueryRatio = ifelse(!is.na(TotalValues), round(totalQueries * 100 / TotalValues, 2), 0),
        percentTrial = round(totalQueries * 100 / sum(totalQueries), 2),
        avgQriesperSubject = round(totalQueries / SubjectCount, 2)
      )
    countryLevel$QueryRatio <- gsub("NA", "0", countryLevel$QueryRatio)
    
    countryLevel <- countryLevel %>% select(StudyName, Country, totalQueries, openQueries, resolvedQueries, rejectedQueries, approvedQueries, closedQueries, removedQueries, updatedQueries, updatesRatio, QueryRatio, qriesOpenGrt7, qriesOpenGrt14, qriesOpenGrt21, avgResolutionTime, avgApprovalTime, SubjectCount, avgQriesperSubject, percentTrial)
    countryLevel <- prepareDataForDisplay(countryLevel)
    countryLevel <- setLabel(countryLevel, list("Study", "Country", "Total", "# of Manual Queries (Raised)", "# of Manual Queries (Resolved)", "# of Manual Queries (Rejected)", "# of Manual Queries (Approved)", "# of Manual Queries (Closed)", "# of Manual Queries (Removed)", "Resulting in Data Changes", "Updates / Query %", "Queries / Item %", "# of Queries Open > 7 days", "# of Queries Open > 14 days", "# of Queries Open > 21 days", "Average Time to Resolution (days)", "Average Time to Approval (days)", "Number of Subjects", "Queries / Subject", "% of Queries in Trial"))
    headerCountry <- list(
      firstLevel = c("Study", "Country", "Total", rep("# of Manual Queries", 6), "Resulting in Data Changes", rep("Ratio (%)", 2), rep("# of Queries Open", 3), rep("Average time to (days)", 2), "Number of Subjects", "Queries / Subject", "% of Queries in Trial"),
      secondLevel = c("Raised", "Resolved", "Rejected", "Approved", "Closed", "Removed", "Updates / Query", "Queries / Item", "> 7 days", "> 14 days", "> 21 days", "Resolution", "Approval")
    )
    widths <- rep(0, ncol(countryLevel))
    widths[2] <- 105
    countryLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3:20))
    
    # Most Manually Queried Items ----
    mostManualQueried <- manualQry %>%
      select(StudyName, FormId, FormName, ItemId, ItemName, ClosedByDataEdit, QueryStatus) %>%
      group_by(StudyName, FormId, FormName, ItemId, ItemName) %>%
      summarise(
        totalQueries = n(),
        updatedQueries = sum(ClosedByDataEdit == "Yes", na.rm = T),
        openQueries = sum(QueryStatus == "Query Raised"),
        .groups = "drop"
      ) %>%
      mutate(FormName = as.character(FormName))
    mostManualQueried[is.na(mostManualQueried$FormName), "FormName"] <- "Event Date"
    mostManualQueried <- mostManualQueried %>%
      select(StudyName, FormId, FormName, ItemId, ItemName, totalQueries, openQueries, updatedQueries) %>%
      arrange(desc(totalQueries))
    mostManualQueried <- prepareDataForDisplay(mostManualQueried)
    mostManualQueried <- setLabel(mostManualQueried, list("Study", "FormId", "Form", "ItemId", "Item", "Total # of Raised Queries", "# of Open Queries", "# of Queries Resulting in Data Change"))
    widths <- rep(0, ncol(mostManualQueried))
    mostManualQueriedColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(6:8))
    
    reportOutput <- list(
      "by Country" = list("data" = countryLevel, header = headerCountry, "columnDefs" = countryLevelColumnDefs),
      "by Site" = list("data" = siteLevel, header = headerSite, "columnDefs" = siteLevelColumnDefs),
      "by Event" = list("data" = eventLevel, header = headerEvent, "columnDefs" = eventLevelColumnDefs),
      "by Subject" = list("data" = subjectLevel, header = headerSubject, "columnDefs" = subjectLevelColumnDefs),
      "by Form" = list("data" = formLevel, header = headerForm, "columnDefs" = formLevelColumnDefs),
      "Most Manually Queried Items" = list("data" = mostManualQueried, "columnDefs" = mostManualQueriedColumnDefs)
    )
  }
  }
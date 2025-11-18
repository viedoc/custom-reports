#---------- Pre-Queries ----------

# Get data ----
output <- data.frame(Empty = "No Data")
crf <- edcData$Forms
qry <- edcData$ProcessedQueries
ss <- edcData$SubjectStatus
ed <- edcData$EventDates

if (ncol(qry) == 0 || nrow(qry) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  # Get count and average duration of pre-queries for each subreport ----
  countPreQueries <- function(prequery, groupby_cols){
    prequeriesValue <- prequery %>%
      group_by(across(all_of(groupby_cols))) %>%
      summarise(
        totalPreqries = n(),
        openPreqries = sum(QueryStatus == "Prequery Raised"),
        removedPreqries = sum(QueryStatus == "Prequery Removed"),
        rejectedPreqries = sum(QueryStatus == "Prequery Rejected"),
        promotedPreqries = sum(QueryStatus == "Prequery Promoted"),
        releasedPreqries = sum(str_detect(QueryStatus, "^Query")),
        modifiedPreqries = sum(TextModified == TRUE),
        modifiedRatio = ifelse(!is.na(totalPreqries), round(modifiedPreqries * 100 / totalPreqries, 2), 0),
        releaseRatio = ifelse(!is.na(totalPreqries), round(releasedPreqries * 100 / totalPreqries, 2), 0),
        updatedPreqries = sum(ClosedByDataEdit == "Yes", na.rm = T),
        processedPreqries = sum(QueryStatus %in% c("Prequery Rejected", "Query Resolved", "Query Approved", "Query Rejected", "Query Closed")),
        updatesRatio = ifelse(processedPreqries != 0, round(updatedPreqries * 100  / processedPreqries, 2), 0),
        notReleasedGrt7 = sum(!is.na(PrequeryAge) & PrequeryAge > 7 & !PrequeryAge > 14),
        notReleasedGrt14 = sum(!is.na(PrequeryAge) & PrequeryAge > 14 & !PrequeryAge > 21),
        notReleasedGrt21 = sum(!is.na(PrequeryAge) & PrequeryAge > 21),
        avgReleaseTime = round(mean(TimeToRelease, na.rm = T ),2),
        .groups = "drop"
      )
    return(prequeriesValue)
  }
  
  # Get Visit order ----
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
  
  # Get all the prequeries ----
  preqry <- qry %>% filter(QueryType != "Unconfirmed missing data" & QueryType != "Missing data") %>%
    filter(!is.na(PrequeryRaised) | PrequeryRaised != "") 
  if (nrow(preqry) == 0)   reportOutput <- list("data" = list("data" = output))
  else {
    # Get Study Name ----
    preqry$SiteCode <- as.character(preqry$SiteCode)
    preqry <- preqry %>%
      mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
    ed <- ed %>%
      filter(!is.na(EventInitiatedDate)) %>%
      select(Country, SiteName, SiteCode, SubjectSeq, SubjectId, EventSeq = EventRepeatKey, EventId) %>%
      mutate(StudyName = params$UserDetails$studyinfo$studyName[1], FormId = NA, FormSeq = NA, Total_filled = 1)
    ss <- ss %>%
      mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
    
    preqry <- preqry %>%
      mutate(QueryText = as.character(QueryText),
             PrequeryText = as.character(PrequeryText),
             TextModified = ifelse(!is.na(QueryRaised) & QueryRaised != "", QueryText != PrequeryText, FALSE))
    
    # Get the number of entered items in the CRF ----
    edcRecords <- getCRFitems(crf, params)
    edcRecords <- rbind(edcRecords, ed) %>% left_join(eventNames %>% select(EventId, EventName), by ="EventId")
    
    preqry <- preqry %>%
      select(-EventName) %>%
      left_join(eventNames %>% select(EventId, EventName), by ="EventId") #To get latest EventName
    
    # Form Level ----
    formDetails <- preqry %>%
      select(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, SubjectSeq, SubjectId, FormId, FormName, FormSeq) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName", "EventSeq", "SubjectSeq", "SubjectId", "FormId", "FormSeq")) %>%
      group_by(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, SubjectSeq, SubjectId, FormId, FormName, FormSeq) %>%
      summarise(TotalValues = sum(Total_filled)) # To calculate number of entered items in all the Forms
    
    formLevel <- countPreQueries(preqry, c('StudyName', 'Country', 'SiteCode', 'SiteName', 'EventName', 'EventSeq', 'SubjectSeq', 'SubjectId', 'FormId', 'FormName', 'FormSeq')) %>%
      data.frame() %>%
      mutate(avgReleaseTime = ifelse(is.nan(avgReleaseTime), NA, avgReleaseTime)) %>% 
      left_join(formDetails, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName", "EventSeq", "SubjectSeq", "SubjectId", "FormId", "FormName", "FormSeq")) %>% # To get the TotalValues column
      mutate(
        PrequeryRatio = ifelse(!is.na(TotalValues), round(totalPreqries * 100 / TotalValues, 2), 0),
        FormName = as.character(FormName)
      )
    formLevel[is.na(formLevel$FormName), "FormName"] <- "Event Date"
    formLevel$PrequeryRatio <- gsub("NA", "0", formLevel$PrequeryRatio)
    
    formLevel <- formLevel %>% select(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, SubjectSeq, SubjectId, FormName, FormSeq, totalPreqries, openPreqries, rejectedPreqries, promotedPreqries, releasedPreqries, removedPreqries, updatedPreqries, updatesRatio, releaseRatio, modifiedRatio, PrequeryRatio, notReleasedGrt7, notReleasedGrt14, notReleasedGrt21, avgReleaseTime)
    formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "EventSeq", "SubjectSeq", "FormSeq"))
    if (!is.na(visitOrder)) {
      visitOrder <- visitOrder[visitOrder %in% formLevel$EventName]
      formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
      formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
    }
    formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site Name", "Event", "Event Sequence", "Subject Sequence", "Subject", "Form", "Form Sequence",  "Total",  "# of Pre-queries (Raised)", "# of Pre-queries (Rejected)", "# of Pre-queries (Promoted)", "# of Pre-queries (Released)", "# of Pre-queries (Removed)", "Resulting in Data Changes", "Updates / Pre-query %", "Released / Pre-query %", "Modification / Pre-query %", "Pre-queries / Item %", "# of Pre-queries not Released > 7 days", "# of Pre-queries not Released > 14 days", "# of Pre-queries not Released > 21 days", "Average Time to Release (days)"))
    headerForm <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Event", "Event Sequence", "Subject Sequence", "Subject", "Form", "Form Sequence", "Total", rep("# of Pre-queries", 5), "Resulting in Data Changes", rep("Ratio (%)", 4), rep("# of Pre-queries not Released", 3), "Average Time to Release (days)"),
      secondLevel = c("Raised", "Rejected", "Promoted", "Released", "Removed", "Updates / Pre-query", "Released / Pre-query",  "Modification / Pre-query", "Pre-queries / Item", "> 7 days", "> 14 days", "> 21 days")
    )
    widths <- rep(0, ncol(formLevel))
    widths[2] <- 105
    widths[7] <- 90
    formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6, 9:24))
    
    # Subject Level ----
    subjectDetails <- preqry %>%
      select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName", "SubjectSeq", "SubjectId")) %>%
      group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>%
      summarise(TotalValues = sum(Total_filled)) # To calculate number of entered items in all the Forms for respective subjects
    
    subjectLevel <- countPreQueries(preqry, c('StudyName', 'Country', 'SiteCode', 'SiteName', 'SubjectSeq', 'SubjectId')) %>%  
      data.frame() %>%
      mutate(avgReleaseTime = ifelse(is.nan(avgReleaseTime), NA, avgReleaseTime)) %>% 
      left_join(subjectDetails, by = c("StudyName", "Country", "SiteCode", "SiteName", "SubjectSeq", "SubjectId")) %>% # To get the TotalValues column
      mutate(PrequeryRatio = ifelse(!is.na(TotalValues), round(totalPreqries * 100 / TotalValues, 2), 0))
    subjectLevel$PrequeryRatio <- gsub("NA", "0", subjectLevel$PrequeryRatio)
    
    subjectLevel <- subjectLevel %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, totalPreqries, openPreqries, rejectedPreqries, promotedPreqries, releasedPreqries, removedPreqries, updatedPreqries, updatesRatio, releaseRatio, modifiedRatio, PrequeryRatio, notReleasedGrt7, notReleasedGrt14, notReleasedGrt21, avgReleaseTime)
    subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq", "SubjectId"))
    subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Total",  "# of Pre-queries (Raised)", "# of Pre-queries (Rejected)", "# of Pre-queries (Promoted)", "# of Pre-queries (Released)", "# of Pre-queries (Removed)", "Resulting in Data Changes", "Updates / Pre-query %", "Released / Pre-query %", "Modification / Pre-query %", "Pre-queries / Item %", "# of Pre-queries not Released > 7 days", "# of Pre-queries not Released > 14 days", "# of Pre-queries not Released > 21 days", "Average Time to Release (days)"))
    headerSubject <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Total", rep("# of Pre-queries", 5), "Resulting in Data Changes", rep("Ratio (%)", 4), rep("# of Pre-queries not Released", 3), "Average Time to Release (days)"),
      secondLevel = c("Raised", "Rejected", "Promoted", "Released", "Removed", "Updates / Pre-query", "Released / Pre-query",  "Modification / Pre-query", "Pre-queries / Item", "> 7 days", "> 14 days", "> 21 days")
    )
    widths <- rep(0, ncol(subjectLevel))
    widths[2] <- 105
    widths[5] <- 90
    subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:20))
    
    # Event Level ----
    eventDetails <- preqry %>%
      select(StudyName, Country, SiteCode, SiteName, EventName) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName")) %>%
      group_by(StudyName, Country, SiteCode, SiteName, EventName) %>%
      summarise(TotalValues = sum(Total_filled)) # To calculate number of entered items in all the Forms in respective event
    
    eventLevel <- countPreQueries(preqry, c('StudyName', 'Country', 'SiteCode', 'SiteName', 'EventName')) %>%
      data.frame() %>%
      mutate(avgReleaseTime = ifelse(is.nan(avgReleaseTime), NA, avgReleaseTime)) %>% 
      left_join(eventDetails, by = c("StudyName", "Country", "SiteCode", "SiteName", "EventName")) %>% # To get the TotalValues column
      mutate(PrequeryRatio = ifelse(!is.na(TotalValues), round(totalPreqries * 100 / TotalValues, 2), 0))
    eventLevel$PrequeryRatio <- gsub("NA", "0", eventLevel$PrequeryRatio)
    
    eventLevel <- eventLevel %>% select(StudyName, Country, SiteCode, SiteName, EventName, totalPreqries, openPreqries, rejectedPreqries, promotedPreqries, releasedPreqries, removedPreqries, updatedPreqries, updatesRatio, releaseRatio, modifiedRatio, PrequeryRatio, notReleasedGrt7, notReleasedGrt14, notReleasedGrt21, avgReleaseTime)
    eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName"))
    if (!is.na(visitOrder)) {
      visitOrder <- visitOrder[visitOrder %in% eventLevel$EventName]
      eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
      eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, .by_group = TRUE)
    }
    eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site Name", "Event", "Total",  "# of Pre-queries (Raised)", "# of Pre-queries (Rejected)", "# of Pre-queries (Promoted)", "# of Pre-queries (Released)", "# of Pre-queries (Removed)", "Resulting in Data Changes", "Updates / Pre-query %", "Released / Pre-query %", "Modification / Pre-query %", "Pre-queries / Item %", "# of Pre-queries not Released > 7 days", "# of Pre-queries not Released > 14 days", "# of Pre-queries not Released > 21 days", "Average Time to Release (days)"))
    headerEvent <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Event", "Total", rep("# of Pre-queries", 5), "Resulting in Data Changes", rep("Ratio (%)", 4), rep("# of Pre-queries not Released", 3), "Average Time to Release (days)"),
      secondLevel = c("Raised", "Rejected", "Promoted", "Released", "Removed", "Updates / Pre-query", "Released / Pre-query",  "Modification / Pre-query", "Pre-queries / Item", "> 7 days", "> 14 days", "> 21 days")
    )
    widths <- rep(0, ncol(eventLevel))
    widths[2] <- 105
    eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:20))
    
    
    # Site Level ----
    siteNames <- ss %>% group_by(StudyName, Country, SiteCode, SiteName) %>% summarize(SubjectCount = n()) %>% data.frame()
    siteDetails <- preqry %>%
      select(StudyName, Country, SiteCode, SiteName) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country", "SiteCode", "SiteName")) %>%
      group_by(StudyName, Country, SiteCode, SiteName) %>%
      summarise(TotalValues = sum(Total_filled)) %>% # To calculate number of entered items in all the Forms for respective sites
      left_join(siteNames, by = c("StudyName", "Country", "SiteCode", "SiteName")) # To get the number of subjects in the site
    
    siteLevel <- countPreQueries(preqry, c('StudyName', 'Country', 'SiteCode', 'SiteName')) %>%  
      data.frame() %>%
      mutate(avgReleaseTime = ifelse(is.nan(avgReleaseTime), NA, avgReleaseTime))
    
    siteLevel <- siteLevel %>%  
      left_join(siteDetails, by = c("StudyName", "Country", "SiteCode", "SiteName")) %>% # To get the TotalValues column and subject count
      mutate(
        PrequeryRatio = ifelse(!is.na(TotalValues), round(totalPreqries * 100 / TotalValues, 2), 0),
        percentTrial = round(totalPreqries * 100 / sum(totalPreqries), 2),
        avgPreqryperSubject = round(totalPreqries / SubjectCount, 2)
      ) %>%
      group_by(StudyName, Country) %>%
      mutate(percentCountry = round(totalPreqries * 100 / sum(totalPreqries), 2),
             .groups= "drop") %>%
      data.frame()
    siteLevel$PrequeryRatio <- gsub("NA", "0", siteLevel$PrequeryRatio)
    
    siteLevel <- siteLevel %>% select(StudyName, Country, SiteCode, SiteName, totalPreqries, openPreqries, rejectedPreqries, promotedPreqries, releasedPreqries, removedPreqries, updatedPreqries, updatesRatio, releaseRatio, modifiedRatio, PrequeryRatio, notReleasedGrt7, notReleasedGrt14, notReleasedGrt21, avgReleaseTime, SubjectCount, avgPreqryperSubject, percentTrial, percentCountry)
    siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
    siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site Name", "Total",  "# of Pre-queries (Raised)", "# of Pre-queries (Rejected)", "# of Pre-queries (Promoted)", "# of Pre-queries (Released)", "# of Pre-queries (Removed)", "Resulting in Data Changes", "Updates / Pre-query %", "Released / Pre-query %", "Modification / Pre-query %", "Pre-queries / Item %", "# of Pre-queries not Released > 7 days", "# of Pre-queries not Released > 14 days", "# of Pre-queries not Released > 21 days", "Average Time to Release (days)", "Number of Subjects", "Pre-queries / Subject", "% of Pre-queries in Trial", "% of Pre-queries in Country"))
    headerSite <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Total", rep("# of Pre-queries", 5), "Resulting in Data Changes",rep("Ratio (%)", 4), rep("# of Pre-queries not Released", 3), "Average Time to Release (days)", "Number of Subjects", "Pre-queries / Subject", "% of Pre-queries in Trial", "% of Pre-queries in Country"),
      secondLevel = c("Raised", "Rejected", "Promoted", "Released", "Removed", "Updates / Pre-query", "Released / Pre-query",  "Modification / Pre-query", "Pre-queries / Item", "> 7 days", "> 14 days", "> 21 days")
    )
    widths <- rep(0, ncol(siteLevel))
    widths[2] <- 105
    siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 5:23))
    
    # Country Level ----
    countryNames <- ss %>% group_by(StudyName, Country) %>% summarize(SubjectCount = n()) %>% data.frame()
    countryDetails <- preqry %>%
      select(StudyName, Country) %>%
      unique() %>%
      left_join(edcRecords, by = c("StudyName", "Country")) %>%
      group_by(StudyName, Country) %>%
      summarise(TotalValues = sum(Total_filled))%>% # To calculate number of entered items in all the Forms in respective country
      left_join(countryNames, by = c("StudyName", "Country")) # To get the number of subjects in the country
    
    countryLevel <- countPreQueries(preqry, c('StudyName', 'Country')) %>%  
      data.frame() %>%
      mutate(avgReleaseTime = ifelse(is.nan(avgReleaseTime), NA, avgReleaseTime)) %>% 
      left_join(countryDetails, by = c("StudyName", "Country")) %>% # To get the TotalValues column and subject count
      mutate(
        PrequeryRatio = ifelse(!is.na(TotalValues), round(totalPreqries * 100 / TotalValues, 2), 0),
        percentTrial = round(totalPreqries * 100 / sum(totalPreqries), 2),
        avgPreqryperSubject = round(totalPreqries / SubjectCount, 2)
      )
    countryLevel$PrequeryRatio <- gsub("NA", "0", countryLevel$PrequeryRatio)
    
    countryLevel <- countryLevel %>% select(StudyName, Country, totalPreqries, openPreqries, rejectedPreqries, promotedPreqries, releasedPreqries, removedPreqries, updatedPreqries, updatesRatio, releaseRatio, modifiedRatio, PrequeryRatio, notReleasedGrt7, notReleasedGrt14, notReleasedGrt21, avgReleaseTime, SubjectCount, avgPreqryperSubject, percentTrial)
    countryLevel <- prepareDataForDisplay(countryLevel)
    countryLevel <- setLabel(countryLevel, list("Study", "Country", "Total",  "# of Pre-queries (Raised)", "# of Pre-queries (Rejected)", "# of Pre-queries (Promoted)", "# of Pre-queries (Released)", "# of Pre-queries (Removed)", "Resulting in Data Changes", "Updates / Pre-query %", "Released / Pre-query %", "Modification / Pre-query %", "Pre-queries / Item %", "# of Pre-queries not Released > 7 days", "# of Pre-queries not Released > 14 days", "# of Pre-queries not Released > 21 days", "Average Time to Release (days)", "Number of Subjects", "Pre-queries / Subject", "% of Pre-queries in Trial"))
    headerCountry <- list(
      firstLevel = c("Study", "Country", "Total", rep("# of Pre-queries", 5), "Resulting in Data Changes", rep("Ratio (%)", 4), rep("# of Pre-queries not Released", 3), "Average Time to Release (days)", "Number of Subjects", "Pre-queries / Subject", "% of Pre-queries in Trial"),
      secondLevel = c("Raised", "Rejected", "Promoted", "Released", "Removed", "Updates / Pre-query", "Released / Pre-query",  "Modification / Pre-query", "Pre-queries / Item", "> 7 days", "> 14 days", "> 21 days")
    )
    widths <- rep(0, ncol(countryLevel))
    widths[2] <- 105
    countryLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3:20))
    
    # Most Pre-queried Items ----
    mostPrequeried <- preqry %>%
      select(StudyName, FormId, FormName, ItemId, ItemName, ClosedByDataEdit, QueryStatus) %>%
      group_by(StudyName, FormId, FormName, ItemId, ItemName) %>%
      summarise(totalPreqries = n(),
                updatedPreqries = sum(ClosedByDataEdit == "Yes", na.rm = T),
                openPreqries = sum(QueryStatus %in% c("Prequery Raised", "Prequery Promoted")),
                openQueries = sum(QueryStatus == "Query Raised"),
                .groups = "drop") %>%
      mutate(FormName = as.character(FormName))
    mostPrequeried[is.na(mostPrequeried$FormName), "FormName"] <- "Event Date"
    mostPrequeried <- mostPrequeried %>%
      select(StudyName, FormId, FormName, ItemId, ItemName, totalPreqries, openPreqries, openQueries, updatedPreqries) %>%
      arrange(desc(totalPreqries))
    mostPrequeried <- prepareDataForDisplay(mostPrequeried)
    mostPrequeried <- setLabel(mostPrequeried, list("Study", "FormId", "Form", "ItemId", "Item", "Total # of Raised Pre-queries", "# of Unreleased Pre-queries", "# of Open Queries", "# of Pre-queries Resulting in Data Change"))
    widths <- rep(0, ncol(mostPrequeried))
    mostPrequeriedColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(6:9))
    
    reportOutput <- list(
      "by Country" = list("data" = countryLevel, header = headerCountry, "columnDefs" = countryLevelColumnDefs),
      "by Site" = list("data" = siteLevel, header = headerSite, "columnDefs" = siteLevelColumnDefs),
      "by Event" = list("data" = eventLevel, header = headerEvent, "columnDefs" = eventLevelColumnDefs),
      "by Subject" = list("data" = subjectLevel, header = headerSubject, "columnDefs" = subjectLevelColumnDefs),
      "by Form" = list("data" = formLevel, header = headerForm, "columnDefs" = formLevelColumnDefs),
      "Most Pre-queried Items" = list("data" = mostPrequeried, "columnDefs" = mostPrequeriedColumnDefs)
    )
  }
}

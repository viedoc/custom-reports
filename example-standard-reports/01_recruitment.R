#----------Recruitment Report----------

# Get data
ss <- edcData$SubjectStatus
ed <- edcData$EventDates
sfr <- edcData$Forms$SCRFRREP
output <- data.frame(Empty = "No Data")

if (ncol(ss) == 0 || nrow(ss) == 0) {
  reportOutput <- list("data" = list("data" = output))
  } else {
    # Get Study Name
    ld <- params$UserDetails$sites %>% 
    select(SiteCode = siteCode, SiteName = siteName, Country = country, ETS = expectedNumberOfSubjectsScreened, ETE = expectedNumberOfSubjectsEnrolled, MSA = maximumNumberOfSubjectsScreened)
    ss$SiteCode <- as.character(ss$SiteCode)
    ss <- ss %>%
    mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
    ed$SiteCode <- as.character(ed$SiteCode)
    # Get Screen failure subjects if SCRFRREP form is present in the study
    if ("ScreeningFailureState" %in% colnames(sfr)) {
      ss <- ss %>% left_join(sfr %>% select(SiteCode, SiteName, SubjectSeq, SubjectId, ScreeningFailureState))
      ss[is.na(ss$ScreeningFailureState),"ScreeningFailureState"] <- FALSE
    }
    
    # Get Withdrawal reason (if available)
    formId <- ""
    itemId <- ""
    wdData <- data.frame()
    if (any(params$reportConfigurations$reportType == "Dashboard")) {
      cnf <- params$reportConfigurations$plotConfigurations[params$reportConfigurations$reportType == "Dashboard"][[1]]$expression
      if (!is.na(cnf)) {
        cnf <- unlist(strsplit(cnf, "[.]"))
        if (length(cnf) == 3) {
          formId <- unlist(strsplit(cnf, "[.]"))[2]
          itemId <- unlist(strsplit(cnf, "[.]"))[3]
          wdData <- edcData$Forms[[formId]]
          if (!itemId %in% colnames(wdData)) { # Handle checkbox fields
            data <- wdData
            checkboxCols <- colnames(data)[grepl(paste0("^",itemId,"[0-9]{1,2}$"),colnames(data))] # Retaining this line for backward compatibility
            
            # Get checkboxCols from metadata
            if ("HtmlType" %in% colnames(metadata$ItemDef) && "checkbox" %in% metadata$ItemDef$HtmlType) {
              itemdef <- metadata$ItemDef %>% 
                filter(metadata$ItemDef$HtmlType == "checkbox") %>% 
                mutate(OID = gsub(".*__(.*?)__.*", "\\1", OID)) %>% 
                filter(OID == itemId) %>% arrange(as.numeric(MDVOID)) %>% tail(1)
              if (nrow(itemdef) == 1) {
                codedvalues <- metadata$CodeList %>% filter(OID == itemdef$CodeListOID) %>% select(CodedValue) %>% unlist() %>% unique()
                if (length(codedvalues) > 0) {
                  checkboxCols <- paste0(itemId,codedvalues)
                  checkboxCols <- checkboxCols[checkboxCols %in% colnames(data)]
                }
              }
              }
            rm(metadata)
            
            if (length(checkboxCols) > 0) {
              for (col in checkboxCols) {
                if (!itemId %in% colnames(data)) data[[itemId]] <- data[[col]]
                else data[[itemId]] <- ifelse(is.na(data[[col]]),data[[itemId]],ifelse(is.na(data[[itemId]]),data[[col]],paste0(data[[itemId]],",",data[[col]])))
                }
              wdData <- data
              }
            rm(data)
            }
          if (!itemId %in% colnames(wdData) || nrow(wdData) == 0) itemId <- ""
        }
      }
      }
    if (itemId != "") {
      wdData[["WDREAS"]] <- wdData[[itemId]]
      wdData <- wdData %>% filter(!is.na(WDREAS)) %>% group_by(SiteCode, SiteName, SubjectSeq, SubjectId) %>% summarise(WDREAS = paste(WDREAS, collapse=","))
      } else wdData <- data.frame()
  
    # Calculate required fields
    ss <- ss %>%
      mutate(
        SCREENED = ifelse(ScreenedState, "Yes", ""),
        SCREENEDDATE = ScreenedOnDate,
        ENROLLED = ifelse(EnrolledState, "Yes", ""),
        ENROLLEDDATE = EnrolledOnDate,
        CANDIDATE = ifelse(!ScreenedState & !CompletedState & !WithdrawnState, "Yes", ""),
        ONGOING = ifelse(ScreenedState & !CompletedState & !WithdrawnState, "Yes", ""),
        COMPLETED = ifelse(CompletedState, "Yes", ""),
        COMPLETEDDATE = CompletedOnDate,
        WITHDRAWN = ifelse(WithdrawnState, "Yes", ""),
        WITHDRAWNDATE = WithdrawnOnDate,
        DROPOUT = WithdrawnState & EnrolledState
        )
    # If 'SCRFRREP' form present in study, Screen failure logic is used from the form else old logic is retained
    {
      if("ScreeningFailureState" %in% colnames(ss)) ss$SCREENFAILED <- ss$ScreeningFailureState
      else ss$SCREENFAILED <- ss$WithdrawnState & !ss$EnrolledState & ss$ScreenedState
    }
  
    # Subject level
    subjectlevel <- ss %>%
      select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SCREENED, ENROLLED, CANDIDATE, ONGOING, COMPLETED, WITHDRAWN)
    if (ncol(wdData) > 0) subjectlevel <- subjectlevel %>% left_join(wdData, by = c("SiteCode", "SiteName", "SubjectSeq", "SubjectId"))
    subjectlevel <- prepareDataForDisplay(subjectlevel, c("SiteCode", "SiteName", "SubjectSeq"))
    lbls <- list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Screened", "Enrolled", "Candidate (Added, not yet screened)", "Ongoing", "Completed", "Withdrawn")
    if (ncol(wdData) > 0) lbls <- append(lbls, "Reason for withdrawal")
    subjectlevel <- setLabel(subjectlevel, lbls)
    widths <- rep(0, ncol(subjectlevel))
    widths[2] <- 105
    widths[5] <- 90
    widths[6:11] <- 60
    subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
    colnms <- c("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Screened", "Enrolled", "Candidate", "Ongoing", "Completed", "Withdrawn")
    if (ncol(wdData) > 0) colnms <- append(colnms, "Reason for withdrawal")
    headerSubject <- list(firstLevel = colnms)
  
    # Subject level (with dates)
    subjectlevelWithDate <- ss %>%
      select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, SCREENED, SCREENEDDATE, ENROLLED, ENROLLEDDATE, CANDIDATE, ONGOING, COMPLETED, COMPLETEDDATE, WITHDRAWN, WITHDRAWNDATE)
    if (ncol(wdData) > 0) subjectlevelWithDate <- subjectlevelWithDate %>% left_join(wdData, by = c("SiteCode", "SiteName", "SubjectSeq", "SubjectId"))
    subjectlevelWithDate <- prepareDataForDisplay(subjectlevelWithDate, c("SiteCode", "SiteName", "SubjectSeq"))
    lbls <- list("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Screened", "Screened Date", "Enrolled", "Enrolled Date", "Candidate (Added, not yet screened)", "Ongoing", "Completed", "Completed Date", "Withdrawn", "Withdrawn Date")
    if (ncol(wdData) > 0) lbls <- append(lbls, "Reason for withdrawal")
    subjectlevelWithDate <- setLabel(subjectlevelWithDate, lbls)
    widths <- rep(0, ncol(subjectlevelWithDate))
    widths[2] <- 105
    widths[5] <- 90
    widths[c(6,8,10,11,12,14)] <- 60
    subjectLevelWithDateColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3,7,9,13,15))
    colnms <- c("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject", "Screened", "Screened Date", "Enrolled", "Enrolled Date", "Candidate", "Ongoing", "Completed", "Completed Date", "Withdrawn", "Withdrawn Date")
    if (ncol(wdData) > 0) colnms <- append(colnms, "Reason for withdrawal")
    headerSubjectWithDate <- list(firstLevel = colnms)
  
    # Site level
    dod <- substr(params$dateOfDownload, 1, 10)
    sitelevel <- ss %>%
      group_by(StudyName, Country, SiteCode, SiteName) %>%
      summarize(TOTAL = n(), CANDIDATE = sum(CANDIDATE == "Yes"), SCREENED = sum(SCREENED == "Yes"), ENROLLED = sum(ENROLLED == "Yes"), ONGOING = sum(ONGOING == "Yes"), COMPLETED = sum(COMPLETED == "Yes"), WITHDRAWN = sum(WITHDRAWN == "Yes"), SCREENFAILED = sum(SCREENFAILED), DROPOUT = sum(DROPOUT), LastScreenedDT = coalesce(max(as.character(ScreenedOnDate), na.rm = T),paste(Sys.Date())), LastEnrolledDT =  coalesce(max(as.character(EnrolledOnDate), na.rm = T),paste(Sys.Date())), SFR = ifelse(SCREENED == 0, 0, round(sum(SCREENFAILED) * 100 / SCREENED, 1)), DOR = ifelse(ENROLLED == 0, 0, round(sum(DROPOUT) * 100 / ENROLLED, 1))) %>%
      data.frame()
    edsite <- ed %>% group_by(Country, SiteCode, SiteName) %>% summarize(fromDate = substr(as.character(min(EventInitiatedDate, na.rm = T)), 1, 10))
    sitelevel <- sitelevel %>% 
      left_join(edsite, by = c("Country", "SiteCode", "SiteName")) %>% 
      left_join(ld, by = c("Country", "SiteCode", "SiteName")) %>% 
      mutate(
        DLS = as.integer(difftime(paste(Sys.Date()), substr(LastScreenedDT, 1, 10), units = "days")),
        DLE = as.integer(difftime(paste(Sys.Date()), substr(LastEnrolledDT, 1, 10), units = "days")),
        enrollmentCompleted = ifelse(is.na(ETE), F, ENROLLED >= ETE),
        toDate = ifelse(enrollmentCompleted, substr(LastEnrolledDT, 1, 10), dod),
        elapsedDays = (as.numeric(difftime(toDate, fromDate, units = "days")) + 1),
        ERM = round(ENROLLED / (elapsedDays / 30), 1),
        ERW = round(ENROLLED / (elapsedDays / 7), 1)
        ) %>%
      select(StudyName, Country, SiteCode, SiteName, TOTAL, SCREENED, ETS, MSA, DLS, SCREENFAILED, SFR, ENROLLED, ETE, DLE, ERW, ERM, DROPOUT, DOR, CANDIDATE, ONGOING, COMPLETED, WITHDRAWN)
    sitelevel <- prepareDataForDisplay(sitelevel, c("SiteCode", "SiteName"))
    sitelevel <- setLabel(sitelevel, list("Study", "Country", "Site Code", "Site Name", "Total", "Screened (Current)", "Screened (Expected)", "Screened (Max allowed)", "Days since latest screening", "Screen failure", "Screen Failure Rate %", "Enrolled (Current)", "Enrolled (Expected)", "Days since latest enrollment", "Enrollment Rate/week", "Enrollment Rate/month", "Drop-out", "Drop-out Rate %", "Candidate (Added, not yet screened)", "Ongoing", "Completed", "Withdrawn"))
    headerSite <- list(
      firstLevel = c("Study", "Country", "Site Code", "Site Name", "Total", rep("Screened",6), rep("Enrolled",7), rep("Total",4)),
      secondLevel = c("Current", "Expected", "Max allowed", "DLS", "SF", "SFR %", "Current", "Expected", "DLE", "ER/week", "ER/month", "DO", "DOR %", "Candidate", "Ongoing", "Completed", "Withdrawn")
      )
    widths <- rep(0, ncol(sitelevel))
    widths[2] <- 105
    siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  
    # Country level
    countrylevel <- ss %>%
      group_by(StudyName, Country) %>%
      summarize(TOTAL = n(), CANDIDATE = sum(CANDIDATE == "Yes"), SCREENED = sum(SCREENED == "Yes"), ENROLLED = sum(ENROLLED == "Yes"), ONGOING = sum(ONGOING == "Yes"), COMPLETED = sum(COMPLETED == "Yes"), WITHDRAWN = sum(WITHDRAWN == "Yes"), SCREENFAILED = sum(SCREENFAILED), DROPOUT = sum(DROPOUT), LastScreenedDT = coalesce(max(as.character(ScreenedOnDate), na.rm = T),paste(Sys.Date())), LastEnrolledDT = coalesce(max(as.character(EnrolledOnDate), na.rm = T),paste(Sys.Date())), SFR = ifelse(SCREENED == 0, 0, round(sum(SCREENFAILED) * 100 / SCREENED, 1)), DOR = ifelse(ENROLLED == 0, 0, round(sum(DROPOUT) * 100 / ENROLLED, 1))) %>%
      data.frame()
    edcountry <- ed %>% group_by(Country) %>% summarize(fromDate = substr(as.character(min(EventInitiatedDate, na.rm = T)), 1, 10))
    ldcountry <- ld %>% group_by(Country) %>% summarize(SitesCount = n(), ETS = sum(ETS), MSA = sum(MSA), ETE = sum(ETE))
    countrylevel <- countrylevel %>% 
      left_join(edcountry, by = "Country") %>% 
      left_join(ldcountry, by = "Country") %>% 
      mutate(
        DLS = as.integer(difftime(paste(Sys.Date()), substr(LastScreenedDT, 1, 10), units = "days")),
        DLE = as.integer(difftime(paste(Sys.Date()), substr(LastEnrolledDT, 1, 10), units = "days")),
        enrollmentCompleted = ifelse(is.na(ETE), F, ENROLLED >= ETE),
        toDate = ifelse(enrollmentCompleted, substr(LastEnrolledDT, 1, 10), dod),
        elapsedDays = (as.numeric(difftime(toDate, fromDate, units = "days")) + 1),
        ERM = round(ENROLLED / (elapsedDays / 30), 1),
        ERW = round(ENROLLED / (elapsedDays / 7), 1)
        ) %>%
      select(StudyName, Country, TOTAL, SCREENED, ETS, MSA, DLS, SCREENFAILED, SFR, ENROLLED, ETE, DLE, ERW, ERM, DROPOUT, DOR, CANDIDATE, ONGOING, COMPLETED, WITHDRAWN, SitesCount)
    countrylevel <- prepareDataForDisplay(countrylevel)
    countrylevel <- setLabel(countrylevel, list("Study", "Country", "Total", "Screened (Current)", "Screened (Expected)", "Screened (Max allowed)", "Days since latest screening", "Screen failure", "Screen Failure Rate %", "Enrolled (Current)", "Enrolled (Expected)", "Days since latest enrollment", "Enrollment Rate/week", "Enrollment Rate/month", "Drop-out", "Drop-out Rate %", "Candidate (Added, not yet screened)", "Ongoing", "Completed", "Withdrawn", "# of sites"))
    headerCountry <- list(
      firstLevel = c("Study", "Country", "Total", rep("Screened",6), rep("Enrolled",7), rep("Total",4), "# of sites"),
      secondLevel = c("Current", "Expected", "Max allowed", "DLS", "SF", "SFR %", "Current", "Expected", "DLE", "ER/week", "ER/month", "DO", "DOR %", "Candidate", "Ongoing", "Completed", "Withdrawn")
      )
    widths <- rep(0, ncol(countrylevel))
    widths[2] <- 105
    countryLevelColumnDefs <- getColumnDefs(colwidths = widths)
  
    reportOutput <- list(
      "by Country" = list("data" = countrylevel,header = headerCountry, columnDefs = countryLevelColumnDefs), 
      "by Site" = list("data" = sitelevel, header = headerSite, columnDefs = siteLevelColumnDefs), 
      "by Subject" = list("data" = subjectlevel, header = headerSubject, columnDefs = subjectLevelColumnDefs),
      "by Subject (with dates)" = list("data" = subjectlevelWithDate, header = headerSubjectWithDate, columnDefs = subjectLevelWithDateColumnDefs)
    )
    }

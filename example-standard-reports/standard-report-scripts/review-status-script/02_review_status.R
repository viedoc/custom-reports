#----------Review Status----------

# Get data ----
output <- data.frame(Empty = "No Data")
rs <- edcData$ReviewStatus

if (ncol(rs) == 0 || nrow(rs) == 0) {
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
    visitOrder <- visitOrder[visitOrder %in% rs$EventName]
    missingVisits <- setdiff(sort(unique(rs$EventName)), visitOrder)
    visitOrder <- c(visitOrder, missingVisits)
  }
  
  # Get Study Name ----
  rs$SiteCode <- as.character(rs$SiteCode)
  rs$StudyName <- rep(params$UserDetails$studyinfo$studyName[1], nrow(rs))
  
  # Prepare data ----
  rs <- rs %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, EventDate, ActivityId, ActivityName, FormName, FormSeq, ReviewedItem, SDV = SdvBy, SDVDATE = SdvDate, SIGNED = SignBy, SIGNEDDATE = SignDate, LOCKED = LockBy, LOCKEDDATE = LockDate, DATAREVIEW = DmBy, DATAREVIEWDATE = DmDate, CLINICALREVIEW = CrBy, CLINICALREVIEWDATE = CrDate)
  rs$SDV <- as.character(rs$SDV)
  rs$SIGNED <- as.character(rs$SIGNED)
  rs$LOCKED <- as.character(rs$LOCKED)
  rs$DATAREVIEW <- as.character(rs$DATAREVIEW)
  rs$CLINICALREVIEW <- as.character(rs$CLINICALREVIEW)
  rs <- setNAtoBlank(rs, forceCharacter = c("SubjectId", "SiteCode", "EventSeq", "FormSeq"))
  
  # Form Level
  formLevel <- rs %>% 
    mutate(FormName = ifelse(FormName == "", "Event date", FormName))
  formLevel <- prepareDataForDisplay(formLevel, c("SiteCode", "SiteName", "SubjectSeq", "EventSeq", "FormSeq"))
  formLevel <- formLevel %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventSeq, EventDate, ActivityId, ActivityName, FormName, FormSeq, ReviewedItem, CLINICALREVIEW, CLINICALREVIEWDATE, DATAREVIEW, DATAREVIEWDATE, SDV, SDVDATE, SIGNED, SIGNEDDATE, LOCKED, LOCKEDDATE)
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% formLevel$EventName]
    formLevel$EventName <- factor(formLevel$EventName, levels = visitOrder)
    formLevel <- formLevel %>% group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  formLevel <- setLabel(formLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "Event ", "Event Sequence", "Event Date", "Activity Id", "Activity Name", "Form", "Form Sequence", "Reviewed Item", "Clinical Review By", "Clinical Review Date", "DM Review By", "DM Review Date", "SDV By", "SDV Date", "Signed By", "Signed Date", "Locked By", "Locked Date"))
  widths <- rep(0, ncol(formLevel))
  widths[2] <- 105
  widths[5] <- 90
  formLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 7, 8, 12, 15, 17, 19, 21, 23))
  
  # Event Level
  eventLevel <- rs %>%
    group_by(StudyName, Country, SiteCode, SiteName, EventName, EventSeq) %>%
    summarize(
      SDVCompleted = sum(SDV != "" & SDV != "N/A"),
      CLINICALREVIEWCompleted = sum(CLINICALREVIEW != "" & CLINICALREVIEW != "N/A"),
      DATAREVIEWCompleted = sum(DATAREVIEW != "" & DATAREVIEW != "N/A"),
      SIGNEDCompleted = sum(SIGNED != "" & SIGNED != "N/A"),
      LOCKEDCompleted = sum(LOCKED != "" & LOCKED != "N/A"),
      sdvtotal = sum(SDV != "N/A"),
      total = sum(CLINICALREVIEW != "N/A"),
      SDVCount = paste0(SDVCompleted, "/", sdvtotal),
      SDVPercent = ifelse(sdvtotal > 0, round(SDVCompleted * 100 / sdvtotal, 1), NA),
      CLINICALREVIEWCount = paste0(CLINICALREVIEWCompleted, "/", total),
      CLINICALREVIEWPercent = round(CLINICALREVIEWCompleted * 100 / total, 1),
      DATAREVIEWCount = paste0(DATAREVIEWCompleted, "/", total),
      DATAREVIEWPercent = round(DATAREVIEWCompleted * 100 / total, 1),
      SIGNEDCount = paste0(SIGNEDCompleted, "/", total),
      SIGNEDPercent = round(SIGNEDCompleted * 100 / total, 1),
      LOCKEDCount = paste0(LOCKEDCompleted, "/", total),
      LOCKEDPercent = round(LOCKEDCompleted * 100 / total, 1),
      patientsCount = length(unique(interaction(SubjectId, SubjectSeq)))
    )
  eventLevel <- eventLevel %>% select(StudyName, Country, SiteCode, SiteName, EventName, EventSeq, CLINICALREVIEWPercent, DATAREVIEWPercent, SDVPercent, SIGNEDPercent, LOCKEDPercent, CLINICALREVIEWCount, DATAREVIEWCount, SDVCount, SIGNEDCount, LOCKEDCount, patientsCount)
  eventLevel <- prepareDataForDisplay(eventLevel, c("SiteCode", "SiteName", "EventSeq"))
  if (!is.na(visitOrder)) {
    visitOrder <- visitOrder[visitOrder %in% eventLevel$EventName]
    eventLevel$EventName <- factor(eventLevel$EventName, levels = visitOrder)
    eventLevel <- eventLevel %>% group_by(StudyName, Country, SiteCode, SiteName) %>% arrange(EventName, EventSeq, .by_group = TRUE)
  }
  eventLevel <- setLabel(eventLevel, list("Study", "Country", "Site Code", "Site name", "Event ", "Event Sequence", "CR %", "DM %", "SDV %", "Sign %", "Lock %", "CR (n/N)", "DM (n/N)", "SDV (n/N)", "Sign (n/N)", "Lock (n/N)", "# of subjects"))
  widths <- rep(0, ncol(eventLevel))
  widths[2] <- 105
  eventLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:16))
  headerEvent  <- list(
    firstLevel = c("Study", "Country", "Site Code", "Site name", "Event ", "Event Sequence", rep("Percentage (%)",5),rep("Count (n/N)",5), "# of subjects"),
    secondLevel = c("CR", "DM", "SDV", "Sign", "Lock", "CR", "DM", "SDV", "Sign", "Lock")
  )
  
  # Subject Level
  subjectLevel <- rs %>%
    group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId) %>%
    summarize(
      SDVCompleted = sum(SDV != "" & SDV != "N/A"),
      CLINICALREVIEWCompleted = sum(CLINICALREVIEW != "" & CLINICALREVIEW != "N/A"),
      DATAREVIEWCompleted = sum(DATAREVIEW != "" & DATAREVIEW != "N/A"),
      SIGNEDCompleted = sum(SIGNED != "" & SIGNED != "N/A"),
      LOCKEDCompleted = sum(LOCKED != "" & LOCKED != "N/A"),
      sdvtotal = sum(SDV != "N/A"),
      total = sum(CLINICALREVIEW != "N/A"),
      SDVCount = paste0(SDVCompleted, "/", sdvtotal),
      SDVPercent = ifelse(sdvtotal > 0, round(SDVCompleted * 100 / sdvtotal, 1), NA),
      CLINICALREVIEWCount = paste0(CLINICALREVIEWCompleted, "/", total),
      CLINICALREVIEWPercent = round(CLINICALREVIEWCompleted * 100 / total, 1),
      DATAREVIEWCount = paste0(DATAREVIEWCompleted, "/", total),
      DATAREVIEWPercent = round(DATAREVIEWCompleted * 100 / total, 1),
      SIGNEDCount = paste0(SIGNEDCompleted, "/", total),
      SIGNEDPercent = round(SIGNEDCompleted * 100 / total, 1),
      LOCKEDCount = paste0(LOCKEDCompleted, "/", total),
      LOCKEDPercent = round(LOCKEDCompleted * 100 / total, 1)
    )
  subjectLevel <- subjectLevel %>% select(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, CLINICALREVIEWPercent, DATAREVIEWPercent, SDVPercent, SIGNEDPercent, LOCKEDPercent, CLINICALREVIEWCount, DATAREVIEWCount, SDVCount, SIGNEDCount, LOCKEDCount)
  subjectLevel <- prepareDataForDisplay(subjectLevel, c("SiteCode", "SiteName", "SubjectSeq"))
  subjectLevel <- setLabel(subjectLevel, list("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", "CR %", "DM %", "SDV %", "Sign %", "Lock %", "CR (n/N)", "DM (n/N)", "SDV (n/N)", "Sign (n/N)", "Lock (n/N)"))
  widths <- rep(0, ncol(subjectLevel))
  widths[2] <- 105
  widths[5] <- 90
  subjectLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:15))
  headerSubject <- list(
    firstLevel = c("Study", "Country", "Site Code", "Site name", "Subject Sequence", "Subject", rep("Percentage (%)",5),rep("Count (n/N)",5)),
    secondLevel = c("CR", "DM", "SDV", "Sign", "Lock", "CR", "DM", "SDV", "Sign", "Lock")
  )
  
  # Site Level
  siteLevel <- rs %>%
    group_by(StudyName, Country, SiteCode, SiteName) %>%
    summarize(
      SDVCompleted = sum(SDV != "" & SDV != "N/A"),
      CLINICALREVIEWCompleted = sum(CLINICALREVIEW != "" & CLINICALREVIEW != "N/A"),
      DATAREVIEWCompleted = sum(DATAREVIEW != "" & DATAREVIEW != "N/A"),
      SIGNEDCompleted = sum(SIGNED != "" & SIGNED != "N/A"),
      LOCKEDCompleted = sum(LOCKED != "" & LOCKED != "N/A"),
      sdvtotal = sum(SDV != "N/A"),
      total = sum(CLINICALREVIEW != "N/A"),
      SDVCount = paste0(SDVCompleted, "/", sdvtotal),
      SDVPercent = ifelse(sdvtotal > 0, round(SDVCompleted * 100 / sdvtotal, 1), NA),
      CLINICALREVIEWCount = paste0(CLINICALREVIEWCompleted, "/", total),
      CLINICALREVIEWPercent = round(CLINICALREVIEWCompleted * 100 / total, 1),
      DATAREVIEWCount = paste0(DATAREVIEWCompleted, "/", total),
      DATAREVIEWPercent = round(DATAREVIEWCompleted * 100 / total, 1),
      SIGNEDCount = paste0(SIGNEDCompleted, "/", total),
      SIGNEDPercent = round(SIGNEDCompleted * 100 / total, 1),
      LOCKEDCount = paste0(LOCKEDCompleted, "/", total),
      LOCKEDPercent = round(LOCKEDCompleted * 100 / total, 1),
      patientsCount = length(unique(interaction(SubjectId, SubjectSeq)))
    )
  siteLevel <- siteLevel %>% select(StudyName, Country, SiteCode, SiteName, CLINICALREVIEWPercent, DATAREVIEWPercent, SDVPercent, SIGNEDPercent, LOCKEDPercent, CLINICALREVIEWCount, DATAREVIEWCount, SDVCount, SIGNEDCount, LOCKEDCount, patientsCount)
  siteLevel <- prepareDataForDisplay(siteLevel, c("SiteCode", "SiteName"))
  siteLevel <- setLabel(siteLevel, list("Study", "Country", "Site Code", "Site name", "CR %", "DM %", "SDV %", "Sign %", "Lock %", "CR (n/N)", "DM (n/N)", "SDV (n/N)", "Sign (n/N)", "Lock (n/N)", "# of subjects"))
  widths <- rep(0, ncol(siteLevel))
  widths[2] <- 105
  siteLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 5:14))
  headerSite <- list(
    firstLevel = c("Study", "Country", "Site Code", "Site name", rep("Percentage (%)",5), rep("Count (n/N)",5), "# of subjects"),
    secondLevel = c("CR", "DM", "SDV", "Sign", "Lock", "CR", "DM", "SDV", "Sign", "Lock")
  )
  
  # Country Level
  countryLevel <- rs %>%
    group_by(StudyName, Country) %>%
    summarize(
      SDVCompleted = sum(SDV != "" & SDV != "N/A"),
      CLINICALREVIEWCompleted = sum(CLINICALREVIEW != "" & CLINICALREVIEW != "N/A"),
      DATAREVIEWCompleted = sum(DATAREVIEW != "" & DATAREVIEW != "N/A"),
      SIGNEDCompleted = sum(SIGNED != "" & SIGNED != "N/A"),
      LOCKEDCompleted = sum(LOCKED != "" & LOCKED != "N/A"),
      sdvtotal = sum(SDV != "N/A"),
      total = sum(CLINICALREVIEW != "N/A"),
      SDVCount = paste0(SDVCompleted, "/", sdvtotal),
      SDVPercent = ifelse(sdvtotal > 0, round(SDVCompleted * 100 / sdvtotal, 1), NA),
      CLINICALREVIEWCount = paste0(CLINICALREVIEWCompleted, "/", total),
      CLINICALREVIEWPercent = round(CLINICALREVIEWCompleted * 100 / total, 1),
      DATAREVIEWCount = paste0(DATAREVIEWCompleted, "/", total),
      DATAREVIEWPercent = round(DATAREVIEWCompleted * 100 / total, 1),
      SIGNEDCount = paste0(SIGNEDCompleted, "/", total),
      SIGNEDPercent = round(SIGNEDCompleted * 100 / total, 1),
      LOCKEDCount = paste0(LOCKEDCompleted, "/", total),
      LOCKEDPercent = round(LOCKEDCompleted * 100 / total, 1),
      patientsCount = length(unique(interaction(SubjectId, SubjectSeq)))
    )
  countryLevel <- countryLevel %>% select(StudyName, Country, CLINICALREVIEWPercent, DATAREVIEWPercent, SDVPercent, SIGNEDPercent, LOCKEDPercent, CLINICALREVIEWCount, DATAREVIEWCount, SDVCount, SIGNEDCount, LOCKEDCount, patientsCount)
  countryLevel <- prepareDataForDisplay(countryLevel)
  countryLevel <- setLabel(countryLevel, list("Study", "Country", "CR %", "DM %", "SDV %", "Sign %", "Lock %", "CR (n/N)", "DM (n/N)", "SDV (n/N)", "Sign (n/N)", "Lock (n/N)", "# of subjects"))
  widths <- rep(0, ncol(countryLevel))
  widths[2] <- 105
  countryLevelColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3:12))
  headerCountry <- list(
    firstLevel = c("Study", "Country", rep("Percentage (%)",5), rep("Count (n/N)",5), "# of subjects"),
    secondLevel = c("CR", "DM", "SDV", "Sign", "Lock", "CR", "DM", "SDV", "Sign", "Lock")
  )
  
  reportOutput <- list(
    "by Country" = list("data" = countryLevel, header = headerCountry, "columnDefs" = countryLevelColumnDefs),
    "by Site" = list("data" = siteLevel, header = headerSite, "columnDefs" = siteLevelColumnDefs),
    "by Event" = list("data" = eventLevel, header = headerEvent, "columnDefs" = eventLevelColumnDefs),
    "by Subject" = list("data" = subjectLevel, header = headerSubject, "columnDefs" = subjectLevelColumnDefs),
    "by Form" = list("data" = formLevel, "columnDefs" = formLevelColumnDefs)
  )
  }

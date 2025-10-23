# ----------Disposition----------

# Get data ----
output <- data.frame(Empty = "No Data")
ss <- edcData$SubjectStatus
ed <- edcData$EventDates
sfr <- edcData$Forms$SCRFRREP
if (ncol(ss) == 0 || nrow(ss) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  # Get Study Name
  ed$SiteCode <- as.character(ed$SiteCode)
  ed <- ed %>%
    mutate(StudyName = params$UserDetails$studyinfo$studyName[1])
  ss$SiteCode <- as.character(ss$SiteCode)
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
          if ("ItemDef" %in% names(metadata)) {
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
  }
  if (itemId != "") {
    wdData[["WDREAS"]] <- wdData[[itemId]]
    wdData <- wdData %>% filter(!is.na(WDREAS)) %>% group_by(SiteCode, SiteName, SubjectSeq, SubjectId) %>% summarise(WDREAS = paste(WDREAS, collapse=","))
  } else wdData <- data.frame()
  
  # Get Subject Status
  if (ncol(wdData) > 0) {
    ss <- ss %>% left_join(wdData, by = c("SiteCode", "SiteName", "SubjectSeq", "SubjectId")) %>% mutate(WDREAS = ifelse(is.na(WDREAS), "", WDREAS))
  } else ss$WDREAS <- ""
  # If 'SCRFRREP' form present in study, Screen failure logic is used from the form else old logic is retained
  if ("ScreeningFailureState" %in% colnames(ss)) {
    ss <- ss %>%
      mutate(
        SubjectStatus = ifelse(
          ScreeningFailureState, "Screen failure",
          ifelse(!ScreenedState & !CompletedState & !WithdrawnState, "Candidate",
                 ifelse(ScreenedState & !CompletedState & !WithdrawnState, "Ongoing",
                        ifelse(CompletedState, "Completed",
                               ifelse(WithdrawnState, 
                                      ifelse(WDREAS == "", "Withdrawn", WDREAS),
                                      ""
                               )
                        )
                 )
          )
        )
      )
  } else {
    ss <- ss %>%
      mutate(
        SubjectStatus = ifelse(
          !ScreenedState & !CompletedState & !WithdrawnState, "Candidate",
          ifelse(WithdrawnState & !EnrolledState & ScreenedState, "Screen failure",
                 ifelse(ScreenedState & !CompletedState & !WithdrawnState, "Ongoing",
                        ifelse(CompletedState, "Completed",
                               ifelse(WithdrawnState, 
                                      ifelse(WDREAS == "", "Withdrawn", WDREAS),
                                      ""
                               )
                        )
                 )
          )
        )
      )
  }
  ss <- ss %>% select(SiteCode, SiteName, SubjectSeq, SubjectId, SubjectStatus)
  ed <- ed %>% 
    left_join(ss, by = c("SiteCode", "SiteName", "SubjectSeq", "SubjectId")) %>%
    mutate(EventInitiatedDate = substr(EventInitiatedDate,1,10)) %>% 
    select(StudyName, CountryCode, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventId, EventName, EventRepeatKey, EventInitiatedDate, SubjectStatus)
  
  # Handle duplicate site codes
  duplicateSiteCodes <- any(duplicated(params$UserDetails$sites$siteCode))
  if (duplicateSiteCodes) {
    uniqueSiteCodes <- ed %>% mutate(SiteCode = paste0(CountryCode,"-",SiteCode)) %>% distinct(Country, SiteName, SiteCode)
  } else uniqueSiteCodes <- ed %>% distinct(Country, SiteName, SiteCode)
  ed <- ed %>% select(-CountryCode)
  
  # Set Subject status order
  dispositionOrder <- c("Candidate", "Screen failure", "Ongoing", "Completed", "Withdrawn")
  dispositionOrder <- dispositionOrder[dispositionOrder %in% ed$SubjectStatus]
  missingDisposition <- setdiff(sort(unique(ed$SubjectStatus)), dispositionOrder)
  dispositionOrder <- unique(c(dispositionOrder, missingDisposition))
  ed$SubjectStatus <- factor(ed$SubjectStatus, levels = dispositionOrder)
  
  # Get Event order
  visitOrder <- c()
  if ("StudyEventDef" %in% names(metadata)) {
    visitOrder <- metadata$StudyEventRef %>%
      rename(EventId = StudyEventOID) %>% 
      inner_join(metadata$StudyEventDef %>% select(MDVOID, EventId = OID, EventName = Name, Type), by = c("MDVOID","EventId")) %>% 
      mutate(OrderNumber = ifelse(!is.na(OrderNumber) & Type == "Scheduled", as.numeric(OrderNumber), max(as.numeric(OrderNumber), na.rm = T) + 1)) %>% 
      distinct(MDVOID, OrderNumber, EventId, EventName) %>% 
      group_by(EventId) %>% 
      arrange(desc(as.numeric(MDVOID)), .by_group = TRUE) %>%
      filter(row_number() == 1) %>% 
      select(-MDVOID) %>% 
      data.frame() %>% 
      mutate(EventNameTrunc = ifelse(nchar(EventName) <= 35, EventName, paste0(substr(EventName,1,32), "..."))) %>%
      group_by(EventName) %>% 
      arrange(as.numeric(OrderNumber), .by_group = TRUE) %>% 
      mutate(count = n(), seq = row_number()) %>% 
      data.frame() %>% 
      mutate(EventName = ifelse(count == 1, EventName, paste0(EventName,"_",seq))) %>%
      group_by(EventNameTrunc) %>% 
      arrange(as.numeric(OrderNumber), .by_group = TRUE) %>% 
      mutate(count = n(), seq = row_number()) %>% 
      data.frame() %>% 
      mutate(EventNameTrunc = ifelse(count == 1, EventNameTrunc, paste0(EventNameTrunc,"_",seq))) %>%
      distinct(EventId, OrderNumber, EventName, EventNameTrunc)
    ed <- ed %>% 
      left_join(visitOrder %>% select(EventId, NewEventName = EventName, EventNameTrunc), by = "EventId") %>%
      mutate(
        EventName = coalesce(NewEventName, EventName),
        EventNameTrunc = coalesce(EventNameTrunc, EventName)
      ) %>% 
      select(-EventId, -NewEventName)
    visitOrderTrunc <- visitOrder %>% 
      arrange(as.numeric(OrderNumber), EventNameTrunc) %>% 
      distinct(EventNameTrunc) %>% 
      unlist(use.names = F)
    visitOrder <- visitOrder %>% 
      arrange(as.numeric(OrderNumber), EventName) %>% 
      distinct(EventName) %>% 
      unlist(use.names = F)
  }
  
  # Make EventName unique
  ed <- ed %>% 
    group_by(StudyName, Country, SiteCode, SiteName, SubjectSeq, SubjectId, EventName, EventRepeatKey, SubjectStatus, EventNameTrunc) %>%
    summarise(EventInitiatedDate = min(EventInitiatedDate, na.rm = TRUE)) %>% 
    ungroup()%>%
    group_by(SiteCode, SubjectSeq, SubjectId, EventName) %>%
    mutate(VisitFreq = n()) %>%
    ungroup() %>%
    group_by(EventName) %>% 
    mutate(maxv = max(VisitFreq)) %>% 
    data.frame() %>%
    mutate(
      EventName_ = ifelse(maxv > 1, paste(EventName, EventRepeatKey), EventName),
      EventNameTrunc = ifelse(maxv > 1, paste(EventNameTrunc, EventRepeatKey), EventNameTrunc)
    ) %>%
    select(-VisitFreq, -EventRepeatKey, -maxv)
  ed$OrderNumber <- sapply(ed$EventName, function(x) which(visitOrder == x))
  ed$EventName <- ed$EventName_
  ed[["EventName_"]] <- NULL
  
  visitOrder <- ed %>% distinct(OrderNumber, EventName) %>% arrange(OrderNumber) %>% select(EventName) %>% unlist()
  visitOrder <- unique(visitOrder)
  ed$EventName <- factor(ed$EventName, levels = visitOrder)
  
  visitOrderTrunc <- ed %>% distinct(OrderNumber, EventNameTrunc) %>% arrange(OrderNumber) %>% select(EventNameTrunc) %>% unlist()
  visitOrderTrunc <- unique(visitOrderTrunc)
  ed$EventNameTrunc <- factor(ed$EventNameTrunc, levels = visitOrderTrunc)
  
  ed$OrderNumber <- NULL
  
  # Event dates by Subject
  eventDetails <- ed %>% 
    select(-EventNameTrunc) %>% 
    spread(EventName, EventInitiatedDate, fill = "") %>%
    select(-SubjectStatus, SubjectStatus)
  lbls <- as.list(colnames(eventDetails))
  lbls[1:6] <- c("Study", "Country", "Site Code", "Site Name", "Subject Sequence", "Subject")
  lbls[length(lbls)] <- "Subject Status"
  eventDetails <- prepareDataForDisplay(eventDetails, c("SiteCode", "SiteName"))
  eventDetails <- setLabel(eventDetails, lbls)
  widths <- rep(0, ncol(eventDetails))
  eventDetailsColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3, 6:(length(lbls) - 1)))
  colnms <- as.character(lbls)
  eventDetailsHeader <- list(
    firstLevel = colnms
  )
  
  # Site level - Event Summary
  siteEventSummary <- ed %>%
    group_by(StudyName, Country, SiteCode, SiteName, EventName) %>%
    summarise(InitiatedEvents = sum(!is.na(EventInitiatedDate))) %>%
    ungroup() %>% 
    data.frame() %>% 
    spread(EventName, InitiatedEvents, fill = 0)
  lbls <- as.list(colnames(siteEventSummary))
  lbls[1:4] <- c("Study", "Country", "Site Code", "Site Name")
  siteEventSummary <- prepareDataForDisplay(siteEventSummary, c("SiteCode", "SiteName"))
  siteEventSummary <- setLabel(siteEventSummary, lbls)
  widths <- rep(0, ncol(siteEventSummary))
  siteEventSummaryColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  colnms <- as.character(lbls)
  siteEventSummaryHeader <- list(
    firstLevel = colnms
  )
  
  siteEventSummary_ <- ed %>%
    select(-SiteCode) %>%
    left_join(uniqueSiteCodes) %>%
    group_by(StudyName, Country, SiteCode, SiteName, EventNameTrunc) %>%
    summarise(InitiatedEvents = sum(!is.na(EventInitiatedDate))) %>%
    ungroup() %>% 
    data.frame() %>% 
    mutate(SiteCode = paste(SiteCode, SiteName))
  ncolors <- length(validLevels(siteEventSummary_$SiteCode))
  siteEventPlot <- plot_ly(data = siteEventSummary_, x=~EventNameTrunc, y=~InitiatedEvents, type="bar", color=~SiteCode, colors = GetColors(ncolors), hovertemplate = "<span>%{x}:</span> %{y}") %>%
    layout(
      title = "Event Summary (by Site)", 
      xaxis = list(title = list(text = "Event Name")), 
      yaxis = list(title = list(text = "# of initiated events"), ticklen = 4, tickcolor = "transparent"),
      margin = list(t = 50),
      showlegend = T,
      font = globalFont, 
      hoverlabel = list(bgcolor = "black", bordercolor = "black", font = list(color = "white"), align = "left")
    )
  
  # Country level - Event Summary
  countryEventSummary <- ed %>%
    group_by(StudyName, Country, EventName) %>%
    summarise(InitiatedEvents = sum(!is.na(EventInitiatedDate))) %>%
    ungroup() %>% 
    data.frame() %>% 
    spread(EventName, InitiatedEvents, fill = 0)
  lbls <- as.list(colnames(countryEventSummary))
  lbls[1:2] <- c("Study", "Country")
  countryEventSummary <- prepareDataForDisplay(countryEventSummary)
  countryEventSummary <- setLabel(countryEventSummary, lbls)
  widths <- rep(0, ncol(countryEventSummary))
  countryEventSummaryColumnDefs <- getColumnDefs(colwidths = widths)
  colnms <- as.character(lbls)
  countryEventSummaryHeader <- list(
    firstLevel = colnms
  )
  
  countryEventSummary_ <- ed %>%
    group_by(StudyName, Country, EventNameTrunc) %>%
    summarise(InitiatedEvents = sum(!is.na(EventInitiatedDate))) %>%
    ungroup() %>% 
    data.frame() 
  ncolors <- length(validLevels(countryEventSummary_$Country))
  countryEventPlot <- plot_ly(data = countryEventSummary_, x=~EventNameTrunc, y=~InitiatedEvents, type="bar", color=~Country, colors = GetColors(ncolors), hovertemplate = "<span>%{x}:</span> %{y}") %>%
    layout(
      title = "Event Summary (by Country)", 
      xaxis = list(title = list(text = "Event Name")), 
      yaxis = list(title = list(text = "# of initiated events"), ticklen = 4, tickcolor = "transparent"),
      margin = list(t = 50),
      showlegend = T,
      font = globalFont,
      hoverlabel = list(bgcolor = "black", bordercolor = "black", font = list(color = "white"), align = "left")
    )
  
  # Study level - Event Summary
  studyEventSummary <- ed %>%
    group_by(EventName) %>%
    summarise(InitiatedEvents = sum(!is.na(EventInitiatedDate))) %>%
    ungroup() %>% data.frame()
  lbls <- list("Event Name", "# of initiated events")
  lvls <- levels(studyEventSummary$EventName)
  studyEventSummary <- prepareDataForDisplay(studyEventSummary)
  studyEventSummary$EventName <- factor(studyEventSummary$EventName, levels = lvls)
  studyEventSummary <- studyEventSummary %>% arrange(EventName)
  studyEventSummary <- setLabel(studyEventSummary, lbls)
  widths <- rep(0, ncol(studyEventSummary))
  studyEventSummaryColumnDefs <- getColumnDefs(colwidths = widths)
  colnms <- as.character(lbls)
  studyEventSummaryHeader <- list(
    firstLevel = colnms
  )
  
  # Site level - Subject Summary
  eventDetails$SubjectStatus <- factor(eventDetails$SubjectStatus, levels = dispositionOrder)
  siteDispositionSummary_ <- eventDetails %>%
    group_by(StudyName, Country, SiteCode, SiteName, SubjectStatus) %>%
    summarise(Freq = n()) %>%
    ungroup() %>% data.frame() 
  siteDispositionSummary <- siteDispositionSummary_ %>% spread(SubjectStatus, Freq, fill = 0)
  lbls <- as.list(colnames(siteDispositionSummary))
  lbls[1:4] <- c("Study", "Country", "Site Code", "Site Name")
  siteDispositionSummary <- prepareDataForDisplay(siteDispositionSummary, c("SiteCode", "SiteName"))
  siteDispositionSummary <- setLabel(siteDispositionSummary, lbls)
  widths <- rep(0, ncol(siteDispositionSummary))
  siteDispositionSummaryColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(3))
  colnms <- as.character(lbls)
  siteDispositionSummaryHeader <- list(
    firstLevel = colnms
  )
  
  siteDispositionSummary_ <- siteDispositionSummary_ %>% 
    select(-SiteCode) %>%
    left_join(uniqueSiteCodes)
  ncolors <- length(validLevels(siteDispositionSummary_$SubjectStatus))
  siteDispositionPlot <- plot_ly(data = siteDispositionSummary_, x=~SiteCode, y=~Freq, type="bar", color=~SubjectStatus, colors = GetColors(ncolors), text = ~paste(SiteCode,SiteName), hovertemplate="<span>%{text}:</span> %{y:.1f}", marker = list(line = list(width = 2, color = "white"))) %>% 
    layout(
      legend = list(traceorder = "normal"),
      barmode = "stack", 
      barnorm = "percent", 
      title = "Subject Summary (by Site)", 
      xaxis = list(title = list(text = "Site Code")), 
      yaxis = list(title = list(text = "% of subject status"), ticklen = 4, tickcolor = "transparent"),
      margin = list(t = 50),
      showlegend = T,
      font = globalFont,
      hoverlabel = list(bgcolor = "black", bordercolor = "black", font = list(color = "white"), align = "left")
    )
  
  # Country level - Subject Summary
  countryDispositionSummary_ <- eventDetails %>%
    group_by(StudyName, Country, SubjectStatus) %>%
    summarise(Freq = n()) %>%
    ungroup() %>% data.frame()
  countryDispositionSummary <- countryDispositionSummary_ %>% spread(SubjectStatus, Freq, fill = 0)
  lbls <- as.list(colnames(countryDispositionSummary))
  lbls[1:2] <- c("Study", "Country")
  countryDispositionSummary <- prepareDataForDisplay(countryDispositionSummary)
  countryDispositionSummary <- setLabel(countryDispositionSummary, lbls)
  widths <- rep(0, ncol(countryDispositionSummary))
  countryDispositionSummaryColumnDefs <- getColumnDefs(colwidths = widths)
  colnms <- as.character(lbls)
  countryDispositionSummaryHeader <- list(
    firstLevel = colnms
  )
  
  ncolors <- length(validLevels(countryDispositionSummary_$SubjectStatus))
  countryDispositionPlot <- plot_ly(data = countryDispositionSummary_, x=~Country, y=~Freq, type="bar", color=~SubjectStatus, colors = GetColors(ncolors), hovertemplate="%{y:.1f}", marker = list(line = list(width = 2, color = "white"))) %>% 
    layout(
      legend = list(traceorder = "normal"),
      barmode = "stack", 
      barnorm = "percent", 
      title = "Subject Summary (by Country)", 
      xaxis = list(title = list(text = "Country")), 
      yaxis = list(title = list(text = "% of subject status"), ticklen = 4, tickcolor = "transparent"),
      margin = list(t = 50),
      showlegend = T,
      font = globalFont,
      hoverlabel = list(bgcolor = "black", bordercolor = "black", font = list(color = "white"), align = "left")
    )
  
  # Study level - Subject Summary
  studyDispositionSummary <- eventDetails %>%
    group_by(SubjectStatus) %>%
    summarise(Freq = n()) %>%
    ungroup() %>% data.frame()
  lbls <- list("Subject Status", "# of subjects")
  lvls <- levels(studyDispositionSummary$SubjectStatus)
  studyDispositionSummary <- prepareDataForDisplay(studyDispositionSummary)
  studyDispositionSummary$SubjectStatus <- factor(studyDispositionSummary$SubjectStatus, levels = lvls)
  studyDispositionSummary <- studyDispositionSummary %>% arrange(SubjectStatus)
  studyDispositionSummary <- setLabel(studyDispositionSummary, lbls)
  widths <- rep(0, ncol(studyDispositionSummary))
  studyDispositionSummaryColumnDefs <- getColumnDefs(colwidths = widths)
  colnms <- as.character(lbls)
  studyDispositionSummaryHeader <- list(
    firstLevel = colnms
  )
  reportOutput <- list(
    "Event (table by Study)" = list(data = studyEventSummary, header = studyEventSummaryHeader, columnDefs = studyEventSummaryColumnDefs),
    "Event (table by Country)" = list(data = countryEventSummary, header = countryEventSummaryHeader, columnDefs = countryEventSummaryColumnDefs),
    "Event (table by Site)" = list(data = siteEventSummary, header = siteEventSummaryHeader, columnDefs = siteEventSummaryColumnDefs),
    "Event (plot by Country)" = list(plot = countryEventPlot),
    "Event (plot by Site)" = list(plot = siteEventPlot),
    "Subject status (table by Study)" = list(data = studyDispositionSummary, header = studyDispositionSummaryHeader, columnDefs = studyDispositionSummaryColumnDefs),
    "Subject status (table by Country)" = list(data = countryDispositionSummary, header = countryDispositionSummaryHeader, columnDefs = countryDispositionSummaryColumnDefs),
    "Subject status (table by Site)" = list(data = siteDispositionSummary, header = siteDispositionSummaryHeader, columnDefs = siteDispositionSummaryColumnDefs),
    "Subject status (plot by Country)" = list(plot = countryDispositionPlot),
    "Subject status (plot by Site)" = list(plot = siteDispositionPlot),
    "Event dates by Subject" = list(data = eventDetails, header = eventDetailsHeader, columnDefs = eventDetailsColumnDefs)
  )
}

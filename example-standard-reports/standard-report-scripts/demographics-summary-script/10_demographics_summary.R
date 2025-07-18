# ----------Demographics Summary----------

# Get data ----
output <- data.frame(Empty = "No Data")
blankText <- "(blank)"
indentation <- paste(rep("&nbsp;", 4), collapse = "")
  
dm <- edcData$SubjectStatus
if (nrow(dm) == 0) {
  reportOutput <- list("data" = list("data" = output))
  } else {
  dm <- dm %>%
    mutate(STATUS = ifelse(CompletedState == T, "Completed", ifelse(WithdrawnState == T, "Withdrawn", ifelse(ScreenedState == T, "Ongoing", "Candidate"))), ENROLLED = ifelse(EnrolledState, "Yes", "No"), SiteOID = paste(SiteCode, SiteName)) %>%
    select(SubjectId, SiteOID, STATUS, ENROLLED)
  
  # Get Demographic Characteristics
  plotConfiguration <- data.frame()
  if (any(params$reportConfigurations$reportType == "Demographics")) plotConfiguration <- params$reportConfigurations$plotConfigurations[params$reportConfigurations$reportType == "Demographics"][[1]]
  if (!is.data.frame(plotConfiguration)) plotConfiguration <- data.frame()
  
  if (nrow(plotConfiguration) > 0) {
    plotConfiguration$Form <- sapply(plotConfiguration$expression, function(x) unlist(strsplit(x, "[.]"))[2])
    plotConfiguration$Field <- sapply(plotConfiguration$expression, function(x) unlist(strsplit(x, "[.]"))[3])
    plotConfiguration <- plotConfiguration[!duplicated(plotConfiguration$Field),]
    for (i in 1:nrow(plotConfiguration)) {
      Form <- plotConfiguration$Form[i]
      Field <- plotConfiguration$Field[i]
      data <- edcData$Forms[[Form]]
      
      # Handle checkbox fields
      if (!Field %in% colnames(data)) {
        checkboxCols <- colnames(data)[grepl(paste0("^",Field,"[0-9]{1,2}$"),colnames(data))] # Retaining this line for backward compatibility
        
        # Get checkboxCols from metadata
        if ("HtmlType" %in% colnames(metadata$ItemDef) && "checkbox" %in% metadata$ItemDef$HtmlType) {
          itemdef <- metadata$ItemDef %>% 
            filter(metadata$ItemDef$HtmlType == "checkbox") %>% 
            mutate(OID = gsub(".*__(.*?)__.*", "\\1", OID)) %>% 
            filter(OID == Field) %>% arrange(as.numeric(MDVOID)) %>% tail(1)
          if (nrow(itemdef) == 1) {
            codedvalues <- metadata$CodeList %>% filter(OID == itemdef$CodeListOID) %>% select(CodedValue) %>% unlist() %>% unique()
            if (length(codedvalues) > 0) {
              checkboxCols <- paste0(Field,codedvalues)
              checkboxCols <- checkboxCols[checkboxCols %in% colnames(data)]
            }
          }
        }
        # rm(metadata)
        
        if (length(checkboxCols) > 0) {
          for (col in checkboxCols) {
            if (!Field %in% colnames(data)) data[[Field]] <- data[[col]]
            else data[[Field]] <- ifelse(is.na(data[[col]]),data[[Field]],ifelse(is.na(data[[Field]]),data[[col]],"MULTIPLE"))
          }
        }
      }
      
      if (Field %in% colnames(data)) {
        if ("EventDate" %in% colnames(data)) {
          data <- data %>% 
            filter_(paste0("!is.na(",Field,") & ",Field," != ''")) %>% 
            group_by(SubjectId) %>%
            arrange(desc(EventDate)) %>%
            filter(row_number() == 1) %>%
            select(c("SubjectId", all_of(Field))) %>% 
            ungroup() # One record per subject
        }
        else {
          data <- data %>% 
            filter_(paste0("!is.na(",Field,") & ",Field," != ''")) %>% 
            select(c("SubjectId", all_of(Field))) %>% 
            group_by(SubjectId) %>%
            filter(row_number() == n()) %>%
            ungroup() # One record per subject
        }
        dm <- dm %>% left_join(data, by = "SubjectId")
      }
      rm(data)
    }
    plotConfiguration <- plotConfiguration %>% filter(Field %in% colnames(dm))
  }
  dm <- prepareDataForDisplay(dm)
  
  SITE_summary_TOTAL <- dm %>%
    summarise(Value = n(), .groups = "drop") %>%
    data.frame() %>%
    mutate(SiteOID = "Total", PARAM = "Subject count", Value = paste0("N = ",Value)) %>%
    select(SiteOID, PARAM, Value)
  SITE_summary <- dm %>%
    group_by(SiteOID) %>%
    summarise(Value = n(), .groups = "drop") %>%
    data.frame() %>%
    mutate(PARAM = "Subject count", Value = paste0("N = ",Value)) %>%
    select(SiteOID, PARAM, Value) %>%
    rbind(SITE_summary_TOTAL) %>%
    spread(SiteOID, Value) 
  dm$STATUS <- as.character(dm$STATUS)
  dm$STATUS[is.na(dm$STATUS)] <- blankText
  dm$STATUS <- factor(dm$STATUS, levels = rev(c(blankText, "Candidate", "Ongoing", "Withdrawn", "Completed")))
  STATUS_summary_TOTAL <- dm %>%
    group_by(PARAM = STATUS) %>%
    summarise(siteFreq = n(), .groups = 'drop') %>%
    data.frame() %>%
    mutate(
      SiteOID = "Total",
      sitePerc = format(round(siteFreq*100/sum(siteFreq), 1), nsmall = 1),
      Value = paste0(siteFreq," (",trimws(sitePerc),"%)")
    ) %>%
    select(SiteOID, PARAM, Value)
  STATUS_summary <- dm %>%
    group_by(SiteOID, PARAM = STATUS) %>%
    summarise(siteFreq = n(), .groups = 'drop') %>%
    data.frame() %>%
    full_join(expand.grid(SiteOID = unique(dm$SiteOID), PARAM = unique(dm$STATUS), stringsAsFactors = F), by = c("SiteOID", "PARAM")) %>%
    replace(is.na(.), 0) %>%
    mutate(
      sitePerc = format(round(siteFreq*100/sum(siteFreq), 1), nsmall = 1),
      Value = paste0(siteFreq," (",trimws(sitePerc),"%)")
    ) %>%
    select(SiteOID, PARAM, Value) %>%
    rbind(STATUS_summary_TOTAL) %>%
    spread(SiteOID, Value)
  STATUS_summary$PARAM <- paste0(indentation,as.character(STATUS_summary$PARAM))
  STATUS_header <- STATUS_summary %>% filter(row_number() == 0)
  STATUS_header[1,] <- as.list(c("<b>Subject Status</b>", rep("", ncol(STATUS_summary) - 1)))
  STATUS_summary <- rbind(SITE_summary, STATUS_header, STATUS_summary)
  
  dm$ENROLLED <- as.character(dm$ENROLLED)
  dm$ENROLLED[is.na(dm$ENROLLED)] <- blankText
  dm$ENROLLED <- factor(dm$ENROLLED, levels = rev(c(blankText, "No", "Yes")))
  ENROLLED_summary_TOTAL <- dm %>%
    group_by(PARAM = ENROLLED) %>%
    summarise(siteFreq = n(), .groups = 'drop') %>%
    data.frame() %>%
    mutate(
      SiteOID = "Total",
      sitePerc = format(round(siteFreq*100/sum(siteFreq), 1), nsmall = 1),
      Value = paste0(siteFreq," (",trimws(sitePerc),"%)")
    ) %>%
    select(SiteOID, PARAM, Value)
  ENROLLED_summary <- dm %>%
    group_by(SiteOID, PARAM = ENROLLED) %>%
    summarise(siteFreq = n(), .groups = 'drop') %>%
    data.frame() %>%
    full_join(expand.grid(SiteOID = unique(dm$SiteOID), PARAM = unique(dm$ENROLLED), stringsAsFactors = F), by = c("SiteOID", "PARAM")) %>%
    replace(is.na(.), 0) %>%
    mutate(
      sitePerc = format(round(siteFreq*100/sum(siteFreq), 1), nsmall = 1),
      Value = paste0(siteFreq," (",trimws(sitePerc),"%)")
    ) %>%
    select(SiteOID, PARAM, Value) %>%
    rbind(ENROLLED_summary_TOTAL) %>%
    spread(SiteOID, Value)
  ENROLLED_summary$PARAM <- paste0(indentation,as.character(ENROLLED_summary$PARAM))
  ENROLLED_header <- ENROLLED_summary %>% filter(row_number() == 0)
  ENROLLED_header[1,] <- as.list(c("<b>Enrolled</b>", rep("", ncol(ENROLLED_summary) - 1)))
  ENROLLED_summary <- rbind(ENROLLED_header, ENROLLED_summary)
  summary <- rbind(STATUS_summary, ENROLLED_summary)
  
  if (nrow(plotConfiguration) > 0) {
    for (i in 1:nrow(plotConfiguration)) {
      title <- trimws(plotConfiguration$plotTitle[i])
      Field <- plotConfiguration$Field[i]
      if (title == "") title <- Field
      paramDF <- dm
      paramDF$PARAM <- paramDF[[Field]]
      if (is.numeric(type.convert(as.character(paramDF$PARAM)))) {
        paramDF$PARAM <- as.numeric(paramDF$PARAM)
        FIELD_summary_TOTAL <- paramDF %>%
          summarise(
            avg = format(round(mean(PARAM, na.rm = T), 2), nsmall = 2),
            stddev = format(round(sd(PARAM, na.rm = T), 2), nsmall = 2),
            min = format(round(min(PARAM, na.rm = T), 1), nsmall = 1),
            max = format(round(max(PARAM, na.rm = T), 1), nsmall = 1),
            med = format(round(median(PARAM, na.rm = T), 2), nsmall = 2),
            Q1 = format(round(quantile(PARAM, 0.25, na.rm = T), 2), nsmall = 2),
            Q3 = format(round(quantile(PARAM, 0.75, na.rm = T), 2), nsmall = 2),
            blankRecs = sum(is.na(PARAM)),
            .groups = 'drop'
          ) %>%
          data.frame() %>%
          mutate(
            SiteOID = "Total",
            msd = paste0(avg, " (",stddev,")"),
            miq = paste0(med, " (",Q1,", ",Q3,")")
          ) %>%
          gather("PARAM", "Value", rev(c("msd", "miq", "min", "max", "blankRecs"))) %>%
          select(SiteOID, PARAM, Value)
        FIELD_summary <- paramDF %>%
          group_by(SiteOID) %>%
          summarise(
            avg = format(round(mean(PARAM, na.rm = T), 2), nsmall = 2),
            stddev = format(round(sd(PARAM, na.rm = T), 2), nsmall = 2),
            min = format(round(min(PARAM, na.rm = T), 1), nsmall = 1),
            max = format(round(max(PARAM, na.rm = T), 1), nsmall = 1),
            med = format(round(median(PARAM, na.rm = T), 2), nsmall = 2),
            Q1 = format(round(quantile(PARAM, 0.25, na.rm = T), 2), nsmall = 2),
            Q3 = format(round(quantile(PARAM, 0.75, na.rm = T), 2), nsmall = 2),
            blankRecs = sum(is.na(PARAM)),
            .groups = 'drop'
          ) %>%
          data.frame() %>%
          mutate(
            msd = paste0(avg, " (",stddev,")"),
            miq = paste0(med, " (",Q1,", ",Q3,")")
          ) %>%
          gather("PARAM", "Value", rev(c("msd", "miq", "min", "max", "blankRecs"))) %>%
          select(SiteOID, PARAM, Value) %>%
          rbind(FIELD_summary_TOTAL) %>%
          spread(SiteOID, Value)
        FIELD_summary <- FIELD_summary[c(5,4,3,2,1),]
        FIELD_summary$PARAM <- c("mean (sd)", "median (Q1, Q3)", "min", "max", blankText)
        if (!any(is.na(paramDF$PARAM))) FIELD_summary <- FIELD_summary %>% filter(PARAM != blankText)
        FIELD_summary$PARAM <- paste0(indentation,as.character(FIELD_summary$PARAM))
        FIELD_header <- FIELD_summary %>% filter(row_number() == 0)
        FIELD_header[1,] <- as.list(c(paste0("<b>",title,"</b>"), rep("", ncol(FIELD_summary) - 1)))
        FIELD_summary <- rbind(FIELD_header, FIELD_summary)
        summary <- rbind(summary, FIELD_summary)
      }
      else {
        paramDF$PARAM <- as.character(paramDF$PARAM)
        paramDF$PARAM[paramDF$PARAM == "(blank)"] <- blankText
        lvls <- sort(unique(paramDF$PARAM))
        paramDF$PARAM[is.na(paramDF$PARAM)] <- blankText
        paramDF$PARAM <- factor(paramDF$PARAM, levels = c(lvls[lvls != blankText], blankText))
        FIELD_summary_TOTAL <- paramDF %>%
          group_by(PARAM) %>%
          summarise(siteFreq = n(), .groups = 'drop') %>%
          data.frame() %>%
          mutate(
            SiteOID = "Total",
            sitePerc = format(round(siteFreq*100/sum(siteFreq), 1), nsmall = 1),
            Value = paste0(siteFreq," (",trimws(sitePerc),"%)")
          ) %>%
          select(SiteOID, PARAM, Value)
        FIELD_summary <- paramDF %>%
          group_by(SiteOID, PARAM) %>%
          summarise(siteFreq = n(), .groups = 'drop') %>%
          data.frame() %>%
          full_join(expand.grid(SiteOID = unique(paramDF$SiteOID), PARAM = unique(paramDF$PARAM), stringsAsFactors = F), by = c("SiteOID", "PARAM")) %>%
          replace(is.na(.), 0) %>%
          mutate(
            sitePerc = format(round(siteFreq*100/sum(siteFreq), 1), nsmall = 1),
            Value = paste0(siteFreq," (",trimws(sitePerc),"%)")
          ) %>%
          select(SiteOID, PARAM, Value) %>%
          rbind(FIELD_summary_TOTAL) %>%
          spread(SiteOID, Value)
        FIELD_summary$PARAM <- paste0(indentation,as.character(FIELD_summary$PARAM))
        FIELD_header <- FIELD_summary %>% filter(row_number() == 0)
        FIELD_header[1,] <- as.list(c(paste0("<b>",title,"</b>"), rep("", ncol(FIELD_summary) - 1)))
        FIELD_summary <- rbind(FIELD_header, FIELD_summary)
        summary <- rbind(summary, FIELD_summary)
      }
    }
  }
  summary <- prepareDataForDisplay(summary, blankText = "")
  lbls <- as.list(colnames(SITE_summary))
  lbls[[1]] <- "Parameters"
  summary <- setLabel(summary, lbls)
  widths <- rep(0, ncol(summary))
  summaryColumnDefs <- getColumnDefs(colwidths = widths, alignCenter = c(2:ncol(summary)))
  invisible(sapply(1:length(summaryColumnDefs), function(x) {
    summaryColumnDefs[[x]][["orderable"]] <<- FALSE
    summaryColumnDefs[[x]][["searchable"]] <<- FALSE
  }))
  output <- list("Descriptive Summary" = list(data = summary, columnDefs = summaryColumnDefs))
  
  # Display plots ----
  if (nrow(plotConfiguration) > 0) {
    for (i in 1:nrow(plotConfiguration)) {
      title <- trimws(plotConfiguration$plotTitle[i])
      Field <- plotConfiguration$Field[i]
      if (title == "") title <- Field
      if (nchar(title) > 35) title <- paste0(substr(title, 1, (32 - 3)), "...")
      if (is.numeric(type.convert(as.character(dm[[Field]])))) next()
      if (all(is.na(dm[[Field]]))) dm[[Field]] <- ""
      dm <- setNAtoBlank(dm, replaceWithText = blankText, forceCharacter = Field)
      dm[[Field]] <- factor(dm[[Field]])
      ft <- as.data.frame(table(dm[[Field]]))
      lbls <- as.character(ft$Var1)
      lbls <- ifelse(nchar(lbls) > 45, paste0(substr(lbls,1,45), "..."), lbls)
      lbls <- str_wrap(lbls, width = 15)
      pl <- plot_ly(data = ft, labels = lbls, values = ~Freq, type = "pie", hole = .5, rotation = -90, marker = list(colors = GetColors(length(lbls)), line = list(color = "#FFFFFF", width = 1))) %>% layout(title = title, margin = list(t = 100, b = 50), font = globalFont, hoverlabel = list(bgcolor = "black", bordercolor = "black", font = list(color = "white"), align = "left"))
      output[[title]] <- list(plot = pl)
    }
  }
  reportOutput <- output
}
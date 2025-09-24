# ----------Medical Coding----------

# Get data ----
output <- data.frame(Empty = "No Data")
medDRA <- edcData$MedDRA
whoDD <- edcData$WHODrug
medDRA_J <- edcData$MedDRAJ
atc <- edcData$ATCWithoutDDD
IDF <- edcData$IDF

if (length(medDRA) == 0 && length(whoDD) == 0 && length(medDRA_J) == 0 && length(atc) == 0 && length(IDF) == 0) {
  reportOutput <- list("data" = list("data" = output))
} else {
  dictList <- list()
  utrList <- list()
  
  # UTR for MedDRA ----
  if (ncol(medDRA) > 0 && nrow(medDRA) > 0) {
    colsToFactor <- c("SiteSeq", "SiteCode", "SubjectSeq", "EventSeq", "FormSeq", "SubjectFormSeq", "OriginSubjectFormSeq", "SourceSubjectFormSeq", "CodeSeqNumber", "soc_code", "hlgt_code", "hlt_code", "pt_code", "pt_soc_code", "llt_code")
    medDRA_raw <- prepareDataForDisplay(medDRA, c("SiteName", colsToFactor))
    medDRA_raw <- setLabel(medDRA_raw, as.list(getLabel(medDRA)))
    colsToFactor <- c(colsToFactor, "EventDate", "CodedOnDate", "ApprovedOnDate")
    dictList <- append(dictList, list("MedDRA" = list("data" = medDRA_raw, "columnDefs" = getColumnDefs(colwidths = rep(0, ncol(medDRA_raw)), alignRight = which(colnames(medDRA_raw) %in% colsToFactor)))))
    utr_medDRA <- medDRA %>% 
      mutate(Term = toupper(gsub("\\s+", " ", str_trim(Term)))) %>% 
      select(Term, soc_name, hlgt_name, hlt_name, pt_name, llt_name, llt_currency, ApprovedByUser, Version, DictInstance, CodedOnDate) %>% 
      group_by(Term, soc_name, hlgt_name, hlt_name, pt_name, llt_name) %>% 
      mutate(llt_currency = ifelse(all(llt_currency == "Y"),"Y","N"), num_coded = n(), num_approved = sum(!is.na(ApprovedByUser)), DictInstance = str_trim(str_split_fixed(DictInstance,",",2)[,2]), Version = ifelse(Version == "" | is.na(Version), DictInstance, Version), LastCodedOn = max(substr(as.character(CodedOnDate),1,10))) %>% 
      select(-ApprovedByUser, -DictInstance, -CodedOnDate) %>% 
      data.frame()
    utr_medDRA$Version <- sapply(utr_medDRA$Version, function(x) ifelse(grepl("^[0-9]", x),paste("Ver",x),x))
    utr_medDRA <- utr_medDRA %>% 
      group_by(Term, soc_name, hlgt_name, hlt_name, pt_name, llt_name, Version) %>% 
      mutate(ver_count = n()) %>% 
      distinct() %>% 
      select(num_coded, num_approved, Term, soc_name, hlgt_name, hlt_name, pt_name, llt_name, llt_currency, LastCodedOn, Version, ver_count) %>% 
      spread(Version, ver_count, fill = 0)
    
    verCols <- colnames(utr_medDRA)
    verCols <- verCols[-c(1:10)]
    utr_medDRA <- utr_medDRA %>% 
      group_by(Term) %>%
      mutate(Discrepancy = ifelse(n() > 1, "Yes", "No")) %>%
      ungroup() %>% 
      select(c("num_coded", "Term", "llt_name", "pt_name", "hlt_name", "hlgt_name", "soc_name", "llt_currency", "Discrepancy", "LastCodedOn", all_of(verCols), "num_approved")) %>% 
      mutate(num_not_approved = num_coded - num_approved) %>%
      arrange(Term)
    colLabels <- as.list(c("# Coded terms", "Term", "LLT Name", "PT Name", "HLT Name", "HLGT Name", "SOC Name", "LLT Currency", "Coding Discrepancy", "Last term coded on", verCols, "# Coded terms approved", "# Coded terms not approved"))
    utr_medDRA <- prepareDataForDisplay(utr_medDRA)
    utr_medDRA <- setLabel(utr_medDRA, colLabels)
    
    widths <- rep(0, ncol(utr_medDRA))
    utr_medDRAColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(10))
    
    utrList <- append(utrList, list("UTR for MedDRA" = list("data" = utr_medDRA, "columnDefs" = utr_medDRAColumnDefs)))
  }
  
  # UTR for WhoDD ----
  if (ncol(whoDD) > 0 && nrow(whoDD) > 0) {
    whoDD <- whoDD %>% mutate(DrugName = gsub(";","<br>",DrugName), Ingredients = gsub(";","<br>",Ingredients), ATCCodes = gsub(";","<br>",ATCCodes), PreferredName = gsub(";","<br>",PreferredName))
    colsToFactor <- c("SiteSeq", "SiteCode", "SubjectSeq", "EventSeq", "FormSeq", "SubjectFormSeq", "OriginSubjectFormSeq", "SourceSubjectFormSeq", "CodeSeqNumber", "Drug Code", "MedProdId", "PreferredCode")
    whoDD_raw <- prepareDataForDisplay(whoDD, c("SiteName", colsToFactor))
    whoDD_raw <- setLabel(whoDD_raw, as.list(getLabel(whoDD)))
    colsToFactor <- c(colsToFactor, "EventDate", "CodedOnDate", "ApprovedOnDate")
    dictList <- append(dictList, list("WHODrug" = list("data" = whoDD_raw, "columnDefs" = getColumnDefs(colwidths = rep(0, ncol(whoDD_raw)), alignRight = which(colnames(whoDD_raw) %in% colsToFactor)))))
    utr_whoDD <- whoDD %>% 
      mutate(Term = toupper(gsub("\\s+", " ", str_trim(Term)))) %>% 
      select(Term, DrugCode, DrugName, ATCCodes, PreferredName, OldForm, ApprovedByUser, DictInstance, Version, CodedOnDate) %>% 
      group_by(Term, DrugCode, DrugName, ATCCodes, PreferredName) %>%
      mutate(OldForm = ifelse(all(OldForm == "N"), "N", "Y"), num_coded = n(), num_approved = sum(!is.na(ApprovedByUser)), DictInstance = str_trim(str_split_fixed(DictInstance,",",2)[,2]), Version = ifelse(Version == "" | is.na(Version), DictInstance, Version), LastCodedOn = max(substr(as.character(CodedOnDate),1,10))) %>% 
      select(-ApprovedByUser, -DictInstance, -CodedOnDate) %>% 
      data.frame()
    utr_whoDD$Version <- sapply(utr_whoDD$Version, function(x) ifelse(grepl("^[0-9]", x),paste("Ver",x),x))
    utr_whoDD <- utr_whoDD %>% 
      group_by(Term, DrugCode, DrugName, ATCCodes, PreferredName, Version) %>% 
      mutate(ver_count = n()) %>% 
      distinct() %>% 
      select(num_coded, num_approved, Term, DrugCode, DrugName, ATCCodes, PreferredName, OldForm, LastCodedOn, Version, ver_count) %>% 
      spread(Version, ver_count, fill = 0) %>%
      arrange(Term)
    
    verCols <- colnames(utr_whoDD)
    verCols <- verCols[-c(1:9)]
    utr_whoDD <- utr_whoDD %>% 
      group_by(Term) %>%
      mutate(Discrepancy = ifelse(n() > 1, "Yes", "No")) %>%
      ungroup() %>% 
      select(c("num_coded", "Term", "PreferredName", "DrugName", "DrugCode", "ATCCodes", "OldForm", "Discrepancy", "LastCodedOn", all_of(verCols), "num_approved")) %>% 
      mutate(num_not_approved = num_coded - num_approved)
    colLabels <- as.list(c("# Coded terms", "Term", "Preferred Name", "Drug Name", "Drug Code", "ATC Code", "Old Form", "Coding Discrepancy", "Last term coded on", verCols, "# Coded terms approved", "# Coded terms not approved"))
    utr_whoDD <- prepareDataForDisplay(utr_whoDD)
    utr_whoDD <- setLabel(utr_whoDD, colLabels)
    
    widths <- rep(0, ncol(utr_whoDD))
    utr_whoDDColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(9))
    
    utrList <- append(utrList, list("UTR for WHODrug" = list("data" = utr_whoDD, "columnDefs" = utr_whoDDColumnDefs)))
  }
  
  # UTR for MedDRA_J ----
  if (ncol(medDRA_J) > 0 && nrow(medDRA_J) > 0) {
    colsToFactor <- c("SiteSeq", "SiteCode", "SubjectSeq", "EventSeq", "FormSeq", "SubjectFormSeq", "OriginSubjectFormSeq", "SourceSubjectFormSeq", "CodeSeqNumber", "soc_code", "soc_order", "hlgt_code", "hlt_code", "pt_code", "pt_soc_code", "llt_code")
    medDRA_J_raw <- prepareDataForDisplay(medDRA_J, c("SiteName", colsToFactor))
    medDRA_J_raw <- setLabel(medDRA_J_raw, as.list(getLabel(medDRA_J)))
    colsToFactor <- c(colsToFactor, "EventDate", "CodedOnDate", "ApprovedOnDate")
    dictList <- append(dictList, list("MedDRA_J" = list("data" = medDRA_J_raw, "columnDefs" = getColumnDefs(colwidths = rep(0, ncol(medDRA_J_raw)), alignRight = which(colnames(medDRA_J_raw) %in% colsToFactor)))))
    utr_medDRA_J <- medDRA_J %>% 
      mutate(Term = toupper(gsub("\\s+", " ", str_trim(Term)))) %>% 
      select(Term, soc_kanji, hlgt_kanji, hlt_kanji, pt_kanji, llt_kanji, llt_currency, llt_jcurr, ApprovedByUser, DictInstance, Version, CodedOnDate) %>% 
      group_by(Term, soc_kanji, hlgt_kanji, hlt_kanji, pt_kanji, llt_kanji, llt_jcurr) %>%
      mutate(llt_currency = ifelse(all(llt_currency == "Y"),"Y","N"), num_coded = n(), num_approved = sum(!is.na(ApprovedByUser)), DictInstance = str_trim(str_split_fixed(DictInstance,",",2)[,2]), Version = ifelse(Version == "" | is.na(Version), DictInstance, Version), LastCodedOn = max(substr(as.character(CodedOnDate),1,10))) %>% 
      select(-ApprovedByUser, -DictInstance, -CodedOnDate) %>% 
      data.frame()
    utr_medDRA_J$Version <- sapply(utr_medDRA_J$Version, function(x) ifelse(grepl("^[0-9]", x),paste("Ver",x),x))
    utr_medDRA_J <- utr_medDRA_J %>% 
      group_by(Term, soc_kanji, hlgt_kanji, hlt_kanji, pt_kanji, llt_kanji, llt_jcurr, Version) %>% 
      mutate(ver_count = n()) %>% 
      distinct() %>% 
      select(num_coded, num_approved, Term, soc_kanji, hlgt_kanji, hlt_kanji, pt_kanji, llt_kanji, llt_currency, llt_jcurr, LastCodedOn, Version, ver_count) %>% 
      spread(Version, ver_count, fill = 0) %>%
      arrange(Term)
    
    verCols <- colnames(utr_medDRA_J)
    verCols <- verCols[-c(1:11)]
    utr_medDRA_J <- utr_medDRA_J %>% 
      group_by(Term) %>%
      mutate(Discrepancy = ifelse(n() > 1, "Yes", "No")) %>%
      ungroup() %>% 
      select(c("num_coded", "Term", "llt_kanji", "pt_kanji", "hlt_kanji", "hlgt_kanji", "soc_kanji", "llt_currency", "llt_jcurr", "Discrepancy", "LastCodedOn", all_of(verCols), "num_approved")) %>% 
      mutate(num_not_approved = num_coded - num_approved)
    colLabels <- as.list(c("# Coded terms", "Term", "LLT Kanji", "PT Kanji", "HLT Kanji", "HLGT Kanji", "SOC Kanji", "LLT Currency", "LLT JCurrency", "Coding Discrepancy", "Last term coded on", verCols, "# Coded terms approved", "# Coded terms not approved"))
    utr_medDRA_J <- prepareDataForDisplay(utr_medDRA_J)
    utr_medDRA_J <- setLabel(utr_medDRA_J, colLabels)
    
    widths <- rep(0, ncol(utr_medDRA_J))
    utr_medDRA_JColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(11))
    
    utrList <- append(utrList, list("UTR for MedDRA_J" = list("data" = utr_medDRA_J, "columnDefs" = utr_medDRA_JColumnDefs)))
  }
  
  # UTR for ATC without DDD ----
  if (ncol(atc) > 0 && nrow(atc) > 0) {
    colsToFactor <- c("SiteSeq", "SiteCode", "SubjectSeq", "EventSeq", "FormSeq", "SubjectFormSeq", "OriginSubjectFormSeq", "SourceSubjectFormSeq", "CodeSeqNumber")
    atc_raw <- prepareDataForDisplay(atc, c("SiteName", colsToFactor))
    atc_raw <- setLabel(atc_raw, as.list(getLabel(atc)))
    colsToFactor <- c(colsToFactor, "EventDate", "CodedOnDate", "ApprovedOnDate")
    dictList <- append(dictList, list("ATC without DDD" = list("data" = atc_raw, "columnDefs" = getColumnDefs(colwidths = rep(0, ncol(atc_raw)), alignRight = which(colnames(atc_raw) %in% colsToFactor)))))
    utr_atc <- atc %>% 
      mutate(Term = toupper(gsub("\\s+", " ", str_trim(Term)))) %>% 
      select(Term, L1name, L2name, L3name, L4name, L5name, L5code, ApprovedByUser, DictInstance, Version, CodedOnDate) %>% 
      group_by(Term, L1name, L2name, L3name, L4name, L5name, L5code) %>%
      mutate(num_coded = n(), num_approved = sum(!is.na(ApprovedByUser)), DictInstance = str_trim(str_split_fixed(DictInstance,",",2)[,2]), Version = ifelse(Version == "" | is.na(Version),DictInstance,Version), LastCodedOn = max(substr(as.character(CodedOnDate),1,10))) %>% 
      select(-ApprovedByUser, -DictInstance, - CodedOnDate) %>% 
      data.frame()
    utr_atc$Version <- sapply(utr_atc$Version, function(x) ifelse(grepl("^[0-9]", x),paste("Ver",x),x))
    utr_atc <- utr_atc %>% 
      group_by(Term, L1name, L2name, L3name, L4name, L5name, L5code, Version) %>% 
      mutate(ver_count = n()) %>% 
      distinct() %>% 
      select(num_coded, num_approved, Term, L1name, L2name, L3name, L4name, L5name, L5code, LastCodedOn, Version, ver_count) %>% 
      spread(Version, ver_count, fill = 0) %>%
      arrange(Term)
    
    verCols <- colnames(utr_atc)
    verCols <- verCols[-c(1:10)]
    utr_atc <- utr_atc %>% 
      group_by(Term) %>%
      mutate(Discrepancy = ifelse(n() > 1, "Yes", "No")) %>%
      ungroup() %>% 
      select(c("num_coded", "Term", "L5name", "L5code", "L4name", "L3name", "L2name", "L1name", "Discrepancy", "LastCodedOn", all_of(verCols), "num_approved")) %>% 
      mutate(num_not_approved = num_coded - num_approved)
    colLabels <- as.list(c("# Coded terms", "Term", "L5 Name", "L5 Code", "L4 Name", "L3 Name", "L2 Name", "L1 Name", "Coding Discrepancy", "Last term coded on", verCols, "# Coded terms approved", "# Coded terms not approved"))
    utr_atc <- prepareDataForDisplay(utr_atc)
    utr_atc <- setLabel(utr_atc, colLabels)
    
    widths <- rep(0, ncol(utr_atc))
    utr_atcColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(10))
    
    utrList <- append(utrList, list("UTR for ATC without DDD" = list("data" = utr_atc, "columnDefs" = utr_atcColumnDefs)))
  }
  
  # UTR for IDF ----
  if (ncol(IDF) > 0 && nrow(IDF) > 0) {
    colsToFactor <- c("SiteSeq", "SiteCode", "SubjectSeq", "EventSeq", "FormSeq", "SubjectFormSeq", "OriginSubjectFormSeq", "SourceSubjectFormSeq", "L1DrugCode", "L2DrugCode", "L3DrugCode", "L4DrugCode", "CodeSeqNumber", "L5DrugCode", "L5UseCategory1", "L5ManufacturerCode", "L5DosageFormCode", "L5DrugCodeCategory1", "L5MaintenanceYears", "L6DrugCode", "L6UseCategory1", "L6ManufacturerCode", "L6DosageFormCode", "L6DrugCodeCategory1", "L6MaintenanceYears")
    IDF_raw <- prepareDataForDisplay(IDF, c("SiteName", colsToFactor))
    IDF_raw <- setLabel(IDF_raw, as.list(getLabel(IDF)))
    colsToFactor <- c(colsToFactor, "EventDate", "CodedOnDate", "ApprovedOnDate")
    dictList <- append(dictList, list("IDF" = list("data" = IDF_raw, "columnDefs" = getColumnDefs(colwidths = rep(0, ncol(IDF_raw)), alignRight = which(colnames(IDF_raw) %in% colsToFactor)))))
    utr_IDF <- IDF %>% 
      mutate(Term = toupper(gsub("\\s+", " ", str_trim(Term)))) %>% 
      select(Term, L1DrugName, L2DrugName, L3DrugName, L4DrugName, L5DrugName, L6DrugName, L6GenericName, ApprovedByUser, DictInstance, Version, CodedOnDate) %>% 
      group_by(Term, L1DrugName, L2DrugName, L3DrugName, L4DrugName, L5DrugName, L6DrugName, L6GenericName) %>%
      mutate(num_coded = n(), num_approved = sum(!is.na(ApprovedByUser)), DictInstance = str_trim(str_split_fixed(DictInstance,",",2)[,2]), Version = ifelse(Version == "" | is.na(Version), DictInstance, Version), LastCodedOn = max(substr(as.character(CodedOnDate),1,10))) %>% 
      select(-ApprovedByUser, -DictInstance, -CodedOnDate) %>% 
      data.frame()
    utr_IDF$Version <- sapply(utr_IDF$Version, function(x) ifelse(grepl("^[0-9]", x),paste("Ver",x),x))
    utr_IDF <- utr_IDF %>% 
      group_by(Term, L1DrugName, L2DrugName, L3DrugName, L4DrugName, L5DrugName, L6DrugName, L6GenericName, Version) %>% 
      mutate(ver_count = n()) %>% 
      distinct() %>% 
      select(num_coded, num_approved, Term, L1DrugName, L2DrugName, L3DrugName, L4DrugName, L5DrugName, L6DrugName, L6GenericName, LastCodedOn, Version, ver_count) %>% 
      spread(Version, ver_count, fill = 0) %>%
      arrange(Term)
    
    verCols <- colnames(utr_IDF)
    verCols <- verCols[-c(1:11)]
    utr_IDF <- utr_IDF %>% 
      group_by(Term) %>%
      mutate(Discrepancy = ifelse(n() > 1, "Yes", "No")) %>%
      ungroup() %>% 
      select(c("num_coded", "Term", "L6GenericName", "L6DrugName", "L5DrugName", "L4DrugName", "L3DrugName", "L2DrugName", "L1DrugName", "Discrepancy", "LastCodedOn", all_of(verCols), "num_approved")) %>% 
      mutate(num_not_approved = num_coded - num_approved)
    colLabels <- as.list(c("# Coded terms", "Term", "L6 Generic Name", "L6 Drug Name", "L5 Drug Name", "L4 Drug Name", "L3 Drug Name", "L2 Drug Name", "L1 Drug Name", "Coding Discrepancy", "Last term coded on", verCols, "# Coded terms approved", "# Coded terms not approved"))
    utr_IDF <- prepareDataForDisplay(utr_IDF)
    utr_IDF <- setLabel(utr_IDF, colLabels)
    
    widths <- rep(0, ncol(utr_IDF))
    utr_IDFColumnDefs <- getColumnDefs(colwidths = widths, alignRight = c(11))
    
    utrList <- append(utrList, list("UTR for IDF" = list("data" = utr_IDF, "columnDefs" = utr_IDFColumnDefs)))
  }
  reportOutput <- append(dictList, utrList)
  }

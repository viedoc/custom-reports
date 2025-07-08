## Viedoc Custom Report - Outliers

# This report serves as an example on how to identify statistical outliers in the data.

# This custom report will generate the following output:
# Sub-report "Systolic BP": A table listing outliers in the systolic blood pressure data.
# Sub-report "Diastolic BP": A table listing outliers in the diastolic blood pressure data.


# Create vs dataframe from Vital Signs form data
vs <- edcData$Forms$VS

# Check if any data exists
# if data exists, calculate z-scores for systolic and diastolic blood pressure and add to vs data frame
# if no data exists, create empty data frame with expected number of columns
if(!is.null(vs)){
  vs <- mutate(vs, sysBP_zScores = as.vector(scale(SYSBP_VSORRES)), diaBP_zScores = as.vector(scale(DIABP_VSORRES)))
} else{
  vs <- data.frame(matrix(ncol = 9, nrow = 0))
  colnames(vs) <- c("sysBPOutliers", "SiteName", "SiteCode", "SubjectId", "EventName", "EventDate", "SYSBP_VSORRES", "sysBP_zScores", "diaBP_zScores")
}

# Set a hardcoded threshold (in standard deviations) for the z-scores
threshold <- 2

# Create data frames of the outliers for each of the systolic and diastolic measurements
sysBPOutliers <- filter(vs, abs(sysBP_zScores) > threshold)
diaBPOutliers <- filter(vs, abs(diaBP_zScores) > threshold)

# Checking if data exists after filtering steps (i.e, if there are any outliers)
# if data exists, setting up the column labels and showing appropriate footer text
# if no data exists, creating expected data frame and showing appropriate footer text
if(nrow(sysBPOutliers)>0){
  sysBPOutliers <- select(sysBPOutliers, SiteName, SiteCode, SubjectId, EventName, EventDate, SYSBP_VSORRES)
  sysBPOutliers_label = as.list(getLabel(sysBPOutliers))
  sysBPOutliers = prepareDataForDisplay(sysBPOutliers)
  sysBPOutliers = setLabel(data = sysBPOutliers, labels = sysBPOutliers_label)
  sysOut_footerText = paste("Outliers listed above include data beyond", threshold, "standard deviations.")
} else{
  sysBPOutliers <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(sysBPOutliers) <- c("sysBPOutliers", "SiteName", "SiteCode", "SubjectId", "EventName", "EventDate", "SYSBP_VSORRES")
  sysOut_footerText = paste("No outliers beyond", threshold, "standard deviations.")
}

if(nrow(diaBPOutliers)>0){
  diaBPOutliers <- select(diaBPOutliers, SiteName, SiteCode, SubjectId, EventName, EventDate, SYSBP_VSORRES)
  diaBPOutliers_label = as.list(getLabel(diaBPOutliers))
  diaBPOutliers = prepareDataForDisplay(diaBPOutliers)
  diaBPOutliers = setLabel(data = diaBPOutliers, labels = diaBPOutliers_label)
  diaOut_footerText = paste("Outliers listed above include data beyond", threshold, "standard deviations.")
} else{
  diaBPOutliers <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(diaBPOutliers) <- c("diaBPOutliers", "SiteName", "SiteCode", "SubjectId", "EventName", "EventDate", "DIABP_VSORRES")
  diaOut_footerText = paste("No outliers beyond", threshold, "standard deviations.")
}

# Final output
reportOutput = list(
  "Systolic BP" = list("data" = sysBPOutliers, footer = list(text = sysOut_footerText, displayOnly = TRUE)),
  "Diatolic BP" = list("data" = diaBPOutliers, footer = list(text = diaOut_footerText, displayOnly = TRUE)))
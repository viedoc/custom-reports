#simple report to display outliers of blood pressure
#written by Lyle Wiemerslage 2024 Jan 08 version 1.0
#should work for any study following CDASH nomenclature

#create vs dataframe from Vital Signs form data
vs <- edcData$Forms$VS

#calculate z-scores for systolic and diastolic blood pressure and add to vs data frame
vs = mutate(vs, sysBP_zScores=as.vector(scale(SYSBP_VSORRES)), diaBP_zScores=as.vector(scale(DIABP_VSORRES)))

#set a hardcoded threshold (in standard deviations) for the z-scores
threshold = 2

#create data frames of the outliers for each of the systolic and diastolic measurements
sysBPOutliers = filter(vs, abs(sysBP_zScores)>threshold)
diaBPOutliers = filter(vs, abs(diaBP_zScores)>threshold)

#selecting only specific columns to display
sysBPOutliers=select(sysBPOutliers, SiteName, SiteCode, SubjectId, EventName, EventDate, SYSBP_VSORRES)
diaBPOutliers=select(diaBPOutliers, SiteName, SiteCode, SubjectId, EventName, EventDate, DIABP_VSORRES)

#changing the column headers from the item ID to the item label
sysBPOutliers_label = as.list(getLabel(sysBPOutliers))
diaBPOutliers_label = as.list(getLabel(diaBPOutliers))

#making things look pretty
sysBPOutliers = prepareDataForDisplay(sysBPOutliers)
diaBPOutliers = prepareDataForDisplay(diaBPOutliers)

#Getting label
sysBPOutliers = setLabel(data = sysBPOutliers, labels = sysBPOutliers_label)
diaBPOutliers = setLabel(data = diaBPOutliers, labels = diaBPOutliers_label)

#adding explanatory footer text
Out_footerText = paste("Outliers listed above include data beyond", threshold, "standard deviations.")

#final output
reportOutput = list(
  "Systolic BP" = list("data" = sysBPOutliers, footer = list(text = Out_footerText, displayOnly = TRUE)),
  "Diatolic BP" = list("data" = diaBPOutliers, footer = list(text = Out_footerText, displayOnly = TRUE)))


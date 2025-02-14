# Custom Reports for Viedoc Reports
## Introduction
Viedoc Reports is an integrated Viedoc application for viewing and analysing study progress and performace, allowing data to be browsed and visualised in reports and graphs.

While most usecases are covered by the provided reports, custom reports can be developed. These reports are configured as a single R script, which is run on-demand to ensure up-to-date visualisations.

This repository aims to provide additional support to the eLearning through examples and more in-depth documentation.


## Setup

<details>

### Pre-requisits
- access to Viedoc Reports and Viedoc Designer 
- an implemented study in Viedoc clinic (training or production)
- [R](https://cran.rstudio.com/) version 4.04 or later optionally with an R IDE such as [R Studio](https://posit.co/products/open-source/rstudio/)

### Downloading the package
A .zip package for creating custom reports is downloaded from the Settings menu, found in the upper right corner of Viedoc Reports. This package is only available for users with access to the Reports page.

![reports_settings_menu](https://github.com/viedoc/custom-reports/assets/settings_menu_4_72.png?raw=true)

By clicking Download data for custom reports, and following the instructions on the screen, the .zip package is downloaded to your computer.

![reports_settings_menu](https://github.com/viedoc/custom-reports/assets/custom_reports_4_72.png?raw=true)

The .zip package consists of the following files that are to be used as support when writing your custom reports:

|file|description|
|-|-|
|edcData.rds| This file contains sample data from the study, including CRF data and operational data, such as queries, processedqueries, reviews, signature, database lock, timelapse, and so on.| 
| params.rds | **- Date of download:** the date and time at which the data was pulled from Viedoc to the Reports server   <br> **- Study Name**  <br>  **- Study Type**  <br>  **- Study Level Data:** ExpectedNumberOfScreenedSubjects, expectedNumberOfEnrolledSubjects,  expectedDateOfCompleteEnrollment, totalNumberOfStudySites, totalNumberOfUniqueCountries  <br> **- Site Level Data:** siteNumber, siteCode, siteName, countryCode, country, timeZone, timezoneOffset, siteType, expectedNumberOfSubjectsScreened, expectedNumberOfSubjectsEnrolled, maximumNumberOfSubjectsScreened <br>  <br> The list of sites in the "Site Level Data" is based on the user’s access to the study.|
| SampleReportCode.R | This is a sample report with explanations of the report structure. The code is a sample to give an idea to the user on how to write a report code, its corresponding inputs, and the structure of the output. This file also contains a list of R packages available for the user.<br><br> For information and a code snippit for available R packages, open this file, scroll down to find a section called "Sample Code". This code snippit can be used to generate a custom report which identifies available R packages and versions supported by custom reports.|
| utilityFunctions.R | This file contains various functions that are provided in the runtime environment and can be used when writing the custom report.|

### Setting up a local coding environment
Ensure that you have R installed on your computer. An IDE such as R Studio can streamline the development process.

Unzip the folder that was downloaded.

The following code downloads and installs the packages that are available for use in the Viedoc Reports runtime environment. This only needs to be done once. It can be run in a script or directly in the R terminal.

```
install.packages(c( "vctrs", "R6", "generics", "glue", "lifecycle", "magrittr", "tibble", "ellipsis", "pillar", "crayon", "pkgconfig", "tidyselect", "purrr", "Rcpp", "tidyr", "dplyr", "rlang", "lubridate", "stringr", "stringi", "plotly", "survival", "xml2"))
```

In your R development environment (e.g. R Studio), open a new file for your report code and save it to the same folder as the downloaded files.

The following code loads the installed packages into the working environment, sets a working directory, imports the utility functions, and reads in the data from the demo study.

```
library(vctrs)
library(R6)
library(generics)
library(glue)
library(lifecycle)
library(magrittr)
library(tibble)
library(ellipsis)
library(pillar)
library(crayon)
library(pkgconfig)
library(tidyselect)
library(purrr)
library(Rcpp)
library(tidyr)
library(dplyr)
library(rlang)
library(lubridate)
library(stringr)
library(stringi)
library(plotly)
library(survival)
library(xml2)

setwd("C:\\Users\\SvenSvensson\\Downloads\\SampleForCustomReports")
source("utilityFunctions.R", local = T)
edcData <- readRDS("edcData.rds")
params <- readRDS("params.rds")
metadata <- readRDS("metadata.rds")
```

> [!IMPORTANT] 
> Make sure to change the file path in `setwd` to point to the folder where your custom report is stored.

The above code must be commented out (using a `#` symbol in front of each line of text) or deleted before uploading your script to Viedoc.

</details>

## Available Data/Valid inputs
<details>

### edcData

This variable is a list that contains the CRF data and operational data.
- edcData$Forms$[form id] will be a data.frame that contains the CRF data of that particular form. eg. edcData$Forms$DM will have the data from Demographics form

### Operational data

edcData$[operational data name] will be data.frames that contain operational data. 

- edcData$EventDates: Contains one record per visit and itscorresponding dates for each subject
- edcData$Queries: Contains one record per query per status alongwith its status remarks and dates
- edcData$ReviewStatus: Contains one record per visit and form andhas the statuses for DM Review, Clinical Review, Signature, and Lock
- edcData$SubjectStatus: Contains one record per subject along withthe screening, enrollment, withdrawal status
- edcData$PendingForms: Contains one record per pending form
- edcData$TimeLapse: Contains one record per form with lapse days(number of days between the event date and the data entry start date)
- edcData$Items: Contains one record per item with ID, label,datatype, content length and other details.
- edcData$CodeLists: Contains one record per code text with formatname, datatype and code value.
- edcData$ProcessedQueries: Contains one record per query (processedacross the status)
  - QueryStudySeqNo
  - SiteSeq
  - SiteName
  - SiteCode
  - SubjectSeq
  - SubjectId
  - EventSeq
  - EventId
  - EventName
  - EventDate
  - ActivityId
  - ActivityName
  - FormId
  - FormName
  - FormSeq
  - SubjectFormSeq
  - OriginSubjectFormSeq
  - SourceSubjectFormSeq
  - ItemId
  - ItemName
  - QueryItemSeqNo
  - RaisedOn
  - QueryType
  - RangeCheckOID
  - QueryText
  - PrequeryText: Query text for the prequery raised
  - UserName: Username for the person who raised the query/ who left the field blank 
  - QueryResolution
  - ClosedByDataEdit: Value is 'Yes', if on filtering Queries EDC where a single query can have multiple records, the text 'Query closed due to data edit' is present for any Query State in Query Resolved, Query Rejected, Query Approved, Query Closed.
  - QueryResolutionHistory
  - QueryStatus
  - PrequeryPromoted
  - PrequeryPromotedBy
  - PrequeryRaised
  - PrequeryRaisedBy
  - PrequeryRejected
  - PrequeryRejectedBy
  - PrequeryRemoved
  - PrequeryRemovedBy
  - QueryApproved
  - QueryApprovedBy
  - QueryClosed
  - QueryClosedBy
  - QueryRaised
  - QueryRaisedBy
  - QueryRejected
  - QueryRejectedBy
  - QueryRemoved
  - QueryRemovedBy
  - QueryResolved
  - QueryResolvedBy
  - QueryClosed_C
  - OpenQueryAge: Difference between the Query Raised date and current date for query in 'Query Raised' state
  - ResolvedQueryAge: Difference between the Query Resolved date and current date for query in 'Query Resolved' state
  - PrequeryAge: Difference between the Prequery Raised date and current date for prequery in 'Prequery Raised' or 'Prequery Promoted' states
  - TimeToResolution: Difference between the Query Raised date and Query Resolved/ Query Closed date
  - TimeToApproval: Difference between the Query Resolved date and Query Approved/ Query Rejected date;
  - TimeToRelease: Difference between the Prequery Raised date and Prequery Rejected/Removed/Released(Query Raised) date
  - TimeofQueryCycle: Difference between the Query Raised date and Query Approved/ Query Rejected/ Query Closed date
  - TimeToRemoval
  - RaisedMonth
  - ResolvedMonth
  - RemovedMonth
  - LatestActionBy
  - LatestActionOn
  
### params
This variable is a list that contains the below listed study and user parameters
params$dateOfDownload - Contains date and time at which the data waspulled from Viedoc Clinic.

- params$UserDetails$studyinfo: Contains the studyName and studyType
- params$UserDetails$studysettings: Contains the study level parameters:
  - expectedNumberOfScreenedSubjects: Expected number of subjects to be screened
  - expectedNumberOfEnrolledSubjects: Expected number of subjects to be enrolled 
  - expectedDateOfCompleteEnrollment: Expected date of 100% enrollment
  - totalNumberOfStudySites: Total number of sites
  - totalNumberOfUniqueCountries: Total number of countries
- params$UserDetails$sites: Contains a data.frame with one record per site and includes the site level parameters:
  - expectedNumberOfSubjectsScreened: Expected number of subjects to be screened
  - expectedNumberOfSubjectsEnrolled: Expected number of subjects to be enrolled
  - maximumNumberOfSubjectsScreened: Maximum number of subjects that can be screened

### metadata 
This variable is a list that contains the ODM elements information.
- metadata$MDVOIDs: Contains the design versions applied in thestudy.
- metadat$GlobalVariables: A data.frame that has the information onStudyName, StudyDescription and ProtocolName.
- metadata$BasicDefinitions: A data.frame that has information onany definitions used in the study(Columns: Definition, OID and Name).
- metadata$StudyEventRef: Contains the order of a Study Eventpresent across the design versions(Data.frame with columns MDVOID,StudyEventOID, OrderNumber and Mandatory).
- metadata$StudyEventDef: Contains Study Event Definitions appliedacross the design versions(Data.frame with columns MDVOID, OID,Name, Repeating, Type and Category).
- metadata$FormRef: Contains details on the Forms added in an Eventacross the design versions(Data.frame with columns MDVOID,StudyEventOID and FormOID).
- metadata$FormDef: Contains Form Definitions applied across thedesign versions of a study (Data.frame with columns MDVOID, OID,Name, Repeating, Sdv and Hidden).
- metadata$ItemGroupRef: Contains details of the ItemGroups insidea form across design versions(Data.frame with columns MDVOID,FormOID and ItemGroupOID.
- metadata$ItemGroupDef: Contains details of ItemGroup definitionsapplied across design versions(Data.frame with columns MDVOID, OID,Name, Repeating, IsReferenceData, SASDatasetName, Domain, Origin,Purpose and Comment).
- metadata$ItemRef: Contains details of the Items within anItemGroup(Data.frame with columns MDVOID, ItemGroupOID and ItemOID).
- metadata$ItemDef: Contains the Item definitions applied acrossdesign versions(Data.frame with columns MDVOID, OID, Name, DataType,Length, SignificantDigits, SASFieldName, SDSVarName, Origin,Comment, Question, MeasurementUnitOID, CodeListOID, HtmlType and Sdv.
- metadata$CodeList: Contains the CodeList information as a dataframe with columns MDVOID, OID, Name, DataType, SASFormatName,CodeListType, CodedValue, DecodedValue, Rank and OrderNumber.
- metadata$RolesDef: Contains the Roles defined in the study acrossdesign versions and their permissions(Data.frame with columnsMDVOID, OID, Name and Permissions).
- metadata$SDVSettings: Contains details about the SDVScope setacross design versions as a data.frame with columns MDVOID andSDVScope.
- metadata$formitems: Contains summarized information of Form andItem information(Data.frame with columns OID, FormOID, FormName,Hidden, ItemGroupOID, ItemOID, Name, DataType, Length,SignificantDigits, SASFieldName, SDSVarName, Origin, Comment,Question, MeasurementUnitOID, CodeListOID, HtmlType and Sdv).

</details>

## Utility functions
see [utilityFunctions.R]

## Output 
<details>
`reportOutput` - This variable should contain the final output that needs to bedisplayed in the screen
This variable is a list. There should be one or more entry inthe list.
Each entry will be made available via a drop-down menu (Similarto "by Country", "by Site', "by Subject" drop-down in theEnrollment Status report)

An example of a single output: 
  
```R 
reportOutput <- list("Name of output" = list("data" = data.frame()))
```

The "Name of output" will be displayed in the screen via a drop-down menu(incase of more than one entry). On selecting that output, the data.frame in the above entry will be displayed in the screen.
An example of two outputs:

```R 
reportOutput <- list(
                   "Name of first output" = list("data" = data.frame()),
                   "Name of second output" = list("data" = data.frame())
                 )
```

Two outputs (one data frame and another plotly)

```R 
reportOutput <- list(
                  "Name of first output" = list("data" = data.frame()),
                  "Name of second output" = list("plot" = plot_ly())
                )
```

> [!NOTE] 
> The name of the list entry containing the data.frame should be named"data" and the plot should be named "plot", as given in above examples. Custom report supports only plot_ly plots. 
> Please refer to https://plotly.com/r/reference/ for help on plotly plots.

The following parameters can be passed to the  `reportOutput` variable to improve how the report displays

### Footer
A footer to the output table can be included as given in the below example:

```R 
reportOutput <- list("by Country" = list("data" = data.frame(), footer =list(text = "Additional notes to the table", displayOnly = TRUE)))
```

The footer text can include HTML tags. 
eg. `"This footer text <strong>emphasises</strong> a word"` renders like this: "This footer text <strong>emphasises</strong> a word"

`displayOnly` - a logical parameter that affects how the custom report behaves on download.

If `TRUE`, the footer will be displayed, but ignored when the report is downloaded. If `FALSE`, the footer will beincluded in the download.

If "displayOnly" is not mentioned, by default it is considered to be FALSE
For a plot output, if "`displayOnly = FALSE`", then please use plotly `bottommargin` (refer the example code below) to sufficiently display the note in the plot

### Custom headers
Normally, the data.frame column labels will be used as table header.However, the column labels can be overridden using the header feature asgiven below:

```R 
newHeader <- list(firstLevel = c("Study", "Country", "Site Code", "SiteName", "Subject", "Screened", "Enrolled", "Candidate", "Ongoing","Completed", "Withdrawn"))
reportOutput <- list("by Country" = list("data" = data.frame(), header =newHeader))
```

Two levels of header can be set for a table as given below:
```R
 twoLevelHeader <- list(
   firstLevel = c("Column 1", "Column 2", rep("Covers Columns 3, 4, 5", 3), "Column 6, "Column 7", rep("Covers Columns 8, 9", 2)),
   secondLevel = c("Column 3", "Column 4", "Column 5", "Column 8", "Column 9")
 )
 reportOutput <- list("by Country" = list("data" = data.frame(), header = twoLevelHeader))
```

The above code will render a header as shown below:

```
--------------------------------------------------------------------------------------------------
                    |     Covers Columns 3, 4, 5     |                     | Covers Columns 8, 9 | 
-------------------------------------------------------------------------------------------------
Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column7 | Column 8 | Column 9 | 
-------------------------------------------------------------------------------------------------
```

> [!CAUTION]
> If the wrong number of names are provided for the header parameter, it will revert to the labels included in the table.

### Custom column widths
The column width can be defined for all or selected columns as give below:

```R
outputdata <- data.frame() # Output data

widths <- rep(0, ncol(outputdata)) # set all columns to auto width
widths[2] <- 105 # Set 2nd column to 105 px
widths[5] <- 90 # Set 5th column to 90 px
widths[6:11] <- 60 # Set columns 6 to 11 to 60 px

newcolumnDefs <- getColumnDefs(colwidths = widths)

reportOutput <- list(
  "by Country" = list("data" = outputdata, columnDefs =newcolumnDefs)
  )
```
</details>

## Upload the script
When finished, the R file uploads in the Global design settings of Viedoc Designer. For more information, see [Configuring Viedoc Reports](https://help.viedoc.net/c/e311e6/326d81/en/). The custom report is then selectable for users with permissions to see it in Viedoc Reports.

## Data sync between EDC and Viedoc Reports
The ProcessedQueries dataset will be updated to include the new columns __only when there is a new sync with the EDC__. For production studies this happens automatically every day, as long as there has been a data change. For training studies, and for production studies without data modification in the past 24 hours, there will be no automatic data sync. As soon as the data is synced after the release, the new columns in the ProcessedQueries dataset are populated correctly and the standard reports using data will also display correctly.

Until the data has synced, the new Queries reports, and other reports that use data from the ProcessedQueries dataset, such as Missing Data, Form Status, PMS, and KRI will result in error/incorrect data. This is because they use the old ProcessedQueries data from Viedoc 4.79 and earlier, which would not have the required columns/column values for populating all reports.

## Included Examples:

### Visualisation demos
> These are basic examples of how to achieve certain layouts using the graphing package [Plotly](https://plotly.com/r/). These can be used as a guide when developing custom reports 

- [Plot and table](./graphing-demos/Plot_and_table.R)
- [Plot with dropdowns](./graphing-demos/Plot_with_dropdown.R)
- [Plot with filters](./graphing-demos/plotly_filter_buttons.R)

### Study-independent functional reports:
> These reports can be added to any study without modification for additional monitoring functionality. They use system-generated data as inputs. 

- [locked form with issues](./functional-reports/locked-issues/locked_forms_with_issues.R)
- [Old queries](./functional-reports/aging_queries/Old_Query_Aging_Standard_Report.R)
- 
### Use cases for a demo design
> The example 'use case' reports have been developed for the [Phase II study design template](StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml) included in this directory. Some 
reports depend on a more specilased design, which will be included in the folder. These examples also demonstrate testing and QC of custom reports, using test cases.

- [Ongoing Adverse Events](./example-reports/ongoing-AEs/ongoingAEs.R): how to select data that fulfills certain criteria (adverse events that were recorded as ongoing) and data sorting.
- [Treatment-related Severe Adverse Events](./example-reports/treatment-related-SAEs/treatmentRelatedSAEs.R): how to select data that fulfills certain criteria (adverse events that were recorded as (possibly) treatment-related and serious) and summarising the data by site.
- [Serious Adverse Events by demograpahics](./example-reports/demographics-SAEs/saeDemographics.R): select data that fulfills certain criteria (adverse events that were recorded as serious) and how to combine this with data from a different form (in this case, a few data points from the Demographics form).
- [Blood Pressure](./example-reports/blood-pressure/bloodPressurePlot.R): simple scatter plots as subreports using the plotly package
- [Drug Accountability](./example-reports/drug-accountability/drugAccountability.R): monitoring of kit allocation and returns
- [Medication Inconsistency](./example-reports/medication-inconsistency/medicationInconsistency.R): relationship between concommitant medication forms and adverse event forms
- [Outliers](/example-reports/outliers/outliers.R): how to identify statistical outliers in the data
- [Survival Curve](./example-reports/survival-curve/survivalCurvePlotKaplanMeier.R): how to perform a survival analysis using the Survival package, and a more complicated plot using the plotly package.


#### To use:
1. In Viedoc Admin, create a new study. Assign a designer and allow Reports in Design Settings.
2. Import the study design template into Designer and Publish, and in Global design settings, set access to reports, upload the custom report and publish these settings.
3. In Viedoc Admin, create demo sites and assign an investigator and role with permission to see the reports.
4. If running tests, open reports to test custom script with no initialised data
5. Otherwise, as an investigator in Viedoc Clinic add test subjects, inputing data for any forms used by the script.
6. In order to manually sync data between Clinic and reports, disable reports in Admin Study Settings, wait an hour, and reenable it. The training server does not automatically sync reports.


## Available packages
The R script for a custom report is run in a managed environment which may be different to your development environment. It is important to therefore be aware of what R packages (and their versions) the script can access. At the time of writing, the deployed R version is 4.04.

In order to confirm the package versions used on your system and on in the Viedoc runtime environment, use the following script.

```R
packagesInstalled <- installed.packages()

packageVersions <- data.frame(
  Package = packagesInstalled[,"Package"],
  Version = packagesInstalled[,"Version"],
  stringsAsFactors = FALSE
  )

reportOutput <- list("Packages" = list("data" = packageVersions))
```

## Actions to avoid

Please exercise caution to avoid below scenarios in your code:
- Infinite loops
- Data manipulation that might yield huge incorrect data ending up taking unnecessary disk space
- Any tampering with the host system properties and performance
- Below list of functions are blocked:
  - `system`
  - `system2`
  - `dir.create`
  - `library`
  - `require`
  - `Sys.sleep`
  - `unlink`
  - `file.remove`
  - `file.rename`
  - `tempdir`
  - `detach`
  - `file.copy`
  - `file.create`
  - `file.append`
  - `setwd`

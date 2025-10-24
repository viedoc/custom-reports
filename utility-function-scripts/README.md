# Utility and development tools

## Purpose
Provide access to reusable helper functions to speed up development, validation, and troubleshooting custom Viedoc Reports.

## Prerequisites
- Local environment prepared with the [development starter kit](../development-starter-kit/README.md) or equivalent R setup.
- Access to Viedoc report data objects (`edcData`, `metadata`, `params`).

## Instructions / Usage notes
### Preloaded utility functions
`utilityFunctions.R` contains core helpers such as `isValid()`, `prepareDataForDisplay()`, `setNAtoBlank()`. These are preloaded into the the Viedoc Reports server, and can be used as-is. The function below can be used to load the functions into your local development environment. The script has been included for reference, and note that the script file included in the downloaded sample zip will be up-to-date with the current live Reports system.

```r
source("utility-function-scripts/utilityFunctions.R", local = TRUE)
```

<details><summary>isValid </summary>  
    
```R
isValid(x)
```

- Purpose: 
  - Check whether a value is valid
- Input parameters:
  -  any
- Returns:
  - logical: TRUE:
    - 1.
      - is not atomic
    - 2. OR
      - is atomic AND
      - is not null AND
      - all is not NA AND
      - is not character or logical when vector contains no empty strings, omitting NA
  - logical: FALSE:
    - 1.
      - is atomic AND
      - is null
    - 2. OR
      - is atomic AND
      - is not null AND
      - all is NA
    - 3. OR
      - is atomic AND
      - is not null AND
      - all is not NA AND
      - is character OR Logical AND vector contains no empty strings when omitting NA

</details>

<details><summary>validLevels </summary>  
    
```R
validLevels(vec, type = "", decreasing = T)
```

- Purpose:
  -  Get unique values in a character vector or factor. If the input argument is a factor, unique levels are extracted while dropping the levels that are not present in the input
- Input params:
  - Vec - the character vector or factor from which the unique values should be extracted
  - Type
     - if type is left blank, the result is sorted alphabetically.
     - if type == 'frequency', the result is sorted based on the frequency of the individual values in the input vector
  - Decreasing
    - if type is blank, this value is ignored.
    - If type == "frequency", then this value is used to identify the sort order of the frequency
- Return object
  - if type == "" & input is a factor, returns levels(vec)[levels(vec) %in% unique(vec)]
  - if type == "" & input is not a factor, returns sort(unique(vec))
  - if type == "frequency", returns names(sort(table(vec)[table(vec)!=0], decreasing = decreasing))
  - else returns character(0)

</details>
<details><summary>prepareDataForDisplay</summary>  
    
```R
prepareDataForDisplay(data, forceFactor = c(), forceCharacter = c(), blankText = "(blank)", retainFactor = c())
```

- Purpose: 
  - Prepare the data.frame for optimal display via the DT package
- Input parameters:
  - Data - data.frame that should be prepared for display
  - ForceFactor
    - a character vector of column names that should be forced as factor field.
    - This can be used to force SiteCode into character, without which it would default to numeric.
    - This will help in an optimal filtering feature for the numeric columns (dropdown instead of range filter)
  - forceCharacter - a character vector of column names that should be forced as character field.
    - Similar usage as forceFactor where there is a need to force a numeric field into character, but not factorize the data
    - If the column is not listed in this parameter, and if the data contains only numeric value, then the column will be rendered as numeric
  - blankText - value provided in this parameter will be used to replace blank values
  - retainFactor
    - The function will by default reapply factorization for all the factor fields, character fields (that are not part of forceCharacter),a nd fields that are listed in forceFactor. Hence, for fields that should not lose its assigned factor levels should be listed in this field
- output: 
  - data.frame (or same as input data object)

</details>

<details><summary>setNAtoBlank</summary>  

```R
setNAtoBlank(data, replaceWithText = "", forceCharacter = c())
```

- Purpose: 
  - Remove all NA fields and replace them with blank or substitute text
- Input parameters
  - data - input data.frame
  - replaceWithText - Substitute text to be used as replacement for blank values
  - forceCharacter - a characer vector of columns names that should be forced to character type instead of numeric
- Output: 
  - data.frame

</details>
<details><summary>getLabel</summary>  

```R
getLabel(data)
```    
   
- Purpose: 
  - Get the column labels of a data.frame as character vector
- Input parameters:
  - data - input data.frame
- Output: 
  - character vector

</details>
<details><summary>setLabel</summary>  

```R
setLabel(data, labels)
```   

- Purpose: 
  - Set the column labels of a data.frame
- Input parameters:
  - data - input data.frame
  - Labels 
    - a list of column labels. The number of columns in the data and the count of labels provided in this parameter should match
- Output: 
  - data.frame

</details>
<details><summary>getColumnDefs</summary>  

```R
getColumnDefs(colwidths = NA, data = NA, alignRight = NA, alignLeft = NA, alignCenter = NA)
```
- Purpose: 
  - Provide an easy way to define column widths for report outputs. Uses DT package
- Parameters:
  - colwidths - a numeric vector of column widths in pixels. Length of this parameter should match the count of columns in the data for which this will be used. This parameter is ignored if data is provided
  - data - if data if provided, then the column width is calculated based on the data
  - alignRight - a numeric vector of column numbers that should be right-aligned in display
  - alignLeft - a numeric vector of column numbers that should be left-aligned in display
  - alignCenter - a numeric vector of column numbers that should be center-aligned in display
  - NOTE: While using alignRight, alignLeft, or alignCenter, it is suggested to also include colwidths or data parameter for optimal result
- Output: 
  - list of column definitions as described in DT package.

</details>

### Building-block functions

All other functions in this folder will need the whole definition copy-pasted into your custom report script, and used as a building block during script development. 


<details><summary> <a href="./generate_empty_output.R"> generate_empty_output.R</a> </summary>
This utility provides a standardized way to return a placeholder output when no study data is available, or when a specific form has no records. This helps prevent downstream errors in custom reports by ensuring the `reportOutput` structure is always valid, even when empty.

-  `generate_empty_output(error_message, single_report_only = FALSE)`
   - Purpose: 
     - Generate a minimal placeholder `data.frame` wrapped in a valid report structure to ensure graceful fallback in empty data scenarios.
   - Parameters:
     - `error_message`: Message shown in the “Empty” column.
     - `single_report_only`: Logical. TRUE returns `list(data=...)`; FALSE returns multi-output wrapper.
   - Returns: 
     - list containing a one-row `data.frame`.
- `generate_data(edcData)`
   - Purpose: 
      - example report-generating function to demonstrate example `generate_empty_output()` usage .
   - Returns: 
      - Named list in valid `reportOutput` format irrespective of input data.
</details>


<details><summary>  <a href="./get_visit_metadata.R"> get_visit_metadata.R</a> </summary>


- Purpose: 
  - Build ordered, de-duplicated visit reference (`EventId`, `EventName`, `OrderNumber`). Consolidates and standardizes visit metadata across design versions, returning a clean visit order reference for joins.
- Parameters: 
  - `event_ref_data` (metadata$StudyEventRef), 
  - `event_def_data` (metadata$StudyEventDef).
- Returns: 
  - data.frame with ordered EventId/EventName.

</details>


<details><summary> <a href="./id_output_id_mismatches.R"> id_output_id_mismatches.R</a> </summary>

Identifies discrepancies between item output IDs (`SASFieldName`) and item IDs (`OID`) in metadata, which can prevent successful joins between `edcData` and `metadata`.
- Creates lookup table where `SASFieldName != OID`.
- Prioritizes latest design version.
- Provides lookup to map from output_id → item_id.

> Note: Does not handle duplicate output IDs robustly (selects first match).

</details>


<details><summary>  <a href="./get_most_recent_subject_status.R"> get_most_recent_subject_status.R</a> </summary>

- Purpose: 
  - Returns latest subject status record per subject. Retrieves each subject’s most recent status (e.g., Screened, Enrolled) from a subject status form for studies using custom subject status logic.
- Returns: 
  - Data frame with SubjectId and most recent SubjectStatus.
</details>


<details><summary> <a href="./get_queries_per_subject_form.R"> get_queries_per_subject_form.R</a> </summary>



- Purpose: 
  - Summarizes open or missing-data queries per subject-form. Filters to "Unconfirmed missing data" or "Query Raised", then returns earliest IssueDate and corresponding status.
- Parameters: 
  - `all_queries_df` (usually edcData$ProcessedQueries), `subject_event_form_join_cols` (join keys).
- Returns: 
  - Data frame with join keys + IssueStatus + IssueDate.

</details>


<details><summary> <a href="./set_label_from_map.R"> set_label_from_map.R</a> </summary>

Utility to rename output columns based on a mapping vector of `original_name = "Label"`.

- Purpose: 
  - Reorder and rename columns in a consistent, readable format.
- Parameters:
  - `df`: Input data frame.
  - `labels_map`: Named vector mapping input dataframe column names to the desiredd output labels.
- Returns: 
  - Renamed and reordered data frame.

</details>


<details><summary> <a href="./read_from_xlsx_export.R"> read_from_xlsx_export.R</a> </summary>

Allows Excel Data Exports from Viedoc Clinic to be read into R to replace `edcData.rds` for local testing.

> Note: Dates differ between Excel and Reports - e.g. Country column is not included in reports. 

</details>

<details><summary> <a href="./version_checker.R"> version_checker.R</a> </summary>

Creates a report table showing package versions in the Viedoc Reports environment for troubleshooting package discrepancies. Can be uploaded in Designer as-is.

</details>


## Outputs / Expected results
- Standardized helper functions available in your R session.
- Safer handling of empty datasets and metadata mismatches.
- Faster creation of presentation-ready report outputs.

## Additional resources
- [Repository overview](../README.md)
- [Available data objects](../available-data-objects/README.md)
- [Creating custom reports (Viedoc Learning)](https://help.viedoc.net/c/8a3600/6e9c82/en/)

## Notes
- Scripts rely on tidyverse packages included in the repository `renv.lock`; run `renv::restore()` if functions fail to load.
- Update documentation whenever you add or rename a helper to keep this index accurate.




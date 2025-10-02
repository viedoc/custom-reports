# Utilities and development tools

For more information on custom reports please go to <a href="https://help.viedoc.net/c/8a3600/6e9c82/en/" target="_blank" rel="noopener">Creating custom reports</a> in Viedoc Learning.

For additional information on example custom reports go to <a href="https://help.viedoc.net/c/8a3600/9fc73b/en/" target="_blank" rel="noopener">Custom reports examples</a> in Viedoc Learning.

## [utilityFunctions.R](./utilityFunctions.R)
Viedoc has developed some additional "utility functions" which are preloaded in the Viedoc Reports runtime environment to assist with data wrangling and presentation. These are functions available to any script loaded in the Viedoc Reports Server.
These functions can be loaded into local workspace using `source("utilityFunctions.R", local = T)` when the utilityFunctions.R script is located in the working directory.

Read more about each utility function, its purpose, and usage below:

<details><summary><h3>Utility functions</h3></summary>  

<details><summary>isValid </summary>  
    
```R
isValid(x)
```

- Purpose: Check whether a value is valid
- Input parameters: any
- Returns logical: 
  - TRUE: 
    - 1. 
      - is not atomic
    - 2. OR
      - is atomic AND 
      - is not null AND 
      - all is not NA AND 
      - is not character or logical when vector contains no empty strings, omitting NA
  - FALSE: 
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

- Purpose: Get unique values in a character vector or factor. If the input argument is a factor, unique levels are extracted while dropping the levels that are not present in the input
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
prepareDataForDisplay(data, forceFactor = c(), forceCharacter = c(), blankText = "(blank)", retainFactor = c()
```

- Purpose: Prepare the data.frame for optimal display via the DT package
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
- output: data.frame (or same as input data object)

</details>
<details><summary>setNAtoBlank</summary>  

```R
setNAtoBlank(data, replaceWithText = "", forceCharacter = c()
```

- Purpose: Remove all NA fields and replace them with blank or substitute text
- Input parameters
  - data - input data.frame
  - replaceWithText - Substitute text to be used as replacement for blank values
  - forceCharacter - a characer vector of columns names that should be forced to character type instead of numeric
- Output: data.frame

</details>
<details><summary>getLabel</summary>  

```R
getLabel(data)
```    
   
- Purpose: Get the column labels of a data.frame as character vector
- Input parameters: 
  - data - input data.frame
- Output: character vector

</details>
<details><summary>setLabel</summary>  

```R
setLabel(data, labels)
```   

- Purpose: Set the column labels of a data.frame
- Input parameters: 
  - data - input data.frame
- Labels - a list of column labels. The number of columns in the data and the count of labels provided in this parameter should match
- Output: data.frame

</details>
<details><summary>getColumnDefs</summary>  

```R
getColumnDefs(colwidths = NA, data = NA, alignRight = NA, alignLeft = NA, alignCenter = NA)
```

- Purpose: Provide an easy way to define column widths for report outputs. Uses DT package
- Parameters:
  - colwidths - a numeric vector of column widths in pixels. Length of this parameter should match the count of columns in the data for which this will be used. This parameter is ignored if data is provided
  - data - if data if provided, then the column width is calculated based on the data
  - alignRight - a numeric vector of column numbers that should be right-aligned in display
  - alignLeft - a numeric vector of column numbers that should be left-aligned in display
  - alignCenter - a numeric vector of column numbers that should be center-aligned in display
  - NOTE: While using alignRight, alignLeft, or alignCenter, it is suggested to also include colwidths or data parameter for optimal result
- Output: list of column definitions as described in DT package.

</details>
</details>

## [id_ouptut_id_mismatches.R](./id_ouptut_id_mismatches.R)
The purpose of this code snippet is to resolve issues that are caused when output field IDs are used for form items.  
These items are represented using the output field ID in edcData, but use the standard field_id/item_id in the metadata.  
This means that you cannot perform lookups between them. This script creates a lookup table between the SAS field name (output field id) and the item ID. 

> [!Note]
> Viedoc Designer does not control for conflicting Output IDs, and this script will likely not handle duplicate output field IDs.
> If there are multiple items with the same output ID, it will select the first field ID sorted by descending design version.
> There may also be issues when cross referencing formlink or checkbox items.

## [read_from_xlsx_export.R](./[read_from_xlsx_export.R)
This code snippet allows for the excel Data Exports from Viedoc Clinic to be read into R to replace the edcData.rds. 
This could be useful when testing specific a script on a specific dataset.

> [!Note]
> Dates are handled differently in Excel files and may therefore not be representative of the data available in Reports.  
> A country column is also available in edcData.rds/Reports, but not the data Export.
> The first row of the Excel spreadsheets containing field output labels is not imported.

## [version_checker.R](./version_checker.R)
This script creates a Viedoc Reports table that shows the versions of installed packages in the Viedoc Reports environment, when uploaded as a custom report in Designer.
If functions seem to be behaving differently in Viedoc Reports compared to your local environment, compare the package versions by running the script locally and viewing the packageVersions table.

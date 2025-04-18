# Development guide
[return to root README](./README.md)

## Available Data/Valid inputs
While developing, the edcData an, params and metadata .rds files represent data available in the Viedoc Reports environment. Instructions on how to obtain these files can be found in the [eLearning Designer User Guide](https://help.viedoc.net/c/e311e6/) article entitled "Creating custom reports". Detailed information on the data structure can be found by following the links below:
- [edcData](./data_obj/edcData.md) contains the CRF and operational data such as queries and medical coding. Note that only a sample of subject data is provided, but the subtables contained will be unique to the study. 
- [params](./data_obj/params.md) contains data from Viedoc Administrator, including study, site and user information
- [metadata](./data_obj/metadata.md) contains data from Viedoc Designer and is linked to the design version.

## Output Object

`reportOutput` - This variable should contain the final output that needs to bedisplayed in the screen.  It is a list of lists
This variable is a list. There should be one or more entry in the list.  
Each entry is a 'sub-report' output, made available via a drop-down menu (Similar to "by Country", "by Site', "by Subject" drop-down in theEnrollment Status report).  

<details><summary><h3>  The sub-report  <h3/></summary>
Each subreport item is a named list, where the name is the display name of the subreport, and the list contains the object to be displayed as the first item.  
- if the object is a table, it must be a data.frame() object labelled "data".  
- if the object is a graph, it must be a plot_ly() object labelled "plot".  
The pseudocode below gives an idea of the structure and the data types required, and additional information regarding the optional parameters is provided in the examples.  

```
reportOutput <- list(
"subreport1Name" = list(
    EITHER: "data"=data.frame()
    OR:     "plot=plot_ly(),
    OPTIONAL: footer=list(text = "", displayOnly=FALSE),  
    OPTIONAL: header=list(
                          firstLevel = c('col1-3', 'col1-3', 'col1-3', 'col4'),
                          secondLevel = c('col1', 'col2', 'col3', 'col4'))
    OPTIONAL: columnDefs=getColumnDefs() # see util function below
  ),
"subreport2Name" ...
)

```
</details>

<details><summary><h4>  Examples  <h3/></summary>
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
> The name of the list entry containing the data.frame should be named "data" and the plot should be named "plot", as given in above examples. Custom report supports only plot_ly plots. 
> Please refer to https://plotly.com/r/reference/ for help on plotly plots.

</details>

### Additional customisation parameters

The following parameters can be passed to the  `reportOutput` variable to improve how the report displays

<details><summary><h4> Footer </h4></summary>

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
</details>

<details><summary><h4> Custom headers </h4></summary>

Normally, the data.frame column labels will be used as table header.However, the column labels can be overridden using the header feature asgiven below:

```R 
newHeader <- list(firstLevel = c("Study", "Country", "Site Code", "SiteName", "Subject", "Screened", "Enrolled", "Candidate", "Ongoing","Completed", "Withdrawn"))
reportOutput <- list("by Country" = list("data" = data.frame(), header =newHeader))
```

Two levels of header can be set for a table as given below:
```R
 twoLevelHeader <- list(
   firstLevel = c("Column 1", "Column 2", rep("Covers Columns 3, 4, 5", 3), "Column 6", "Column 7", rep("Covers Columns 8, 9", 2)),
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
</details>

<details><summary><h4> Custom column widths </h3></summary>

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

## Environment
The R script for a custom report is run in a managed environment which may be different to your development environment. It is important to therefore be aware of what R packages (and their versions) the script can access. At the time of writing, the deployed R version is 4.04.
In order to confirm the package versions used on your system and on in the Viedoc runtime environment, use the [version checker script](../utils/version_checker.R).

<details><summary><h3> Supported packages:</h3></summary>  
- vctrs  <br>
- R6  <br>
- generics  <br>
- glue  <br>
- lifecycle  <br>
- magrittr  <br>
- tibble  <br>
- ellipsis  <br>
- pillar  <br>
- crayon  <br>
- pkgconfig  <br>
- tidyselect  <br>
- purrr  <br>
- Rcpp  <br>
- tidyr  <br>
- dplyr  <br>
- rlang  <br>
- lubridate  <br>
- stringr  <br>
- stringi  <br>
- plotly  <br>
- survival  <br>
- xml2  <br>
</details>

### Blocked functions
<details><summary>  Functions that have never been permitted :</summary>
- system <br>
- system2 <br>
- dir.create <br>
- library <br>
- require <br>
- Sys.sleep <br>
- unlink <br>
- file.remove <br>
- file.rename <br>
- tempdir <br>
- detach <br>
- file.copy <br>
- file.create <br>
- file.append <br>
- setwd <br>
</details>  

> [!IMPORTANT]  
> <details><summary> Newly blocked (Viedoc 4.84)</summary>  
> - source  <br>
> - readLine  <br>
> - scan  <br>
> - readChar  <br>
> - readBin  <br>
> - read.table  <br>
> - read.delim  <br>
> - read.delim2  <br>
> - read.csv  <br>
> - read.csv2  <br>
> - pipe  <br>
> - exec  <br>
> - exec_wait  <br>
> - exec_background  <br>
> - exec_internal  <br>
> - ps  <br>
</details>

> [!IMPORTANT]  
> <details><summary> Currently blocked (Viedoc 4.84), but will be unblocked in 4.85 release</summary>  
> - run  <br>
> - process$new  <br>
> - get  <br>
> - do.call  <br>
> - eval  <br>
> - parse  <br>
> - assign  <br>
> - match.fun  <br>
> - call2  <br>
> - evalq  <br>
> - with  <br>
> - getFromNamespac <br>
</details>

### Utility functions
The following custom Viedoc utility functions have been loaded into the runtime environment in Viedoc Reports to assist with data wrangling and presentation.

<details><summary>isValid(x) </summary>  

- purpose: Check whether a value is valid
- input parameters: any
- returns logical: 
  - TRUE: 
    - 1. 
      - is not atomic
    - 2. OR
      - is atomic AND 
      - is not null AND 
      - all is not NA AND 
      - is not character or logical when vector contains no empty strings, ommiting NA
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
      - is character OR Logical AND vector contains no empty strings when omiting NA

</details>

<details><summary>validLevels(vec, type = "", decreasing = T) </summary>  

- Purpose: Get the unique values in a character vector or factor. In case of factor, unique levels are extracted while dropping the levels that are not present in the input
- Input params:
  - vec - the character vector or factor from which the unique values should be extracted
  - type 
     - if type is left blank, the result is sorted alphabetically.
     - if type == 'frequency', the result is sorted based on the frequency of the individual values in the input vector
  - decreasing 
    - if type is blank, this value is ignored. 
    - If type == "frequency", then this value is used to identify the sort order of the frequency
- return object
  - if type == "" & input is a factor, returns levels(vec)[levels(vec) %in% unique(vec)]
  - if type == "" & input is not a factor, returns sort(unique(vec))
  - if type == "frequency", returns names(sort(table(vec)[table(vec)!=0], decreasing = decreasing))
  - else returns character(0)

</details>
<details><summary>prepareDataForDisplay(data, forceFactor = c(), forceCharacter = c(), blankText = "(blank)", retainFactor = c())</summary>  

- purpose: Prepare the data.frame for optimal dislay via the DT package
- input parameters:
  - data - data.frame that should be prepared for display 
  - forceFactor 
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
<details><summary>setNAtoBlank(data, replaceWithText = "", forceCharacter = c())</summary>  

- purpose: Remove all NA fields and replace them with blank or substitute text
- input parameters
  - data - input data.frame
  - replaceWithText - Substitute text to be used as replacement for blank values
  - forceCharacter - a characer vector of columns names that should be forced to character type instead of  numeric
- output: data.frame

</details>
<details><summary>getLabel(data)</summary>  

- Purpose: Get the column labels of a data.frame as character vector
- input parameters: 
  - data - input data.frame
- output: character vector

</details>
<details><summary>setLabel(data, labels)</summary>  

- Purpose: Set the column labels of a data.frame
- Input parameters: 
  - data - input data.frame
- labels - a list of column labels. The number of columns in the data and the count of labels provided in this parameter should match
- Output: data.frame

</details>
<details><summary>getColumnDefs(colwidths = NA, data = NA, alignRight = NA, alignLeft = NA, alignCenter = NA)</summary>  

- Purpose: Provide an easy way to define column widths for report outputs. Uses DT package
- Parameters:
  - colwidths - a numeric vector of column widths in pixels. Length of this parameter should match the count of columns in the data for which this will be used.
  -             This parameter is ignored if data is provided
  - data - if data if provided, then the column width is calculated based on the data
  - alignRight - a numeric vector of column numbers that should be right-aligned in display
  - alignLeft - a numeric vector of column numbers that should be left-aligned in display
  - alignCenter - a numeric vector of column numbers that should be center-aligned in display
  - NOTE: While using alignRight, alignLeft, or alignCenter, it is suggested to also include colwidths or data parameter for optimal result
- Output: list of column definitions as described in DT package.

</details>

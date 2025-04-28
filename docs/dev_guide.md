# Development guide
[return to root README](./README.md)

This guide provides an outline on how to set up a local development environment and write a custom report, including accessing sample data and custom utilities, and the output object requirements. 

## Prerequisites:
- The study-specific `SampleForCustomReports.zip` file from Viedoc Reports. Instructions on obtaining this Viedoc can be found in the Viedoc Reports User Guide article ['Creating custom reports'](https://help.viedoc.net/c/8a3600/6e9c82/). The contents of this zip file are outlined in '[Available data](#available-datavalid-inputs)'
 below. 
- [R](https://posit.co/downloads/) version 4.04 or later, optionally with R Studio or other IDE.

## Setup

- Install the supported packages (see ['supported Packages' section](#supported-packages)) by running the code snippet below in an R terminal or in an R script. These packages will remain installed on the computer between coding sessions, and you should only need to run it once.
```R
install.packages(c("vctrs","R6","generics","glue","lifecycle","magrittr","tibble","ellipsis","pillar","crayon","pkgconfig","tidyselect","purrr","Rcpp","tidyr","dplyr","rlang","lubridate","stringr","stringi","plotly","survival","xml2"))
```
- Open the unzipped folder in your coding environment and create a new R file for your R script.
- Load the installed packages, additional utility functions provided and datasets into memory using the code snippet below. Note that you will need to run this every time the environment restarts (e.g. after restarting the R terminal, or reopening R Studio). You must remove this code before any script is uploaded, or the script will error.

<details> <summary> Expand setup code: :</summary>

```R
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

# setwd("C:\\Users\\SvenSvensson\\Downloads\\SampleForCustomReports") # typically not necessary in R Studio
source("utilityFunctions.R", local = T)
edcData <- readRDS("edcData.rds")
params <- readRDS("params.rds")
metadata <- readRDS("metadata.rds")
```
</details>

## Data Available for custom reports 

> [!Important]
> The sample data provided in the edcData.rds file may include sensitive data; only authorized people should have access to this data.

The edcData, params and metadata .rds files contained in the sample folder represent a 10-subject sample of the data available in the Viedoc Reports environment to aid with local development. Find detailed information on the data structure by following the links below:
- [edcData](./data_obj/edcData.md) contains CRF and operational data such as queries and medical coding. 
- [params](./data_obj/params.md) contains data from Viedoc Administrator, including study, site and user information
- [metadata](./data_obj/metadata.md) contains data from Viedoc Designer linked to the design version.


## Available packages and functions

This includes using locally saved sample data, package management and, when an R script for a custom report is published in Viedoc, it will run in a managed runtime environment on Viedoc Servers which may be different to your development environment.  
For security reasons, only a curated set of packages and functions are available in this environment, as listed below in Supported packages. 

> [!Note]  
> Differences between package versions in your local development environment and in the runtime environment on Viedoc Servers may cause errors. This can be because functions inside packages have been deprecated or changed recently.
> At the time of writing, the deployed R version is 4.04. To confirm the package versions used on your system and on in the Viedoc runtime environment, use the [version checker script](../utils/version_checker.R).    

Viedoc has developed some additional "utility functions" which are preloaded in the Viedoc Reports runtime environment to assist with data wrangling and presentation. The setup code above loads the utility functions from the downloaded folder into your local development environment. The functions are also available [here](../utils/utilityFunctions.R) and usage information for these functions is provided below. 

<details> <summary><h3> Supported packages </h3></summary>
    
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

<details><summary><h3>Blocked functions</h3></summary>
    
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

> Newly blocked (Viedoc 4.84):
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

> Temporarily blocked (Viedoc 4.84), but will be unblocked in 4.85 release  
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

## The ‘reportObject’ Output 


<details><summary><h3>Structure overview<h3/></summary>

A variable referenced as ‘reportObject’ must be specified in the R script. This object will be used to render the custom reports.
` reportObject’ must be a list of lists - each indexed/named value in the top-level list is itself an indexed list that represents a ‘sub-report’. The index for each sub-report is used as the ‘title’ of the sub-report.
A sub-report contains either a table or a graph object to be rendered. Only one sub-report is visible at a time in Viedoc Reports, and If more than one sub-report is included (i.e. the reportOutput list contains more than one item), a drop-down menu becomes available, populated with the sub-report titles.
Each sub-report list must contain specific indexes/names for the values, as they are used to understand what objects to render. 
- if the object is a table, it must be a data.frame() object labelled "data". 
- if the object is a graph, it must be a plot_ly() object labelled "plot". 
The pseudocode below gives an idea of the structure and the data types required, and additional examples provide information on optional parameters.

```
reportOutput <- list(
"My First Table Report" = list(
    "data"=df
    OR:     
    footer=list(text = "", displayOnly=FALSE),   # Optional
     header= # Optional argument
list
                          firstLevel = c('col1-3', 'col1-3', 'col1-3', 'col4'),
                          secondLevel = c('col1', 'col2', 'col3', 'col4') # Optional for header item
)
    OPTIONAL: columnDefs=getColumnDefs() # see util function below
  ),
"My Plot Report" = list(
    "plot=plot_ly(df),
    footer=list(text = "", displayOnly=FALSE)  # Optional
  ),
"My Second Table Report" = list(
    "data"=…)
)

```

An example of a single table output: 
```R 
reportOutput <- list("Name of output" = list("data" = data.frame()))
``` 

An example of a single graph output: 
```R 
reportOutput <- list("Name of output" = list("data" = plot_ly()))

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
> - Custom report supports only plot_ly plots. Please refer to https://plotly.com/r/reference/ for help on plotly plots.
>- Using words other than “data” or “plot” will result in error

</details>

### Additional customization parameters

The following parameters can be passed to the `reportOutput` variable to improve rendering

<details><summary><h4> Footer </h4></summary>

A footer to the output table can be included as given in the below example:

```R 
reportOutput <- list("by Country" = list("data" = data.frame(), footer =list(text = "Additional notes to the table", displayOnly = TRUE)))
```

The footer text can include HTML tags. 
eg. `"This footer text <strong>emphasizes</strong> a word"` renders like this: "This footer text <strong>emphasizes</strong> a word"
- `displayOnly` - an optional logical parameter that affects how the custom report behaves on download. If not specified, defaults to FALSE.
- If `TRUE`, the footer will be displayed, but ignored when the report is downloaded. 
- If `FALSE`, the footer will be included in the download.
For a plot output, if "`displayOnly = FALSE`", then please use plotly `bottommargin` (refer the example code below) to sufficiently display the note in the plot
</details>
<details><summary><h4> Custom headers </h4></summary>

Normally, the data.frame column labels will be used as table header. However, the column labels can be overridden using the header feature as given below:
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

A single-level header can include HTML tags. 

> [!CAUTION]
> If the wrong number of names are provided for the header parameter, it will revert to the labels included in the table.
</details>

<details><summary><h4> Custom column widths </h4></summary>
The column width can be defined for all or selected columns as give below: 

```R
df <- data.frame() # Output data

widths <- rep(0, ncol(df)) # set all columns to auto width
widths[2] <- 105 # Set 2nd column to 105 px
widths[5] <- 90 # Set 5th column to 90 px
widths[6:11] <- 60 # Set columns 6 to 11 to 60 px

newcolumnDefs <- getColumnDefs(colwidths = widths)

reportOutput <- list(
  "by Country" = list("data" = df, columnDefs =newcolumnDefs)
  )
```
</details>

# Gotchas, FAQs and debugging

<details><summary><h2>Actions to avoid </h2></summary>
Please exercise caution to avoid below scenarios in your code:

- Infinite loops
- Data manipulation that might yield huge incorrect data ending up taking unnecessary disk space
- Any tampering with the host system properties and performance

</details>

## Troubleshooting

When things go wrong, step back and ask:
- What is the goal of this code?
- What inputs are expected?
- What should the outputs look like?

Below you find some general tips that can help you with your troubleshooting approach.

## General tips:
- Confirm that all required functions and libraries are loaded.
- Use str(), class(), or typeof() to understand object types.
- Print intermediate outputs (print() or View()) to verify assumptions.
- Avoid chaining (%>%) in long steps while debugging; break into chunks.
- When merging, make sure key columns are the same type in both dataframes.

<details><summary><H2>Common errors during development</H2></summary>
<details><summary><H3>Error: No Package Found</H3></summary>

``` R
Error in library(R6) : there is no package called 'R6'
```
Cause: 
You have not installed the packages. Each package must be installed the first time you work in an R environment.

Fix: see [Setup](./dev_guide.md#setup) above
``` R
install.packages("R6")
```


</details>
<details><summary><H3>Error: Cannot Open File</H3></summary>

``` R
> In file(filename, "r", encoding = encoding) :
>   cannot open file 'utilityFunctions.R': No such file or directory
```
(Likely) cause:
The R terminal is not using the correct directory as the 'working directory'

Fix:
> Ensure that you substitute in the correct path to your R files
```R
setwd("C:\\Users\\JackSpratt\\Downloads\\SampleForCustomReports")
```

</details>
<details><summary><H3>Error: subscript out of bounds</H3></summary>

``` R
> Error in vec[4] : subscript out of bounds
```
Explanation: You tried to access the 4th element of a 3-element vector.
See 
(Likely) cause:
The column or row that you are trying to get doesn't exist. You may be calling the [n+1]th item in a list that is n items long, or using an incorrect column name.


</details>
<details><summary><H3>Error: object of type ‘closure’ is not subsettable</H3></summary>
 
``` R
Error in mean[1] : object of type 'closure' is not subsettable
```
Possible cause:
Cause: A typo (e.g., forgot to add parentheses or had a name clash with a function) resulted in an object being interpreted as a function.

Possible cause: You overrode the built-in mean function with a custom function, then tried to index it as if it were a list or vector. (see [Incorrect Indexing](./dev_guide.md#incorrect-indexing-) below)
Example:
``` R
mean <- function(x) x + 1
mean[1]
```

</details></details>
<details><summary><H2>Common errors after publishing (it ran fine locally) </H2></summary>
Differences to consider besides the functions available those relating to the additional data available in the production environment, specifically with respect to additional/nonstandard datatypes and data and data labels from earlier design versions.

<details><summary><H3>Error: Could not find function</H3></summary>
 
Error:
``` R
> Could not find function "..."
```
(Likely) cause:
You are using a package or function other than ones that are supported by Viedoc Custom Report (see [Supported Packages](https://github.com/viedoc/custom-reports/blob/syllybelle-prune-contents/docs/dev_guide.md#-supported-packages-) above).
Alternatively, you may be using a different version of a package that is supported. Upload [this utility script](https://github.com/viedoc/custom-reports/blob/main/utils/version_checker.R) as a Custom Report to see the package versions that are used by Viedoc Reports.

Fix:
Find an alternative function to achieve the same result, if possible.

</details>
<details><summary><H3>Error: uses the forbidden function</H3></summary>
 
Error:
```R
Custom report code uses the forbidden functions (library). Please check and upload the code again.
```
(Likely) cause:
You have forgotten to comment out or delete the development environment setup code.

Fix:
Ensure any code included to load packages and data is commented out. Check the list of [Forbidden Functions](./dev_guide.md#blocked-functions) above to make sure you're not using a blocked function in your code.

</details>
<details><summary><H3>Error: no applicable method function</H3></summary>

Error:
``` R
no applicable method for [...] applied to an object of class "NULL"
```
(Possible) cause: 
The input form requested contains no data or does not exist.

Fix:
- Ensure there is data for the forms used, and that you are not filtering out all valid cases (see [Handling null cases](https://github.com/viedoc/custom-reports/blob/syllybelle-prune-contents/docs/dev_guide.md#handling-null-cases-) below). Add null checks to your code, to prevent errors if there are no cases
- Confirm that you are not indexing a non-existent column (see [Incorrect Indexing](https://github.com/viedoc/custom-reports/blob/syllybelle-prune-contents/docs/dev_guide.md#incorrect-indexing-) below.)
- Confirm that datatypes are explicitly handled. Production data may introduce new datatypes that are not present in the data sample.

</details>
</details>

<details><summary><h2>Datatype issues </h2></summary>
Datatype issues can often be very insidious, as they can fail 'silently', or masquerade  as other issues.
For example, a mismatch in conditional logic can cause incorrect filtering:
 
 ```R
df <- data.frame(id = c(1, 2, 3), name = c("Alice", "Bob", "Carol"))
df %>% filter(id == "2")  # returns no rows
```

Joining dataframes with mismatched columns can also be an issue.
```R
df1 <- data.frame(id = 1:3)  # integers
df2 <- data.frame(id = c("1", "2", "3"))  # character

inner_join(df1, df2, by = "id")  # returns null
```


 
### Get value from a dataframe as a string
R will return a factor or numeric by default, depending on how the dataframe was created. To ensure a string, use `paste0()` or `as.character()`.

 ```R
item_id <- paste0(df$itemId[1])  # Ensures value is string
# alternatively:
item_id <- as.character(df$itemId[1])

```

### Convert DataFrame Columns to Specific Types
Sometimes, especially after reading from CSVs or APIs, the data types may not be what you expect. Use `mutate(across(...))` for converting multiple columns:
```R
df <- df %>%
  mutate(across(everything(), as.character))  # or as.numeric, as.factor, etc.
```
Use `str(df)` or `glimpse(df)` to confirm column types.

</details>
<details><summary><h2>Handling null cases </h2></summary>

Certain functions will raise errors if they receive a NULL value, instead of an empty dataframe or list. This can often be an issue in Viedoc Reports, but not in your local environment.

It's important to note that if no forms have been completed, they will not be represented in the dataset, so for example, if no adverse events have occurred, `edcData$Forms$AE` will return null.

The way to fix this issue is to create a default object to return.

### Return NA value if source dataframe is empty

 ```R
# example 1
myFunction <- function(df)
default_value <- NA_character_
if (nrow(df) == 0) {
    return(default_value)
  }
```

### Return empty dataframe if source dataframe is null or empty

 ```R
if(is.null(ae_data) || nrow(ae_data)==0){
  ae_data <- data.frame(matrix(ncol = 6, nrow = 0)) %>%
    mutate(across(!item_3, as.character))
  colnames(ae_data) <- c("SubjectId","SiteName","item_1","item_2","item_3",)
}
```

### Get value based on another column if exists

```R
first_value <- default_value

if(!is.null(df) && nrow(df) > 0){
  if (id_value %in% df$id_column){
    values_where_true <- df %>%
      filter(id_column == id_value) %>%
      select(value_column)
    first_value <- paste0(
      values_where_true[
        order(values_where_true$date_column, decreasing = FALSE),
      ][1]
    )
  }
}
```

</details>
<details><summary><h2>Incorrect Indexing </h2></summary>

Indexing errors are extremely common in R and often result in confusing or misleading behavior.
### Subscript Out of Bounds
This happens when you attempt to access an index that doesn’t exist.

```R
vec <- c(1, 2, 3)
vec[4]  # Error: subscript out of bounds
```
Fix:
Always check the length of your vector or the number of rows/columns:
```R
if (length(vec) >= 4) {
  value <- vec[4]
}
```

### returning a one-row dataframe instead of a value (or vice versa))

- `[[` extracts a single element as a value
- `[` returns a subset of the object (e.g., a one-row dataframe)

```R
df[1]       # returns a one-column dataframe
df[[1]]     # returns the actual values from the first column
```

Accessing Non-existent Columns

```R
df$nonexistent_column  # returns NULL
df[["nonexistent_column"]]  # returns NULL, but can error in some contexts
```
Avoid silent errors by validating column names:

```R

if ("target_column" %in% colnames(df)) {
  val <- df[["target_column"]]
}
```

</details>


## Data availability

As per current data modelling best-practices, Viedoc separates "transactional" (EDC) and analytical ("Reports") data. 
To maintain visibility rules, data transfers are conducted per role, as defined in the Reports setup in Designer. Therefore, any reports generated from this data will be based only on data the role has permission to see. 
Reports are generated on demand (i.e. when a user accesses teh site), so visualisations are always reflective of the data 'analytical' currently available.'

The transactional and analytical databases of production studies sync daily. In order to sync a training study, Reports must be manually turned off for the study (in Admin), and then after about an hour, turned on again.

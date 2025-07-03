# Utility Functions that are shared with customers for custom reports

# Check whether a value is valid ----
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
isValid <- function(x) {
  if (!is.atomic(x)) {
    return(TRUE)
  }
  if (is.null(x)) {
    return(FALSE)
  }
  if (length(x) == 0) {
    return(FALSE)
  }
  if (all(is.na(x))) {
    return(FALSE)
  }
  if (is.character(x) && !any(nzchar(stats::na.omit(x)))) {
    return(FALSE)
  }
  if (is.logical(x) && !any(stats::na.omit(x))) {
    return(FALSE)
  }
  return(TRUE)
}

# Get Valid Levels ----
# ^^^^^^^^^^^^^^^^
# Purpose: Get the unique values in a character vector or factor. In case of factor, unique levels are extracted while dropping the levels that are not present in the input.
# Parameters:
#   vec - the character vector or factor from which the unique values should be extracted
#   type - if type is left blank, the result is sorted alphabetically
#          if type == 'frequency', the result is sorted based on the frequency of the individual values in the input vector
#   decreasing - if type is blank, this value is ignored. If type == "frequency", then this value is used to identify the sort order of the frequency
validLevels <- function(vec, type = "", decreasing = T) {
  lvls <- character(0)
  if (type == "") {
    if (is.factor(vec)) {
      lvls <- levels(vec)
      lvls <- lvls[lvls %in% unique(vec)]
    } else {
      lvls <- sort(unique(vec))
    }
  }
  if (type == "frequency") {
    tbl <- table(vec)
    tbl <- tbl[tbl != 0]
    lvls <- names(sort(tbl, decreasing = decreasing))
  }
  return(lvls)
}

# Prepare data for display using DT package ----
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Purpose: Prepare the data.frame for optimal dislay via the DT package
# Parameters:
#   data - data.frame that should be prepared for display
#   forceFactor - a character vector of column names that should be forced as factor field. 
#                 This can be used to force SiteCode into character, without which it would default to numeric.
#                 This will help in an optimal filtering feature for the numeric columns (dropdown instead of range filter)
#   forceCharacter - a character vector of column names that should be forced as character field. 
#                    Similar usage as forceFactor where there is a need to force a numeric field into character, but not factorize the data
#                    If the column is not listed in this parameter, and if the data contains only numeric value, then the column will be rendered as numeric
#   blankText - value provided in this parameter will be used to replace blank values
#   retainFactor - The function will by default reapply factorization for all the factor fields, character fields (that are not part of forceCharacter),
#                  and fields that are listed in forceFactor. Hence, for fields that should not lose its assigned factor levels should be listed in this field
prepareDataForDisplay <- function(
  data,
  forceFactor = c(),
  forceCharacter = c(),
  blankText = "(blank)",
  retainFactor = c()
) {
  forceFactor    <- c(forceFactor, "SubjectId")
  forceFactor    <- forceFactor[forceFactor %in% colnames(data)]
  isFactorFields <- sapply(data, is.factor)
  factorFields   <- names(isFactorFields)[isFactorFields]
  retainFactor   <- intersect(retainFactor, factorFields) # Retain only actual factor fields in retainFactor
  factorFields   <- setdiff(factorFields, retainFactor) # Remove retainFactor fields so that they would not lose their levels
  factorFields   <- append(factorFields, forceFactor)

  sapply(
    c(factorFields, forceCharacter), 
    function(x) data[[x]] <<- ifelse(
      is.na(data[[x]]), 
      NA_character_, 
      as.character(format(data[[x]], scientific = F))
    )
  )

  data <- setNAtoBlank(
    data, 
    replaceWithText = blankText, 
    forceCharacter = c(factorFields, forceCharacter)
  )
  sapply(
    colnames(data),
    function(x) {
      if (!x %in% retainFactor) {
        if (
          (
            !is.numeric(type.convert(as.character(data[[x]]))) ||
              x %in% factorFields
          ) && !(
            x %in% forceCharacter
          )
        ) {
          dvals <- as.character(data[[x]])
          dvalsContainBlank <- any(dvals == blankText)
          dvals <- dvals[dvals != blankText]
          if (is.numeric(type.convert(dvals))) {
            lvls <- unique(dvals)
            lvls <- lvls[order(as.numeric(lvls))]
            if (dvalsContainBlank) lvls <- c(blankText, lvls)
          } else {
            lvls <- as.character(sort(unique(data[[x]])))
          }
          data[[x]] <<- factor(data[[x]], levels = lvls)
        } else if (
          x %in% forceCharacter
        ) {
          data[[x]] <<- as.character(data[[x]])
        } else {
          data[[x]] <<- as.numeric(data[[x]])
        }
      }
    }
  )
  return(data)
}

# Set NA values to blank for all the character columns ----
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Purpose: Remove all NA fields and replace them with blank or substitute text
# Parameters:
#   data - input data.frame
#   replaceWithText - Substitute text to be used as replacement for blank values
#   forceCharacter - a characer vector of columns names that should be forced to character type instead of  numeric
setNAtoBlank <- function(
  data, replaceWithText = "", forceCharacter = c()
) {
  if (nrow(data) == 0) {
    return(data)
  }
  data <- data %>% data.frame()
  sapply(colnames(data), function(col) {
    ifelse(
      !col %in% forceCharacter &&
        "character" %in% class(data[[col]]) &&
        is.numeric(type.convert(as.character(data[[col]]))),
      data[[col]] <<- as.numeric(data[[col]]),
      ""
    )
  })
  data[
    , which(sapply(data, class) == "character")
  ][
    is.na(data[
      , which(sapply(data, class) == "character")
    ])
  ] <- ""
  sapply(
    colnames(data),
    function(col) {
      if (
        "character" %in% class(data[[col]])
      ) data[[col]] <<- trimws(data[[col]])
    }
  )
  if (
    replaceWithText != "" &&
      length(which(sapply(data, class) == "character")) > 0
  ) {
    data[
      , which(sapply(data, class) == "character")
    ][
      data[
        , which(sapply(data, class) == "character")
      ] == ""
    ] <- replaceWithText
  }
  data[, which(sapply(data, class) == "logical")][is.na(data[, which(sapply(data, class) == "logical")])] <- ""
  return(data)
}

# getLabel ----
# ^^^^^^^^
# Purpose: Get the column labels of a data.frame as character vector
# Parameters:
#   data - input data.frame
getLabel <- function(data) {
  as.character(
    sapply(
      colnames(data), function(x) {
        lbl <- attr(data[[x]], "label")
        if (!isValid(lbl) || lbl == "NA") lbl <- x
        lbl
      }
    )
  )
}

# setLabel ----
# ^^^^^^^^
# Purpose: Set the column labels of a data.frame
# Parameters:
#   data - input data.frame
#   labels - a list of column labels. The number of columns in the data and the count of labels provided in this parameter should match
setLabel <- function(data, labels) {
  if (
    is.list(labels) && 
      length(labels) == ncol(data)
  ) {
    sapply(
      1:length(labels),
      function(col){
        attr(data[[col]], "label") <<- labels[[col]]
      }
    )
  }
  return(data)
}

# Get ColumnDefs for display using DT ----
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Purpose: Provide an easy way to define column widths for report outputs
# Parameters:
#   colwidths - a numeric vector of column widths in pixels. Length of this parameter should match the count of columns in the data for which this will be used.
#               This parameter is ignored if data is provided
#   data - if data if provided, then the column width is calculated based on the data
#   alignRight - a numeric vector of column numbers that should be right-aligned in display
#   alignLeft - a numeric vector of column numbers that should be left-aligned in display
#   alignCenter - a numeric vector of column numbers that should be center-aligned in display
#   NOTE: While using alignRight, alignLeft, or alignCenter, it is suggested to also include colwidths or data parameter for optimal result
getColumnDefs <- function(
  colwidths   = NA,
  data        = NA,
  alignRight  = NA,
  alignLeft   = NA,
  alignCenter = NA
) {
  columnDefs <- list()
  if (isValid(colwidths) && !isValid(data)) {
    columnDefs <- lapply(
      1:length(colwidths),
      function(x) {
        list(
          width = paste0(colwidths[x], "px"),
          targets = x - 1
        )
      }
    )
  }
  if (isValid(data)) {
    for (
      i in 1:length(colnames(data))
    ) {
      col <- colnames(data)[i]
      suppressWarnings({
        fldlen <- max(nchar(as.character(data[[col]])), na.rm = T)
      })
      columnDefs[[length(columnDefs) + 1]] <- list(
        width = ifelse(is.na(fldlen),
          "150px",
          ifelse(fldlen < 20,
            "100px",
            ifelse(fldlen < 200, "150px", "250px")
          )
        ),
        targets = c(i - 1)
      )
    }
  }
  if (isValid(alignRight)) {
    columnDefs[[
      length(columnDefs) + 1
    ]] <- list(
        className = "dt-right", 
        targets = alignRight - 1
      )
  } else if (isValid(alignLeft)) {
    columnDefs[[
      length(columnDefs) + 1
    ]] <- list(
      className = "dt-left", 
      targets = alignLeft - 1
    )
  } else if (isValid(alignCenter)) {
    columnDefs[[
      length(columnDefs) + 1
    ]] <- list(
      className = "dt-center", 
      targets = alignCenter - 1
    )
  }
  return(columnDefs)
}

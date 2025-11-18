# set path to data files
local_project_path <- "C"
excel_export_path <- "demodataExport.xlsx" # relative to project path or absolute

# install.packages("renv")
# library("renv")
# renv::restore()

setwd(local_project_path)
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

# load data
edcData <- readRDS("edcData.rds")
params <- readRDS("params.rds")
metadata <- readRDS("metadata.rds")
source("utilityFunctions.R", local = T)

# --- Excel import block -------------------------------------------------------
library(readxl)
if (excel_export_path == "") {
  message("ℹ No additional data loaded")
  xlsxData <- list()
} else if (!file.exists(excel_export_path)) {
  message("⚠ Excel data export file not found: ", excel_export_path)
  xlsxData <- list()
} else {
  sheet_names <- tryCatch(readxl::excel_sheets(excel_export_path),
                          error = function(e) character(0))
  if (length(sheet_names) == 0) {
    message("⚠ No valid sheets found in Excel file.")
    xlsxData <- list()
  } else {
    message("ℹ Loading Excel data from: ", excel_export_path)

    # drop README sheet if present
    sheet_names <- setdiff(sheet_names, "README")

    # --- load all sheets as data frames --------------------------------------
    xlsx_all <- setNames(lapply(sheet_names, function(s) {
        # fetch column names
        hdr <- tryCatch(
            readxl::read_excel(excel_export_path, sheet = s, skip = 1, n_max = 0),
            error = function(e) NULL
        )
        if (is.null(hdr)) {
            message("⚠ Error reading header for sheet '", s, "'")
            return(data.frame(Empty = paste("Could not read sheet:", s), stringsAsFactors = FALSE))
        }
        # create vector to enforce char type (avoid NA)
        col_types <- rep("text", ncol(hdr))


    tryCatch(
            readxl::read_excel(
                excel_export_path,
                sheet = s,
                skip = 1,
                col_types = col_types,
                .name_repair = "minimal"  # keep original column names as-is
            ),
            error = function(e) {
            message("⚠ Error reading sheet '", s, "': ", conditionMessage(e))
            data.frame(Empty = paste("Could not read sheet:", s),
                        stringsAsFactors = FALSE)
            }
        )
    }), sheet_names)

    # --- build structured object like edcData.rds ----------------------------
    xlsxData <- list(
      Forms             = xlsx_all[setdiff(names(xlsx_all), 
                                           c("Items","CodeLists","Queries",
                                             "Review status","SDV",
                                             "MedDRA","WHODrug",
                                             "Event dates",
                                             "Calculated subject status",
                                             "Pending forms"))],
      Items             = if ("Items" %in% names(xlsx_all)) xlsx_all[["Items"]] else data.frame(),
      CodeLists         = if ("CodeLists" %in% names(xlsx_all)) xlsx_all[["CodeLists"]] else data.frame(),
      Queries           = if ("Queries" %in% names(xlsx_all)) xlsx_all[["Queries"]] else data.frame(),
      ReviewStatus      = if ("Review status" %in% names(xlsx_all)) xlsx_all[["Review status"]] else data.frame(),
      SDV               = if ("SDV" %in% names(xlsx_all)) xlsx_all[["SDV"]] else data.frame(),
      MedDRA            = if ("MedDRA" %in% names(xlsx_all)) xlsx_all[["MedDRA"]] else data.frame(),
      WHODrug           = if ("WHODrug" %in% names(xlsx_all)) xlsx_all[["WHODrug"]] else data.frame(),
      EventDates        = if ("Event dates" %in% names(xlsx_all)) xlsx_all[["Event dates"]] else data.frame(),
      SubjectStatus     = if ("Calculated subject status" %in% names(xlsx_all)) xlsx_all[["Calculated subject status"]] else data.frame(),
      PendingForms      = if ("Pending forms" %in% names(xlsx_all)) xlsx_all[["Pending forms"]] else data.frame()
    )

    message("✅ Excel data loaded successfully (", length(sheet_names), " sheets)")
  }
}
# install.packages("readxl")
library(readxl)

read_excel_all_sheets <- function(filename, tibble = TRUE) {
  sheet <- readxl::excel_sheets(filename)
  x <- lapply(sheet, function(X) readxl::read_excel(filename, sheet = X, skip = 1))
  if (!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheet
  x
}

edcData <- list(Forms = read_excel_all_sheets("[name_of_file.xlsx]"))

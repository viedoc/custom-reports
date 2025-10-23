generate_empty_output <- function(error_message, single_report_only = FALSE) {
  empty_output <- data.frame(Empty = error_message, stringsAsFactors = FALSE)
  if (isTRUE(single_report_only)) {
    return(list(data = empty_output))
  }
  # else: empty report wrapper
  return(list(empty = list(data = empty_output)))
}

generate_data <- function(edcData){
     if (is.null(edcData) || length(edcData$Forms) == 0){
        return(generate_empty_output("No data available for study", single_report_only=FALSE))
    }
    form_defs <- metadata$FormDef
    # exit if any dataset is empty
    all_reports <- list()
    for (i in unique(form_defs[["OID"]])){
        form_name <- form_def$Name[form_def$OID == i]
        form_data <- edcData$Forms[[as.character(i)]]
        if (ncol(form_data)== 0 || !is.data.frame(form_data) || is.null(form_data) || nrow(form_data)==0){
            output <-generate_empty_output(
                paste0("form ", form_name, " contains no data"), single_report_only=TRUE
            )
        } else output <- list(data = edcData$Forms[[as.character(i)]])
        all_reports[[i]] <- output
    }
}

reportOutput <-generate_data(edcData)
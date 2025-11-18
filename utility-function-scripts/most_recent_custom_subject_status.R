subject_status_form_id <- "SS"

get_most_recent_subject_status <- function(
    subject_status_form_data,
    subject_status_col,
    subject_guid_col="SubjectId",    
    last_edit_date_col="LastEditedDate",  
         # "SStat"
    ) {
    # return empty column  if no data
    if (!is_df_nonempty(subject_status_df)) return( NA_character_)
    
    # Null saftey and datatype safety
    null_safe_subject_status_df <- add_required_cols(subject_status_df, c(subject_guid_col, last_edit_date_col, subject_status_col )) %>%  
        dplyr::filter(!is.na(.data[[subject_guid_col]]))
        dplyr::mutate(`.date` = datify(.data[[last_edit_date_col]])) %>%
        dplyr::filter(!is.na(.data[[".date"]]))
    if (!is_df_nonempty(null_safe_subject_status_df))return(NA_character_)
    
    # get most recent status per subject
    latest_subject_status_df <- null_safe_subject_status_df %>%
        dplyr::group_by(.data[[subject_guid_col]]) %>%
        dplyr::slice_max(order_by  = .data[[".date"]], n = 1, with_ties = FALSE) %>%
        dplyr::ungroup() %>%
        dplyr::select(dplyr::all_of(c(subject_guid_col, subject_status_col)))
    # return if valid
    if (!is_df_nonempty(latest_subject_status_df)) return(NA_character_)
    return (latest_subject_status_df)
}


subject_status_df  <- edcData$Forms[[subject_status_form_id]] 
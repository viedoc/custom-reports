
join_on_subject_form_cols <- c("SubjectId","EventSeq","EventId","ActivityId","FormId","FormSeq")
queries_df     <- edcData$ProcessedQueries

get_queries_per_subject_form <- function(
    all_queries_df,
    subject_event_form_join_cols  
) {
    # Null check
    if (!is_df_nonempty(all_queries_df)) return(NA_character_)

    # only consider unconfirmed missing data or query raised queries.
    raised_queries_df <- all_queries_df %>%
        dplyr::filter(
            .data[["QueryType"]] == "Unconfirmed missing data" | 
            .data[["QueryStatus"]] == "Query Raised") 
    # Null check
    if (!is_df_nonempty(raised_queries_df)) return(NA_character_)
    raised_queries_df <- raised_queries_df %>%
        dplyr::mutate(
            IssueStatus = dplyr::if_else(
                .data[["QueryType"]] == "Unconfirmed missing data", "Missing data",
                "Open query"
                ),
            IssueDate   = suppressWarnings(as.Date(dplyr::if_else( is.na(QueryRaised), EventDate, QueryRaised)) )
        ) %>%
        dplyr::group_by(dplyr::across(dplyr::all_of(subject_event_form_join_cols))) %>%
        dplyr::slice_min(order_by = IssueDate, n = 1, with_ties = FALSE, na_rm = TRUE) %>% 
        dplyr::ungroup() 
    return (raised_queries_df %>% dplyr::select(dplyr::any_of(c(subject_event_form_join_cols, "IssueStatus", "IssueDate"))))
}

grouped_queries_df <- get_queries_per_subject_form(
        queries_df,
        join_on_subject_form_cols
    ) 
    
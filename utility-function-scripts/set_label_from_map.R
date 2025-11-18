output_labels <- c(                 
    StudyName       = "Study",
    Country         = "Country",
    SiteCode        = "Site Code",
    # SiteSeq        = "",
    SiteName        = "Site Name",
    SubjectSeq      = "Subject Sequence",
    SubjectId       = "Subject",
    SubjectStatus   = "Subject Status",
    # SourceSubjectFormSeq = "",
    # EventDate      = "",
    # EventId        = "",
    EventName       = "Event",
    EventSeq        = "Event Sequence",
    # ActivityId     = "",
    ActivityName    = "Activity Name",
    # FIELDID         = "custom"
)

set_label_from_map <- function(df, labels_map){
    existing <- intersect(names(labels_map), names(df))
    # null check
    if (!length(existing)) return(df)
    # reorder
    df <- df %>% dplyr::select(dplyr::all_of(existing), dplyr::everything())
    # rename
    new_names <- names(df)
    idx <- match(existing, new_names)
    new_names[idx] <- unname(labels_map[existing])
    names(df) <- new_names
    return(df)
}
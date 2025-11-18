get_visit_metadata <-function(event_ref_data, event_def_data){
    # null and  type safety
    if (!is_df_nonempty(event_ref_data) || !is_df_nonempty(event_def_data)) return (NA_character_)
    event_ref_data <- event_ref_data %>%
        add_required_cols(c("MDVOID","StudyEventOID","OrderNumber","Mandatory")) %>% 
        dplyr::transmute(
            Design=as.numeric(MDVOID),
            EventId= StudyEventOID,
            OrderNumber = as.numeric(OrderNumber),
            Mandatory=Mandatory
        )   %>%   # remove duplicates and order to bring preferred rows to top
        dplyr::arrange(dplyr::desc(!is.na(OrderNumber))) %>% 
        dplyr::distinct(Design, EventId, .keep_all = TRUE)
    event_def_data <- event_def_data %>%
        add_required_cols(c("MDVOID","OID","Name","Type")) %>%
        dplyr::transmute(
        Design    = suppressWarnings(as.numeric(MDVOID)),
        EventId   = OID,
        EventName = Name,
        EventType = Type
        )  %>% 
        dplyr::arrange(dplyr::desc(EventType == "Scheduled")) %>%  
        dplyr::distinct(Design, EventId, .keep_all = TRUE)
    
    # get a list of all events defined in the study
    study_events <- event_ref_data %>%
        dplyr::inner_join(event_def_data, by = c("Design", "EventId")) %>%
        #  if event is scheduled and has an order number, return the order number, else send to end 
        dplyr::mutate(
            # safe fallback: if all OrderNumber NA, push to end with a big number
            OrderNumber = ifelse(
                !is.na(OrderNumber) & EventType == "Scheduled", OrderNumber, 
                ifelse(all(is.na(OrderNumber)), 0, max(OrderNumber, na.rm = TRUE)) + 1
            )
        ) %>% 
        dplyr::distinct(Design, OrderNumber, EventId, EventName)

    # null check
    if (!is_df_nonempty(study_events)) return (NA_character_)

    # Within each EventId, keep the row from the most recent Design version
    most_recent_events <- study_events %>% 
        dplyr::group_by(EventId) %>% 
        dplyr::arrange(OrderNumber, .by_group = TRUE) %>%
        dplyr::slice_max(Design, n = 1, with_ties = FALSE)  %>%
        dplyr::ungroup() 

    # For duplicate EventNames (recurring unscheduled events), 
    # add a suffix _<sequence> in the order of OrderNumber so names are unique.
    visitOrder <- most_recent_events %>% 
        dplyr::group_by(EventName) %>%
        dplyr::mutate(
            EventName = dplyr::if_else(
                n() == 1L, EventName, # set first instance to event name, 
                paste0(EventName, "_", row_number()) # else append number order suffix
            )
        ) %>%
        dplyr::ungroup() %>%
        dplyr::arrange(OrderNumber) %>%
        dplyr::distinct(EventId, OrderNumber, EventName)
    return(visitOrder)
}

visitOrder <- get_visit_metadata(metadata$StudyEventRef, metadata$StudyEventDef)

subject_events <- edcData$EventDates %>%
  left_join(visitOrder, by = "EventId") %>%
  arrange(OrderNumber)

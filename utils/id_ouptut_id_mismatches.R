# Identify items that have different output ID to field ID, to prevent failed lookups in edcData

has_object_id <- metadata$ItemDef %>%
  select(OID, SASFieldName, MDVOID) %>%
  # select items with a output ID
  filter(SASFieldName != "") %>%
  filter(!is.na(SASFieldName)) %>%
  filter(SASFieldName != OID)

if(!is.null(has_object_id) && nrow(has_object_id) > 0){
  has_object_id <- has_object_id[
    order(has_object_id$MDVOID, decreasing = TRUE),
  ] %>% distinct()
  }

## Example implementation, lookup an item_id from output_field_ID
item_id <- paste0(output_id[1])
  if(!is.null(has_object_id) && nrow(has_object_id) > 0){
    if (output_id %in% has_object_id$SASFieldName){
      item_id_vec <- has_object_id %>%
        filter(SASFieldName == output_id) %>%
        select(OID)
      # select first item_id (if multiple rows have same output_id) .
      item_id <- paste0(item_id_vec[1])
    }
  }

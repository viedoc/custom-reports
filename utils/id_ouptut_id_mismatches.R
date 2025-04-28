# identify items that have different output ID to field ID, to prevent failed lookups in edcData
has_object_id <- metadata$ItemDef %>%
  select(OID, SASFieldName, "MDVOID") %>%
  # select items with a output ID
  filter(, SASFieldName != "") %>%
  filter(, !is.na(SASFieldName)) %>%
  # remove checkbox suffixes/prefixes):
  ## replace OID with the capture group where 
  ## capture group starts with '__' and ends with '__',
  ## optionally followed by digits (checkbox suffixes)
  mutate(OID = str_replace(OID, "__([\\w\\d]+)__\\d.*", "\\1")) %>%
  filter(, SASFieldName != OID)
has_object_id <- has_object_id[
  order(has_object_id$MDVOID, decreasing = TRUE),
] %>% distinct()

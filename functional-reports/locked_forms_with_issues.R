# This custom report lists locked forms that might require unlocking to resolve an issue.
# Those issues are: Unanswered query, unconfirmed missing data, pending form upgrade.

# Get locked forms from the ReviewStatus dataframe; keep only needed columns
lockedforms <- edcData$ReviewStatus %>%
  filter(!is.na(LockDate)) %>%
  select(SubjectId, SiteCode, EventName, EventSeq, ActivityId, FormName, FormSeq)

# Get issues where site's action is needed from Queries dataframe; keep only needed columns
openissues <- edcData$Queries %>%
  group_by(QueryStudySeqNo, SiteCode, SubjectId, EventId, EventSeq, ActivityId, FormId, FormSeq, ItemId) %>%
  slice_tail(n = 1) %>%
  filter(QueryState == "Query Raised" | QueryType %in% c("Pending form upgrade", "Unconfirmed missing data")) %>%
  select(SubjectId, SiteCode, EventName, EventSeq, ActivityId, FormName, FormSeq, QueryState, QueryType)

# Join the locked forms and open issues; remove locked forms without open issues;
# count the number of open issues per form; set the display labels
lockedforms_with_openissues <- lockedforms %>%
  left_join(openissues, by = c("SubjectId", "SiteCode", "EventName", "EventSeq", "ActivityId", "FormName", "FormSeq"), multiple = "all") %>%
  filter(!is.na(QueryType)) %>%
  group_by(SubjectId, SiteCode, EventName, EventSeq, ActivityId, FormName, FormSeq) %>%
  summarize(raisedQueries = sum(QueryState == "Query Raised", na.rm = T),
            missingData = sum(QueryType == "Unconfirmed missing data"),
            pendingUpgr = if_else(any(QueryType == "Pending form upgrade"), "Yes", "No")) %>%
  setLabel(labels = as.list(c(getLabel(.)[1:7], "Number of open queries", "Number of unconfirmed missing data points", "Form upgrade pending?")))
  
# Create the report output
reportOutput = list(
  "Locked Forms with Queries" = list(data = lockedforms_with_openissues)
)

# Creating the nested tibble from the list of forms returned by edcData
forms_nested <- tibble(FormID=names(edcData$Forms), data = edcData$Forms)
form_defs <- metadata$FormDef %>%
  select(c("DesignVersion"="MDVOID", "FormID"="OID", "FormName"="Name")) %>%
  group_by(DesignVersion, FormID)

forms_nested_norm <- forms_nested %>%
  mutate(
    data = map(
      data, function(df){
        df %>% select(c(
          "DesignVersion",
          "SiteName",
          "SubjectId",
          "EventName",
          "EventDate",
          "InitiatedDate",
          "LastEditedDate"
        )) %>% 
        mutate(
          DesignVersion =  as.character(DesignVersion),
          SiteName = as.character(SiteName),
          SubjectId = as.character(SubjectId),
          EventName = as.character(EventName),
          EventDate = as.Date(EventDate),
          InitiatedDate = as.Date(InitiatedDate),
          LastEditedDate = as.Date(LastEditedDate)
        )
    }
  ))

unnested <- forms_nested_norm %>% unnest(data) 

unnested <- left_join(unnested, form_defs, by=c("FormID", "DesignVersion")) %>%
   mutate(DesignVersion =  as.numeric(DesignVersion)) %>%
   mutate(FormName = paste(FormName, " (", FormID, ")", sep = "")) %>% 
   group_by(DesignVersion, SiteName, EventName, SubjectId, FormName)

# create cross table with count of intersection
forms <- table(unnested$DesignVersion, unnested$FormName)

# convert table object to data.frame
forms_df <- as.data.frame.matrix(forms)

# add total row & column
forms_df <- cbind(forms_df, Total = rowSums(forms_df))
forms_df <- rbind(forms_df, Total = colSums(forms_df))

# convert 0 values to NA values
forms_df[forms_df == 0] <- NA

# convert row index to column
forms_df <- cbind(`Design Version` = row.names(forms_df), forms_df)
cols <- colnames(forms_df)

reportOutput <- list(
  "Implemented design versions by form" = list("data" = prepareDataForDisplay(forms_df, blankText = ""), header = list(firstLevel = cols))

)

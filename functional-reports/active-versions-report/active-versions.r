library(vctrs)
library(R6)
library(generics)
library(glue)
library(lifecycle)
library(magrittr)
library(tibble)
library(ellipsis)
library(pillar)
library(crayon)
library(pkgconfig)
library(tidyselect)
library(purrr)
library(Rcpp)
library(tidyr)
library(dplyr)
library(rlang)
library(lubridate)
library(stringr)
library(stringi)
library(plotly)
library(survival)
library(xml2)

setwd("C:\\Users\\SylviaVanBelle\\OneDrive - Viedoc Technologies\\reports")


source("utilityFunctions.R", local = T)
edcData <- readRDS("edcData.rds")
params <- readRDS("params.rds")
metadata <- readRDS("metadata.rds")


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
   group_by(DesignVersion, SiteName, EventName, SubjectId, FormName)

n_unique <- unnested  %>%  group_by(DesignVersion) %>% summarise(
  `Unique Sites` = n_distinct(SiteName),
  `Unique Events` = n_distinct(EventName),
  `Unique Subjects` = n_distinct(SubjectId),
  `Unique Forms`   = n_distinct(FormName),
  `Date First Initiated` = min(InitiatedDate),
  `Date Last Edited` = max(LastEditedDate)
  )

event_date <- unnested  %>%  group_by(DesignVersion, EventDate, SiteName) %>% summarise(
  count = n(),
)

sites <- unnested  %>%  group_by(DesignVersion, SiteName) %>% summarise(
  `Unique Events` = n_distinct(EventName),
  `Unique Subjects` = n_distinct(SubjectId),
  `Unique Forms`   = n_distinct(FormName),
  `Date First Initiated` = min(InitiatedDate),
  `Date Last Edited` = max(LastEditedDate)
  )

events <- unnested  %>%  group_by(DesignVersion, EventName) %>% summarise(
  `Unique Sites` = n_distinct(SiteName),
  `Unique Subjects` = n_distinct(SubjectId),
  `Unique Forms`   = n_distinct(FormName),
  `Date First Initiated` = min(InitiatedDate),
  `Date Last Edited` = max(LastEditedDate)
)

forms <- unnested  %>%  group_by(DesignVersion, FormName) %>% summarise(
  `Unique Sites` = n_distinct(SiteName),
  `Unique Events` = n_distinct(EventName),
  `Unique Subjects` = n_distinct(SubjectId),
  `Date First Initiated` = min(InitiatedDate),
  `Date Last Edited` = max(LastEditedDate)
)

subjects <- unnested  %>%  group_by(DesignVersion, SubjectId) %>% summarise(
  `Unique Sites` = n_distinct(SiteName),
  `Unique Events` = n_distinct(EventName),
  `Unique Forms`   = n_distinct(FormName),
  `Date First Initiated` = min(InitiatedDate),
  `Date Last Edited` = max(LastEditedDate)
)

p_event_date <- event_date %>% ggplot(data= event_date, mapping = aes(x=DesignVersion, y = EventDate, color=SiteName)) +  geom_point(aes(size = count), alpha = 0.3) +
  scale_size(range = c(5, 10)) %>% add_annotations(
      text = "Plot 4",
      x = 0,
      y = 1,
      yref = "paper",
      xref = "paper",
      xanchor = "left",
      yanchor = "top",
      yshift = 20,
      showarrow = FALSE,
      font = list(size = 15)
    ) 
p2 <-
  plot_ly(
    type = "table",
    domain = list(x=c(0,0.5), y=c(0,1)),
    header = list(values = names(event_date)),
    cells = list(values = unname(as.list(ungroup(event_date))))
  )



ggplot(event_date, aes(x=rownames(event_date), y = names(event_date), fill=event_date)) +
    annotate(geom='table',
           x=4,
           y=0,
           label=list(df))


p3 <-subplot(list(p_event_date, p2), nrows = 2,  margin = 0.06)  %>%
  layout(xaxis = list(domain=c(0.5,1.0)), xaxis2 = list(domain=c(0,0.5)))

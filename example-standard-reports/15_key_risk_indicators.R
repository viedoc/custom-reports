SubjectStatus <- edcData$SubjectStatus
ScoreCard <- ScoreCard

# Get Country and Study Name
ld <- params$UserDetails$sites %>% select(SiteCode = siteCode, SiteName = siteName, Country = country, CountryCode = countryCode)
ld$SiteCode <- as.character(ld$SiteCode)
ScoreCard$SiteCode <- as.character(ScoreCard$SiteCode)
ScoreCard <- ScoreCard %>%
  left_join(ld, by = c("SiteName", "SiteCode")) %>%
  mutate(StudyName = params$UserDetails$studyinfo$studyName[1],
         SiteCode = paste0(CountryCode,"-",SiteCode))

ScoreCard <<- ScoreCard %>% mutate(
  RGB = case_when(
    Status == "+/- 1 SD" ~ "#00AC26",
    Status == "+/- 2 SD" ~ "#EBE73D",
    Status == "> +/- 2 SD" ~ "#F86800"
  )
)

# Overview ----
subjCount <- SubjectStatus %>%  mutate(SiteCode = paste0(CountryCode,"-",SiteCode)) %>% group_by(SiteCode, SiteName) %>% summarize(NoOfSubj = n())  %>% data.frame()
overviewSpread <- ScoreCard %>%
  full_join(subjCount) %>%
  arrange(StudyName, Country, SiteCode, SiteName, NoOfSubj, Indicator) %>%
  group_by(StudyName, Country, SiteCode, SiteName, NoOfSubj) %>%
  summarize(Red = sum(Status == "> +/- 2 SD"),
            Orange = sum(Status == "+/- 2 SD"),
            Green = sum(Status == "+/- 1 SD")) %>%
  data.frame() %>%
  arrange(desc(Red), desc(Orange), desc(Green)) %>%
  select(StudyName, Country, SiteCode, SiteName, NoOfSubj, Green, Orange, Red)

overviewSpread <- setLabel(overviewSpread, list("Study Name", "Country", "Site Code", "Site Name", "# of Subjects", "+/- 1 SD", "+/- 2 SD", "> +/- 2 SD"))
headerOverview <- list(firstLevel = c("Study Name", "Country", "Site Code", "Site Name", "# of Subjects", "+/- 1 SD", "+/- 2 SD", "> +/- 2 SD"))
# by Site ----
# * Render by site pie chart ----

selectedSite <- "DE-96" # the country code and site code together is used to select a site

title <- paste0("Key Risk Indicator Status for ",selectedSite)
data <- ScoreCard %>% filter(SiteCode == selectedSite)
statusFreq <- data %>% group_by(Status, RGB) %>% summarize(Freq = n()) %>% data.frame()
pl <- plot_ly(statusFreq, labels = ~Status, values = ~Freq, type = "pie", texttemplate = "%{label} %{percent}", textposition = "outside", hoverinfo = "none", marker = list(colors = ~RGB, line = list(color = "#ffffff", width = 2)), hole = 0.7) %>%
  layout(
    title = list(text = title, x = 0.5),
    showlegend = F,
    margin = list(t = 30, l = 20, r = 10, b = 30),
    font = globalFont
  )

# * Render by site data table ----
siteTableData <<- data %>% select(StudyName, Country, SiteCode, SiteName, Indicator, SiteAverage, StudyAverage, StudyDeviation, Status)
siteTableData <- setLabel(siteTableData, list("Study Name", "Country", "Site Code", "Site Name", "Key Risk Indicator", "Site Value", "Study Mean", "Study Deviation", "Status"))
headerSiteTable <- list(firstLevel = c("Study Name", "Country", "Site Code", "Site Name", "Key Risk Indicator", "Site Value", "Study Mean", "Study Deviation", "Status"))

# by Indicator ----
# * Render by indicator pie chart ----

selectedIndicator <- "Data changes per form"

title <- paste0("Site status for key risk indicator ",selectedIndicator)
data <- ScoreCard %>% filter(Indicator == selectedIndicator)
statusFreq <- data %>% group_by(Status, RGB) %>% summarize(Freq = n()) %>% data.frame()
pl_indicator <- plot_ly(statusFreq, labels = ~Status, values = ~Freq, type = "pie", texttemplate = "%{label} %{percent}", textposition = "outside", hoverinfo = "none", marker = list(colors = ~RGB, line = list(color = "#ffffff", width = 2)), hole = 0.7) %>%
  layout(
    title = list(text = title, x = 0.5),
    showlegend = F,
    margin = list(t = 30, l = 20, r = 10, b = 30),
    font = globalFont
  )

# * Render by indicator data table ----
indicatorTableData <<- data %>% select(StudyName, Country, SiteCode, SiteName, Indicator, SiteAverage, StudyAverage, StudyDeviation, Status)
indicatorTableData <- setLabel(indicatorTableData, list("Study Name", "Country", "Site Code", "Site Name", "Key Risk Indicator", "Site Value", "Study Mean", "Study Deviation", "Status"))
headerIndicatorTable <- list(firstLevel = c("Study Name", "Country", "Site Code", "Site Name", "Key Risk Indicator", "Site Value", "Study Mean", "Study Deviation", "Status"))

reportOutput <- list("Overview " = list("data" = prepareDataForDisplay(overviewSpread), header = headerOverview),
                     "Plot by Site" = list("plot" = pl),
                     "Data by Site " = list("data" = prepareDataForDisplay(siteTableData), header = headerSiteTable),
                     "Plot by Indicator" = list("plot" = pl_indicator),
                     "Data by Indicator " = list("data" = prepareDataForDisplay(indicatorTableData), header = headerIndicatorTable)
)

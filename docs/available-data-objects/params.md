[Return to dev guide](../dev_guide.md)

# params.rds
## params.UserDetails:   
###  params.UserDetails.studyinfo
```JavaScript   
{
  studyName: "my_study",
  studyType: "Training",
}
```   

### params.UserDetails.sites:
  
```JavaScript
/* The list of sites in the "Site Level Data" is based on the user’s access to the study. */
{
  siteNumber: 1,
  siteCode: "1",
  siteName: "1",
  countryCode: "SE",
  country: "Sweden",
  timeZone: "W. Europe Standard Time",
  tzOffset: 60,
  siteType: "Training",
  expectedNumberOfSubjectsScreened: "NA",
  expectedNumberOfSubjectsEnrolled: "NA",
  maximumNumberOfSubjectsScreened: "NA",
},
```   

### params.UserDetails.studysettings:
  
```JavaScript  
{
  expectedNumberOfScreenedSubjects: null,
  expectedNumberOfEnrolledSubjects: null,
  expectedDateOfCompleteEnrollment: null,
  totalNumberOfStudySites: 1,
  totalNumberOfUniqueCountries: 1,
}

```   

## params.dateOfDownload:

```JavaScript
/* the date and time at which the data was pulled from Viedoc to the Reports server */
"2025-03-25 15:51:30"  
```   

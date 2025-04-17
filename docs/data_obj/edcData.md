[Return to dev guide](../dev_guide.md)

# edcData.rds 
## edcData.EventDates  
  <details><summary>Items  </summary>   
    
> Contains one record per visit and its corresponding dates for each subject  
    
```JavaScript   
{  
  SiteSeq: 1,  
  SiteName: "1",  
  SiteCode: "1",  
  SubjectSeq: 1,  
  SubjectId: "SE-1-001",  
  EventId: "E00",  
  EventName: "Subject Registration",  
  EventRepeatKey: "1",  
  EventStatus: "Initiated",  
  EventInitiatedDate: "2025-03-25 15:45",  
  EventPlannedDate: "NA",  
  EventProposedDate: "NA",  
  EventWindowStartDate: "NA",  
  EventWindowEndDate: "NA",  
  InitiatedBy: "Sven Svensson (14389)",  
  InitiatedDate: "2025-03-25 14:45",  
  LastEditedBy: "Sven Svensson (14389)",  
  LastEditedDate: "2025-03-25 14:45",  
  DesignVersion: "1.0",  
  CountryCode: "SE",  
  Country: "Sweden",  
},
```  
  </details>  

## edcData.Items  
  <details><summary>Items  </summary>   

>  Contains one record per item with ID, label,datatype, content length and other details.  
    
```JavaScript   
{ 
  ID: "SiteSeq",  
  Label: "Site sequence number",  
  DataType: "integer",  
  Mandatory: "NA",  
  Decimals: "NA",  
  MinLength: "NA",  
  MaxLength: "NA",  
  FormatName: "NA",  
  ContentLength: 1,  
},
```  
  </details>  

## edcData.CodeLists  
  <details><summary>Items  </summary>      

>  Contains one record per code text with format name, datatype and code value. 
    
```JavaScript  
{  
  FormatName: "CL_CPROTVERSF",  
  DataType: "integer",  
  CodeValue: "1",  
  CodeText: "21 Dec 2021 Version 5.0",  
},
```  
  </details>  

## edcData.Queries
  <details><summary>Items  </summary>       
    
> Contains one record per query per status along with its status remarks and dates  
    
```JavaScript  
{  
  QueryStudySeqNo: 1,  
  SiteSeq: 1,  
  SiteName: "1",  
  SiteCode: "1",  
  SubjectSeq: 1,  
  SubjectId: "SE-1-001",  
  EventSeq: "1",  
  EventId: "E00",  
  EventName: "Subject Registration",  
  EventDate: "2025-03-25",  
  ActivityId: "START_IC",  
  ActivityName: "NA",  
  FormId: "IC",  
  FormName: "Subject Registration",  
  FormSeq: "1",  
  SubjectFormSeq: 1,  
  OriginSubjectFormSeq: 1,  
  SourceSubjectFormSeq: "NA",  
  ItemId: "PRVSCRNO",  
  ItemName: "Previous screening number",  
  QueryItemSeqNo: 1,  
  RaisedOn: "Item",  
  QueryType: "Validation",  
  RangeCheckOID: "RC_PRVSCRNO_1_0_1",  
  QueryText:  
    "'Previous screening number' is not in the expected format.   Please correct.",
  QueryState: "Query Raised",  
  QueryResolution: "NA",  
  UserName: "System (0)",  
  DateTime: "2025-03-25 14:45",  
  UserRole: "NA",  
  QueryRaisedByRole: "NA",  
  CountryCode: "SE",  
  Country: "Sweden",  
},
```  
    
  </details>  

## edcData.ReviewStatus
<details><summary>Items  </summary>  

> Contains one record per visit and form and has the statuses for DM Review, Clinical Review, Signature, and Lock  
    
```JavaScript  
{  
  SiteSeq: 1,  
  SiteName: "1",  
  SiteCode: "1",  
  SubjectSeq: 1,  
  SubjectId: "SE-1-001",  
  EventSeq: "1",  
  EventId: "E01",  
  EventName: "V1 Screening",  
  EventDate: "2025-03-13",  
  ActivityId: "NA",  
  ActivityName: "NA",  
  FormId: "$EVENT",  
  FormName: "NA",  
  FormSeq: "NA",  
  SubjectFormSeq: 0,  
  OriginSubjectFormSeq: 0,  
  SourceSubjectFormSeq: "NA",  
  ReviewedItem: "Event date",  
  CrBy: "N/A",  
  CrDate: "N/A",  
  DmBy: "N/A",  
  DmDate: "N/A",  
  SdvBy: "N/A",  
  SdvDate: "N/A",  
  SignBy: "N/A",  
  SignDate: "N/A",  
  LockBy: "N/A",  
  LockDate: "N/A",  
  CountryCode: "SE",  
  Country: "Sweden",  
},
```  
</details>    

## edcData.SubjectStatus
  <details><summary>Items  </summary>   

> Contains one record per subject along with the screening, enrollment, withdrawal status
    
```JavaScript  
{  
  SiteSeq: 1,  
  SiteName: "1",  
  SiteCode: "1",  
  SubjectSeq: 1,  
  SubjectId: "SE-1-001",  
  ScreenedState: true,  
  ScreenedOnDate: "2025-03-13 00:00",  
  EnrolledState: true,  
  EnrolledOnDate: "2025-03-25 15:47",  
  CompletedState: false,  
  CompletedOnDate: "NA",  
  WithdrawnState: false,  
  WithdrawnOnDate: "NA",  
  CountryCode: "SE",  
  Country: "Sweden",  
}, 
```    
  </details>  

## edcData.PendingForms
  <details><summary>Items  </summary>  

> Contains one record per pending form  
    
```JavaScript  
{  
  SiteSeq: 1,  
  SiteName: "1",  
  SiteCode: "1",  
  SubjectSeq: 1,  
  SubjectId: "SE-1-001",  
  EventSeq: "1",  
  EventId: "E01",  
  EventName: "V1 Screening",  
  EventDate: "2025-03-13",  
  ActivityId: "SCR_LBASS",  
  ActivityName: "NA",  
  FormId: "LB_LL_CC",  
  FormName: "Clinical Chemistry – Local lab",  
  PendingSince: "2025-03-25 14:45",  
  CountryCode: "SE",  
  Country: "Sweden",  
},
```  
  </details>     

## edcData.ProcessedQueries
  <details><summary>Items  </summary>   

> Contains one record per query (processed across the status)  
    
```JavaScript  
{  
  QueryStudySeqNo: 1,  
  SiteSeq: 1,  
  SiteName: "1",  
  SiteCode: "1",  
  SubjectSeq: 1,  
  SubjectId: "SE-1-001",  
  EventSeq: "1",  
  EventId: "E00",  
  EventName: "Subject Registration",  
  EventDate: "2025-03-25",  
  ActivityId: "START_IC",  
  ActivityName: "NA",  
  FormId: "IC",  
  FormName: "Subject Registration",  
  FormSeq: "1",  
  SubjectFormSeq: 1,  
  OriginSubjectFormSeq: 1,  
  SourceSubjectFormSeq: "NA",  
  ItemId: "PRVSCRNO",  
  ItemName: "Previous screening number",  
  QueryItemSeqNo: 1,  
  RaisedOn: "Item",  
  QueryType: "Validation",  
  RangeCheckOID: "RC_PRVSCRNO_1_0_1",  
  QueryText:  
  "'Previous screening number' is not in the expected format.   Please   correct.",
  PrequeryText: "NA",  
  UserName: "System (0)",  // Username for the person who raised the   query/who left the field blank
  QueryResolution: "sdf",  
  ClosedByDataEdit: "NA",  
  QueryResolutionHistory: "QueryResolved:Sven Svensson (14389):sdf;     ",
  QueryStatus: "Query Resolved",  
  PrequeryPromoted: "NA",  
  PrequeryPromotedBy: "NA",  
  PrequeryRaised: "NA",  
  PrequeryRaisedBy: "NA",  
  PrequeryRejected: "NA",  
  PrequeryRejectedBy: "NA",  
  PrequeryRemoved: "NA",  
  PrequeryRemovedBy: "NA",  
  QueryApproved: "NA",  
  QueryApprovedBy: "NA",  
  QueryClosed: "NA",  
  QueryClosedBy: "NA",  
  QueryRaised: "2025-03-25 14:45",  
  QueryRaisedBy: "System (0)",  
  QueryRejected: "NA",  
  QueryRejectedBy: "NA",  
  QueryRemoved: "NA",  
  QueryRemovedBy: "NA",  
  QueryResolved: "2025-03-25 14:45",  
  QueryResolvedBy: "Sven Svensson (14389)",  
  QueryClosed_C: "NA",  
  OpenQueryAge: "NA",  // Difference (in days) between the Query Raised date and current date for query in 'Query Raised' state;
  ResolvedQueryAge: 0,   // Difference (in days) between the Query Resolved date and current date for query in 'Query Resolved' state
  PrequeryAge: "NA",  // Difference (in days) between the Prequery Raised date and current date for prequery in 'Prequery Raised' or 'Prequery Promoted' states
  TimeToResolution: 0,  // Difference (in days) between the Query Raised date and Query Resolved/ Query Closed date
  TimeToApproval: "NA",  // Difference between the Query Resolved date and Query Approved/ Query Rejected date;
  TimeToRelease: "NA",  // Difference between the Prequery Raised date and Prequery Rejected/Removed/Released(Query Raised) date
  TimeofQueryCycle: "NA",  // Difference between the Query Raised date and Query Approved/ Query Rejected/ Query Closed date
  TimeToRemoval: "NA",  
  RaisedMonth: "Mar 2025",  
  ResolvedMonth: "Mar 2025",  
  RemovedMonth: "NA",  
  LatestActionBy: "Sven Svensson (14389)",  
  LatestActionOn: "2025-03-25 14:45",  
  CountryCode: "SE",  
  Country: "Sweden",  
},
```  
  </details>     

## edcData.Forms
  <details><summary>Items  </summary> 

> edcData\$Forms\$[form id] will be a data.frame that contains the CRF data of that particular form. eg. edcData$Forms$DM will have the data from Demographics form
  
### edcData.Forms.ExFormID

```JavaScript  
{
  SiteSeq: 5,
  SiteName: "checkbox",
  SiteCode: "CH",
  SubjectSeq: 1,
  SubjectId: "SE-CH-001",
  EventSeq: "1",
  EventId: "e1",
  EventName: "event1",
  EventDate: "2025-04-16",
  ActivityId: "act2",
  ActivityName: "act2",
  FormSeq: "1",
  SubjectFormSeq: 1,
  OriginSubjectFormSeq: 1,
  SourceSubjectFormSeq: "NA",
  DesignVersion: "11.2",
  InitiatedBy: "Sylvia Van Belle (30358)",
  InitiatedDate: "2025-04-16 13:43",
  LastEditedBy: "Sylvia Van Belle (30358)",
  LastEditedDate: "2025-04-16 13:43",
  Item1: "NA",
  Item11CD: "NA",
  CountryCode: "SE",
  Country: "Sweden"
},
```
  </details>     

## edcData.TimeLapse
  <details><summary>Items  </summary>  

> Contains one record per form with lapse days(number of days between the event date and the data entry start date)  
    
```JavaScript  
{
  SiteCode: "1",  
  SiteName: "1",  
  SubjectId: "SE-1-001",  
  EventId: "E00",  
  EventName: "Subject Registration",  
  EventSeq: "1",  
  ActivityId: "START_IC",  
  ActivityName: "NA",  
  FormSeq: "1",  
  DesignVersion: "1.0",  
  EventDate: "2025-03-25",  
  InitiatedDate: "2025-03-25",  
  FormName: "Subject Registration",  
  LapseDays: 0,  
  CountryCode: "SE",  
  Country: "Sweden"
},
```  
  </details>  
  

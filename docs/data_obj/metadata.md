# metadata.rds  
## MDVOIDs: 
  <details><summary>Items  </summary> 
    
  ```JavaScript   
"2.0",
  ```
  </details>
  
  ## GlobalVariables:   
  <details><summary>Items  </summary>     
    
  ```JavaScript   
    {
      StudyName: "MYSTUDY",
      StudyDescription: "MYSTUDY",
      ProtocolName: "000359",
    },
```
</details>

##  BasicDefinitions:   
 <details><summary>Items  </summary>         
    
```JavaScript   
    {
      Definition: "MeasurementUnit",
      OID: "MU_17",
      Name: "mL",
    },
```     
</details>   
   
 ##  StudyEventRef:    
  <details><summary>Items  </summary>        
    
```JavaScript   
    {
      MDVOID: "1.0",
      StudyEventOID: "E00",
      OrderNumber: "0",
      Mandatory: "No",
    },
```
   </details>    
   
## StudyEventDef:    
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      OID: "E00",
      Name: "Subject Registration",
      Repeating: "No",
      Type: "Scheduled",
      Category: "AddEvent",
    },
```
</details>
       
## FormRef:    
<details><summary>Items  </summary>      
  
```JavaScript   
    {
      MDVOID: "1.0",
      StudyEventOID: "E00",
      FormOID: "IC",
    },
```
</details>   

## FormDef:   
<details><summary>Items  </summary>
  
  ```JavaScript   
    {
      MDVOID: "1.0",
      OID: "LB_LL_CC",
      Name: "Clinical Chemistry – Local lab",
      Repeating: "No",
      Sdv: "None",
      Hidden: "",
    },
 ```
 </details>
 
 ## ItemGroupRef:
 <details><summary>Items  </summary>
   
```JavaScript   
    {
      MDVOID: "1.0",
      FormOID: "LB_LL_CC",
      ItemGroupOID: "LB_LL_CCG22",
    },
```
</details>

##  ItemGroupDef:
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      OID: "LB_LL_CCG22",
      Name: "Instructions 22",
      Repeating: "No",
      IsReferenceData: "",
      SASDatasetName: "",
      Domain: "",
      Origin: "",
      Purpose: "",
      Comment: "",
    },
 ```
 </details>
 
 ## ItemDef:
  <details><summary>Items  </summary>
    
```JavaScript   
    {
      MDVOID: "1.0",
      OID: "CC_LBPERF",
      Name: "CC_LBPERF",
      DataType: "integer",
      Length: "12",
      SignificantDigits: "",
      SASFieldName: "",
      SDSVarName: "",
      Origin: "",
      Comment: "",
      Question: "Was the sample for clinical chemistry test collected?",
      MeasurementUnitOID: "",
      CodeListOID: "CL_HM_LBPERF",
      HtmlType: "radio",
      Sdv: "Required",
    },
```
</details>   

## ItemRef  
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      ItemGroupOID: "CCG1",
      ItemOID: "CC_LBPERF",
    }
```
</details>

## CodeList:
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      OID: "CL_VDYN",
      Name: "CL_VDYN",
      DataType: "text",
      SASFormatName: "YN",
      CodeListType: "CodeListItem",
      CodedValue: "Y",
      DecodedValue: "Yes",
      Rank: "",
      OrderNumber: "",
    },
```
</details>

##  RolesDef:
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      OID: "R1",
      Name: "Investigator",
      Permissions:
        "AddForm,ResetForm,AddPatient,EditForm,ScheduleEvent,EditEventSchedule,SignEvent,SignForm,ExportReport,DeleteSubjects,AnonymizeData,ViewRoles",
    },
```
</details>

## SDVSettings:
<details><summary>Items  </summary>
  
  ```JavaScript   
    {
      MDVOID: "1.0",
      SDVScope: "All",
    },
```
</details>

## ActivityDef:
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      OID: "ACT_E00_START",
      ExcludeDateForm: "true",
    },
```
</details>

## formitems:
<details><summary>Items  </summary>
  
```JavaScript   
    {
      MDVOID: "1.0",
      FormOID: "LB_LL_CC",
      FormName: "Clinical Chemistry – Local lab",
      Hidden: "",
      ItemGroupOID: "LB_LL_CCG22",
      ItemOID: "NA",
      Name: "NA",
      DataType: "NA",
      Length: "NA",
      SignificantDigits: "NA",
      SASFieldName: "NA",
      SDSVarName: "NA",
      Origin: "NA",
      Comment: "NA",
      Question: "NA",
      MeasurementUnitOID: "NA",
      CodeListOID: "NA",
      HtmlType: "NA",
      Sdv: "NA",
    },
```
</details>


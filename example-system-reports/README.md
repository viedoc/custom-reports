# Study-independent functional reports:

> These reports can be added to any study without modification for additional monitoring functionality. They use system-generated data as inputs. 

## Active versions report
<details>
  
### Purpose
Identify all active design versions across implemented forms. 
This assists:
- Designers/support when debugging issues in studies that may result from inconsistent versioning between patients, as this information is typically found in data exports which contain sensitive information. 
- Administrators who will be implementing version updates or revisions.
- Designers who may need to implement revisions across design versions.

### Source Data/required data inputs:
- `edcData`
- `metadata$FormDef`

### Output:
Creates a table showing the number of instantiated forms of each design version, where each form is a column, and each design version as a row. 
</details>

## Aging and old queries report
<details>
  
### Purpose
Gives an overview of queries and time spent in various states to assist in the identification of bottlenecks or red flags.

### Source Data/required data inputs:
- `edcData$ProcessedQueries`

### Output:
Creates a table with a query per row and columns detailing what was queried, query type, status, age, and time spent in various states.
</details>

## Locked forms with issues report
<details>
### Purpose
Provides a list of forms that will require unlocking for issue resolution, including unanswered queries, unconfirmed missing data and forms pending upgrade.

### Source Data/required data inputs:
- `edcData$ReviewStatus`
- `edcData$Queries`

### Output:
Creates a table with showing an the number of open queries, unconfirmed missing data points and if a form upgrade is pending alongside form details. Each row represents a form instance (form per subject per event, etc.) that has has queries and is locked.
</details>

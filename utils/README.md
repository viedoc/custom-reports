# Utils

## [utilityFunctions.R](./utilityFunctions.R)
These are functions available to any script loaded in the Viedoc Reports Server. See [Utility Function Documentation](../docs/dev_guide.md#utility-functions).
These functions can be loaded into local workspace using `source("utilityFunctions.R", local = T)` when the utilityFunctions.R script is located in the working directory.

## [id_ouptut_id_mismatches.R](./id_ouptut_id_mismatches.R)
The purpose of this code snippet is to resolve issues that are caused when output field IDs are used for form items.  
These items are represented using the output field ID in edcData, but use the standard field_id/item_id in the metadata.  
This means that you cannot perform lookups beetween them. This script creates a lookup table between the SAS field name (output field id) and the item ID 

> [!Note]
> Viedoc Designer does not control for conflicting Output IDs, and this script will likely not handle duplicate output field IDs.
> If there are multiple items with the same output ID, it will select the first field ID sorted by descending design version.
> There may also be issues when cross referenicng formlink or checkbox items.

## [read_from_xlsx_export.R](./[read_from_xlsx_export.R)
This code snippet allows for the excel Data Exports from Viedoc Clinic to be read into R to replace the edcData.rds. 
This could be useful when testing specific a script on a specific dataset.

> [!Note]
> Dates are handled differently in Excel files and may therefore not be representative of the data available in Reports.  
> A country column is also available in edcData.rds/Reports, but not the data Export.
> The first row of the Excel spreadsheets containing field output labels is not imported.

## [version_checker.R](./version_checker.R)
This script creates a Viedoc Reports table that shows the versions of installed packages in the Viedoc Reports environment, when uploaded as a custom report in Designer.
If functions seem to be behaving differently in Viedoc Reports compared to your local environment, compare the package versions by running the script locally and viewing the packageVersions table.


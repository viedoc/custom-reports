# Example custom reports
[return to root README](../README.md)

## Purpose
Demonstrate patterns for building bespoke Viedoc custom reports, including data joins, visualizations, and error handling.

## Audience
Report developers seeking reusable examples that can be adapted to study-specific requirements.

## Prerequisites
- Local environment configured with the [development starter kit](../development-starter-kit/README.md) or equivalent.
- Access to sample data that aligns with the included study design (`StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml`).

## Instructions
1. Import the provided study design template into Viedoc Designer and publish the global settings that enable custom reports.
2. Load `SampleReportCode.R` or any report script in this folder into your local R session to understand the structure.
3. Review the example summaries below, then open the corresponding subfolder to inspect the script and supporting assets.
4. Adapt the examples to match your study design, test locally, and upload to Viedoc Reports when validated.

## Available examples


<details><summary><a href="./ongoing-AEs/ongoingAEs.R"> Ongoing Adverse Events:</a>: lists ongoing adverse events with sub-reports filtered by duration since start date.</summary>

- Overview
  - This report displays all ongoing adverse events. This demonstrates a good example of how to filter data based on specific criteria, as well as how to create a report with two sub-reports.
  - how to select data that fulfills certain criteria (adverse events that were recorded as ongoing)
  - data sorting
- Source Data/required data inputs:
  - `edcData$Forms$AE`
- Output
  - 'Ongoing AEs': A table of all adverse events (AEs) that are ongoing, sorted by start date (ascending).
  - Sub-report 'Start Date > 30 days': A table of ongoing AEs with a start date of more than 30 days ago.

</details>
<details><summary><a href="./treatment-related-SAEs/treatmentRelatedSAEs.R">Treatment-related Severe Adverse Events</a>: summarizes treatment-related serious adverse events by subject and site.</summary>

- Overview
  - how to select data that fulfills certain criteria (adverse events that were recorded as (possibly) treatment-related and serious) and summarising the data by site.
  - customised column widths
- Source Data/required data inputs:
   - `edcData$Forms$AE`
- Output
  - 'by Subject': A table of all AEs entered as possibly related to the study treatment and as Serious.
  - 'by Site': A table of the number of AEs fulfilling the above criteria per site.

</details>
<details><summary><a href="./demographics-SAEs/saeDemographics.R">Serious Adverse Events by demographics </a>: joins adverse events with demographics to analyze serious events by subject characteristics.</summary>


- Overview
    - Joining data from two forms with detailed explanation of the function.
    - Concatonating data across a row (merging columns for a checkbox item)
- Source Data/required data inputs:  
  - `edcData$Forms$AE`
  - `edcData$Forms$DM`
- Output
  - A table of AEs entered as Serious, combined with the subject's sex and age from the demographic form, where each row is a reported adverse event.

</details>
<details><summary><a href="./blood-pressure/bloodPressurePlot.R">Blood Pressure</a>: produces scatter plots and mean arterial pressure calculations using <code>edcData$Forms$VS</code>.</summary>

- Overview
   - Demonstrates simple scatter plot implementation
- Source Data/required data inputs*
  - `edcData$Forms$VS`
  - `params$dateOfDownload`
- Output
  - 'Mean Arterial Pressure' (MAP): A plot of the calculated MAP.
  - 'Systolic only': A scatter plot of the systolic blood pressure.
  - 'Diastolic only': A scatter plot of the diastolic blood pressure.

</details>
<details><summary><a href="./drug-accountability/drugAccountability.R">Drug Accountability</a>: reconciles allocated and returned kits, including safeguards for missing form data.</summary>


- Overview
  - Handle null when edcData contains no instances of a form. 
  - Using a custom report to calculate scores or other metrics
  - Merging data from two forms
  - Monitoring kit allocation and returns
- Source Data/required data inputs*
  - `edcData$Forms$DA`
  - `edcData$Forms$KIT`
- Output
  - A table of allocated and returned kits with the expected and the actual returned numbers of tablets. Each row represents an instnace of a kit allocation form.

</details>
<details><summary><a href="./medication-inconsistency/medicationInconsistency.R">Medication Inconsistency</a>: cross-checks concomitant medications against adverse events to surface data entry discrepancies.</summary>


- Overview
  - Compares AEs with concomitant medication (CMs) to check for inconsistencies in data entry.
  - use of regEx to identify columns based on a name pattern
  - pivoting a table to convert wide data into long data.  
- Source Data/required data inputs*
  - edcData$Forms$AE
  - edcData$Forms$CM
- Output
  - 'CMs linked to AEs where no meds were prescribed': A table showing the concomitant medication (CMs) entries that are linked to the adverse events entries in which it was reported that no treatments or medications were prescribed. One row represents a form link item on a reported CM form.
  - 'AEs where meds were prescribed not linked to CMs': A table showing adverse events entries for which it was reported that treatments or medications were prescribed, but for which no concomitant medications entry exists. One row is a reported Adverse event where use of medication was reported, but no form links to the adverse event were reported on concommitant medication forms.
  
</details>
<details><summary><a href="./outliers/outliers.R">Outliers</a>: flags statistical outliers in vital sign measurements for targeted review.</summary>

- Source Data/required data inputs*
  - `edcData$Forms$VS`
- Output
  - 'Systolic BP': A table listing outliers in the systolic blood pressure data.
  - 'Diastolic BP': A table listing outliers in the diastolic blood pressure data.

</details>
<details><summary><a href="./survival-curve/survivalCurvePlotKaplanMeier.R">Survival Curve</a>: generates Kaplan-Meier plots and supporting tables </summary>


- Overview
  - how ow to perform a survival analysis using the Survival package, and a more complicated plot (see nested README for screenshots).
  - Source Data/required data inputs*
  - `edcData$Forms$DM`
  - `edcData$Forms$DS`
- Output
  - 'Survival Curve': A plot of the Kaplan-Meier model, with 95% confidence intervals.
  - 'Survival Table': A table with the plotted values.  

</details>
<details><summary><a href="./SAE-guage-plot/SAE%20gauge%20plot.R">SAE gauge plot (unvalidated)</a>: demonstrates gauge visualizations for recent adverse events and serious adverse events.</summary>

- Overview
  - Showcases guage plot implementation
  - Provides an example of 'ageing' a form
- Source Data/required data inputs*
  - `edcData$Forms$AE`
  - `params[["dateOfDownload"]]`
- Output
  - 'by Subject': table showing the details of all adverse events that were marked as serious, where each row is an adverse event form instance.
  - 'by Site': table showing the count of serious adverse events per site, where each row is a site that reported severe adverse events.
  - 'AE Plot': Guage plot showing the proportion of adverse events that occured within 7 days of data export
  - 'SAE Plot': Guage plot showing the proportion of severe adverse events that occured within 7 days of data export
</details>

## Outputs / Expected results
- Working custom report scripts that showcase filtering, joining, plotting, and multi-output patterns.
- Reusable snippets for handling empty datasets, date calculations, and labeling.

## Tips / Troubleshooting / FAQs
- Some examples expect CDASH-like naming; adjust item identifiers if your forms differ.
- Use the helper utilities from `utility-function-scripts/` to simplify label management and empty-output handling.
- When adapting plots, confirm the required packages are available in the Viedoc runtime (`utilityFunctions.R` loads common dependencies).

## Additional resources
- [Available data objects](../available-data-objects/README.md)
- [Study-independent reports](../example-system-reports/README.md)
- [Creating custom reports (Viedoc Learning)](https://help.viedoc.net/c/8a3600/6e9c82/en/)

## Notes
- The examples were authored for the included Phase II template but can be reworked for other designs.

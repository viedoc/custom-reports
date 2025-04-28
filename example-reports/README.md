# Example reports 
[return to root README](../README.md)

> [!Note]
> The example 'use case' reports have been developed for the [Phase II study design template](./StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml) included in this directory, or any studies that follow the Clinical Data Acquisition Standards Harmonization (CDASH) standards. Some reports depend on a more specialised design, which will be included in the relevant subfolder folder.  
> These examples also demonstrate to a variable degree testing and QC of custom reports.

## To use:
1. In Viedoc Admin, create a new study. Assign a designer and allow Reports in Design Settings.
2. Import the study design template into Designer and Publish, and in Global design settings, set access to reports, upload the custom report and publish these settings.
3. In Viedoc Admin, create demo sites and assign an investigator and role with permission to see the reports.
4. If running tests, open reports to test custom script with no initialised data
5. Otherwise, as an investigator in Viedoc Clinic add test subjects, inputing data for any forms used by the script.
6. In order to manually sync data between Clinic and reports, disable reports in Admin Study Settings, wait an hour, and reenable it. The training server does not automatically sync reports.

## Contents:

<details><summary><h3>Ongoing Adverse Events<a href="./ongoing-AEs/ongoingAEs.R">:link:</a></h3></summary>
  
#### Overview
This report displays all ongoing adverse events. This demonstrates a good example of how to filter data based on specific criteria, as well as how to create a report with two sub-reports.
  - how to select data that fulfills certain criteria (adverse events that were recorded as ongoing)
  - data sorting
#### Source Data/required data inputs:
- `edcData$Forms$AE`
#### Output
- 'Ongoing AEs': A table of all adverse events (AEs) that are ongoing, sorted by start date (ascending).
- Sub-report 'Start Date > 30 days': A table of ongoing AEs with a start date of more than 30 days ago.

</details>
<details><summary><h3>Treatment-related Severe Adverse Events<a href="./treatment-related-SAEs/treatmentRelatedSAEs.R">:link:</a></h3></summary>

#### Overview
how to select data that fulfills certain criteria (adverse events that were recorded as (possibly) treatment-related and serious) and summarising the data by site.
- customised column widths
#### Source Data/required data inputs:
 - `edcData$Forms$AE`
#### Output
- 'by Subject': A table of all AEs entered as possibly related to the study treatment and as Serious.
- 'by Site': A table of the number of AEs fulfilling the above criteria per site.

</details>
<details><summary><h3>Serious Adverse Events by demographics <a href="./demographics-SAEs/saeDemographics.R">:link:</a></h3></summary>

#### Overview
- Joining data from two forms with detailed explanation of the function.
- Concatonating data across a row (merging columns for a checkbox item)
#### Source Data/required data inputs:
- `edcData$Forms$AE`
- `edcData$Forms$DM`
#### Output
- A table of AEs entered as Serious, combined with the subject's sex and age from the demographic form, where each row is a reported adverse event.

</details>
<details><summary><h3>Blood Pressure<a href="./blood-pressure/bloodPressurePlot.R">:link:</a></h3></summary>

#### Overview
Demonstrates simple scatter plot implementation
#### Source Data/required data inputs:
- `edcData$Forms$VS`
- `params$dateOfDownload`
#### Output
- 'Mean Arterial Pressure' (MAP): A plot of the calculated MAP.
- 'Systolic only': A scatter plot of the systolic blood pressure.
- 'Diastolic only': A scatter plot of the diastolic blood pressure.

</details>
<details><summary><h3>Drug Accountability<a href="./drug-accountability/drugAccountability.R">:link:</a></h3></summary>

#### Overview
- Handle null when edcData contains no instances of a form. 
- Using a custom report to calculate scores or other metrics
- Merging data from two forms
- Monitoring kit allocation and returns
#### Source Data/required data inputs:
- `edcData$Forms$DA`
- `edcData$Forms$KIT`
#### Output
- A table of allocated and returned kits with the expected and the actual returned numbers of tablets. Each row represents an instnace of a kit allocation form.

</details>
<details><summary><h3>Medication Inconsistency<a href="./medication-inconsistency/medicationInconsistency.R">:link:</a></h3></summary>

#### Overview
Compares AEs with concomitant medication (CMs) to check for inconsistencies in data entry.
- use of regEx to identify columns based on a name pattern
- pivoting a table to convert wide data into long data.  
#### Source Data/required data inputs:
- edcData$Forms$AE
- edcData$Forms$CM
#### Output
- 'CMs linked to AEs where no meds were prescribed': A table showing the concomitant medication (CMs) entries that are linked to the adverse events entries in which it was reported that no treatments or medications were prescribed. One row represents a form link item on a reported CM form.
- 'AEs where meds were prescribed not linked to CMs': A table showing adverse events entries for which it was reported that treatments or medications were prescribed, but for which no concomitant medications entry exists. One row is a reported Adverse event where use of medication was reported, but no form links to the adverse event were reported on concommitant medication forms.
  
</details>
<details><summary><h3>Outliers<a href="./outliers/outliers.R">:link:</a></h3></summary>

#### Overview
how to identify statistical outliers in the data
#### Source Data/required data inputs:
- `edcData$Forms$VS`
#### Output
- 'Systolic BP': A table listing outliers in the systolic blood pressure data.
- 'Diastolic BP': A table listing outliers in the diastolic blood pressure data.

</details>
<details><summary><h3>Survival Curve<a href="./survival-curve/survivalCurvePlotKaplanMeier.R">:link:</a></h3></summary>

#### Overview
how to perform a survival analysis using the Survival package, and a more complicated plot.
#### Source Data/required data inputs:
- `edcData$Forms$DM`
- `edcData$Forms$DS`
#### Output
- 'Survival Curve': A plot of the Kaplan-Meier model, with 95% confidence intervals.
- 'Survival Table': A table with the plotted values.  

</details>
<details><summary><h3>SAE gauge plot (unvalidated)<a href="./SAE-guage-plot/SAE%20gauge%20plot.R">:link:</a></h3></summary>

#### Overview
- Showcases guage plot implementation
- Provides an example of 'ageing' a form
#### Source Data/required data inputs:
- `edcData$Forms$AE`
- `params[["dateOfDownload"]]`
#### Output
- 'by Subject': table showing the details of all adverse events that were marked as serious, where each row is an adverse event form instance.
- 'by Site': table showing the count of serious adverse events per site, where each row is a site that reported severe adverse events.
- 'AE Plot': Guage plot showing the proportion of adverse events that occured within 7 days of data export
- 'SAE Plot': Guage plot showing the proportion of severe adverse events that occured within 7 days of data export
</details>

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

  - how to select data that fulfills certain criteria (adverse events that were recorded as ongoing)
  - data sorting

#### Source Data/required data inputs:
#### Output
  
</details>
<details><summary><h3>Treatment-related Severe Adverse Events<a href="./treatment-related-SAEs/treatmentRelatedSAEs.R">:link:</a></h3></summary>

how to select data that fulfills certain criteria (adverse events that were recorded as (possibly) treatment-related and serious) and summarising the data by site.
#### Source Data/required data inputs:
#### Output

</details>

<details><summary><h3>Serious Adverse Events by demographics <a href="./demographics-SAEs/saeDemographics.R">:link:</a></h3></summary>
  
select data that fulfills certain criteria (adverse events that were recorded as serious) and how to combine this with data from a different form (in this case, a few data points from the Demographics form).
#### Source Data/required data inputs:
#### Output

</details>
<details><summary><h3>Blood Pressure
  <a href="./blood-pressure/bloodPressurePlot.R">
    :link:
  </a></h3></summary>

simple scatter plots as subreports using the plotly package
#### Source Data/required data inputs:
#### Output

</details>
<details><summary><h3>Drug Accountability
  <a href="./drug-accountability/drugAccountability.R">
    :link:
  </a></h3></summary>
  
monitoring of kit allocation and returns
#### Source Data/required data inputs:
#### Output

</details>
<details><summary><h3>Medication Inconsistency<a href="./medication-inconsistency/medicationInconsistency.R">:link:</a></h3></summary>
  
relationship between concomitant medication forms and adverse event forms
#### Source Data/required data inputs:
#### Output

</details>
<details><summary><h3>Outliers<a href="./outliers/outliers.R">:link:</a></h3></summary>

how to identify statistical outliers in the data
#### Source Data/required data inputs:
#### Output

</details>
<details><summary><h3>Survival Curve<a href="./survival-curve/survivalCurvePlotKaplanMeier.R">:link:</a></h3></summary>
  

how to perform a survival analysis using the Survival package, and a more complicated plot using the plotly package.

#### Source Data/required data inputs:
#### Output

</details>
<details><summary><h3>SAE gauge plot (unvalidated)<a href="./SAE-guage-plot/SAE%20gauge%20plot.R">:link:</a></h3></summary>

example of a gauge plot
  
#### Source Data/required data inputs:

#### Output

</details>

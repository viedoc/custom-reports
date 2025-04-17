# Example reports 
[return to root README](../README.md)

This folder contains information and resources previously contained on the  [eLearning Designer User Guide](https://help.viedoc.net/c/e311e6/) article entitled Custom reports examples.

> The example 'use case' reports have been developed for the [Phase II study design template](./StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml) included in this directory, or any studies that follow the Clinical Data Acquisition Standards Harmonization (CDASH) standards. Some reports depend on a more specialised design, which will be included in the folder. These examples also demonstrate to a variable degree testing and QC of custom reports. Additional information on the inputs and outputs of each report can be found in the README file in the relevant graph's subdirectory.

> ex

## Contents:
- name of plot, forms it depends on, output object

- [Ongoing Adverse Events](./ongoing-AEs/ongoingAEs.R): how to select data that fulfills certain criteria (adverse events that were recorded as ongoing) and data sorting.
- [Treatment-related Severe Adverse Events](./treatment-related-SAEs/treatmentRelatedSAEs.R): how to select data that fulfills certain criteria (adverse events that were recorded as (possibly) treatment-related and serious) and summarising the data by site.
- [Serious Adverse Events by demographics](./demographics-SAEs/saeDemographics.R): select data that fulfills certain criteria (adverse events that were recorded as serious) and how to combine this with data from a different form (in this case, a few data points from the Demographics form).
- [Blood Pressure](./blood-pressure/bloodPressurePlot.R): simple scatter plots as subreports using the plotly package
- [Drug Accountability](./drug-accountability/drugAccountability.R): monitoring of kit allocation and returns
- [Medication Inconsistency](./medication-inconsistency/medicationInconsistency.R): relationship between concomitant medication forms and adverse event forms
- [Outliers](/outliers/outliers.R): how to identify statistical outliers in the data
- [Survival Curve](./survival-curve/survivalCurvePlotKaplanMeier.R): how to perform a survival analysis using the Survival package, and a more complicated plot using the plotly package.
- [SAE gauge plot](./SAE-guage-plot/SAE%20gauge%20plot.R) (unvalidated): example of a gauge plot

## To use:
1. In Viedoc Admin, create a new study. Assign a designer and allow Reports in Design Settings.
2. Import the study design template into Designer and Publish, and in Global design settings, set access to reports, upload the custom report and publish these settings.
3. In Viedoc Admin, create demo sites and assign an investigator and role with permission to see the reports.
4. If running tests, open reports to test custom script with no initialised data
5. Otherwise, as an investigator in Viedoc Clinic add test subjects, inputing data for any forms used by the script.
6. In order to manually sync data between Clinic and reports, disable reports in Admin Study Settings, wait an hour, and reenable it. The training server does not automatically sync reports.

# Example reports overview

## Usage
- The example reports have been developed for the [Phase II study design template](StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml) included in this directory. Some reports depend on a more specilased design, which will be included in the folder. These examples also demonstrate testing and QC of custom reports, using test cases.

## Use case examples:
- [Blood Pressure](./blood-pressure/bloodPressurePlot.R): simple scatter plots as subreports using the plotly package
- [Drug Accountability](./drug-accountability/drugAccountability.R): monitoring of kit allocation and returns
- [Medication Inconsistency](./medication-inconsistency/medicationInconsistency.R): relationship between concommitant medication forms and adverse event forms
- [Outliers](./outliers/outliers.R): how to identify statistical outliers in the data
- [Survival Curve](./survival-curve/survivalCurvePlotKaplanMeier.R): how to perform a survival analysis using the Survival package, and a more complicated plot using the plotly package.
- [Serious Adverse Events by demograpahics](./demographics-SAEs/saeDemographics.R): select data that fulfills certain criteria ( adverse events that were recorded as serious) and how to combine this with data from a different form (in this case, a few data points from the Demographics form).
- [Treatment-related Severe Adverse Events](./treatment-related-SAEs/treatmentRelatedSAEs.R): how to select data that fulfills certain criteria (adverse events that were recorded as (possibly) treatment-related and serious) and summarising the data by site.
- [Ongoing Adverse Events](./ongoing-AEs/ongoingAEs.R): how to select data that fulfills certain criteria (adverse events that were recorded as ongoing) and data sorting.

## Functionality examples
- [locked form with issues](./functionality-examples/locked_forms_with_issues.R)
- [Old queries](./functionality-examples/Old_Query_Aging_Standard_Report.R)
- [Plot and table](./functionality-examples/Plot_and_table.R)
- [Plot with dropdowns](./functionality-examples/Plot_with_dropdown.R)
- [Plot with filters](./functionality-examples/plotly_filter_buttons.R)


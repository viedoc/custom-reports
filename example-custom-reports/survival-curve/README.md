# Survival curve

## Purpose
Document the survival curve example report so you can understand its inputs, outputs, and visualization behavior before adapting it.

## Audience
Developers and analysts who plan to reuse or modify the survival analysis example in other studies.

## Prerequisites
- Local environment configured per the [development starter kit](../../development-starter-kit/README.md).
- Access to subject status and disposition data (`edcData$Forms$DM` and `edcData$Forms$DS`).
- The `survival` and `plotly` packages available through the repository `renv` setup.

## Instructions
1. Load the parent folder README to understand how this example fits within the broader catalogue.
2. Open `survivalCurvePlotKaplanMeier.R` to review the data preparation, survival model, and plot generation steps.
3. Execute the script locally to confirm the Kaplan-Meier output using the sample design template.
4. Adjust form IDs or grouping logic to match your target study before publishing to Viedoc.

## Outputs / Expected results
- `Survival Curve` sub-report: interactive Kaplan-Meier plot with 95% confidence intervals rendered via `plotly`.
- `Survival Table` sub-report: tabular summary of time-to-event calculations aligned with the plot.
- Reference screenshot (`/docs/assets/survival_curve2.png`) that illustrates the expected report appearance.

## Tips / Troubleshooting / FAQs
- Ensure censoring logic matches your study's disposition codes; update the mapping in the script if necessary.
- Verify that time-to-event units (days vs. weeks) align with study conventions before distributing the report.
- Use `generate_empty_output()` from `utility-function-scripts` if you repurpose the script for designs with optional forms.

## Additional resources
- [Example custom reports overview](../README.md)
- [Creating custom reports (Viedoc Learning)](https://help.viedoc.net/c/8a3600/6e9c82/en/)

## Notes
- Keep the screenshot path up to date if assets move; update this README when you add new visuals or parameters.

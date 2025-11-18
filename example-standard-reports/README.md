# Example standard reports for Viedoc Reports

## Purpose
Share reference implementations of the standard reports delivered with Viedoc so teams can review, adapt, or troubleshoot them locally.

## Audience
Developers and analysts who need to understand or extend the behavior of Viedoc standard reports.

## Prerequisites
- Access to `edcData`, `metadata`, and `params` objects that mirror the production study.
- Local environment prepared via the [development starter kit](../development-starter-kit/README.md).
- Working knowledge of the standard report catalogue.

## Instructions
1. Browse the scripts in this folder and select the report you want to replicate or customize.
2. Source the chosen file in your local environment and validate the output against sample data.
3. Modify parameters or logic as needed, keeping alignment with the naming conventions used by the standard report.
4. Upload the updated script as a custom report if you require study-specific adjustments.

### Included scripts
- `01_recruitment.R`
- `02_review_status.R`
- `03_missing_items.R`
- `04_pending_forms.R`
- `05_data_entry_cycle_time.R`
- `06_medical_coding.R`
- `07_disposition.R`
- `08_overdue_events.R`
- `09_form_status.R`
- `10_demographics_summary.R`
- `11_manual_validation_queries.R`
- `12_manual_queries.R`
- `13_validation_queries.R`
- `14_prequeries.R`

## Outputs / Expected results
- One-to-one script copies of the standard reports, ready for local execution.
- Consistent naming and structure that mirrors the in-product reports, enabling straightforward comparisons.

## Tips / Troubleshooting / FAQs
- Ensure the required forms exist in your study before deploying a script; standard reports expect standard form identifiers.
- Keep the original file names when uploading to maintain traceability.
- Use `utility-function-scripts/utilityFunctions.R` for helper functions that are common across reports.

## Additional resources
- [Repository overview](../README.md)
- [Custom report examples](../example-custom-reports/README.md)
- [Viedoc Reports User Guide](https://help.viedoc.net/c/8a3600)

## Notes
- Scripts do not include package installation commands or environment configuration; run them within the prepared development environment.
- Document customizations in a separate README if you adapt these scripts for a project-specific workflow.

# Study-independent functional reports
[return to root README](../README.md)

## Purpose
Provide ready-to-use monitoring scripts that work across studies without design-specific customization.

## Audience
Study designers, support engineers, and data managers who want to customise the reports already available..

## Prerequisites
- Published study with reports enabled and accessible `edcData` objects.
- Local setup described in the [development starter kit](../development-starter-kit/README.md) for testing prior to upload.

## Instructions
1. Review the script summaries below to choose the report that fits your monitoring need.
2. Load the selected `.R` file into your local environment and run it against sample data to confirm expected outputs.
3. Upload the script to Designer, publish it to the study.
4. Monitor outputs and adjust parameters (for example, filtering logic) where desired.

### Available reports
- `active-versions.r` - counts instantiated forms per design version to highlight inconsistent upgrades across subjects.
- `Old_Query_Aging_Standard_Report.R` - summarizes query lifecycles so teams can track bottlenecks and aged queries.
- `locked_forms_with_issues.R` - lists locked forms that still have outstanding issues such as queries or pending upgrades.

## Outputs / Expected results
- Tables and summaries that can be published directly to Viedoc Reports with no study-specific code changes.
- Consistent monitoring snapshots for support teams and study administrators.

## Tips / Troubleshooting / FAQs
- If a script references missing columns, verify the study design includes the corresponding forms and that data has been synchronized to Reports.
- Use the helper utilities in `utility-function-scripts/` when extending these reports with additional logic.

## Additional resources
- [Available data objects](../available-data-objects/README.md)
- [Custom report examples](../example-custom-reports/README.md)
- [Creating custom reports (Viedoc Learning)](https://help.viedoc.net/c/8a3600/6e9c82/en/)

## Notes
- All scripts assume the standard Viedoc runtime (`edcData`, `metadata`, `params`) and should not contain package installation commands.


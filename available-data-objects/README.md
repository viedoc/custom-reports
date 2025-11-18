# Available data objects for custom reports
[Repository overview](../README.md)

## Purpose
Document the runtime data structures (`edcData`, `metadata`, and `params`) that Viedoc Reports makes available to custom report scripts.

## Audience
Developers and analysts who need to understand the fields exposed in the Viedoc Reports execution environment.

## Prerequisites
- Access to the Viedoc sample data package or exports generated from a study.
- Ability to load `.rds` files into R for inspection (`readRDS()` is included in base R).
- Familiarity with the standard report execution lifecycle described in the [root README](../README.md).

## Instructions
1. Start with `edcData.md` for subject-level clinical data, including record layouts for forms, queries, and visits.
2. Review `metadata.md` to understand study definitions (forms, events, and codelists) and how they map to `edcData`.
3. Use `params.md` to see which runtime parameters are passed to scripts (for example, `dateOfDownload`).
4. Open the corresponding objects from your downloaded sample data (`.rds`) in R to validate field availability in your study design.

## Outputs / Expected results
- Clear understanding of table structures, keys, and example records for each object.
- Consistent mapping between metadata definitions and the data returned to custom report scripts.

## Tips / Troubleshooting / FAQs
- When fields appear missing, confirm the study design version and publish status before investigating data integrity.
- Use the `utility-function-scripts` helpers to simplify joins between `edcData` and `metadata`.

## Additional resources
- <a href="https://help.viedoc.net/c/8a3600/6e9c82/en/" target="_blank" rel="noopener">Creating custom reports</a>
- <a href="https://help.viedoc.net/c/8a3600/9fc73b/en/" target="_blank" rel="noopener">Custom reports examples</a>

## Notes
- The `.md` files in this folder describe data structures; the actual `.rds` files are included in the Viedoc sample data download.

# Custom reports for Viedoc Reports

## Purpose
Provide a single reference point for building, testing, and maintaining Viedoc custom reports, including sample code, reusable utilities, and data descriptions.

## Audience
Viedoc solution designers, developers, and analysts who create or support custom reports for study teams.

## Prerequisites
- Access to a Viedoc study with permission to upload custom reports.
- Local R 4.x environment with the ability to install packages.
- Familiarity with the Viedoc Reports runtime (`edcData`, `metadata`, `params`) and the publishing workflow.

## Instructions / Tips
1. Review `instructions_&_troubleshooting.md` for end-to-end guidance on authoring custom reports and debugging guidance.
2. Use `development-starter-kit/` to provision a local workspace that mirrors the Viedoc Reports runtime and streamline the development process.
3. Consult `available-data-objects/` for field-level descriptions of the data surfaces available to report scripts.
4. Reuse and adapt assets from:
   - `example-standard-reports/` for baseline scripts that match in-product reports.
   - `example-custom-reports/` for advanced patterns, plots, and data joins.
   - `example-system-reports/` for study-independent monitoring utilities.
   - `utility-function-scripts/` for helper functions that streamline data manipulation and validation.

## Outputs / Expected results
- Consistent report scripts and documentation that align with Viedoc production environments.
- Repeatable local setup that accelerates development and QA.
- Centralized access to reusable code, helper functions, and data definitions.
- A public forum for community feedback and engagement.

## Additional resources
- [Viedoc Reports User Guide](https://help.viedoc.net/c/8a3600)
- [Custom reports examples (Viedoc Learning)](https://help.viedoc.net/c/8a3600/9fc73b/en/)

  
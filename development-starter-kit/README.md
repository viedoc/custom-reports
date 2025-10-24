# Development starter kit
[Repository overview](../README.md)
  
## Purpose
Supply an opinionated R setup that mirrors the Viedoc Reports runtime so contributors can validate custom reports locally before uploading them while avoiding including "forbbiden" functions in their custom report.

## Audience
Report developers who need to prototype, debug, or extend custom report scripts on their workstation.

## Prerequisites
- R 4.x installed locally with permission to install packages.
- RStudio or another IDE capable of running R projects.
- Access to Viedoc sample data exports or study-specific `.rds`/`.xlsx` files.
- Installation of `renv` R package

## Instructions
1. Clone the repository or download the zipped `development-starter-kit/` folder.
2. Populate `source/` with the sample data produced by Viedoc (replacing the provided demo files).
3. Open the folder in RStudio and run `renv::restore()` (automatically triggered through `.Rprofile`) to align package versions with the Viedoc runtime (`renv.lock` targets R 4.5.1).
4. Execute `env_setup.R` to load the sample data, utility functions, and configuration variables into your session. Set `local_project_path` to the root folder when prompted.
5. Use `SampleReportCode.R` or your own scripts as a template, sourcing any helpers from `utility-function-scripts/` as needed.

## Outputs / Expected results
- Reproducible local environment that aligns with the server package set.
- Preloaded `edcData`, `metadata`, `params`, and utility functions for rapid iteration.
- Working example script that demonstrates report rendering end to end.

## Tips / Troubleshooting / FAQs
- If packages fail to install, verify the local R version and reinstall `renv` (`install.packages("renv")`) before running `renv::restore()`.
- Install or update `Rtools`
- Keep study-specific exports outside of version control; add them to `source/` but exclude them from commits.
- Update `env_setup.R` cautiously; shared helpers rely on the structure documented in `utility-function-scripts/README.md`.

## Additional resources
- [Viedoc Reports User Guide](https://help.viedoc.net/c/8a3600)
- [Custom report examples](https://help.viedoc.net/c/8a3600/9fc73b/en/)

## Notes
- The Viedoc Reports production environment currently runs on R 4.0.4; slight version differences from the local lockfile may exist but are mitigated through `renv`. The lockfile was generated in a Windows x64 environment. There may be issues on alternative systems.

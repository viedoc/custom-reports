# Custom Reports for Viedoc Reports

> [!IMPORTANT]
> There have been recent changes to the packages/functions for supported within scripts for custom reports. Please review the list, including changes [here](./docs/dev-guide.md#environment)

## Contents:
- [Purpose and scope](#purpose-and-scope)
- [What are Viedoc Reports and Viedoc Custom Reports](#what-are-viedoc-reports-and-viedoc-custom-reports)
- [Overview of the repository contents](#overview-of-the-repository)
- [Changelog](#changelog)
- [Roadmap](#roadmap)

## Purpose and scope
This repository aims to provide a development guide and additional support for creating custom reports for use in Viedoc Reports. This includes example report scripts, some troubleshooting guides, and tools for assisting with report development.
Details about Viedoc Reports and non-development aspects of custom reports can be found in the [Viedoc Designer User Guide](https://help.viedoc.net/c/e311e6/).

## Overview of the repository
- [Development Guide](./docs/dev_guide.md): This README contains information and resources on how to develop a custom report, including:
    - Prerequisits & setup
    - Details about input data available
    - Available packages and functions in Viedoc reports
    - Output format
    - Trouble shooting & common errors
- examples & use cases:
  - [Example reports](./example-reports/README.md): source code for the reports showcased in the [eLearning Reports User Guide](https://help.viedoc.net/c/8a3600/9fc73b/en/). These have been developed for the [Phase II study design template](./example-reports/StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml). A range of visualisations are implemented across these reports.
  - [Functional reports](./functional-reports/README.md): reports which  can be added to any study without modification for additional monitoring functionality
  - [Graphing demos](./graphing-demos/README.md): basic examples of how to achieve certain layouts to be used as a guide when developing custom reports 
- [utils](./utils/README.md): this folder contains additional tools that help in the report development and debugging process.

## Changelog
2025-02: initial transfer of documentation and code from eLearning platform to GitHub, decisions regarding repo structure, minor updates to contents.
2025-04-04: Updated list specifiying supported packages

## Roadmap
- add information about report testing
- update/refine documentation regarding utility functions
- add troubleshooting guide



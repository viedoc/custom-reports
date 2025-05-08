# Custom Reports for Viedoc Reports

## Purpose and scope
The goal of this repository is to offer further assistance and a development guide for making custom reports that can be used with Viedoc Reports.  This contains tools to help with report development, some troubleshooting advice, and sample report scripts.
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
2025-05-08: Changes made to the fellowing reports: Ongoing AE report: Addition of Null checks. Blood Pressure plot: Addition of correct visit sorting.
2025-04-28: Content formalisation, restructuring and updates to common issues in Dev Guide.  
2025-04-04: Updated list specifiying supported packages  
2025-02: initial transfer of documentation and code from eLearning platform to GitHub, decisions regarding repo structure, minor updates to contents.  

## Roadmap
- add information about report testing
- update/refine documentation regarding utility functions

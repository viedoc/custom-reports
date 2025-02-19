# Custom Reports for Viedoc Reports

## What are Viedoc Reports and Viedoc Custom Reports
Viedoc Reports is an integrated Viedoc application for viewing and analysing study progress and performance, allowing data to be browsed and visualised in reports and graphs.

![Reports](./docs/assets/reports.png)
A number of dashboards and overviews can be configured in designer, and  a number of additional information regarding typical use-cases are covered in the 'Reports' section. 

![ReportsReports](./docs/assets/reports2.png)

However, if a bespoke visualisation is desired, custom reports can be developed.These reports are configured as a single R script, which is run on-demand to ensure up-to-date visualisations.

## Purpose and scope
This repository aims to provide a how-to guide for creating custom reports for use in Viedoc Reports, as well as version-controlled public storage of example report scripts.

## Overview of the repository
- documentation:
  - [quick-start guide](./docs/quick-start.md): 
    - downloading demo data
    - setting up the local environment 
    - publishing reports
  - [Developing a custom report](./docs/dev-guide.md)
    - Details about input data available
    - Defining the output object
  - [Additional information](./docs/quick-start.md)
    - actions to avoid
    - Trouble shooting & common errors
- examples & use cases
  - [Example reports](./example-reports/README.md): reports which have been developed for the [Phase II study design template](./example-reports/StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml) included in this directory. Includes instructions
  - [Functional reports](./functional-reports/README.md): reports which  can be added to any study without modification for additional monitoring functionality
  - [Graphing demos](./graphing-demos/README.md): basic examples of how to achieve certain layouts to be used as a guide when developing custom reports 

## Changelog
2025-02: initial transfer of documentation and code from eLearning platform to GitHub, decisions regarding repo structure, minor updates to contents.

## Roadmap
- add information about report testing
- update/refine documentation regarding utility functions
- add troubleshooting guide
- add functional report regarding

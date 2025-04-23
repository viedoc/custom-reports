# Custom Reports for Viedoc Reports

> [!IMPORTANT]
> There have been recent changes to the packages/functions for supported within scripts for custom reports. Please review the list, including changes [here](./docs/dev_guide.md#blocked-functions)

## Contents:
- [Purpose and scope](#purpose-and-scope)
- [What are Viedoc Reports and Viedoc Custom Reports](#what-are-viedoc-reports-and-viedoc-custom-reports)
- [Overview of the repository contents](#overview-of-the-repository)
- [Changelog](#changelog)
- [Roadmap](#roadmap)

## Purpose and scope
The goal of this repository is to offer further assistance and a development guide for making custom reports that can be used with Viedoc Reports.  This contains tools to help with report development, some troubleshooting advice, and sample report scripts.
Details about Viedoc Reports and non-development aspects of custom reports can be found in the [Viedoc Designer User Guide](https://help.viedoc.net/c/e311e6/).

## Overview of the repository
- Documentation: This folder contains information and resources previously contained on the [eLearning Designer User Guide](https://help.viedoc.net/c/e311e6/) article entitled "Creating custom reports". The main information present on this reposiroty is described below.
    - Setting up the local environment 
    - Details about input data available
    - Defining the output object
    - Environment (supported packages, blocked functions, and added functions)
    - Actions to avoid
    - Trouble shooting & common errors
- Examples & use cases:
  - [Example reports](./example-reports/README.md): reports which have been developed for the [Phase II study design template](./example-reports/StudyDesign_VIEDOC-PHASE-II-TEMPLATE_2.0.xml) included in this directory. Formerly contained on the  [eLearning Designer User Guide](https://help.viedoc.net/c/e311e6/) article entitled "Custom reports examples".
  - [Functional reports](./functional-reports/README.md): reports which  can be added to any study without modification for additional monitoring functionality
  - [Graphing demos](./graphing-demos/README.md): basic examples of how to achieve certain layouts to be used as a guide when developing custom reports 
- Utils: this folder contains additional tools that help in the report development and debugging process. Note that documentation for these functions is included in the [Dev guide](./docs/dev-guide.md)


## Changelog
2025-04-23: Link updates and general rewriting of content
2025-04-04: Updated list specifiying supported packages
2025-02: initial transfer of documentation and code from eLearning platform to GitHub, decisions regarding repo structure, minor updates to contents.


## Roadmap
- add information about report testing
- update/refine documentation regarding utility functions
- add troubleshooting guide



# Title

1. Download this starter kit as a zip file, or clone this repository locally
2. Drop files: extract the files from SampleForCustomReports.zip into  source/exports. If you need your full dataset to test specific cases, add a clinic .xlsx and/or .csv export (include all additional data _except_ uplaoded files)
3. Setup: open RStudio → open folder → run install_or_restore.R.
4. Render: run render_report.R.
5. Change inputs: edit .Renviron or config.yml (no code editing required).

Notes on versions: Local uses latest R 4.x; the lockfile records R 4.5.1, which may differ from the Shiny server’s 4.0.x.

# custom-customer-solutions

Currently limited to R scripts and/or API scripts. other artifacts such as xmls remain in sharepoint.

[Repo shortcut](https://dev.azure.com/pcgsolutions/_git/Custom%20customer%20solutions?path=%2Frenv.lock&version=GBmain&_a=contents)

structure should be
- client_name
  - work-order_id
    - specific project/task/report

When working on custom reports: 
- install.packages("renv")
  - this will not completely mimic server setup because that's on R 4.0.x but it's better practcie than writing install in R.
  - additional packages added for dev env convenience: 
    - readxl (to read data from excel rather than RDS)
    - jsonlite (for VS code plugin. is a requirement for other packages though.)
- add sample data (rds/xlsx/csv) in the subfolder
- add path to project folder as `local_project_path=""` in [./env_setup.R], include any additional data import files and run the script to load data, libraries and utils to R environment.


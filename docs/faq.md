# FAQ and additional information
[return to root README](../README.md)
## Actions to avoid
Please exercise caution to avoid below scenarios in your code:

- Infinite loops
- Data manipulation that might yield huge incorrect data ending up taking unnecessary disk space
- Any tampering with the host system properties and performance
- Below list of functions are blocked:
  - `system`
  - `system2`
  - `dir.create`
  - `library`
  - `require`
  - `Sys.sleep`
  - `unlink`
  - `file.remove`
  - `file.rename`
  - `tempdir`
  - `detach`
  - `file.copy`
  - `file.create`
  - `file.append`
  - `setwd`

## Troubleshooting & common errors
- confirm that your functions exist and behave the same way as the version available in the runtime environment
- ensure you have data populated for the tables you are using as inputs.
- ensure your Reports data is up-to-date with the EDC data (data will not automatically sync in training studies.)
- when merging, confirm column data types are as expected.


- 'no applicable method for [...] applied to an object of class "NULL"'. 
  - Possible cause: The input form requested contains no data or does not exist.
  - Debug step 1: upload an R script containing just the data sources that you use

## Data availability

As per current data modelling best-practices, Viedoc separates "transactional" (EDC) and analytical ("Reports") data. 
To maintain visibility rules, data transfers are conducted per role, as defined in the Reports setup in Designer. Therefore, any reports generated from this data will be based only on data the role has permission to see. 
Reports are generated on demand (i.e. when a user accesses teh site), so visualisations are always reflective of the data 'analytical' currently available.'

The transactional and analytical databases of production studies sync daily. In order to sync a training study, Reports must be manually turned off for the study (in Admin), and then after about an hour, turned on again.


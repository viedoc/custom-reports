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
- ensure you have data populated for the tables you are using as inputs (and ensure tht your Reports data is up to date)
- when merging, confirm column data types are as expected.


- 'no applicable method for [...] applied to an object of class "NULL"'. 
  - Possible cause: The input form requested contains no data or does not exist.
  - Debug step 1: upload an R script containing just the data sources that you use


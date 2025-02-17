# Medication inconsistency

This report compares AEs with concomitant medication (CMs) to check for inconsistencies in data entry. This is something that previously was an offline check that required a manual comparison of the data. This custom report provides a list of the problematic data immediately.

This custom report generates the following output:

- Sub-report 'CMs linked to AEs where no meds were prescribed': A table showing the concomitant medication (CMs) entries that are linked to the adverse events entries in which it was reported that no treatments or medications were prescribed.

- Sub-report 'AEs where meds were prescribed not linked to CMs': A table showing adverse events entries for which it was reported that treatments or medications were prescribed, but for which no concomitant medications entry exists.

![rx_inconsistancy_output_table](/docs/assets/medication_inconsistency2.png?raw=true)

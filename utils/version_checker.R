packagesInstalled <- installed.packages()

packageVersions <- data.frame(
  Package = packagesInstalled[,"Package"],
  Version = packagesInstalled[,"Version"],
  stringsAsFactors = FALSE
  )

reportOutput <- list("Packages" = list("data" = packageVersions))

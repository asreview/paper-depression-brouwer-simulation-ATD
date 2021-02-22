# required packages
packages <- c(
  "tidyverse",
  "devtools",
  "glue",
  "knitr",
  "readr"
)
# install if they're missing
install.packages(setdiff(packages, rownames(installed.packages())))

# install latest version of asreview R-package
# if this fails, debug with the readme of this package: https://github.com/asreview/asreview-report/blob/main/README.md
devtools::install_github(
  "asreview/asreview-report", 
  ref = 'main',
  build = TRUE)

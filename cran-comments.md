## Test environments

* Local Ubuntu install, R 3.6.1
* win-builder (devel)

## R CMD check results

0 ERRORs | 0 WARNINGs | 1 NOTE

* checking R code for possible problems ... NOTE Undefined global functions or variables: prob statistic

That variables are column names of a dataframe. The note arises because of dplyr notation.



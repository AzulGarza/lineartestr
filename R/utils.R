
# Objective ---------------------------------------------------------------

# Utils functions


# Packs -------------------------------------------------------------------

require(dplyr)


# Functions ---------------------------------------------------------------

independent_data <- function(model){
  # Get the data of the independent variables of
  # a `model`
  indep_vars <- attr(model$terms, "term.labels")

  data <- select_(model$model, .dots = indep_vars)

  return(data)
}

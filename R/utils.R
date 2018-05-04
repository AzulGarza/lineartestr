
# Objective ---------------------------------------------------------------

# Utils functions


# Packs -------------------------------------------------------------------

require(dplyr)


# Functions ---------------------------------------------------------------

data_independet <- function(model){
  # Get the data of the independent variables of
  # a `model`
  dep_var <- all.vars(model$call)[1]

  data <- select_(model$model, paste("-", dep_var))

  return(data)
}

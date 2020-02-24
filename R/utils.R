
# Objective ---------------------------------------------------------------

# Utils functions
# Functions ---------------------------------------------------------------

independent_data <- function(model){
  # Get the data of the independent variables of
  # a `model`
  indep_vars <- attr(model$terms, "term.labels")

  data <- dplyr::select_(model$model, .dots = indep_vars)

  return(data)
}

# Constructed model
constructed_model <- function(fitted_dep_var, residuals, data_indep, distribution = "rnorm"){
  # Input:
  # - fitted_dep_var: The fitted values of the dependet variable
  # - residuals: The residuals of the model
  # - data_indep: The data of the independent variables
  # Output:
  # -A constructed model with the dependent variable modified:
  #     y_new  = y_fitted + residuals*noise
  # where y_fitted corresponds to fitted_dep_var
  n_fitted <- length(fitted_dep_var)
  n_resids <- length(residuals)
  n_data <- nrow(data_indep)

  if(n_fitted != n_resids | n_resids != n_data){

    stop("Inpust must have the same length")

  }
  # Adding noise to residuals
  n <- length(residuals)
  dist_f <- get(distribution)
  rvariable <- dist_f(n)

  #New dependent variable
  y_constructed <- fitted_dep_var + residuals*rvariable

  new_model <- lm(y_constructed ~ ., data = dplyr::mutate(data_indep, y_constructed = y_constructed))

  return(new_model)
}


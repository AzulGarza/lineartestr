
# Objective ---------------------------------------------------------------
# Functions for boostrap


# Packs -------------------------------------------------------------------
require(dplyr)
require(purrr)

# Constructed residuals with a particular distribution
# residuals*random variable
constructed_residuals <- function(residuals, distribution = "rnorm"){
  n <- length(residuals)

  dist_f <- get(distribution)

  rvariable <- dist_f(n)

  return(residuals*rvariable)
}

# Constructed dependent variable
constructed_dep_var <- function(fitted_dep_var, residuals, distribution = "rnorm"){
  # Returns fitted dependent variable plus
  # constructed residuals
  n_fitted <- length(fitted_dep_var)
  n_resids <- length(residuals)

  if(n_fitted != n_resids){

    stop("Fitted dependent variable and residuals must have the same length")

  } else {

    return(fitted_dep_var + constructed_residuals(residuals, distribution))

  }

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

  } else {

    y_constructed <- constructed_dep_var(fitted_dep_var, residuals, distribution)


    return(lm(y_constructed ~ ., data = mutate(data_indep, y_constructed = y_constructed)))

  }


}

# Sample distribution  of residuals
presiduals <- function(fitted_values, residuals, new_dep_value){
  # Input:
  # - fitted_values: Fitted values from a model
  # - residuals: residuals from a model
  # - new_dep_value: New vale of dependent value
  # Output:
  # Acumulated distribution of residuals at new_dep_value
  n_fitted <- length(fitted_values)
  n_resids <- length(residuals)
  n_obs <- length(new_dep_value)

  if(n_fitted != n_resids){

    stop("Fitted values and residuals must have the same length")

  } else if(n_obs != 1) {

    stop("New_dep_value muste have length one")

  } else {

    indicator <- as.numeric(fitted_values < new_dep_value)

    return((1/sqrt(n_obs))*sum(residuals*indicator))

  }
}

# We vectorize the previous function
presiduals_vec <- Vectorize(presiduals, vectorize.args = "new_dep_value")

# Bootstrap

wild_bootstrap <- function(model, times = 300, distribution = "rnorm", statistic = "cvm_value"){
  # Input
  # - model: A lm model
  # - times: Times of boostrap
  # - distribution: Distribution to noise the residuals
  # - statistic: Statistic to use in bootstap

  if(class(model) != "lm"){

    stop("Model must be a lm model")

  } else {
    statistic_fun <- get(statistic)

    # Statistic with residuals without function
    statistic_n <- statistic_fun(model)

    data <- independent_data(model)
    fitted_values <- model$fitted.values
    resids <- model$residuals


    # Times statistics with constructed residuals
    statistic_star <- rep(NA, times)

    for(time in 1:times){
      # New model
      new_model <- constructed_model(fitted_values, resids, data, distribution)
      statistic_star[time] <- statistic_fun(new_model)
      print(paste("Iteration: ", time))
    }

    return(list(statistic = statistic_n, bootstrap = sort(statistic_star)))

  }


}

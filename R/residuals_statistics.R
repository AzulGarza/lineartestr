# Sample distribution  of residuals
presiduals_x <- function(fitted_values, residuals, new_dep_value){
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

    indicator <- as.numeric(fitted_values <= new_dep_value)

    return((1/sqrt(n_fitted))*sum(residuals*indicator))

  }
}

# We vectorize the previous function
presiduals_vec <- Vectorize(presiduals_x, vectorize.args = "new_dep_value")


presiduals <- function(fitted_values, resids){
  # Input:
  # - fitted_values: Fitted values from a model
  # - residuals: residuals from a model
  # Output:
  # Acumulated distribution of residuals at each residual point
  ordered_res <- resids[order(fitted_values)]
  n_obs <- length(resids)
  dist_values <- cumsum(ordered_res)/sqrt(n_obs)

  return(dist_values)
}

# Cramer von Mises value
cvm_value <- function(model){
  # Calculates the Cramer von Mises value
  # given an lm model with its residuals
  # Input:
  # - model: A lm model
  # Output:
  # The Cramer von Mises value
  if(class(model) != "lm"){
    stop("Model must be a lm model")
  }

  fitted_values <- model$fitted.values
  resids <- model$residuals
  n_obs <- length(fitted_values)
  presids <- presiduals(fitted_values, resids)

  return(sum(presids^2)/n_obs)
}

# Kolmogorov value
kmv_value <- function(model){
  # Calculates the Kolmogorov value
  # given a lm model with its residuals
  # Input:
  # - model: A lm model
  # Output:
  # The Kolmogorov value
  if(class(model) != "lm"){
    stop("Model must be a lm model")
  }

  fitted_values <- model$fitted.values
  resids <- model$residuals
  n_obs <- length(fitted_values)
  presids <- presiduals(fitted_values, resids)

  return(max(abs(presids)))
}


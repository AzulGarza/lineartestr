
# Objective ---------------------------------------------------------------

# Functions of the statistics
require(dplyr)
require(purrr)

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
  n_obs <- length(fitted_values)
  presids <- presiduals_vec(fitted_values, model$residuals, fitted_values)
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
  } else {
    fitted_values <- model$fitted.values
    n_obs <- length(fitted_values)
    presids <- presiduals_vec(fitted_values, model$residuals, fitted_values)
    return(max(abs(presids)))
  }
}


# reset test for linear model
reset_test <- function(model, robust = F){
  # Calculates the reset rest
  # of a linear model
  if(class(model) != "lm"){
    stop("Model must be a lm model")
  }
  fitted_values <- model$fitted.values
  y_squared <- fitted_values^2
  y_cubic <- fitted_values^3
  n_obs_pre <- length(model$coefficients)
  model_m <- model$model
  new_model <- update(
    model, . ~ . + y_squared + y_cubic,
    data = data.frame(model_m, y_squared, y_cubic)
  )
  restrictions <- cbind(
    matrix(rep(0, 2*n_obs_pre - 2), nrow = 2),
    matrix(c(1,0,0,1), nrow = 2)
  )
  value <- matrix(c(0,0))
  wald <- wald_test(new_model, restrictions, value, robust)
  return(wald)
}

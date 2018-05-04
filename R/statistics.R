
# Objective ---------------------------------------------------------------

# Functions of the statistics
require(dplyr, purrr)

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

  } else {

    fitted_values <- model$fitted.values
    n_obs <- length(fitted_values)

    presids <- presiduals_vec(fitted_values, model$residuals, fitted_values)

    return(sum(presids^2)/n_obs)
  }

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


presiduals <- function(fitted_values, resids){
  # Input:
  # - fitted_values: Fitted values from a model
  # - residuals: residuals from a model
  # Output:
  # Acumulated distribution of residuals at each residual point
  ordered_res <- resids[order(fitted_values)]
  dist_values <- cumsum(ordered_res)

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
  #if(class(model) != "lm"){
  #  stop("Model must be a lm model")
  #}

  fitted_values <- model$fitted.values
  resids <- model$residuals
  n_obs <- length(fitted_values)
  presids <- presiduals(fitted_values, resids)

  return(sum(presids**2)/(n_obs**2))
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


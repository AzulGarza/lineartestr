
# Residuals statistics ----------------------------------------------------

#' Calculates the accumulated distribution of
#' residuals at each residual point.
#'
#' @param fitted_values Vector of fitted values.
#' @param resids Residuals vector of each fitted value.
#' @return Vector of size length(resids).
#' @examples
#' y_hat <- c(4, 8, 7)
#' resids <- c(1, 5, 3)
#' presiduals(y_hat, resids)
presiduals <- function(fitted_values, resids){

  if(length(fitted_values) != length(resids)){
    stop("Lenght of fitted values must be equal to lenght of resids")
  }
  ordered_res <- resids[order(fitted_values)]
  dist_values <- cumsum(ordered_res)

  return(dist_values)
}

#' Calculates the Cramer von Mises value
#' given an lm model with its residuals.
#'
#' @param model An lm model.
#' @return The Cramer von Mises value of the model.
#' @examples
#' x <- 1:10
#' y <- 2*x + rnorm(10)
#' model <- lm(y~x-1)
#' cvm_value(model)
cvm_value <- function(model){

  if(!inherits(model, "lm")){
    stop("Model must be an lm model")
  }

  fitted_values <- model$fitted.values
  resids <- model$residuals
  n_obs <- length(fitted_values)
  presids <- presiduals(fitted_values, resids)

  return(sum(presids**2)/(n_obs**2))
}

#' Calculates the Kolmogorov value
#' given an lm model with its residuals.
#'
#' @param model An lm model.
#' @return The Kolmogorov value of the model.
#' @examples
#' x <- 1:10
#' y <- 2*x + rnorm(10)
#' model <- lm(y~x-1)
#' kmv_value(model)
kmv_value <- function(model){

  if(!inherits(model, "lm")){
    stop("Model must be an lm model")
  }

  fitted_values <- model$fitted.values
  resids <- model$residuals
  n_obs <- length(fitted_values)
  presids <- presiduals(fitted_values, resids)

  return(max(abs(presids)))
}



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

#' Calculates the Cramer von Mises value or
#' Kolmogorov value
#' given a linear model compatible with
#' `fitted.values` and `residuals` functions.
#'
#' @param model An existing fit from a linear model function.
#' @param value Type of value to compute, can be `cvm_value` or `kmv_value`.
#' @return The statistic value of the model.
#' @examples
#' x <- 1:10
#' y <- 2*x + rnorm(10)
#' model <- lm(y~x-1)
#' statistic_value(model)
#' statistic_value(model, value = "cvm_value")
#' statistic_value(model, value = "kmv_value")
statistic_value <- function(model, value = "cvm_value"){

  fitted_values <- fitted.values(model)
  resids <- residuals(model)
  n_obs <- length(fitted_values)
  presids <- presiduals(fitted_values, resids)

  if(value == "cvm_value"){

    return(sum(presids**2)/(n_obs**2))

  } else if (value == "kmv_value"){

    return(max(abs(presids)))

  }
}


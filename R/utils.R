
# utils  ------------------------------------------------------------------

#' Gets the independent data of a lm model
#'
#' @param model An lm model
#' @return A dataframe with the independet data of the lm model
#' @examples
#' x <- 1:10
#' z <- x**2
#' y <- 1:10
#' model <- lm(y~x+z)
#' independent_data(model)
independent_data <- function(model){

  indep_vars <- attr(model$terms, "term.labels")

  data <- dplyr::select_(model$model, .dots = indep_vars)

  return(data)
}

#' Constructsa new model with noised residuals
#' y_new  = y_fitted + residuals*noise
#'
#' @param fitted_dep_var fitted values of an lm model
#' @param residuals residuals of a model
#' @param data_indep independent data used to adjust an lm model
#' @param distribution Type of noise added to residuals, ej "rnorm" or "rrademacher"
#' @return Constructed lm model
#' @examples
#' y_hat <- 1:10
#' residuals <- rnorm(10)
#' data_indep <- data.frame(x=10:19)
#' constructed_model(y_hat, residuals, data_indep)
constructed_model <- function(fitted_dep_var, residuals, data_indep, distribution = "rnorm"){

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


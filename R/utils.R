
# utils  ------------------------------------------------------------------


#' Constructs a new model with noised residuals:
#' y_new  = y_fitted + residuals*noise
#'
#' @param model An existing fit from a model function such as `lm`, `lfe`, `Arima` and others
#' compatible with `update`.
#' @param fitting_data Data used to adjust a linear model.
#' @param distribution Type of noise added to residuals, ej "rnorm" or "rrademacher".
#' @return Constructed linear model.
#' @examples
#' x <- 1:100
#' y <- 2*x + rnorm(100)
#' model <- lm(y~x-1)
#' fitting_data <- model.frame(model)
#' updated_model(model, fitting_data)
#' updated_model(model, fitting_data, distribution = "rnorm")
#' updated_model(model, fitting_data, distribution = "rmammen_point")
#' updated_model(model, fitting_data, distribution = "rmammen_cont")
#' updated_model(model, fitting_data, distribution = "rrademacher")
#'
#' x_arma <- rnorm(100)
#' arma_model <- forecast::Arima(x_arma, c(1, 0, 1))
#' fitting_data_arma <- model.frame(arma_model)
#' updated_model(arma_model, fitting_data_arma)
updated_model <- function(model, fitting_data, distribution = "rnorm"){
  # Getting fitted values and residuals
  fitted_values <- as.vector(fitted.values(model))
  residuals <- as.vector(residuals(model))

  # Adding noise to residuals
  n <- length(residuals)
  dist_f <- get(distribution)
  rvariable <- dist_f(n)

  #New dependent variable
  y_constructed <- fitted_values + rvariable*residuals

  if(inherits(model, "forecast_ARIMA")){
    new_model <- forecast::Arima(y_constructed, model = model)
  } else {
    new_data <- data.frame(fitting_data, y_constructed)
    new_model <- update(model, formula = y_constructed ~ ., data = new_data)
  }
  return(new_model)
}



# Specification tests ------------------------------------------------------

#' Custom Wald test
#' Tests if restrictions*beta = value, where beta are lm coefficients
#'
#' @param model An lm model
#' @param restrictions Matrix of size len(coefficients)xnumber of restrictions,
#' for free restrictions use zeros
#' @param value Values of restrictions
#' @param robust Use robust varcov matrix
#' @return A list with the wald value and the corresponding pvalue
#' @examples
#' x <- 1:10
#' z <- x**2
#' y <- 1:10
#' model <- lm(y~x+z)
#' restrictions <- diag(3)
#' value <-  as.matrix(c(0, 0, 0))
#' wald_test(model, restrictions, value)
wald_test <- function(model, restrictions, value, robust = F){

  if(class(model) != "lm"){
    stop("Model must be an lm model")
  }
  if(class(restrictions) != "matrix" | class(value) != "matrix"){
    stop("Restriction and value must be a matrix class")
  }
  coefs <- model$coefficients
  n_coefs <- length(coefs)
  n_rest <- nrow(restrictions)

  if(sum(is.na(coefs))>0){
    stop("Some coefficients are NA")
  }

  if(ncol(restrictions) != n_coefs){
    stop("Number of columns of restrictions must be equal to number of coefficients,
         for free restrictions use zeros")
  }
  if(nrow(value) != n_rest){
    stop("Number of rows of values must be equal to number of restrictions,
         for free restrictions use zeros")
  }
  if(Matrix::rankMatrix(restrictions) != n_rest){
    stop("Restrictions matrix must have a full rank")
  }

  wald_test <- list(wald_value = NULL, p_value = NULL)
  theta <- restrictions%*%coefs - value
  if(!robust){
    asy_var_theta <- solve(restrictions%*%vcov(model)%*%t(restrictions))
  } else {
    asy_var_theta <- solve(restrictions%*%sandwich::vcovHC(model, type = "HC1")%*%t(restrictions))
  }
  wald_test$wald_value <- as.numeric(t(theta)%*%asy_var_theta%*%theta)
  wald_test$p_value <- 1-pchisq(wald_test$wald_value, df = n_rest)
  return(wald_test)
}

#' Reset test
#' Tests the specification of a linear model adding squared and cubic
#' fitted values
#'
#' @param model An lm model
#' @param robust Use robust varcov matrix
#' @return A list with the wald value and the corresponding pvalue
#' @examples
#' x <- 1:10
#' y <- 1:10
#' model <- lm(y~x)
#' reset_test(model)
reset_test <- function(model, robust = F){

  if(class(model) != "lm"){
    stop("Model must be an lm model")
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
    matrix(rep(0, 2*n_obs_pre), nrow = 2),
    matrix(c(1,0,0,1), nrow = 2)
  )
  value <- matrix(c(0,0))
  wald <- wald_test(new_model, restrictions, value, robust)
  return(wald)
}

#' Tests the specification of a linear model using wild bootrap
#'
#' @param model An lm model
#' @param times Number of bootstrap samples
#' @param distribution Type of noise added to residuals, ej "rnorm" or "rrademacher"
#' @param statistic Type of statistic to be used, can be one of "cmv_value" or "kmv_value"
#' @param verbose TRUE for print each bootstrap iteration
#' @param quantiles vector of quantiles to calculate pvalues
#' @return A list with a data.frame results and the orderend values of each boostrap iteration
#' @references Manuel A. Domínguez and Ignacio N. Lobato (2019)
#' *Specification testing with estimated variables.* Econometrics Reviews.
#' @examples
#' x <- 1:10
#' y <- 1:10
#' model <- lm(y~x-1)
#' dominguez_lobato_test(model)
dominguez_lobato_test <- function(model, times = 300, distribution = "rnorm", statistic = "cvm_value", verbose = FALSE, quantiles=c(.9, .95, .99)){

  if(class(model) != "lm"){
   stop("Model must be an lm model")
  }

  statistic_fun <- get(statistic)

  # Statistic with residuals without function
  statistic_value <- statistic_fun(model)

  data <- independent_data(model)
  fitted_values <- model$fitted.values
  resids <- model$residuals


  # Times statistics with constructed residuals
  statistic_star <- rep(NA, times)

  for(time in 1:times){
    # New model
    new_model <- constructed_model(fitted_values, resids, data, distribution)
    statistic_star[time] <- statistic_fun(new_model)
    if (verbose) print(paste("Iteration: ", time))
  }

  test <- list(
    name_distribution = distribution,
    name_statistic = statistic,
    statistic = statistic_value,
    p_value = sum(statistic_star>=statistic_value)/times
  )

  # Calculating critical values
  calculated_quantiles <- quantile(statistic_star, quantiles)

  for(idx in seq_along(quantiles)){
    test[[paste0("quantile_", 100*quantiles[idx])]] <- calculated_quantiles[idx]
  }

  test <- dplyr::as_tibble(test)

  r_list <- list(test = test, bootstrap = sort(statistic_star))
  class(r_list) <- "dl_test"

  return(r_list)
}

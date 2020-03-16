
# Specification tests ------------------------------------------------------

#' Custom Wald test.
#' Tests restrictions*coefficients = value.
#'
#' @param model An lm model.
#' @param restrictions Matrix of size (number of restrictions) times length(coefficients),
#' for free restrictions use zeros.
#' @param value Values of restrictions.
#' @param robust Use robust varcov matrix.
#' @return A list with the Wald value and the corresponding pvalue.
#' @examples
#' x <- 1:10
#' z <- x**2
#' y <- 1:10
#' model <- lm(y~x+z)
#' restrictions <- diag(3)
#' value <-  as.matrix(c(0, 0, 0))
#' wald_test(model, restrictions, value)
wald_test <- function(model, restrictions, value, robust = F){

  if(!inherits(model, "lm")){
    stop("Model must be an lm model")
  }

  if(!inherits(restrictions, "matrix")){
    stop("restrictions and value must be a matrix class")
  }

  if(!inherits(value, "matrix")){
    stop("value must be a matrix class")
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

#' Reset test.
#' Tests the specification of a linear model adding squared and cubic
#' fitted values.
#'
#' @param model An lm model.
#' @param robust Use robust varcov matrix.
#' @return A list with the Wald value and the corresponding pvalue.
#' @examples
#' x <- 1:10
#' y <- 1:10
#' model <- lm(y~x)
#' reset_test(model)
reset_test <- function(model, robust = F){

  if(!inherits(model, "lm")){
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

#' Tests the specification of a linear model using wild-bootstrap.
#'
#' @param model An lm model.
#' @param distribution Type of noise added to residuals, ej "rnorm" or "rrademacher".
#' @param statistic Type of statistic to be used, can be one of "cvm_value" or "kmv_value".
#' @param times Number of bootstrap samples.
#' @param quantiles Vector of quantiles to c alculate pvalues.
#' @param verbose TRUE to print each bootstrap iteration.
#' @param n_cores Number of cores to be used.
#' @return A list with dataframe results and the ordered values of each bootstrap iteration.
#' @references Manuel A. Dominguez and Ignacio N. Lobato (2019).
#' Specification Testing with Estimated Variables. Econometric Reviews.
#' @examples
#' x <- 1:10
#' y <- 1:10
#' model <- lm(y~x-1)
#' dominguez_lobato_test(model)
dominguez_lobato_test <- function(
    model,
    distribution = "rnorm", statistic = "cvm_value",
    times = 300,
    quantiles=c(.9, .95, .99),
    verbose = FALSE,
    n_cores = 1
  ){

  if(!inherits(model, "lm")){
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

  if(n_cores > 1){
    cl <- parallel::makeCluster(n_cores)
    parallel::clusterExport(cl, varlist = ls(), envir = environment())
    parallel::clusterCall(cl, function() library(linearspectestr))

    statistic_star <- parallel::parLapply(cl, 1:times, function(time) {
      # New model
      new_model <- constructed_model(fitted_values, resids, data, distribution)
      statistic <- statistic_fun(new_model)

      return(statistic)
    })

    parallel::stopCluster(cl)
  } else {
    statistic_star <- lapply(1:times, function(time) {
      # New model
      new_model <- constructed_model(fitted_values, resids, data, distribution)
      #statistic_star[time] <- statistic_fun(new_model)
      statistic <- statistic_fun(new_model)

      if (verbose) print(paste("Iteration: ", time))
      return(statistic)
    })
  }

  statistic_star <- unlist(statistic_star, use.names = FALSE)

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

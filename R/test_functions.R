
# Specification tests ------------------------------------------------------

#' Custom Wald test.
#' Tests restrictions*coefficients = value.
#'
#' @param model Model compatible with
#' `fitted` and `residuals` functions.
#' @param restrictions Matrix of size (number of restrictions) times length(coefficients),
#' for free restrictions use zeros.
#' @param value Values of restrictions.
#' @param robust Use robust `varcov` matrix.
#' @param quantiles Vector of quantiles to calculate pvalues.
#' @return A `tibbble` with the Wald value, the corresponding pvalue and the quantiles of the distribution.
#' @examples
#' x <- 1:10
#' z <- x**2
#' y <- 1:10
#' model <- lm(y~x+z)
#' restrictions <- diag(3)
#' value <-  as.matrix(c(0, 0, 0))
#' wald_test(model, restrictions, value)
#' wald_test(model, restrictions, value, robust = TRUE)
#' wald_test(model, restrictions, value, quantiles = c(.97))
wald_test <- function(model, restrictions, value, robust = F,  quantiles=c(.9, .95, .99)){

  if(!inherits(restrictions, "matrix")){
    stop("restrictions and value must be a matrix class")
  }

  if(!inherits(value, "matrix")){
    stop("value must be a matrix class")
  }

  coefs <- coefficients(model)
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

  wald_test <- list(statistic = NULL, p_value = NULL, df = n_rest)
  theta <- restrictions%*%coefs - value

  if(!robust){
    asy_var_theta <- solve(restrictions%*%vcov(model)%*%t(restrictions))
  } else {
    asy_var_theta <- solve(restrictions%*%sandwich::vcovHC(model)%*%t(restrictions))
  }

  wald_test$statistic <- as.numeric(t(theta)%*%asy_var_theta%*%theta)
  wald_test$p_value <- pchisq(wald_test$statistic, df = n_rest, lower.tail = FALSE)

  # Calculating critical values
  calculated_quantiles <- qchisq(quantiles, df = n_rest)

  for(idx in seq_along(quantiles)){
    wald_test[[paste0("quantile_", 100*quantiles[idx])]] <- calculated_quantiles[idx]
  }

  wald_test <- dplyr::as_tibble(wald_test)

  return(wald_test)
}

#' Reset test.
#' Tests the specification of a linear model adding and testing
#' powers of fitted values.
#'
#' @param model An existing fit from a model function such as `lm`, `lfe` and others
#' compatible with `update`.
#' @param robust Use robust `varcov` matrix.
#' @param max_power Max power of fitted values to add.
#' @param quantiles Vector of quantiles to calculate pvalues.
#' @return A `tibble` with the Wald value, the corresponding pvalue, and the quantiles of the distribution.
#' @examples
#' x <- 1:10  + rnorm(10)
#' y <- 1:10
#' model <- lm(y~x)
#' reset_test(model)
#' reset_test(model, robust = TRUE)
#' reset_test(model, quantiles = c(.97))
#' reset_test(model, max_power = 4)
#' reset_test(model, robust = TRUE, max_power = 4)
reset_test <- function(model, robust = FALSE, max_power = 3, quantiles=c(.9, .95, .99)){

  fitted_values <- fitted(model)
  n_obs_pre <- length(coefficients(model))
  model_data <- model.frame(model)


  powers <- 2:max_power
  formula <- ". ~ . "
  for(power in powers){
    variable <- paste0("y_", power)
    model_data[[variable]] <- fitted_values^power

    formula <- paste0(formula, ' + ', variable)
  }
  new_model <- update(
    model,
    formula = as.formula(formula),
    data = model_data
  )

  n_test_vars <- max_power - 1

  restrictions <- cbind(
    matrix(rep(0, n_test_vars*n_obs_pre), nrow = n_test_vars),
    diag(n_test_vars)
  )

  value <- matrix(rep(0, n_test_vars))

  wald <- wald_test(new_model, restrictions, value, robust, quantiles)

  class(wald) <- append(class(wald), "reset_test")

  return(wald)
}

#' Tests the specification of a linear model using wild-bootstrap.
#'
#' @param model An lm model.
#' @param distribution Type of noise added to residuals, ej `rnorm` or `rrademacher`.
#' @param statistic Type of statistic to be used, can be one of `cvm_value` or `kmv_value`.
#' @param times Number of bootstrap samples.
#' @param quantiles Vector of quantiles to calculate pvalues.
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
#' dominguez_lobato_test(model, distribution = "rmammen_point", statistic = "kmv_value")
#' dominguez_lobato_test(model, times = 100)
dominguez_lobato_test <- function(
    model,
    distribution = "rnorm",
    statistic = "cvm_value",
    times = 300,
    quantiles=c(.9, .95, .99),
    verbose = FALSE,
    n_cores = 1
  ){

  # Statistic with residuals without function
  statistic_v <- statistic_value(model, statistic)

  data <- model.frame(model)

  # Times statistics with constructed residuals
  statistic_star <- rep(NA, times)

  if(n_cores > 1){
    cl <- parallel::makeCluster(n_cores)
    packs <- c(.packages())
    parallel::clusterExport(cl, varlist = ls(), envir = environment())
    parallel::clusterCall(cl, function() lapply(packs, library, character.only = T))

    statistic_star <- parallel::parLapply(cl, 1:times, function(time) {
      # New model
      new_model <- updated_model(model, data, distribution)
      statistic <- statistic_value(new_model, statistic)

      return(statistic)
    })

    parallel::stopCluster(cl)
  } else {
    statistic_star <- lapply(1:times, function(time) {
      # New model
      new_model <- updated_model(model, data, distribution)
      statistic <- statistic_value(new_model, statistic)

      if (verbose) print(paste("Iteration: ", time))
      return(statistic)
    })
  }

  statistic_star <- unlist(statistic_star, use.names = FALSE)

  test <- list(
    name_distribution = distribution,
    name_statistic = statistic,
    statistic = statistic_v,
    p_value = sum(statistic_star>=statistic_v)/times
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

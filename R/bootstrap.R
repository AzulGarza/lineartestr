
# Objective ---------------------------------------------------------------
# Functions for boostrap

# Constructed residuals with a particular distribution
# residuals*random variable
constructed_residuals <- function(residuals, distribution = "rnorm"){
  if(is.numeric(residuals)){
    n <- length(residuals)

    dist_f <- get(distribution)

    rvariable <- dist_f(n)

    return(residuals*rvariable)
  } else {
    return("residuals must be a numeric vector")
  }
}

# Sample distribution  of residuals
sample_dist_residuals <- function(residuals, data, new_obs){
  # data is a matrix of observations
  # new_obs is the new observation
  n_obs <- nrow(data)
  n_vars <- ncol(data)

  if(! n_obs == length(residuals)){

    stop("residuals and observations must have the same lengt2h")

  } else if(! n_vars == length(new_obs)) {

    stop("The new and original observation must have the same length")

  } else {

    cum_sum <- 0

    for(obs in 1:n_obs){
      bool_indicator <- I(data[obs,] < new_obs)
      indicator <- ifelse(all(bool_indicator), 1, 0)
      cum_sum <- cum_sum + residuals[obs]*indicator
    }

    return((1/sqrt(n_obs))*cum_sum)

  }
}

# Bootstrap

wild_bootstrap <- function(model, data, times = 100, distribution = "rnorm", statistic = "cvm_test"){
  dfr_obs <- model.frame(update(model, NULL ~ .), data)

  model_fit <- lm(model, data)

  res <- residuals(model_fit)

  statistic_f <- get(statistic)

  # Statistic with residuals without function
  statistic_n <- statistic_f(res, dfr_obs)

  # Times statistics with constructed residuals
  statistic_star <- rep(NA, times)

  for(time in 1:times){
    res_cons <- constructed_residuals(res, distribution)
    statistic_star[time] <- statistic_f(res_cons, dfr_obs)
  }

  return(statistic_star)

}

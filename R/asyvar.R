
# Objective ---------------------------------------------------------------
# Obtain asyvar from a the estimated parameters
# of a lm model

asy_var <- function(model, robust = F){
  # Input
  # - model: A lm model
  # Output
  # - The asyvar of the model
  if(class(model) != "lm"){
    stop("Model must be a lm model")
  }
  resids <- model$residuals
  data_m <- model.matrix(formula(model$terms), model$model)
  #data <- data.matrix(independent_data(model))
  n_obs <- nrow(data)
  #if(as.logical(attr(model$terms, "intercept"))){
    # Adding ones if is necesary
  #  intercept <- rep(1, n_obs)
  #  setNames(intercept, "intercept")
  #  data_m <- cbind(intercept, data)
  #} else {
  #  data_m <- data
  #}
  var <- solve(t(data_m)%*%data_m)
  if(!robust){
    return(sum(resids^2)*var/n_obs)
  } else {
    # Function for robust errors
    mult_error <- function(x){(resids[x]^2)*data_m[x,]%*%t(data_m[x,])}
    var_r <- Reduce('+', map(1:n_obs, mult_error))
    return(var%*%var_r%*%var)
  }
}


# Objective ---------------------------------------------------------------
# Wald test


# packs -------------------------------------------------------------------
require(Matrix)
require(sandwich)

# Code --------------------------------------------------------------------
wald_test <- function(model, restrictions, value, robust = F){
  # Input:
  # - model: A lm model
  # - restrictions: M matrix
  # - value: m value
  # Ouput
  # Return the wald statistic and the
  # result of the constrast
  # Test if M*beta = m, where M = m_rest,
  # m = m_val and beta is the coefficiients
  # of model
  if(class(model) != "lm"){
    stop("Model must be a lm model")
  }
  if(class(restrictions) != "matrix" | class(value) != "matrix"){
    stop("Restriction and value must be a matrix class")
  }
  coefs <- model$coefficients
  n_coefs <- length(coefs)
  n_rest <- nrow(restrictions)
  if(ncol(restrictions) != n_coefs){
    stop("Number of columns of restrictions must be equal to number of coefficients,
         for free restrictions use zeros")
  }
  if(nrow(value) != n_rest){
    stop("Number of rows of values must be equal to number of restrictions,
         for free restrictions use zeros")
  }
  if(rankMatrix(restrictions) != n_rest){
    stop("Restrictions matrix must have a full rank")
  }
  wald_test <- list(wald_value = NULL, p_value = NULL)
  theta <- restrictions%*%coefs - value
  if(!robust){
    asy_var_theta <- solve(restrictions%*%vcov(model)%*%t(restrictions))
  } else {
    asy_var_theta <- solve(restrictions%*%vcovHC(model, type = "HC1")%*%t(restrictions))
  }
  wald_test$wald_value <- as.numeric(t(theta)%*%asy_var_theta%*%theta)
  wald_test$p_value <- pchisq(wald_test$wald_value, df = n_rest)
  return(wald_test)
}



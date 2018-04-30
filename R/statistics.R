
# Objective ---------------------------------------------------------------

# Functions of the statistics

# Cramer von Mises test
cvm_test <- function(residuals, data){
  s_d_r <- function(x){
    sample_dist_residuals(residuals, data, x)
  }

  vec <- apply(data, 1, s_d_r)

  return(norm(vec, "2"))
}

# Kolmogorov test
kmv_test <- function(residuals, data){
  s_d_r <- function(x){
    abs(sample_dist_residuals(residuals, data, x))
  }

  vec <- apply(data, 1, s_d_r)

  return(max(vec))
}

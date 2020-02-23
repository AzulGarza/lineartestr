
# Objective ----------------------------------------------------------------
# Special functions for wildboostrap

# Mammen's two points distribution
rmammen_point <- function(n){
  sqrt_5 <- sqrt(5)
  # Probability
  gold <- (sqrt_5 + 1)/(2*sqrt_5)

  # Binominal
  res <- rbinom(n, size = 1, prob = gold)

  # If it is 1, it must be -(srt(5)-1)/2
  # if it is 0 then (sqrt(5)+1)/2
  res_f <- ifelse(res == 1, -(sqrt_5-1)/2, (sqrt_5+1)/2)

  # Result
  return(res_f)
}

# Mammen's continous distribution
rmammen_cont <- function(n){
  # In this case we use two standard  normals
  # Mean default
  mean_d <- 0

  # Standar deviation default
  sd_d <- 1

  # Normal 1
  norm_1 <- rnorm(n, mean = mean_d, sd = sd_d)

  # Normal 1
  norm_2 <- rnorm(n, mean = mean_d, sd = sd_d)

  # Result
  res <- norm_1/sqrt(2) + 0.5*(norm_2^2 - 1)

  # Result
  return(res)
}

# Rademacher distribution
rrademacher <- function(n){
  # Binominal
  res <- rbinom(n, size = 1, prob = 0.5)

  # If it is 1, it must be -(srt(5)-1)/2
  # if it is 0 then (sqrt(5)+1)/2
  res_f <- ifelse(res == 0, -1, res)

  # Result
  return(res_f)
}

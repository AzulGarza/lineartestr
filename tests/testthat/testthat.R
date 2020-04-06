library(testthat)
library(lineartestr)

y_hat <- c(4, 8, 7)
resids <- c(1, 5, 3)

test_that("presiduals works correctly",{
  expect_identical(presiduals(y_hat, resids), c(1, 4, 9))
})


x <- 1:10
y <- 1:10
model <- lm(y~x-1)

test_that("cvm_value works correctly",{
  expect_equivalent(statistic_value(model, value = "cvm_value"), 0)
})

test_that("kmv_value works correctly",{
  expect_equivalent(statistic_value(model, value = "kmv_value"), 0)
})


#plot test ---------------------------------------------------------------

#' Plots the Dominguez-Lobato test.
#'
#' @param x An object of class "dl_test".
#' @return PLot of type ggplot.
#' @examples
#' x <- 1:10
#' y <- 1:10
#' model <- lm(y~x-1)
#' dl_test <- dominguez_lobato_test(model)
#' plot_dl_test(dl_test)
plot_dl_test <- function(x){
  # This function receives a wild_bootstrap result
  bootstrap <- dplyr::tibble(bootstrap = x$bootstrap)
  d <- density(bootstrap$bootstrap)
  max <- 0

  test <- x[["test"]]
  value_d <- dplyr::select(test, statistic)
  quantiles <- dplyr::select(test, dplyr::contains("quantile"))
  quantiles <- tidyr::gather(quantiles, key = "prob", value = "q")
  quantiles <- dplyr::mutate(quantiles, prob = readr::parse_number(prob)/100)

  plot <-
    ggplot2::ggplot(bootstrap, ggplot2::aes(bootstrap)) +
    ggplot2::geom_density(color = "gray", fill = "gray", alpha = 0.4) +
    ggplot2::geom_vline(ggplot2::aes(xintercept = q, color = factor(q)), data = quantiles) +
    ggplot2::geom_text(
      ggplot2::aes(x = q, y = 0, vjust = -0.2, hjust = -0.2, label = prob, color = factor(q)),
      data = quantiles,
      size = 3
    ) +
    ggplot2::geom_vline(
      ggplot2::aes(xintercept = statistic),
      data = value_d,
      color = "red"
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = statistic, y = 0, vjust = -2, hjust = 1.1, label = "Observed\n statistic"),
      data = value_d,
      color = "red",
      size = 3
    ) +
    viridis::scale_color_viridis(discrete = TRUE, direction = -1) +
    ggplot2::theme(
     axis.title = ggplot2::element_blank(),
     panel.background = ggplot2::element_blank(),
     axis.ticks = ggplot2::element_blank(),
     axis.text = ggplot2::element_blank(),
     legend.position = "none"
    )

  return(plot)
}

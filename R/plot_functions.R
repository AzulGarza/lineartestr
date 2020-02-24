# code --------------------------------------------------------------------

plot.dl_test <- function(dl_test){
  # This function receives a wild_bootstrap result
  bootstrap <- dplyr::tibble(bootstrap = dl_test$bootstrap)
  value_d <- dplyr::tibble(value = dl_test$statistic)
  d <- density(bootstrap$bootstrap)
  max <- 0
  quantiles <- dplyr::tibble(q = quantile(bootstrap$bootstrap, c(.9, .95, .99)))
  quantiles <- dplyr::mutate(quantiles, prob = c("0.90*", "0.95**", "0.99***"))

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
      ggplot2::aes(xintercept = value),
      data = value_d,
      color = "red"
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = value, y = 0, vjust = -2, hjust = 1.1, label = "Observed\n value"),
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

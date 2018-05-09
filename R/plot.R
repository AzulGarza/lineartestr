
# Paquetes ----------------------------------------------------------------
require(ggplot2)
require(viridis)


# code --------------------------------------------------------------------

plot_bootstrap <- function(wild_bootstrap){
  # This function receives a wild_bootstrap result
  bootstrap <- tibble(bootstrap = wild_bootstrap$bootstrap)
  value_d <- tibble(value = wild_bootstrap$statistic)
  d <- density(bootstrap$bootstrap)
  max <- 0
  quantiles <- tibble(q = quantile(bootstrap$bootstrap, c(.9, .95, .99)))
  quantiles <- mutate(quantiles, prob = c("0.90*", "0.95**", "0.99***"))

  plot <- bootstrap %>%
  ggplot(aes(bootstrap)) +
    geom_density(color = "gray", fill = "gray", alpha = 0.4) +
    geom_vline(aes(xintercept = q, color = factor(q)), data = quantiles) +
    geom_text(
      aes(x = q, y = 0, vjust = -0.2, hjust = -0.2, label = prob, color = factor(q)),
      data = quantiles,
      size = 3
    ) +
    geom_vline(
      aes(xintercept = value),
      data = value_d,
      color = "red"
    ) +
    geom_text(
      aes(x = value, y = 0, vjust = -2, hjust = 1.1, label = "Observed\n value"),
      data = value_d,
      color = "red",
      size = 3
    ) +
    scale_color_viridis(discrete = TRUE, direction = -1) +
    theme(
     axis.title = element_blank(),
     panel.background = element_blank(),
     axis.ticks = element_blank(),
     axis.text = element_blank(),
     legend.position = "none"
    )

  return(plot)
}

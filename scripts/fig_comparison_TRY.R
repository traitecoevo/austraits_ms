
#==== 03 Plotting ====
# Scatter plot
#  x = number of records of trait x in AusTraits,
#  y = number of records of trait x in TRY
# color by tissue
p_aus_try <-
  aus_try %>% 
  mutate_at(c("n_austraits", "n_try"), ~.x/28000*100) %>% 
  ggplot(aes(y = n_austraits, x = n_try, color = tissue)) +
  geom_point(alpha = 0.5, size = 2) +
  geom_abline(intercept = 4, slope =1, alpha = 0.2) +
  geom_abline(intercept = 3, slope =1, alpha = 0.2) +
  geom_abline(intercept = 2, slope = 1, alpha = 0.2) +
  geom_abline(intercept = 1, slope =1, alpha = 0.2) +
  geom_abline(intercept = 0, slope = 1, alpha = 0.8) +
  geom_abline(intercept = -1, slope =1, alpha = 0.2) +
  geom_abline(intercept = -2, slope = 1, alpha = 0.2) +
  geom_abline(intercept = -3, slope = 1, alpha = 0.2) +
  geom_abline(intercept = -4, slope = 1, alpha = 0.2) +
  theme_classic() +
  scale_x_log10(limits =c(1E-3, 100), breaks = c(0.001, 0.01, 0.1,1, 10, 100), labels = function(.x) scales::comma(.x, accuracy = 0.01), expand= expansion(0)) +
  scale_y_log10(limits =c(1E-3, 100), breaks = c(0.001, 0.01, 0.1,1, 10, 100), labels = function(.x) scales::comma(.x, accuracy = 0.01), expand= expansion(0)) +
  ylab("Taxa in AusTraits (% flora)") +
  xlab("Species in TRY (% flora)") +
  theme(legend.position = "bottom") +
  labs(color  = "Tissue") +
  scale_color_viridis_d()

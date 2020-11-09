## Austraits: trait composition plot
## Rearrange order of tissue
positions <-
  c("leaf", "stem", "bark", "root", "reproductive", "whole plant")

# Georeferenced trait data
austraits_composition_georef <- 
  trait_composition_list %>%
  filter(!is.na(`latitude (deg)`),!is.na(`longitude (deg)`)) %>%
  group_by(tissue, category) %>%
  summarise(n = n_distinct(taxon_name) %>% replace_na(0)) %>%
  rename(Category = category) %>%
  drop_na() %>%
  ggplot(aes(x = tissue, y = n, fill = Category)) +
  geom_bar(stat = 'identity', position = position_dodge(preserve = "single")) +
  theme_minimal() +
  scale_y_log10(
    breaks = trans_breaks("log10", function(x)
      10 ^ x),
    limits = c(1, 20000),
    labels = trans_format("log10", math_format(10 ^ .x))
  ) +
  xlab("") + ylab("Species (n)") +
  scale_x_discrete(limits = positions) +
  theme(legend.position = "none") +
  scale_fill_viridis_d() +
  annotation_logticks(sides = "l") +
  ggtitle("Geo-referenced")

# Non-georeferenced trait data
austraits_composition_non_georef <- 
  trait_composition_list %>%
  filter(is.na(`latitude (deg)`), is.na(`longitude (deg)`)) %>%
  group_by(tissue, category) %>%
  summarise(n = n_distinct(taxon_name)%>% replace_na(0)) %>%
  rename(Category = category) %>%
  drop_na() %>%
  ggplot(aes(x = tissue, y = n, fill = Category)) +
  geom_bar(stat = 'identity', position = position_dodge(preserve = "single")) +
  theme_minimal() +
  scale_y_log10(
    breaks = trans_breaks("log10", function(x)
      10 ^ x),
    limits = c(1, 20000),
    labels = trans_format("log10", math_format(10 ^ .x))
  ) +
  xlab("Major plant part") + ylab("Species (n)") +
  scale_x_discrete(limits = positions) +
  theme(legend.position = "right") +
  scale_fill_viridis_d() +
  annotation_logticks(sides = "l") +
  ggtitle("Not geo-referenced") 

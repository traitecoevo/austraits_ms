library(tidyverse)

#==== 01 Load data ====
# TRY - data for 3820 species, 46,328 trait x species combinations, 1448 locations
TRY <- bind_rows(
  read_tsv("data/2020.05.28-TRY/tde202052811159.txt", skip = 3),
  read_tsv("data/2020.05.28-TRY/tde2020528113232.txt", skip = 3)) %>% 
  distinct()

# AUSTRAITS -- data over 650000 records,
# for 339 traits, for 23,480 species. 282000 trait x species combinations, 22,000 locations
austraits <- readRDS("data/austraits_2.0.0.rds")
tissue_lookup <- read_csv("data/traits_filled_in.csv") %>%
  select(trait_name, `TRY name`, tissue)


#==== 02 Data wrangling ====
aus_trait_by_taxon <- austraits$traits %>%
  group_by(trait_name) %>%
  summarise(n_austraits = n_distinct(taxon_name))

try_by_sp <- TRY %>%
  group_by(Trait) %>%
  summarise(n_try = n_distinct(AccSpeciesName))


aus_try <- tissue_lookup %>%
  full_join(aus_trait_by_taxon, by = "trait_name") %>%
  full_join(try_by_sp, by = c("TRY name" = "Trait")) %>%
  mutate_if(is.numeric, ~ replace_na(., 0)) %>%
  mutate(tissue = replace_na(tissue, "uncategorised"))



#==== 03 Plotting ====
# Scatter plot
#  x = number of records of trait x in AusTraits,
#  y = number of records of trait x in TRY
# color by tissue
p_aus_try <-
  ggplot(data = aus_try, aes(x = n_austraits, y = n_try, color = tissue)) +
  geom_jitter(alpha = 0.5, size = 2) +
  geom_abline(alpha = 0.1) +
  theme_minimal() +
  scale_x_log10() +
  scale_y_log10() +
  xlab("Taxon in Austraits") +
  ylab("Species in TRY") +
  theme(legend.position = "bottom") +
  labs(color  = "Tissue") +
  scale_color_viridis_d()

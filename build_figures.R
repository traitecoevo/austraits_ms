#### Figures for the Austraits manuscript ####

#devtools::install_deps()
devtools::load_all()

load_data()

source("R/plotting_functions.R") # Load required packages and functions


#### Figure 2: geographical and biome map####
source("scripts/fig_site_locations.R") # A
source("scripts/fig_climate_space_austraits.R") # B

pdf("figures/austraits_fig_biome_map.pdf",
    height = 12,
    width = 8)
austraits_climate_space / austraits_site_locations_by_tissue_fig_2 +  plot_annotation(tag_levels = 'a')
dev.off()

png("figures/austraits_fig_biome_map.png",
    height = 12,
    width = 8, units="in", res=300)
austraits_climate_space / austraits_site_locations_by_tissue_fig_2 +  plot_annotation(tag_levels = 'a')
dev.off()

#### Figure 3: trait composition count ####

source("scripts/fig_trait_composition.R")
pdf("figures/austraits_fig_composition.pdf",
    height = 6,
    width = 8)
austraits_composition_georef / austraits_composition_non_georef +  plot_annotation(tag_levels = 'a')
dev.off()

#### Figure 4: Phylogenetic representation of AusTraits  ####
source("scripts/fig_generate_phylogenies.R") # A Based on 2000 randomly-sampled species
source("scripts/fig_get_family_node.R") # B
source("scripts/fig_link_tree_and_trait_count_matrix.R") # C


pdf(
  "figures/austraits_fig_austraits_phylogenetic_coverage.pdf",
  height = 12,
  width = 12
)
austraits_tree
dev.off()


#### Figure 5: AusTraits and TRY comparison ####
source("scripts/fig_comparison_TRY.R") 
 
pdf( "figures/austraits_fig_austraits_try_comparison.pdf",
     height = 4,
     width = 4)
p_aus_try
dev.off()


#### Figure - coverage

trait_species <- 
  austraits$traits %>% group_by(taxon_name, trait_name) %>% summarise(n=n()) %>% ungroup

trait_species_wide <- 
  trait_species %>% mutate(n = ifelse(n>0,1,0)) %>% pivot_wider(names_from = trait_name, values_from = n) %>% mutate_all(replace_na, 0)

set.seed(22)
data <-
  trait_species_wide %>% 
  sample_n(5000) %>% pivot_longer(cols = -taxon_name, names_to = "trait_name") %>% 
  mutate(
    taxon_name=forcats::fct_reorder(taxon_name, value, sum, .desc = TRUE),
    trait_name=forcats::fct_reorder(trait_name, value, sum, .desc = TRUE),
    )

n_traits <- 
  trait_species_wide %>% pivot_longer(cols = -taxon_name, names_to = "trait_name") %>% 
  group_by(trait_name) %>% 
  summarise(n = sum(value)) %>% 
  arrange(desc(n)) %>% 
  left_join(trait_category_lookup %>% select(trait_name, tissue, category)) %>%
  mutate(i_all= seq_len(n())) %>% 
  group_by(tissue) %>% 
  mutate(i_t =  seq_len(n())) %>% 
  ungroup() %>% 
  arrange(desc(n))

n_spp_aus <- 28980

p1 <- 
  data %>% 
  mutate(trait_i = as.numeric(trait_name),
         taxon_i = as.numeric(taxon_name)/5000*n_spp_aus
         ) %>%
  ggplot(aes(trait_i, taxon_i, fill=value)) +
  geom_tile() +
  labs(x="Trait coverage rank", y="Taxon") +
  scale_y_continuous(limits = c(0, n_spp_aus)) +
  scale_x_continuous(limits = c(0, 450)) +
  theme_classic() +
  scale_fill_viridis() +
  theme(legend.position = "none")

p2 <- 
  n_traits %>%  
  bind_rows(n_traits %>% select(trait_name, n, i_t = i_all) %>% mutate(tissue = "all")) %>% 
  ggplot(aes(i_t, n, col=tissue)) +
  geom_line(size=1.2) +
  scale_y_log10(lim=c(10, n_spp_aus)) +
  lims(x = c(0, 100)) +
  theme_classic() +
  scale_colour_viridis(discrete = T) +
  labs(x = "Trait coverage rank", y = "No. taxa")
  
png("figures/austraits_coverage_by_trait.png", width = 2400, height=1200, res=300)
p1 + p2 +  plot_annotation(tag_levels = 'a')
dev.off()


## Numbers of taxa with multiple records per species

numerical_traits <- austraits$traits %>% filter(!is.na(unit)) %>% pull(trait_name) %>% unique()

top100_traits <- n_traits %>% slice(1:100) %>% pull(trait_name)

n_indiv_per_trait <- 
  trait_species %>% 
  filter(trait_name %in% top100_traits) %>% 
  pivot_wider(names_from = trait_name, values_from = n) %>% 
  mutate_all(replace_na, 0) %>% 
  pivot_longer(cols = -taxon_name, names_to = "trait_name")

n_indiv_per_trait %>% 
  filter(value > 10, trait_name %in% numerical_traits) %>%
  group_by(trait_name) %>%
  summarise(n=n()) %>% 
  arrange(desc(n)) %>% View()
  
austraits$traits %>% 
  filter(trait_name == "leaf_P_per_dry_mass") %>% 
  group_by(taxon_name) %>% 
  mutate(n = n()) %>% 
  ungroup() %>% 
  filter(n>10, dataset_id != "Bloomfield_2018") %>% View()

## duplicate count

## Lizzy checked these in detail and concluded that all or nearly all were genuine records,
## so it would be fairer to say suspected duplicates
## Note that only ture for numerica traits

numerical_traits <- austraits$traits %>% filter(!is.na(unit)) %>% pull(trait_name) %>% unique()

tmp <- 
  austraits$traits %>% 
  select(dataset_id, observation_id, taxon_name, trait_name, value) %>% 
  mutate(check = paste(taxon_name, trait_name, value))

ii <- tmp %>% filter(duplicated(check)) %>% pull(check) %>% unique()

dups <- 
  tmp %>% filter(check %in% ii) %>% 
  arrange(trait_name, taxon_name, value)

dups %>%  filter(trait_name %in% numerical_traits) %>% pull(dataset_id) %>% table() %>% sort(decreasing=T) %>% write.csv("duplicate_count_taxa_numerical.csv")
dups %>%  filter(trait_name %in% numerical_traits)  %>% pull(trait_name) %>% table() %>% sort(decreasing=T) %>% write.csv("duplicate_count_traits_numerical.csv")

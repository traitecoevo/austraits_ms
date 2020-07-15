#### Figures for the Austraits manuscript ####

source("R/plotting_functions.R") # Load required packages and functions

#### Figure 2: geographical and biome map####
source("scripts/fig_site_locations.R") # A
source("scripts/fig_climate_space_austraits.R") # B


pdf("figures/austraits_fig_2_biome_map.pdf",
    height = 12,
    width = 8)
austraits_climate_space / austraits_site_locations_by_tissue_fig_2 +  plot_annotation(tag_levels = 'A')
dev.off()

#### Figure 3: trait composition count ####
source("scripts/fig_trait_composition.R")
pdf("figures/austraits_fig_3_composition.pdf",
    height = 6,
    width = 8)
austraits_composition_georef / austraits_composition_non_georef +  plot_annotation(tag_levels = 'A')
dev.off()

#### Figure 4: Phylogenetic representation of AusTraits  ####
source("scripts/fig_generate_phylogenies.R") # A Based on 2000 randomly-sampled species
source("scripts/fig_get_family_node.R") # B
source("scripts/fig_link_tree_and_trait_count_matrix.R") # C


pdf(
  "figures/austraits_fig_4_austraits_phlogenetic_coverage.pdf",
  height = 12,
  width = 12
)
austraits_tree
dev.off()

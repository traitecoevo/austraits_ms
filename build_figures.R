#### Austraits: Figure 2 ####

library(patchwork)

source("scripts/fig_site_locations.R") # A
source("scripts/fig_climate_space_austraits.R") # B
source("scripts/fig_trait_composition.R") # C


# combined_plot <- (austraits_site_locations+
#                   austraits_climate_space)-
#                   {
#                     austraits_composition +
#                       plot_spacer()+
#                       plot_layout(widths = c(14, 1)) 
#                   }+
#   plot_layout(ncol = 1, heights = c(3, 1))



pdf("figures/austraits_fig2.pdf",height=12, width=8)
austraits_climate_space / austraits_site_locations_by_tissue_fig_2 +  plot_annotation(tag_levels = 'A') 
dev.off()

pdf("figures/austraits_fig3.pdf",height=6, width=8)
austraits_composition_georef / austraits_composition_non_georef +  plot_annotation(tag_levels = 'A') 
dev.off()

#### Austraits: Phylogenetic coverage of traits ####
source("scripts/fig_generate_phylogenies.R") # A
source("scripts/fig_get_family_node.R") # B

#### 1 Plot a base phylogenetic tree ####
base_tree <- ggtree(tree$scenario.2$run.1, layout = "circular",  size=0.01,)+ 
  guides(color=FALSE) #base_tree

# rotate the base_tree
base_tree <- rotate_tree(base_tree, 300)

# make a list of nodes
node_lookup_outcome %>% 
  select(node) %>% 
  unlist() -> nodes_list


base_tree <- ggtree::groupClade(base_tree, .node=nodes_list) # group by nodes


# attach clade label
for(j in 1:length(nodes_list)){
  #Then add each clade label
  if(is.na(node_lookup_outcome$node[j])){
    print("skip labelling clade with one sp")
  } else{
    base_tree <- base_tree + geom_cladelabel(node=node_lookup_outcome$node[j], 
                               label=node_lookup_outcome$family[j], 
                               offset = 100,
                               offset.text=2,
                               barsize = 1, 
                               fontsize=3,
                               angle="auto")
  }
}

tree_breaks = c(1, 3, 10, 30, 80)
austraits_tree <-  gheatmap(base_tree, austraits_summary, 
                offset=4, 
                width=0.2,
                color = NULL,
                colnames_angle=30,
                colnames_position = "top", 
                colnames_offset_x =0,
                colnames_offset_y =50,
                font.size=3,
                hjust=1) +
  scale_fill_gradientn( trans="log10", 
                       # low="#014127",
                       # high="#ff4500",
                       colours=c("#ffcd00", "#94c338", "#2bac66", "#00843D"), # National colours of Australia
                       labels = tree_breaks,
                       breaks = tree_breaks, 
                       na.value = 'white',
                       name="Trait count") +
  theme(legend.position="bottom", legend.justification = "right")+
  guides(fill = guide_colourbar(title.position="top",
                                label.position = "bottom", 
                                barwidth = 10, 
                                barheight = 1))


pdf("figures/fig_4_austraits_phlogenetic_coverage.pdf", height=12, width=12)
austraits_tree
dev.off()

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
base_tree <- ggtree(tree$scenario.2$run.1) #base_tree

# make a list of nodes
node_lookup_outcome %>% 
  select(node) %>% 
  unlist()->nodes_list


base_tree <- groupClade(base_tree, .node=nodes_list) # group by nodes
base_tree<-ggtree(base_tree, # turn base_tree back to ggtree format
                  size=0.01, # change line thickness
                  layout = "circular") + 
  guides(color=FALSE)
#(values = cbp2)
# rotate the base_tree
base_tree <- rotate_tree(base_tree, 300)

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


austraits_tree <-  gheatmap(base_tree, austraits_summary, 
                offset=4, 
                width=0.2, 
                low="#77dd77", 
                high="red", 
                color = NULL,
                colnames_angle=30,
                colnames_position = "top", 
                colnames_offset_x =0,
                colnames_offset_y =50,
                font.size=3,
                hjust=1)

pdf("figures/fig_4_austraits_phlogenetic_coverage.pdf", height=10, width=10)
austraits_tree
dev.off()

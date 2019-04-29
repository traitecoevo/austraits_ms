## 2 Get family node for each family within the sampled species list 


# please run fig_generate_phylogenies.r before executing the code below
# load get_node_tree function
source("R/plotting_functions.R")
rm(myTheme)

#### 1 Group species by family ####
austraits_sp_list_sampled %>%
  filter(species_name %in% tree$scenario.2$run.1$tip.label) %>% 
  group_by(family) %>%
  summarise(species_name = paste(
    paste0("\"",species_name, "\""),collapse=", ")) %>% 
  mutate(species_name=paste0('c(',species_name, ')'))->family_list

#### 2 Calculate the most recent common ancestor to the node for each family ####

## Calulate MRCA
node_lookup<-list()

for(i in 1:nrow(family_list)){
  node_lookup[[i]]<- get_node_tree(family_list[i,]) # get the node for each family
}

# convert list to data frame
node_lookup %>%
  dplyr::bind_rows() ->node_lookup_outcome 

rm(node_lookup)



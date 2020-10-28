## 1 Build a phylogenetic tree from the list of species in AusTraits

##### 1 Read data #####
## add austraits and read the lookup table
austraits <- readRDS("data/austraits_2.0.0.rds")
#tree<-readRDS("data/AusTraits_phylogenies.rds") 
trait_category_lookup<-read_csv("data/trait_categories.csv") %>% 
  dplyr::select(trait_name, tissue, category)


##### 2 Build a phylogenetic tree ####
#build a tree with n number of species
n_species_tree <- 2000

## generate list of species from austraits (or sample 2000 species)
set.seed(10)
austraits$taxa %>% 
  dplyr::select(taxon_name, genus, family) %>% 
  filter(!is.na(family))%>% 
  mutate(taxon_name = gsub(" ", "_", taxon_name)) %>% 
  sample_n(n_species_tree) -> austraits_sp_list_sampled

## Can we use ape::drop.tip instead?

# Build a tree using V.PhyloMaker (probably in a newick format)
tree <- phylo.maker(sp.list = austraits_sp_list_sampled,
                    tree = GBOTB.extended,
                    nodes = nodes.info.1,
                    scenarios = "S2", r = 1)



#### 3 Create a summary table of AusTraits by major organs ####
austraits$traits %>% 
  left_join(trait_category_lookup,by="trait_name")  %>% 
  mutate(category = str_replace(category, "physiology", "physiological"))%>%
  group_by(taxon_name,tissue) %>%
  distinct(taxon_name, trait_name) %>% 
  summarise(n = n()) %>%
  drop_na() %>%
  arrange(-n) %>% 
  ungroup() %>%
  mutate(taxon_name = gsub(" ", "_", taxon_name)) %>% 
  filter(taxon_name %in% tree$species.list$species) %>% 
  spread(key=tissue,value=n) %>%
  select(taxon_name, root, whole_plant, stem, reproductive, leaf) %>% 
  #mutate_if(is.integer, as.logical)%>% 
  #mutate_if(as.integer) %>% 
  as.data.frame() -> austraits_summary

# re-arrange row names to make it compatible with gheatmap
row.names(austraits_summary)<-austraits_summary$taxon_name
austraits_summary$taxon_name<-NULL
colnames(austraits_summary)<-c( "Root", # Root Traits
                                    "Plant", # whole_plant traits
                                    "Stem", # Stem Traits
                                    "Reprod.", # Reproductive traits
                                    "Leaf" # Leaf Traits
                                   ) 

rm(austraits)

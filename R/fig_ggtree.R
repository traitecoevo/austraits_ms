##  The phylogenetic coverage of traits in the Austraits, 
#for the subset of species in the current molecular phylogeny.
library(ggtree)
library(treeio)
library(ggplot2)
library(tidyverse)
library(stringi)
library(taxonlookup)
source("R/taxonlookup.R")

# read a BEAST formatted tree:  Maximum clade credibility tree from the BEAST analysis of the B series
tr<-read.beast(file = url("https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5543309/bin/ncomms16047-s5.txt"))

# the latest molecular phylogeny: Ecography, DOI: 10.1111/ecog.04434
#load(url("https://github.com/jinyizju/V.PhyloMaker/blob/master/data/GBOTB.extended.rda"))

# The get.fields method return all available features that can be used for annotation.
#get.fields(tr)
#get.fields(GBOTB.extended)

#tip_label<-GBOTB.extended$tip.label
tip_label<-get.tree(tr)$tip.label

get.tree(tr)$tip.label
## extract table column
tip_label %>% 
  tibble::enframe()->tr_tiplabel #74,531 species

## replace "_" with a white-space
tr_tiplabel$value<-stri_replace_all_fixed(tr_tiplabel$value, "_", " ")

## add taxon lookup
tr_tiplabel<-tr_tiplabel %>% rename(species_name=value) %>% add_taxon_lookup()

## add austraits and create a lookup table
austraits$traits %>% 
  left_join(trait_category_lookup,by="trait_name")  %>% mutate(category = str_replace(category, "physiology", "physiological"))%>%
  group_by(species_name,tissue) %>% 
  summarise(n = n()) %>% spread(key=tissue, value=n)->austraits_summary # 20,593 species


#How many species are matched? 6,552 species
tr_tiplabel %>%  inner_join(austraits_summary, by="species_name")
# reference lookup
tr_tiplabel %>%  left_join(austraits_summary,by="species_name") %>% select(-name)-> austraits_tree_lookup

## replace  white-space with a "_"
austraits_tree_lookup$species_name<-stri_replace_all_fixed(austraits_tree_lookup$species_name, " ", "_")


# see https://guangchuangyu.github.io/ggtree-book/chapter-ggtree.html

p<-ggtree(tr, layout = "circular") %<+% austraits_tree_lookup+
  geom_tippoint(aes(color=leaf), size=2)


austraits_tree_lookup %>% select(-c(order, group,family, genus))->test
gheatmap(p, test, width=.4, offset=7, colnames=F) %>% 
  scale_x_ggtree


# resources
#https://bioconductor.org/packages/release/bioc/vignettes/ggtree/inst/doc/treeVisualization.html#visualize-a-list-of-trees
#https://guangchuangyu.github.io/software/ggtree/ 
#https://guangchuangyu.github.io/ggtree-book/short-introduction-to-r.html  


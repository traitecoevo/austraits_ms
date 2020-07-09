## Austraits: trait composition plot

library(tidyverse)
library(ggplot2)
library(scales)
library(RColorBrewer)
source("R/plotting_functions.R")

austraits<-readRDS("data/austraits.rds")
trait_category_lookup<-read_csv("data/trait_categories.csv")

austraits$traits %>% 
  left_join(trait_category_lookup,by="trait_name")  %>%
  mutate(category = str_replace(category, "physiology", "physiological"))%>%
  group_by(tissue, category) %>% 
  summarise(n = n_distinct(species_name)) %>%
  rename(Category=category) %>%
  drop_na()-> summary_n_species



## Change the order of the 
positions <- c("leaf", "stem", "root", "reproductive", "whole_plant")
cbPalette <- brewer.pal(5,"Blues")[2:5]

ggplot(data=summary_n_species, 
       aes(x=tissue, y=n, fill=Category))+
  geom_bar( stat='identity', position =position_dodge(preserve = "single")) +
  theme_classic()+ 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)))+
  xlab("Major plant part")+ ylab("Species (n)")+ scale_x_discrete(limits = positions)+ 
  theme(legend.position = "right") +
  scale_fill_viridis_d()-> austraits_composition


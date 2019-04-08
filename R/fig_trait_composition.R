## Austraits: trait composition plot

library(tidyverse)
library(ggplot2)
source("R/plotting_functions.R")

austraits<-readRDS("data/austraits.rds")
trait_category_lookup<-read_csv("data/trait_categories.csv")

austraits$traits %>% 
  left_join(trait_category_lookup,by="trait_name") %>%
  group_by(tissue, category) %>%
  summarise(n = n()) -> summary_n_species



## Change the order of the 
ggplot()+
  geom_bar(data=summary_n_species, 
           aes(x=tissue, y=n, fill=category), 
           stat='identity', position = position_dodge(preserve = "total")) +
  theme_classic()+ 
  scale_y_log10()+



## Austraits: Precipitation–temperature space plot
library(raster)
library(tidyverse)
library(hexbin)
library(ggplot2)
library(viridis)
source("R/plotting_functions.R")



#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)
au_map<-raster("data/au_binary.tif") %>% 
  aggregate(fact=6) %>% 
  as.data.frame(xy=T)


#### 02 Plot AU basemap ####
ggplot()+
  geom_raster(data=au_map, aes(x = x, y = y, fill = au_binary))+
  scale_fill_identity() +theme_minimal() +xlab("")+ylab("")-> au_basemap

#### 03 Overlay species occurences ####
sites<-read_csv("data/austraits_sites.csv")
au_basemap+ geom_point(data=sites, aes(y=`latitude (deg)`, x=`longitude (deg)`), color="grey", alpha=0.5)



## Austraits: site locations plot

library(raster)
library(tidyverse)
library(ggplot2)
library(RColorBrewer)
source("R/plotting_functions.R")



#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)

# one strategy for retrieving data available on web
filename <- "data/australia.tif"
if(!file.exists(filename))
  download.file("htpp:....", filename)

# Read bioclim data using raster package
au_map<-raster(filename) %>% 
 # aggregate(fact=6) %>% 
  as.data.frame(xy=T)


#### 02 Plot AU basemap ####
ggplot()+
  geom_raster(data=au_map, aes(x = x, y = y, fill=factor(australia)))+
  scale_fill_brewer(name="",type = "seq", palette = "#800000", guide=F)+xlab("")+ylab("")+ myTheme-> au_basemap
#au_basemap

#### 03 Overlay site locations  ####
sites<-read_csv("data/austraits_sites.csv")
austraits_site_locations<-au_basemap+
  geom_point(data=sites, aes(y=`latitude (deg)`,
                              x=`longitude (deg)`, size=n),
              alpha=0.3, inherit.aes = F)+
  scale_size(name   = "N Species",
             breaks = sqrt(fivenum(sites$n)),
             labels = fivenum(sites$n))

# austraits_site_locations
# 
# # #### 04 Save plots ####
# ggsave("austraits_sites_distribution.png",
#        austraits_site_locations,  
#        height=4, width=6, units="in")



#### 03 Overlay site locations  ####
austraits_site_locations<-au_basemap+
  geom_point(data=sites, aes(y=`latitude (deg)`,
                              x=`longitude (deg)`, color=n), 
              alpha=0.3, inherit.aes = F, size=2)+
  scale_color_gradient(name="Species (n)", trans="log10", low='#F4A460', high='#800000') +
  theme(legend.justification = c(0, 0), legend.position = c(0.05, 0.05), legend.direction  = "horizontal")
austraits_site_locations

# ggsave("austraits_sites_distribution_v2.png",
#        austraits_site_locations,  
#        height=4, width=5, units="in")

## Austraits: site locations plot

library(raster)
library(tidyverse)
library(ggplot2)

source("R/plotting_functions.R")



#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)
au_map<-raster("data/australia.tif") %>% 
 # aggregate(fact=6) %>% 
  as.data.frame(xy=T)


#### 02 Plot AU basemap ####
ggplot()+
  geom_raster(data=au_map, aes(x = x, y = y, fill=factor(australia)))+
  scale_fill_brewer(name="",type = "seq", palette = "#800000", guide=F)+theme_minimal() +xlab("")+ylab("")-> au_basemap
au_basemap

#### 03 Overlay species occurences ####
sites<-read_csv("data/austraits_sites.csv")
# austraits_site_locations<-au_basemap+
#   geom_point(data=sites, aes(y=`latitude (deg)`,
#                               x=`longitude (deg)`, size=n), 
#               alpha=0.3, inherit.aes = F)+
#   scale_size(name   = "N Species",
#              breaks = sqrt(fivenum(sites$n)),
#              labels = fivenum(sites$n))+
#   theme( legend.position = "bottom", legend.direction  = "horizontal") 
# 
# austraits_site_locations
# 
# 
# ggsave("austraits_sites_distribution.png",
#        austraits_site_locations,  
#        height=4, width=4, units="in")


austraits_site_locations<-au_basemap+
  geom_point(data=sites, aes(y=`latitude (deg)`,
                              x=`longitude (deg)`, color=n), 
              alpha=0.3, inherit.aes = F, size=2)+
  scale_color_gradient(name=" N Species", trans="log10", low='#F4A460', high='#800000') +
  theme(legend.justification = c(0, 0), legend.position = c(0, 0), legend.direction  = "horizontal") 


# ggsave("austraits_sites_distribution_v2.png",
#        austraits_site_locations,  
#        height=4, width=5, units="in")


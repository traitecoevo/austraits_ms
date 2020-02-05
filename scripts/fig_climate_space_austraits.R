## Austraits: Precipitation–temperature space plot
library(raster)
library(tidyverse)
library(hexbin)
library(ggplot2)
source("R/plotting_functions.R")

#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)
bioclim<-getData("worldclim",var="bio",res=10)
# Pick BIO1 (Mean Annual Temperature; T) and BIO12 (Annual Precipitation; P)
bioclim<- bioclim[[c(1,12)]]
names(bioclim) <- c("Temp","Prec")

#### 02 Get the climate data for Australia ####
# Load Australia landmass binary map
au_map<-raster("data/australia.tif")
# Clip bioclim data with the au map
## crop and mask
bioclim_au <- crop(bioclim, extent(au_map)) #%>% mask(.,au_map)
new.bioclim <- projectRaster(bioclim_au, au_map) # harmonize the spatial extent and projection
au_bioclim<-mask(new.bioclim, au_map)

# Transform raster data into a tibble
au_bioclim_table<-au_bioclim %>% 
  as.data.frame() %>%
  na.omit() %>%
  as_tibble %>% mutate(region="Australia")

#### 03 Get the point coordinates of Austraits data ####
source("R/get_sites.R")

# Get climate values for each site
au_sites_clim<- sites %>% rowid_to_column("ID") %>% 
  rename(latitude=`latitude (deg)`, longitude=`longitude (deg)`) %>% 
  combine_occurence_climate(au_bioclim)


# #### 03 Plot the climate data ####
# au_sites_clim
# au_bioclim_table


# # Option 1: hexagonal background + dot points (size ~ species number)
# austraits_climate_space<-ggplot(au_bioclim_table, 
#   aes(x=Prec/10, y=Temp/10)) +
#   geom_hex(alpha=0.8) +
#   theme_minimal()+
#   xlab("Precipitation (cm)")+
#   ylab("Temperature (deg C)")+
#   scale_fill_viridis()+
#   geom_point(data = au_sites_clim, 
#              aes(x=Prec/10, y=Temp/10), 
#              alpha=0.5,shape=1,
#              size=2*log2(au_sites_clim$n),color="black",
#              inherit.aes = FALSE)+ 
#   theme(legend.position = "none") 
# ggsave(austraits_climate_space, "austraits_climate_space.png", width = 4, height = 4)
# 
# austraits_climate_space

# # Option 2: Add whittaker plot
# au_bioclim_table %>%
#   sample_n(1e4) %>% group_by(region)->bioclim_small #sample data points to reduce computing load

library(plotbiomes)
library("RColorBrewer")
austraits_climate_space<-whittaker_base_plot() +
    # add the temperature - precipitation data points
    geom_point(data =au_bioclim_table, 
             aes(x=Temp/10, y=Prec/10, color="Australia"),shape = ".", alpha=0.1,
             inherit.aes = FALSE) + 
  
    geom_point(data = au_sites_clim, 
               aes(x=Temp/10, y=Prec/10, color="AusTraits sites"), 
               alpha=0.2,
              # size=log10(au_sites_clim$n),
               size=1,
               stroke = 0,
               inherit.aes = FALSE,
               position = "jitter")+
  scale_colour_manual(name="",values = c("red","black"))+
  theme_classic()

austraits_climate_space

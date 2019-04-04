## Austraits: Precipitation–temperature space plot
library(raster)
library(tidyverse)
library(hexbin)
library(ggplot2)
library(viridis)
source("R/plotting_functions.R")

#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)
bioclim<-getData("worldclim",var="bio",res=10)
# Pick BIO1 (Mean Annual Temperature; T) and BIO12 (Annual Precipitation; P)
bioclim<- bioclim[[c(1,12)]]
names(bioclim) <- c("Temp","Prec")

#### 02 Get the climate data for Australia ####
# Load Australia landmass binary map
au_map<-raster("data/au_binary.tif")
# Clip bioclim data with the au map
## crop and mask
bioclim_au <- crop(bioclim, extent(au_map)) #%>% mask(.,au_map)
new.bioclim <- projectRaster(bioclim_au, au_map) # harmonize the spatial extent and projection
au_bioclim<-mask(new.bioclim, au_map)

# Transform raster data into a tibble
au_bioclim_table<-au_bioclim %>% 
  as.data.frame() %>%
  na.omit() %>%
  as_tibble()

#### 03 Get the point coordinates of Austraits data ####t

# Get the coordinates of the sites
austraits<-readRDS("data/austraits.rds")
sites <- austraits$sites %>% 
  filter(site_property %in%  c("longitude (deg)","latitude (deg)")) %>% 
  spread(site_property, value)
sites


# get species number for each study
austraits$traits %>%
  group_by(dataset_id, site_name) %>%
  distinct(species_name) %>% 
  count(dataset_id, sort = TRUE) %>% 
  ungroup()-> species_number_lookup

# combine species number vs sites
species_number_lookup %>% na.omit() %>%  
left_join(sites, 
          by = c("dataset_id" = "dataset_id", 
                 "site_name" = "site_name"))->combined_sites

# Get climate values for each site
au_sites_clim<-combined_sites %>% rowid_to_column("ID") %>% 
  rename(latitude=`latitude (deg)`, longitude=`longitude (deg)`) %>% 
  combine_occurence_climate(au_bioclim)


#### 03 Plot the climate data ####
au_sites_clim
au_bioclim_table

# Option 1: hexagonal background + dot points (size ~ species number)
austraits_climate_space<-ggplot(au_bioclim_table %>% sample_n(1e6), 
  aes(x=Prec/10, y=Temp/10)) +
  geom_hex(alpha=0.8) +
  theme_minimal()+
  xlab("Precipitation (cm)")+
  ylab("Temperature (deg C)")+
  scale_fill_viridis()+
  geom_point(data = au_sites_clim, 
             aes(x=Prec/10, y=Temp/10), 
             alpha=0.5,shape=1,
             size=2*log2(au_sites_clim$n),color="black",
             inherit.aes = FALSE)+ 
  theme(legend.position = "none") 
ggsave(austraits_climate_space, "austraits_climate_space.png", width = 4, height = 4)

austraits_climate_space

# Option 2: Add whittaker plot
au_bioclim_table %>% sample_n(1e5)->bioclim_small #sample data points to reduce computing load
library(plotbiomes)
library("RColorBrewer")
austraits_climate_space<-whittaker_base_plot() +
    # add the temperature - precipitation data points
    geom_point(data =bioclim_small, 
             aes(x=Temp/10, y=Prec/10), alpha=0.1) + 
    geom_point(data = au_sites_clim, 
               aes(x=Temp/10, y=Prec/10), 
               alpha=0.5,
               size=log10(au_sites_clim$n),color="white",
               inherit.aes = FALSE)+
    theme_bw() 

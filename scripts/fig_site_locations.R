## Austraits: site locations plot
library(raster)
library(tidyverse)
library(ggplot2)
library(RColorBrewer)
library(viridis)
library(ggpointdensity)
source("R/plotting_functions.R")



#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)

# one strategy for retrieving data available on web
filename <- "data/australia.tif"
if (!file.exists(filename))
  download.file("htpp:....", filename)

# Read bioclim data using raster package
au_map <- raster(filename) %>%
  # aggregate(fact=6) %>%
  as.data.frame(xy = T)


#### 02 Plot AU basemap ####
ggplot() +
  geom_raster(data = au_map, aes(
    x = x,
    y = y,
    fill = factor(australia)
  )) +
  myTheme -> au_basemap



#### 03 Overlay site locations  ####
#sites <- read_csv("data/austraits_sites.csv")
source("R/get_sites.R")
## Filter sites
sites %>%
  filter(
    `latitude (deg)` > (-45),
    `latitude (deg)` < (-9.5),
    `longitude (deg)` < (153),
    `longitude (deg)` > (110)
  ) %>%
  filter(
    !site_name %in% c(
      "site_at_-17.4167_degS_and_151.8833_degE",
      "site_at_-16.5833_degS_and_150.3167_degE",
      "site_at_-16.9333_degS_and_149.1833_degE",
      "site_at_-16.9833_degS_and_149.8833_degE"
    )
  ) -> sites2



#### 03 Overlay site locations  ####
# austraits_site_locations <- produce_site_map(sites2, "latitude (deg)", "longitude (deg)", feature = NA )
# austraits_site_locations_by_tissue <- produce_site_map(sites2, "latitude (deg)", "longitude (deg)", feature = "tissue" )
# austraits_site_locations_by_category <- produce_site_map(sites2, "latitude (deg)", "longitude (deg)", feature = "category" )

austraits_site_locations_by_tissue_fig_2 <- sites2 %>% 
  drop_na() %>%
  produce_site_map( "latitude (deg)", "longitude (deg)", feature = "tissue" )+
  theme(
    #legend.justification = c(-.05, -.05),
    legend.position ="bottom",
   # legend.direction  = "horizontal",
    strip.background = element_blank(),
    strip.text.x = element_text(
      size = 12),
     legend.key.height = unit(0.5, "cm"),
    legend.key.width = unit(2, "cm"),
     legend.box = "horizontal" #,
    # legend.spacing  = unit(0.1, "cm")
    # legend.text = element_text(size=2)
  )

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

au_basemap

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
austraits_site_locations <- au_basemap +
  geom_pointdensity(
    data = sites2,
    aes(y = `latitude (deg)`,
        x = `longitude (deg)`),
    inherit.aes = FALSE,
    show.legend = TRUE,
    adjust = 1
  ) +
  scale_color_viridis(option = "plasma") +
  theme(
    legend.justification = c(-0.1, 0),
    legend.position = c(0.05, 0.05),
    legend.direction  = "horizontal"
  ) +
  scale_fill_grey(
    name = "",
    start = 0.8,
    guide = FALSE,
    na.value = "white"
  ) + xlab("") +ylab("")

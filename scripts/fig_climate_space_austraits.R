## Austraits: Precipitation–temperature space plot
#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)
bioclim <- raster::getData("worldclim", var = "bio", res = 10)
# Pick BIO1 (Mean Annual Temperature; T) and BIO12 (Annual Precipitation; P)
bioclim <- bioclim[[c(1, 12)]]
names(bioclim) <- c("Temp", "Prec")

#### 02 Get the climate data for Australia ####
# Load Australia landmass binary map
au_map <- raster::raster("data/australia.tif")
# Clip bioclim data with the au map
## crop and mask
bioclim_au <- raster::crop(bioclim, raster::extent(au_map)) #%>% mask(.,au_map)
new.bioclim <-
  raster::projectRaster(bioclim_au, au_map) # harmonize the spatial extent and projection
au_bioclim <- raster::mask(new.bioclim, au_map)

# Transform raster data into a tibble
au_bioclim_table <- au_bioclim %>%
  raster::as.data.frame() %>%
  na.omit() %>%
  as_tibble %>%
  mutate(region = as.factor("Australia"))

#### 03 Extract geographic coordinates of AusTraits' sites#

# Get climate values for each site
au_sites_clim <- sites %>% rowid_to_column("ID") %>%
  rename(latitude = `latitude (deg)`, longitude = `longitude (deg)`) %>%
  combine_occurence_climate(au_bioclim)


#### 04 Plot austraits sites over whittaker biome plot ####
austraits_climate_space <- ggplot() +
  geom_polygon(
    data = Whittaker_biomes,
    aes(x    = temp_c,
        y    = precp_cm,
        fill = biome),
    colour = "gray98",
    # colour of polygon border
    size   = 0.1
  )  +
  # add the temperature - precipitation data points
  geom_point(
    data = au_bioclim_table,
    aes(x = Temp / 10, y = Prec / 10, color = "Australia"),
    alpha = 0.2,
    stroke = 0,
    size = 0.5,
    inherit.aes = FALSE
  ) +
  
  # add the AusTraits Sites
  geom_point(
    data = au_sites_clim ,
    aes(x = Temp / 10, y = Prec / 10, color = "AusTraits sites"),
    alpha = 0.3,
    stroke = 0,
    size = 1,
    inherit.aes = FALSE,
    position = "jitter"
  ) +
  
  # set color for  the temperature - precipitation data points and the the AusTraits Sites
  scale_colour_manual(name = "Australian climate space", values = c("#FF7F50", "#233D4D")) +
  scale_fill_manual(
    name   = "Whittaker biomes",
    breaks = names(Ricklefs_colors),
    labels = names(Ricklefs_colors),
    values =  alpha(Ricklefs_colors, 0.5)
    
  ) +
  theme_classic() +
  guides(colour = guide_legend(override.aes = list(alpha = 1, size = 2))) +
  xlab(expression(Temperature (degree * C))) +
  ylab(" Precipitation (cm/yr)") +
  theme(text = element_text(size = 12))  +
  theme(
    legend.justification = c(-0.1, 0),
    legend.position = c(0.005, 0.25),
    legend.text = element_text(size = 8),
    legend.title = element_text(size = 10)
    #legend.key.size = unit(1, "cm")
  ) 

#austraits_climate_space

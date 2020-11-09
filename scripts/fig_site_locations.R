## Austraits: site locations plot

#### 01 Get climate data for Australia ####
# Download bioclim data using library (raster)

# one strategy for retrieving data available on web
filename <- "data/australia.tif"

# Read bioclim data using raster package
au_map <- raster::raster(filename) %>%
  # aggregate(fact=6) %>%
  raster::as.data.frame(xy = T)


#### 02 Plot AU basemap ####
ggplot() +
  geom_raster(data = au_map, aes(
    x = x,
    y = y,
    fill = factor(australia)
  )) +
  myTheme -> au_basemap


#### 03 Overlay site locations  ####

austraits_site_locations_by_tissue_fig_2 <- 
  sites %>%
  select(site_name, `latitude (deg)`, `longitude (deg)`, `tissue`) %>%
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
  ) %>%
  drop_na() %>%
  produce_site_map("latitude (deg)", "longitude (deg)", feature = "tissue") +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    strip.background = element_blank(),
    strip.text.x = element_text(size = 12),
    legend.key.height = unit(0.5, "cm"),
    legend.key.width = unit(2, "cm"),
    legend.box = "horizontal" #,
  )

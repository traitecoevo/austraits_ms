austraits <- readRDS("data/austraits.rds")
library(tidyverse)

# collect sites
austraits$sites %>% 
  as_tibble() %>% 
  filter(site_property %in% c("latitude (deg)", "longitude (deg)")) %>% 
  pivot_wider( names_from =site_property, values_from=value) %>% 
  mutate(`latitude (deg)` = as.numeric(`latitude (deg)`),
         `longitude (deg)` = as.numeric(`longitude (deg)`)) -> sites

# calculate species number
austraits$traits %>%
  as_tibble() %>% 
  dplyr::select(dataset_id, species_name, site_name) %>% 
  dplyr::group_by(dataset_id, site_name) %>% 
  distinct(species_name) %>% 
  count(dataset_id, sort = TRUE) %>% 
  ungroup() -> sp_number

sites<- sites%>%
  left_join(sp_number, by=c("dataset_id", "site_name"))
rm(sp_number)
# 
# library(leaflet)
# library(htmltools)
# sites2 %>%
#   mutate(label=paste(dataset_id,site_name)) %>%
# leaflet() %>%
#    addTiles() %>%
#   addMarkers(~`longitude (deg)`, ~`latitude (deg)`,
#              popup = ~htmlEscape(label),
#              clusterOptions = markerClusterOptions())

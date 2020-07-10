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
  dplyr::select(dataset_id, taxon_name, site_name) %>% 
  dplyr::group_by(dataset_id, site_name) %>% 
  distinct(taxon_name) %>% 
  count(dataset_id, sort = TRUE) %>% 
  ungroup() -> sp_number

# get trait categories
trait_category_lookup <- read_csv("data/traits_filled_in.csv") %>% 
  dplyr::select(trait_name, tissue, category)

# get trait list
trait_list<- austraits$traits %>%
  as_tibble() %>% 
  dplyr::select(dataset_id, taxon_name, site_name, trait_name) 

trait_composition_list <- trait_list %>% 
  full_join(trait_category_lookup, by = "trait_name") %>% 
  full_join(sites, by = c("dataset_id", "site_name"))

# uncategorised/ unclassified traits
unclassified_traits <- austraits$traits %>%
  dplyr::select(dataset_id, site_name, trait_name) %>% 
  left_join(trait_category_lookup, by = "trait_name") %>% 
  dplyr::filter(is.na(category)) %>% 
  dplyr::select(trait_name, tissue, category) %>%
  distinct()

# extract trait categories by dataset_id and site_name
trait_categories <- austraits$traits %>%
  as_tibble()  %>% 
  dplyr::select(dataset_id, site_name, trait_name) %>% 
  left_join(trait_category_lookup, by = "trait_name")  %>%
  mutate(category = str_replace(category, "physiology", "physiological")) %>%
  dplyr::select(-trait_name) %>%
  distinct() 

sites %<>%
  left_join(sp_number, by=c("dataset_id", "site_name")) %>% 
  left_join(trait_categories, by=c("dataset_id", "site_name")) 
  

rm(sp_number, trait_categories)
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

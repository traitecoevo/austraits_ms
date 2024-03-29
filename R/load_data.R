expand <- function(x) {x %>% str_split(", ") %>% unlist() %>% unique() %>% na.omit() %>% sort()}
collapse <- function(x, sep=", ") {x %>% expand() %>% na_if("") %>% na.omit() %>% unique() %>% paste(collapse = sep)}
remove <- function(x, id) {expand(x) %>% subset(., !(. %in% id))  }
keep <- function(x, id) {expand(x) %>% subset(., (. %in% id))  }

load_data <- function(update=FALSE) {
  
  if(update | !exists("austraits", envir = .GlobalEnv )) {
    austraits <- readRDS("data/austraits-3.0.2.rds")
    assign("austraits", austraits, envir = .GlobalEnv)
  }
  
  ## Trait lookup table

  assign("trait_category_lookup", read_csv("data/traits_names_list_20210401v2 - traits_names_list_20210401v2.csv", col_types = cols(.default = "c")), envir = .GlobalEnv)
  
  # identify refs with unpublished data 
  unpub <- 
    tibble(key = map_chr(austraits$sources, ~.x$key), title = map_chr(austraits$sources, ~.x$title), 
           author = map_chr(austraits$sources, ~.x$author[1] %>% paste(collapse = ", "))
    ) %>% 
    filter(grepl("Unpublished data", title, fixed=TRUE))
  
  # 
  sources_all <- 
    bind_rows(
      austraits$methods %>% select(dataset_id, citation_p = source_primary_key),
      austraits$methods %>% select(dataset_id, citation_s = source_secondary_key)
    ) %>% 
    distinct() %>% 
    arrange(dataset_id) %>% 
    group_by(dataset_id) %>% 
    summarise(
      refs_primary = citation_p %>% str_replace_all(";", ",") %>% collapse(),
      refs_secondary = citation_s %>% str_replace_all(";", ",") %>% collapse()
      )
  
  sites <- austraits$sites %>% 
    filter(site_property %in%  c("longitude (deg)","latitude (deg)")) %>% 
    spread(site_property, value)
  
  data_geo <- 
    left_join(by=c("dataset_id", "site_name"),
              select(austraits$traits, -original_name), sites) %>%
    left_join(by="taxon_name",
              select(austraits$taxa, taxon_name, family)) %>% 
    left_join(sources_all, by=c("dataset_id")) 
  
  
  n_records <- 
    data_geo %>% 
    group_by(trait_name) %>%
    summarise(
      Description = "",
      Type= "",
      `all` = n(),
      `geo.` = sum(!is.na(`longitude (deg)`) & !is.na(`latitude (deg)`)),
      datasets = n_distinct(dataset_id),
      taxa = n_distinct(taxon_name),
      families = n_distinct(family),
      dataset_id = dataset_id %>% collapse(),
#      refs_all =  c(refs_primary, refs_secondary) %>% collapse(), 
      refs_primary_pub =  refs_primary %>% remove(unpub$key) %>% collapse(), 
      refs_primary_unpub  = refs_primary %>% keep(unpub$key) %>% collapse(), 
      refs_secondary_pub = refs_secondary %>% remove(unpub$key) %>% collapse(),
      unpub_people = unpub %>% filter(key %in% expand(refs_primary_unpub)) %>% pull(author) %>% expand() %>% collapse()
    ) %>% 
    left_join(trait_category_lookup %>% select(trait_name, tissue, category), by=c("trait_name")) %>% 
    select(Tissue = tissue, Category = category, Trait = trait_name, everything()) %>% 
    arrange(Tissue, Category, Trait)

  n_records$Type <- sapply(austraits$definitions$traits$elements, "[[","type")[n_records$Trait]
  n_records$Description <- sapply(austraits$definitions$traits$elements, "[[","description")[n_records$Trait] %>% unlist()
  assign("n_records", n_records, envir = .GlobalEnv)

  # extract trait categories by dataset_id and site_name
  trait_categories <- 
    austraits$traits %>%
    as_tibble()  %>%
    dplyr::select(dataset_id, site_name, trait_name) %>%
    dplyr::left_join(by = "trait_name", trait_category_lookup %>% select(trait_name, tissue, category)) %>%
    mutate(category = str_replace(category, "physiology", "physiological")) %>%
    dplyr::select(-trait_name) %>%
    distinct()

  assign("trait_categories", trait_categories, envir = .GlobalEnv)

  # calculate species number
  austraits$traits %>%
    as_tibble() %>%
    dplyr::select(dataset_id, taxon_name, site_name) %>%
    dplyr::group_by(dataset_id, site_name) %>%
    distinct(taxon_name) %>%
    count(dataset_id, sort = TRUE) %>%
    ungroup() -> sp_number

  # collect sites
  sites <-
    austraits$sites %>%
    filter(site_property %in% c("latitude (deg)", "longitude (deg)"), !value %in% c("", "unknown")) %>%
    pivot_wider(names_from = site_property, values_from = value) %>%
    drop_na() %>% 
    mutate(
      `latitude (deg)` = as.numeric(`latitude (deg)`),
      `longitude (deg)` = as.numeric(`longitude (deg)`)
    ) %>% 
    left_join(sp_number, by = c("dataset_id", "site_name")) %>%
    left_join(trait_categories, by = c("dataset_id", "site_name"))
   
  assign("sites", sites, envir = .GlobalEnv)

  # get trait list
  trait_composition_list <- 
    austraits$traits %>%
    dplyr::select(dataset_id, taxon_name, site_name, trait_name) %>%
    full_join(by = "trait_name", trait_category_lookup %>% select(trait_name, tissue, category)) %>%
    full_join(by = c("dataset_id", "site_name"), sites %>% select(-tissue, -category))

  assign("trait_composition_list", trait_composition_list, envir = .GlobalEnv)


  # TRY - data for 3820 species, 46,328 trait x species combinations, 1448 locations
  try_by_sp <- 
    suppressWarnings(
    bind_rows(
      read_tsv("data/2020.05.28-TRY/tde202052811159.txt", skip = 3),
      read_tsv("data/2020.05.28-TRY/tde2020528113232.txt", skip = 3)
      )) %>% 
    distinct() %>%
    # load categories
    left_join(by= "Trait", read_csv("data/2020.05.28-TRY/try_categories.csv")) %>%
    group_by(Trait, tissue) %>%
    summarise(
      n_try = n_distinct(AccSpeciesName)) %>% 
    rename("TRY tissue" = "tissue")
  

  aus_try_comparison <- 
    trait_category_lookup %>% 
    select(trait_name, `TRY name`, tissue) %>%
    mutate(`TRY name` = ifelse(duplicated(`TRY name`), NA, `TRY name`)) %>%
    full_join(by = "trait_name",
      austraits$traits %>%
      group_by(trait_name) %>%
      summarise(n_austraits = n_distinct(taxon_name)) 
              ) %>%
    full_join(try_by_sp, by = c("TRY name" = "Trait")) %>%
    mutate_if(is.numeric, ~ replace_na(., 0)) %>%
    mutate(tissue = ifelse(is.na(trait_name),`TRY tissue`, tissue))

  assign("aus_try_comparison", aus_try_comparison, envir = .GlobalEnv)
    
}


load_data <- function() {
  
  if(!exists("austraits", envir = .GlobalEnv )) {
    austraits <- readRDS("data/austraits_2.0.0.rds")
    assign("austraits", austraits, envir = .GlobalEnv)
  }
  
  assign("trait_category_lookup", read_csv("data/trait_categories.csv", col_types = cols(.default = "c")), envir = .GlobalEnv)
  
  aus_trait_by_taxon <- 
    austraits$traits %>%
    group_by(trait_name) %>%
    summarise(n_austraits = n_distinct(taxon_name))
  
  # TRY - data for 3820 species, 46,328 trait x species combinations, 1448 locations
  TRY <- 
    suppressWarnings(
    bind_rows(
      read_tsv("data/2020.05.28-TRY/tde202052811159.txt", skip = 3),
      read_tsv("data/2020.05.28-TRY/tde2020528113232.txt", skip = 3)
      )) %>% 
    distinct() %>%
    left_join(by= "Trait", read_csv("data/2020.05.28-TRY/try_categories.csv"))
  
  
  try_by_sp <- 
    TRY %>%
    group_by(Trait, tissue) %>%
    summarise(
      n_try = n_distinct(AccSpeciesName)) %>% 
    rename("TRY tissue" = "tissue")
  
  aus_try <- 
    trait_category_lookup %>% 
    select(trait_name, `TRY name`, tissue) %>%
    full_join(aus_trait_by_taxon, by = "trait_name") %>%
    full_join(try_by_sp, by = c("TRY name" = "Trait")) %>%
    mutate_if(is.numeric, ~ replace_na(., 0)) %>%
    mutate(tissue = ifelse(is.na(trait_name),`TRY tissue`, tissue)) %>%
    group_by(`TRY name`) %>% 
    summarise(
      trait_name = trait_name[1],
      n_austraits = sum(n_austraits), 
      n_try = n_try[1],
      tissue = subset(tissue, !is.na(tissue))[1]
    ) %>% ungroup()
  
  assign("aus_try", aus_try, envir = .GlobalEnv)
  
  
  sources_all <- 
    bind_rows(
      austraits$methods %>% select(dataset_id, citation = source_primary_key),
      austraits$methods %>% select(dataset_id, citation = source_secondary_key)
    ) %>% 
    na_if("") %>%
    na.omit() %>% 
    distinct() %>% 
    arrange(dataset_id) %>% 
    group_by(dataset_id) %>% 
    summarise(refs = sprintf("%s", citation) %>% paste(collapse = ", ") %>% str_replace_all(";", ",") )
  
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
      studies = n_distinct(dataset_id),
      taxa = n_distinct(taxon_name),
      families = n_distinct(family),
      refs =  refs %>% unique() %>% paste(collapse = ", ")
    ) %>% 
    left_join(trait_categories %>% select(trait_name, tissue, category), by=c("trait_name")) %>% 
    select(Tissue = tissue, Category = category, Trait = trait_name, everything()) %>% 
    arrange(Tissue, Category, Trait)
  
  n_records$Type <- sapply(austraits$definitions$traits$elements, "[[","type")[n_records$Trait]
  n_records$Description <- sapply(austraits$definitions$traits$elements, "[[","description")[n_records$Trait] %>% unlist()
  
 
  assign("n_records", n_records, envir = .GlobalEnv)
  
}

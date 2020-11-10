

# check list of acknowledgements and assistants

data_contributors <- 
  austraits$contributors %>% 
  mutate(
    acknowledge = ifelse(
      # old studies or excluded
      dataset_id %in% c("Lawes_2012", "Westman_1977", "Hall_1981", "Hocking_1982", "Hocking_1986", "Toelken_1996", "Brock_1993", "Forster_1992", "Forster_1995", "Goble_1981", "Clarke_2015") |
        role %in% c("assistant") |
        # deceased
        name %in% c("Peter Clarke", "Barbara Rice", "Peter Myerscough", "Lyn Craven", "Harold Trevor Clifford", "William Cooper", "J. Bastow Wilson") |
        # no response or can't locate
        name %in% c("Emma Laxton", "Huw Morgan", "Wendy Cooper", "Muhammad Islam", "Kate McClenahan") |
        # can't locate
        name %in% c("Ian Davidson", "Kate Hughes", "Kirsten Knox", "Paula Peeters", "Burak Pekin", "Anne Sjostrom")
        ,
      TRUE, FALSE),
    year = dataset_id %>% str_split_fixed("_", 4) %>% .[,2]) %>% 
  arrange(year) %>%
  # take most recent address for each author
  group_by(name) %>% 
  summarise(institution = last(institution),
            dataset_ids = paste(dataset_id, collapse = ", "),
            acknowledge = all(acknowledge)) %>% 
  ungroup() %>% 
  distinct() %>% 
  mutate(surname = str_split(name, " ") %>% map_chr(last)) %>% 
  rename(affiliation = institution) %>%
  arrange(surname) %>% 
  select(-surname)

affiliations_sheet <- googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1nYE5V7utbExcfGmsfILjoXdVsEMDi5CLF_H-uE57EOo/edit#gid=280623389") %>% 
  filter(!is.na(name))

authors_lead <- read_csv("data/lead_authors.csv")

authors <- bind_rows(authors_lead %>% mutate(acknowledge=FALSE), 
                     data_contributors %>% filter(! (name %in% authors_lead$name))
  ) %>% 
  rename(affiliation_dataset = affiliation) %>%  
  left_join(by="name", affiliations_sheet %>% select(name, affiliation))

write_csv(authors, "data/author_list.csv")


taxon_lookup_func<-function(df){
  df[["species_name"]]%>%
    unique()%>%
    lookup_table(., by_species=TRUE)%>%
    tibble::rownames_to_column(., var = "species_name")-> taxon_result
  
  taxon_result
}
#function to join main data with the taxon_lookup_func outcome
add_taxon_lookup<-function(df){
  taxon_lookup_func(df)%>%
    left_join(df, ., by="species_name")
  
}

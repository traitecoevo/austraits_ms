# Convert a list with single entries to dataframe
list1_to_df <- function(my_list) {
  
  for(f in names(my_list)) {
    if(is.null(my_list[[f]])) 
      my_list[[f]] <- NA
  }
  
  tibble(key = names(my_list), value = unlist(my_list))
}


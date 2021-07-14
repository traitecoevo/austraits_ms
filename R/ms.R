# Convert a list with single entries to dataframe
list1_to_df <- function(my_list) {
  
  for(f in names(my_list)) {
    if(is.null(my_list[[f]])) 
      my_list[[f]] <- NA
  }
  
  tibble(key = names(my_list), value = unlist(my_list))
}



## Add `\citet{}` for references. 
## Separate into groups of max size n. 
## This is needed for latex table, overwise citations
## spill off the page
format_cites_n <- function(x){
  
  # Make sorted vector of all unique refs
  str_split(x, ", ") %>% unlist() %>% sort() %>% 
    paste(collapse = "; @") %>% paste0("[  [@", ., "]  ]" )
}


## format table
make_latex_table <- function(data) {
  data %>%
    # nasty hacks - replace `_` with `TTTTT` then return below, prevents unhelpful handling of _ in creation of latex table
    mutate(refs = str_replace_all(refs, "_", "TTTT")) %>%  
    knitr::kable("latex",  booktabs = TRUE, longtable = TRUE ) %>%
    kableExtra::kable_styling(font_size = 7, latex_options = c("repeat_header", "striped")) %>%
    kableExtra::column_spec(1, width = "3cm") %>%
    kableExtra::column_spec(2, width = "4cm") %>%
    kableExtra::column_spec(9, width = "3cm") %>%
    kableExtra::add_header_above(c(" ", " ", " ", "Number of records" = 5)) %>%
    # nasty hacks - clean up backslashes and references. (why oh why is this needed?)
    str_replace_all(fixed("textbackslash{}"), fixed("")) %>%
    str_replace_all(fixed("gray!6"), fixed("gray!20")) %>%
    str_replace_all(fixed("\\{"), fixed("{")) %>%
    str_replace_all(fixed("\\}"), fixed("}"))  %>% 
    str_replace_all(fixed("TTTT"), fixed("_")) %>%
    str_split("\\n") %>% unlist()
}

# wraps text in table cell to max number of characters per line -- needed for long words with no spaces (i.e. trait names)
txt_wrap <- function(txt, n=22) {
  
  f <- function(txt, end=-1L) {
    ifelse(str_length(txt) > 0, paste("\\newline", str_sub(txt, 0, end)), txt)
  }
  
  g <- function(txt) {
    ifelse(str_length(txt) < n, -1L, 
           str_locate_all(txt,"_") %>% purrr::map_dbl(~.x %>% .[,"start"] %>% subset(., .< n) %>% max(., -1L)) 
    )
  }
  
  i <- g(txt)
  txt2 <- ifelse(str_length(txt) >= n , str_sub(txt, i+1), "")
  ii <- g(txt2)
  txt3 <- ifelse(str_length(txt2) >= n , str_sub(txt2, ii+1), "")
  
  paste(str_sub(txt, 1, i), f(txt2, ii), f(txt3))
}


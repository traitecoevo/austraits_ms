
##### Functions ####
extract_climate_data<-function(df, climstack){
  #df is a dataframe of trait data with lat and lon columns
  #climstack is a stack of gridded climate data
  
  df%>%
    # filter(plot_coord_avail==1)%>%
    mutate(lat=as.numeric(lat), lon=as.numeric(lon)) %>% 
    ungroup()%>%
    dplyr::select( lat, lon)%>%
    na.omit()-> coord
  
  sp::coordinates(coord)=~lon+lat
  sp::proj4string(coord)=sp::CRS("+proj=longlat +datum=WGS84")
  raster::extract(climstack,coord,na.rm=F, df=T)->df_climate
  
  df_climate
}


#' Combine species occurence and climate data
#'
#' @param species_occurence_df 
#' @param climate_raster_data 
#'
#' @return
#' @export
#'
#' @examples
combine_occurence_climate<-function(species_occurence_df, climate_raster_data){
  species_occurence_df%>% 
    group_by(ID)%>%
    rename(lat=latitude, lon=longitude) %>%
    extract_climate_data(climate_raster_data) %>%
    left_join(species_occurence_df,., by="ID")->sp_clim_combined
  
  sp_clim_combined
}


myTheme <-
  
  theme(legend.position = "none",
        
        panel.grid.major = element_blank(),
        
        panel.grid.minor = element_blank(),
        
        panel.background = element_blank(),
        
        panel.border = element_rect(colour = "black", fill=NA, size=1),
        
        axis.ticks.length = unit(1, "mm"),
        
        axis.ticks = element_line(size = 1),
        
        axis.line.x = element_line(),
        
        axis.line.y = element_line(),
        
        axis.title.x = element_text( size = 12, margin = margin(10, 0, 0, 0)),
        
        axis.title.y = element_text( size = 12, margin = margin(0, 10, 0, 0)),
        
        axis.text.x = element_text( size = 9, colour = "#666666", margin=margin(15,0,0,0,"pt")),
        
        axis.text.y = element_text( size = 9, colour = "#666666", margin=margin(0,15,0,0,"pt")),
        
        panel.spacing.y = unit(1, "points"),
        
        legend.title=element_text(size=12),
        
        legend.text=element_text(size=10))


#' get_node_tree function
#'
#' @param x  family_list[i,] a tibble of family, species
#' @param t phylogenetic tree
#'
#' @return get_node_tree(family_list[2,], tree$scenario.2$run.1)
#' @export
#'
#' @examples
get_node_tree<-function(x, t=tree$scenario.2$run.1){
  x[2]%>%
    unlist %>%
    rlang::parse_expr()%>%
    rlang::eval_tidy()->y # is a vector of tip (species)
  
  if(length(y)>10){ # select family with >10 species
    #browser()
    ape::getMRCA(t, y)->z # z is a node of the most recent common ancestor 
    mutate(x, node=z) %>% as.data.frame()
  } else
  {
    # parent(as_tibble(t),y) %>% select(node) %>% unlist()->z
    mutate(x, node=NA) %>%
      as.data.frame() # z is the parent node, set into NA if you want to omit clade with only one species,
  }
  
}


#' Produce site maps (Fig 2 A)
#'
#' @param df a dataframe consist of 
#' @param lat latitude in degree decimal
#' @param lon longitude in degree decimal
#' @param feature grouping/classification categories
#'
#' @return
#' @export
#'
#' @examples
produce_site_map <- function(df, lat, lon, feature=NA){
  site_map <- au_basemap +
    geom_pointdensity(
      data = {{df}},
      aes(y = !!as.name(lat),
          x = !!as.name(lon)),
      inherit.aes = FALSE,
      show.legend = TRUE,
      adjust = 1,
      size = 0.5,
      alpha=0.8
    ) +
    scale_color_viridis(option = "plasma") +
    theme(
      legend.justification = c(-0.1, 0),
      legend.position = c(0.05, 0.05),
      legend.direction  = "horizontal"
    ) +
    scale_fill_grey(
      name = "",
      start = 0.8,
      guide = FALSE,
      na.value = "white"
    ) + xlab("") +ylab("")

  if(is.na(feature)){
    site_map } else {
      site_map + facet_wrap(paste("~", feature))
    }

}

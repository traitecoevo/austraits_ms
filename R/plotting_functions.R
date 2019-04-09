extract_climate_data<-function(df, climstack){
  #df is a dataframe of trait data with lat and lon columns
  #climstack is a stack of gridded climate data
  
  df%>%
    # filter(plot_coord_avail==1)%>%
    mutate(lat=as.numeric(lat), lon=as.numeric(lon)) %>% 
    ungroup()%>%
    dplyr::select( lat, lon)%>%
    na.omit()-> coord
  
  coordinates(coord)=~lon+lat
  proj4string(coord)=CRS("+proj=longlat +datum=WGS84")
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
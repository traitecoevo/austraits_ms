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
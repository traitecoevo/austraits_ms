## Austraits: generate figure 2

library(patchwork)

source("R/fig_site_locations.R")
source("R/fig_climate_space_austraits.R")
source("R/fig_trait_composition.R")


combined_plot<-(austraits_site_locations+
                  austraits_climate_space)-
                  {
                    austraits_composition +
                      plot_spacer()+
                      plot_layout(widths = c(14, 1)) 
                  }+
  plot_layout(ncol = 1, heights = c(3, 1))

ggsave("austraits_fig2.png",
       combined_plot,  
       height=6, width=12, units="in")


## Austraits: Figure 2

library(patchwork)

source("scripts/fig_site_locations.R") # A
source("scripts/fig_climate_space_austraits.R") # B
source("scripts/fig_trait_composition.R") # C


combined_plot<-(austraits_site_locations+
                  austraits_climate_space)-
                  {
                    austraits_composition +
                      plot_spacer()+
                      plot_layout(widths = c(14, 1)) 
                  }+
  plot_layout(ncol = 1, heights = c(3, 1))


pdf("figures/austraits_fig2.pdf",height=6, width=12)
combined_plot
dev.off()

# ggsave("figures/austraits_fig2.png",
#        combined_plot,  height=6, width=12, units="in")
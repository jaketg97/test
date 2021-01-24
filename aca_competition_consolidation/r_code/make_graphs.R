library(jtools)

ggplot(data = full_combined, aes(x=insurer_hhi_logged, color=year.f, fill=year.f)) +
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.4, binwidth = .1, position = "identity") + 
  labs(title="Insurer HHI, by year", color="Year:", fill="Year:", y="Percent", x="Insurer HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10)) 

ggsave(filename = "../paper/graphs/hist_year_insurerhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, color=year.f, fill=year.f)) + 
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.1, position = "identity") + 
  labs(title="Hospital HHI, by year", color="Year:", fill="Year:", y="Percent", x="Hospital HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/hist_year_hospitalhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=insurer_hhi_logged, color=region.f)) + 
  geom_density(position = "identity") + 
  labs(title="Insurer HHI, by region", color="Region:", y="Density", x="Insurer HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/kd_region_insurerhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, color=region.f)) + 
  geom_density(position = "identity") + 
  labs(title="Hospital HHI, by region", color="Region:", x="Hospital HHI (logged)", y="Density") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/kd_region_hospitalhhi.png", height = 4, width = 5.5, dpi = 600)

binscat <- binsreg(full_combined$insurer_hhi_logged, full_combined$hospital_hhi_logged, 
          w=data.frame(c(full_combined$rating_area.f), c(full_combined$year.f), c(full_combined$rucc_code_13), c(full_combined$median_age)))

binscat$bins_plot + labs(title="Binned scatterplot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", 
  y="Insurer HHI (logged)") + theme_stata(scheme="s2color") 

ggsave(filename = "../paper/graphs/binscatter_results.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, y=insurer_hhi_logged, color=year.f)) + geom_point() + geom_smooth(method="lm") + 
  labs(title="Scatterplot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", y="Insurer HHI (logged)") + theme_stata(scheme="s2color")

ggsave(filename = "../paper/graphs/scatter_byyear.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, y=insurer_hhi_logged, color=region.f)) + geom_point() + geom_smooth(method="lm") + labs(title="Scatterplot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", 
  y="Insurer HHI (logged)") + theme_stata(scheme="s2color")

ggsave(filename = "../paper/graphs/scatter_byregion.png", height = 4, width = 5.5, dpi = 600)

effect_plot <- effect_plot(model_full, hospital_hhi_logged, rug = TRUE, interval = TRUE)

effect_plot + labs(title="Effect Plot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", 
  y="Insurer HHI (logged)") + theme_stata(scheme="s2color") 

ggsave(filename = "../paper/graphs/effectplot_results.png", height = 4, width = 5.5, dpi = 600)


library(jtools)
library(ggpubr)
library(ggplot2)
library(ggthemes)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
rm(list=ls())

full_14_15 <- read.csv("../clean_data/full_14_15.csv")
full_15_16 <- read.csv("../clean_data/full_15_16.csv")
full_combined <- read.csv("../clean_data/full_combined.csv")

#################################################
# HISTOGRAMS
#################################################

full_combined$year.f <- factor(full_combined$year.f)

ggplot(data = full_combined, aes(x=insurer_hhi_logged, color=year.f, fill=year.f)) +
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.4, position = "identity") + 
  labs(title="Insurer HHI, by year", color="Year:", fill="Year:", y="Percent", x="Insurer HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10)) 

ggsave(filename = "../paper/graphs/hist_year_insurerhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, color=year.f, fill=year.f)) + 
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.4, position = "identity") + 
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

ggplot(data = full_combined, aes(x=num_insurers, color=year.f, fill=year.f)) +
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.4, binwidth = .1, position = "identity") + 
  labs(title="Number of Insurers, by year", color="Year:", fill="Year:", y="Percent", x="Number of Insurers") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10)) 

ggsave(filename = "../paper/graphs/hist_year_numinsurers.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_hospitals, color=year.f, fill=year.f)) + 
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.1, position = "identity") + 
  labs(title="Number of Hospitals, by year", color="Year:", fill="Year:", y="Percent", x="Number of Hospitals") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/hist_year_numhospitals.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_insurers, color=region.f)) + 
  geom_density(position = "identity") + 
  labs(title="Number of Insurers, by region", color="Region:", y="Density", x="Number of Insurers") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/kd_region_numinsurers.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_hospitals, color=region.f)) + 
  geom_density(position = "identity") + 
  labs(title="Number of Hospitals, by region", color="Region:", x="Number of Hospitals", y="Density") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/kd_region_numhospitals.png", height = 4, width = 5.5, dpi = 600)

#################################################
# SCATTERPLOTS
#################################################
library(binsreg)
binscat <- binsreg(full_combined$insurer_hhi_logged, full_combined$hospital_hhi_logged, 
            by = full_combined$year.f, bycolors = c("red", "blue"), bysymbols = c("circle", "circle"), legendTitle = "Year")

binscat$bins_plot + labs(title="Insurer HHI vs. Hospital HHI, by year", x="Hospital HHI (logged)", 
                         y="Insurer HHI (logged)", color = "Year", symbols = "Year") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/binnedscatter_byyear.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, y=insurer_hhi_logged, color=year.f)) + geom_point() + 
  labs(title="Insurer HHI vs. Hospital HHI, by year", x="Hospital HHI (logged)", y="Insurer HHI (logged)", color="Year") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/scatter_byyear.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, y=insurer_hhi_logged, color=year.f)) + geom_smooth(method="lm") + 
  labs(title="Insurer HHI vs. Hospital HHI, by year", x="Hospital HHI (logged)", y="Insurer HHI (logged)", color = "Year") + 
    theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/smoothedscatter_byyear.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, y=insurer_hhi_logged, color=region.f)) + geom_point() + 
  labs(title="Insurer HHI vs. Hospital HHI, by region", x="Hospital HHI (logged)", y="Insurer HHI (logged)", color = "Region") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/scatter_byregion.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, y=insurer_hhi_logged, color=region.f)) + geom_smooth(method="lm") + 
  labs(title="Insurer HHI vs. Hospital HHI, by region", x="Hospital HHI (logged)", y="Insurer HHI (logged)", color="Region") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/smoothedscatter_byregion.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_hospitals, y=num_insurers, color=year.f)) + geom_point() + 
  labs(title="Insurer HHI vs. Hospital HHI, by year", x="Number of Hospitals", y="Number of Insurers", color="Year") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/scatter_byyear_num.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_hospitals, y=num_insurers, color=year.f)) + geom_smooth(method="lm") + 
  labs(title="Number of Insurers vs. Number of Hospitals, by year", x="Number of Hospitals", y="Number of Insurers", color = "Year") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/smoothedscatter_byyear_num.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_hospitals, y=num_insurers, color=region.f)) + geom_point() + 
  labs(title="Number of Insurers vs. Number of Hospitals, by region", x="Number of Hospitals", y="Number of Insurers", color = "Region") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/scatter_byregion_num.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=num_hospitals, y=num_insurers, color=region.f)) + geom_smooth(method="lm") + 
  labs(title="Smoothed Scatterplot, Number of Insurers vs. Number of Hospitals", x="Number of Hospitals", y="Number of Insurers", color="Region") + 
  theme_stata(scheme="s2color") + theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "../paper/graphs/smoothedscatter_byregion_num.png", height = 4, width = 5.5, dpi = 600)

# #################################################
# # BINSCATTER PLOTS
# #################################################
# 
# binscat <- binsreg(full_combined$insurer_hhi_logged, full_combined$hospital_hhi_logged, 
#                    w=data.frame(c(full_combined$rating_area.f), c(full_combined$year.f), c(full_combined$rucc_code_13), c(full_combined$median_age), 
#                                 c(full_combined$black_popn_percent), c(full_combined$native_popn_percent), c(full_combined$white_popn_percent)))
# 
# binscat$bins_plot + labs(title="Binned scatterplot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", 
#                          y="Insurer HHI (logged)") + theme_stata(scheme="s2color") 
# 
# ggsave(filename = "../paper/graphs/binscatter_results.png", height = 4, width = 5.5, dpi = 600)
# 
# binscat_bivariate <- binsreg(full_combined$insurer_hhi_logged, full_combined$hospital_hhi_logged)
# 
# binscat_bivariate$bins_plot + labs(title="Binned scatterplot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", 
#                                    y="Insurer HHI (logged)") + theme_stata(scheme="s2color") 
# 
# ggsave(filename = "../paper/graphs/binscatter_bivariate_results.png", height = 4, width = 5.5, dpi = 600)
# 
# binscat <- binsreg(full_combined$num_insurers, full_combined$num_hospitals, 
#                    w=data.frame(c(full_combined$rating_area.f), c(full_combined$year.f), c(full_combined$rucc_code_13), c(full_combined$median_age), 
#                                 c(full_combined$black_popn_percent), c(full_combined$native_popn_percent), c(full_combined$white_popn_percent)))
# 
# binscat$bins_plot + labs(title="Binned scatterplot, Number of Insurers vs. Number of Hospitals", x="Number of Hospitals", 
#                          y="Number of Insurers") + theme_stata(scheme="s2color") 
# 
# ggsave(filename = "../paper/graphs/binscatter_results_num.png", height = 4, width = 5.5, dpi = 600)
# 
# binscat_bivariate <- binsreg(full_combined$num_insurers, full_combined$num_hospitals)
# 
# binscat_bivariate$bins_plot + labs(title="Binned scatterplot, Number of Insurers vs. Number of Hospitals", x="Number of Hospitals", 
#                                    y="Number of Insurers") + theme_stata(scheme="s2color") 
# 
# ggsave(filename = "../paper/graphs/binscatter_bivariate_results_num.png", height = 4, width = 5.5, dpi = 600)
# 
# #################################################
# # EFFECT PLOTS
# #################################################
# 
# overall_effect_plot <- effect_plot(model_full, hospital_hhi_logged, rug = TRUE, interval = FALSE, data = full_combined)
# 
# overall_effect_plot + labs(title="Effect Plot, Insurer HHI vs. Hospital HHI", x="Hospital HHI (logged)", 
#   y="Insurer HHI (logged)") + theme_stata(scheme="s2color") 
# 
# ggsave(filename = "../paper/graphs/effectplot_mainresults.png", height = 4, width = 5.5, dpi = 600)
# 
# make_effect_plots <- function(x, y) {
#   effect_plot <- effect_plot(x, hospital_hhi_logged, rug=TRUE)
#   effect_plot <- effect_plot + labs(title=y, 
#     x="Hospital HHI (logged)", y="Insurer HHI (logged)") + theme_stata(scheme="s2color")
#   return(effect_plot)
# }
# 
# effect_plot_2015 <- make_effect_plots(model_14_15, "2014-2015")
# effect_plot_2016 <- make_effect_plots(model_15_16, "2015-2016")
# 
# ggarrange(effect_plot_2015, effect_plot_2016)
# ggsave(filename = "../paper/graphs/effectplot_yearresults.png", height = 4, width = 5.5, dpi = 1000)
# 
# west_effect_plot <- make_effect_plots(model_west, "West")
# south_effect_plot <- make_effect_plots(model_south, "South")
# northeast_effect_plot <- make_effect_plots(model_northeast, "Northeast")
# northcentral_effect_plot <- make_effect_plots(model_northcentral, "North Central")
# 
# ggarrange(northeast_effect_plot, northcentral_effect_plot, south_effect_plot, west_effect_plot)
# ggsave(filename = "../paper/graphs/effectplot_regionresults.png", height = 4, width = 5.5, dpi = 1000)
# 
# overall_effect_plot <- effect_plot(model_num_full, num_hospitals, rug = TRUE, data = full_combined)
# 
# overall_effect_plot + labs(title="Effect Plot, Insurer HHI vs. Number of Hospitals", x="Number of Hospitals", 
#                            y="Number of Insurers") + theme_stata(scheme="s2color") 
# 
# ggsave(filename = "../paper/graphs/effectplot_mainresults_num.png", height = 4, width = 5.5, dpi = 600)
# 
# make_effect_plots <- function(x, y) {
#   effect_plot <- effect_plot(x, num_hospitals, rug=TRUE)
#   effect_plot <- effect_plot + labs(title= y, x="Number of Hospitals", y="Number of Insurers") + theme_stata(scheme="s2color")
#   return(effect_plot)
# }
# 
# effect_plot_2015 <- make_effect_plots(model_num_14_15, "2014-2015")
# effect_plot_2016 <- make_effect_plots(model_num_15_16, "2015-2016")
# 
# ggarrange(effect_plot_2015, effect_plot_2016)
# ggsave(filename = "../paper/graphs/effectplot_yearresults_num.png", height = 4, width = 5.5, dpi = 1000)
# 
# west_effect_plot <- make_effect_plots(model_num_west, "West")
# south_effect_plot <- make_effect_plots(model_num_south, "South")
# northeast_effect_plot <- make_effect_plots(model_num_northeast, "Northeast")
# northcentral_effect_plot <- make_effect_plots(model_num_northcentral, "North Central")
# 
# ggarrange(northeast_effect_plot, northcentral_effect_plot, south_effect_plot, west_effect_plot)
# ggsave(filename = "../paper/graphs/effectplot_regionresults_num.png", height = 4, width = 5.5, dpi = 1000)
# 

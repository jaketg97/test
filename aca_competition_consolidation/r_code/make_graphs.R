setwd("../paper/graphs")

ggplot(data = full_combined, aes(x=insurer_hhi_logged, color=year.f, fill=year.f)) + 
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))), alpha=.1) + 
  labs(title="Insurer HHI, by year", color="Year:", fill="Year:", y="Percent", x="Insurer HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "hist_year_insurerhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, color=year.f, fill=year.f)) + 
  geom_histogram(aes(y = (..count..)/sum(..count..)), alpha=.1) + 
  labs(title="Hospital HHI, by year", color="Year:", fill="Year:", y="Percent", x="Hospital HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "hist_year_hospitalhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=insurer_hhi_logged, color=region.f)) + 
  geom_density(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                        ..count..[..group..==2]/sum(..count..[..group..==2]), 
                        ..count..[..group..==3]/sum(..count..[..group..==3]), 
                        ..count..[..group..==4]/sum(..count..[..group..==4]))*100)) + 
  labs(title="Insurer HHI, by region", color="Region:", y="Count", x="Insurer HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "kd_region_insurerhhi.png", height = 4, width = 5.5, dpi = 600)

ggplot(data = full_combined, aes(x=hospital_hhi_logged, color=region.f)) + 
  geom_density(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                       ..count..[..group..==2]/sum(..count..[..group..==2]), 
                       ..count..[..group..==3]/sum(..count..[..group..==3]), 
                       ..count..[..group..==4]/sum(..count..[..group..==4])))) + 
  labs(title="Hospital HHI, by region", color="Region:", y="Count", x="Hospital HHI (logged)") + theme_stata(scheme="s2color") + 
  theme(legend.key.size = unit(0.2, "cm"), legend.title = element_text(size=10))

ggsave(filename = "kd_region_hospitalhhi.png", height = 4, width = 5.5, dpi = 600)




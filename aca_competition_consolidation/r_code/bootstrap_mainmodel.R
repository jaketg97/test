library(car)
library(boot)

rm(list=ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

full_14_15 <- read.csv("../clean_data/full_14_15.csv")
full_15_16 <- read.csv("../clean_data/full_15_16.csv")
full_combined <- read.csv("../clean_data/full_combined.csv")
full_combined$year_dummy <- ifelse(full_combined$year == 2016, 1, 0)
full_combined$rucc.f <- Recode(full_combined$rucc_code_13, "1:3 = '1-3'; 4:6 = '4-6'; 7:9 = '7-9'")
full_combined$no_hospitals <- as.integer(full_combined$no_hospitals)
full_combined <- na.omit(full_combined)
full_combined <- subset(full_combined, single_county_RA==FALSE) #subsetting outside of model, or Boot gets upset
model_full <- lm(insurer_hhi_logged~hospital_hhi_logged*year_dummy+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+rating_area.f*year_dummy+medicare_pc, data=full_combined)

bs <- function(formula, data, indices) {
  d <- data[indices,] # allows boot to select sample 
  fit <- lm(formula, data=d)
  return(summary(fit)$coefficients[2]) 
} 
set.seed(2232021)
boot_coef <- boot(data=full_combined, statistic=bs, R=5000, formula = insurer_hhi_logged~hospital_hhi_logged*year_dummy+no_hospitals+white_popn_percent+black_popn_percent+native_popn_percent+poverty_rate+median_age+rucc_code_13+rating_area.f*year_dummy+medicare_pc)
boot.ci(boot_coef, type="perc", conf=.99)
summary(boot_coef)
coef <- data.frame(boot_coef$t)
colnames(coef) <- c("coef")

ggplot(data = coef, aes(x=coef)) +
  geom_histogram(aes(y=..count../sum(..count..)), alpha=.4, position = "identity", fill="red", bins = 50) + 
  labs(title="Bootstrapped distribution of coefficient of interest (main model)", y="Percent", x="Coefficient of Hospital HHI (logged)", 
       caption = "Bootstrapped 99% confidence interval: (.013, .071)") +
  theme_stata(scheme="s2color") + theme(plot.title=element_text(size=10)) 
  

ggsave(filename = "../paper/graphs/bootstrap_coef.png", height = 4, width = 5.5, dpi = 600)

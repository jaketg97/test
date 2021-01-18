#################################################
# MASTER FILE
#################################################

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Building clean code
setwd("../raw_data")
source("../r_code/build_insurer_hhi.R")
source("../r_code/build_hospital_hhi.R")


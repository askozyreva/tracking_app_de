## This code was used to prepare public anonymized data.
## It requires original data files to run (not included in the public repository) and is included for transparency.

# load packages
if(!require("easypackages")) install.packages("easypackages"); library(easypackages)
packages ("tidyverse", "here", "readr", "sjlabelled", "dplyr", prompt = F)

library(tidyverse)
library(readr)
library(dplyr)
library(here)

source(here('code/functions.R'))

## Import data
dat_path <-
  here("resources/german_tracking_survey_numeric_wave4.csv")
data_4 <- read.csv(dat_path, stringsAsFactors=FALSE, na.strings = "")


dim(data_4)
colnames(data_4)





#remove redundant variables and potentially identifying info
data  <- data_4 %>%
  dplyr::select(-c(starts_with("Recipient"),starts_with("Q_"))) %>%
  dplyr::select(-c(StartDate,EndDate,Status, Progress,RecordedDate,ResponseId,
                   DistributionChannel,UserLanguage,rid,SC0))
dim(data)

data$decline_part_bt =  revscore(data$decline_part_bt,6)

# Rename variables with weird names

data <- data %>%
rename(ahal_abst = Q81_1,
       ahal_hyg = Q81_2,
       ahal_mask= Q81_3,
       ahal_luft = Q81_4,
       wv_freemarket_lim = wv_.freemarket_lim,
       noupload_reasons_all = noupload_reasons.1,
       duration = Duration..in.seconds.)


colnames(data)

write.csv(data, "data/tracking_survey_w4_public.csv")



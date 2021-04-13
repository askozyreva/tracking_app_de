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
  here("resources/german_tracking_survey_numeric_wave3.csv")
covdata <- read.csv(dat_path, stringsAsFactors=FALSE, na.strings = "-99")


dim(covdata)
colnames(covdata)

# remove redundant variables and potentially identifying info
data  <- covdata %>%
  dplyr::select(-c(starts_with("Recipient"),starts_with("Q_"))) %>%
  dplyr::select(-c(StartDate,EndDate,Status, Progress,Duration..in.seconds.,RecordedDate,ResponseId,
                   DistributionChannel,UserLanguage,rid,SC0, free_text))
dim(data)

# recode variables pointing in teh wrong direction

data$reduce_lik_bt = dplyr::recode(data$reduce_lik_bt, `1` = 1, `2` = 2, `3`= 3, `7`= 4, `4` = 5, `5` = 6, .default = NULL)
data$decline_part_bt =  revscore(data$decline_part_bt,6)

# Rename variables with weird names

data  <- data %>%
  rename(wv_freemarket_lim = wv_.freemarket_lim)

colnames(data)

write.csv(data, "data/tracking_survey_w3_public.csv")

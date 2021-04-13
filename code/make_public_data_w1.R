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
  here("resources/german_tracking_survey_numeric_wave1.csv")
covdata <- read.csv(dat_path, stringsAsFactors=FALSE, na.strings = "")


dim(covdata)
colnames(covdata)

# remove redundant and potentially identifying variables
data  <- covdata %>%
  dplyr::select(-c(starts_with("Recipient"),starts_with("Q_"))) %>%
  dplyr::select(-c(StartDate,EndDate,Status, Progress,Duration..in.seconds.,RecordedDate,ResponseId,
                   DistributionChannel,UserLanguage,rid,SC0, free_text))


dim(data)
colnames(data)

# recode variables pointing in teh wrong direction

data$decline_participate=  revscore(data$decline_participate,6)

# Rename variables with weird names
data  <- data %>%
  rename(c(age=age_4,
           COVID_ndays_lockdown=COVID_ndays_lockdown_4,
           reduce_lik_sev=Q284,
           return_activ_mild=Q328,
           return_activ_sev=Q330,
           ability_mild=Q351,
           acc_general_1=Q360_1,
           acc_general_2=Q360_2,
           acc_general_3=Q360_3,
           acc_general_4=Q360_4,
           acc_general_5=Q360_5,
           acc_general_6=Q360_6))

colnames(data)


write.csv(data, "data/tracking_survey_w1_public.csv")

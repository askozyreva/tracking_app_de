
if(!require("pacman")) install.packages("pacman"); library(pacman)

p_load("rio", "tidyverse", "expss", "parsedate", "tools","readxl")

library(tidyverse)
library(expss)
library(rio)
library(parsedate)
library(tools)
library(readxl)


revscore <- function (x,mm) {  #this reverse scores a scale for items of reversed polarity
  return ((mm+1)-x)            ## variables passed to the fucntion by POSITIOn  not by name
}
# Give rounded percentage
Per = function( d, i, r){
  if (missing(r) == TRUE){
    r = 0
  }
  round( (sum(d == i, na.rm=T) / length(d) * 100), r )
}
# Calculate the mode
mode <- function(x) {
  uniqv <- unique(x)
  uniqv[which.max(tabulate(match(x, uniqv)))]
}
# Calculate rounded mean & sd - for mkdown report writing.
m = function(x, dp) {
  if (missing(dp)){dp=0}
  k = round(mean(x, na.rm = T),dp)
  return(k)
}
s = function(x, dp) {
  if (missing(dp)){dp=0}
  k = round(sd(x, na.rm=T),dp)
  return(k)
}


fnc_perc <- function(x) {
  # function that rounds numbers nicely:
  # [adding up rounded percentages to equal 100%](http://dochoffiday.com/professional/adding-up-rounded-percentages-to-equal-100)

  # floor-round percentages
  perc_floor <- floor(100 * x)

  # calculate how many percentage points need to be topped up
  top_up <- 100 - sum(perc_floor)

  # order percentages according to their decimal value
  top_up_indices <-
    order(100 * x - perc_floor, decreasing = TRUE)[1:top_up]

  # top up the floor-rounded percentages
  perc <- perc_floor
  perc[top_up_indices] <- perc[top_up_indices] + 1

  # check
  expect_equal(sum(perc), 100)

  return(perc)
}
#fnc_perc(c(.405, .206, .389))

fnc_perc2 <- function(x) {
  # function that rounds numbers nicely:
  # [adding up rounded percentages to equal 100%](http://dochoffiday.com/professional/adding-up-rounded-percentages-to-equal-100)

  # floor-round percentages
  perc_floor <- floor(100 * x)

  # calculate how many percentage points need to be topped up
  top_up <- 100 - sum(perc_floor)

  # order percentages according to their decimal value
  top_up_indices <-
    order(100 * x - perc_floor, decreasing = TRUE)[1:top_up]

  # top up the floor-rounded percentages
  perc <- perc_floor
  perc[top_up_indices] <- perc[top_up_indices] + 1


  return(perc)
}
#fnc_perc(c(.405, .206, .389))


# Function for loading in world COVID stats using a specified list of countries within a given date range.
# If no countries are specified, Australia is returned by default between Jan 1st 2020 - May 1st 2020.
WorldCOVIDdata = function(Countries, StartDate, EndDate){
  #Countries = c('Australia', 'United_Kingdom', 'United_States_of_America', 'Taiwan', 'Germany', 'China')
  if( missing(Countries) ){ Countries = c('Australia') }
  if( missing(StartDate) ){ StartDate = '2020-01-01' }
  if( missing(EndDate) ){ EndDate = '2020-05-01' }
  WorldCOVID = rio::import('https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx') %>%
    arrange( countriesAndTerritories, year, month, day ) %>%
    group_by(countriesAndTerritories) %>%
    mutate(cases.cum = cumsum(cases), deaths.cum = cumsum(deaths), dateRep = as.Date(dateRep, format = '%d/%m/%Y')) %>%
    select( -c( day, month, year, geoId ) ) %>%
    rename(date = dateRep, country = countriesAndTerritories, code = countryterritoryCode)
  WorldCOVID = complete(WorldCOVID, date = seq.Date(min(WorldCOVID$date), max(WorldCOVID$date), by='day') ) %>%
    group_by(country) %>% fill(cases, deaths, code, cases.cum, deaths.cum)
  WorldSubset = subset(WorldCOVID, country %in% Countries) %>% filter(date >= StartDate & date <= EndDate)
  return(WorldSubset)
  #WorldSubset = subset(WorldCOVID, country %in% Countries) %>% filter(date >= '2020-03-10')
}
# Returns a select sample of data for a single country on a single date. Dates are formatted for easy plotting.
# If not country is specified, all countries will be returned for the given date.
COVIDbyCountry = function(SelectedDate, Country){
  # Date format: '%Y-%m-%d'
  if( missing(Country) ){ Country = FALSE }
  WorldCOVID = rio::import('https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx') %>%
    arrange( countriesAndTerritories, year, month, day ) %>%
    group_by(countriesAndTerritories) %>%
    mutate(cases.cum = cumsum(cases), deaths.cum = cumsum(deaths), dateRep = as.Date(dateRep, format = '%d/%m/%Y')) %>%
    select( -c( day, month, year, geoId ) ) %>%
    rename(date = dateRep, country = countriesAndTerritories, code = countryterritoryCode)
  WorldCOVID = complete(WorldCOVID, date = seq.Date(min(WorldCOVID$date), max(WorldCOVID$date), by='day') ) %>%
    group_by(country) %>% fill(cases, deaths, code, cases.cum, deaths.cum)
  if (Country == FALSE){ WorldCOVID %<>% filter( date == SelectedDate )
  } else { WorldCOVID %<>% filter( date == SelectedDate & country == Country) }
  WorldCOVID %<>% select( country, date, deaths.cum, cases.cum, cases, deaths ) %>%
    rename( Deaths = deaths.cum, Cases = cases.cum, DailyDeaths = deaths, DailyCases = cases, Date = date, Country = country )
}

center_scale <- function(x) {
  scale(x, scale = FALSE)
}



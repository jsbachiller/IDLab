
# - Load packages --------------------------------------------------------------
library(tidyverse)
library(rvest)

# - Scraper --------------------------------------------------------------------
## Define url to scrape from (in our case, 30-days weather forecast for SPb)
source_url <- "https://www.gismeteo.com/weather-sankt-peterburg-4079/month/"

## Get the data

read_html(source_url) %>% 
  # retrieve the date
  html_elements(".date") %>%
  # in a readable format
  html_text() -> days

read_html(source_url) %>% 
  # Maximum temperature...
  html_elements(".maxt") %>% 
  # ... in degrees celsius
  html_elements(".unit_temperature_c") %>% html_text() -> max_temps

read_html(source_url) %>% 
  # Same for minimum
  html_elements(".mint") %>% 
  html_elements(".unit_temperature_c") %>% html_text() -> min_temps

## Build up our small new dataset
tibble(date = days, min = min_temps, max = max_temps) -> weather_data

View(weather_data)

# - Data cleaning --------------------------------------------------------------

## Dates are not useful the way they are, could easily confuse us, so let's 
## create a proper date variable 
weather_data %>%
  
  # Separate the column where the webpage date is stored into month and day
  separate(date, into = c("day", "month"), sep = " ") %>%
  # Since month is only present at its beginning, we carry it down
  fill(month, .direction = "down") %>%
  # Format date properly. "b" stands for non-numerically-defined month
  mutate(date = as.Date(paste0(day, month), "%d%b")) %>%
  # We don't really need anymore the "day" and "months" variables
  select(-day, -month) -> weather_data

View(weather_data)

## Now we can conduct any analysis on this data.

# - More stuff on scraping and cleaning ----------------------------------------

## The data we have  so far is pretty simple and can tell us only so much about 
## the weather. However, we could also try to get information on whether it will
## be rainy, snowy or just cloudy (living in SPb we could almost assume "sunny" 
## out of the list).


## Re-using the former connection to the webpage, we find the weather icons
read_html(source_url) %>% 
  html_elements(".icon") %>% 
  # We want to get their internal naming to be able to parse it into datapoints
  html_children() %>% 
  html_children() %>% 
  html_attrs() %>%
  unlist() -> sky

tibble(date = days, min = min_temps, max = max_temps, sky = sky[-1]) -> weather_data

weather_data %>%
  mutate(day = str_sub(date, 1, 2))

weather_data %>%
  
# Create a proper date variable -------
  # Separate the column where the webpage date is stored into month and day
  separate(date, into = c("day", "month"), sep = " ") %>%
  # Since month is only present at its beginning, we carry it down
  fill(month, .direction = "down") %>%
  # Format date properly. "b" stands for non-numerically-defined month
  mutate(date = as.Date(paste0(day, month), "%d%b")) %>%

# Define actual weather ---------------
  # Drop non-needed characters and homogenize
  mutate(
    sky = str_sub(sky, 2),
    sun = ifelse(str_sub(sky, 1, 1) == "d", 1, 0),
    n_events = str_count(sky, "_"),
    clouds = case_when(
      sun != 0 & n_events == 1 ~ str_sub(sky, 4, 4) ,
      sun == 0 & n_events == 0 ~ str_sub(sky, 2, 2) ,
      sun == 0 & n_events == 1 ~ str_sub(sky, 2, 2),
      n_events == 2 ~ str_sub(sky, 4, 4)
    ),
    precipitation = case_when(
      str_detect(sky, "r") ~ "rain",
      str_detect(sky, "s") ~ "snow",
      TRUE ~ "none"
    ),
    precipitation = ifelse(str_detect(sky, "rs"), "slush", precipitation)
  ) -> final_data






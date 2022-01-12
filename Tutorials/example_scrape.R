# ------------------------------------------------------------------------------
# - Data management with R and RStudio: Examples -------------------------------
# ------------------------------------------------------------------------------
# - Javier Sánchez Bachiller - IDLab - HSE -------------------------------------
# ------------------------------------------------------------------------------

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

## However, temperature is still treated as character, but in order to work with 
## it we would need numbers.

weather_data %>%
  mutate(max = as.numeric(str_replace(max, "−", "-"))) %>%
  mutate(min = as.numeric(str_replace(min, "−", "-"))) -> weather_data

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
  select(-day, -month) -> weather_data_clean

View(weather_data_clean)

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

cbind(weather_data, sky = sky[-1]) -> weather_data

weather_data %>%
  
# Create a proper date variable -------
  # Separate the column where the webpage date is stored into month and day
  separate(date, into = c("day", "month"), sep = " ") %>%
  # Since month is only present at its beginning, we carry it down
  fill(month, .direction = "down") %>%
  # Format date properly. "b" stands for non-numerically-defined month
  mutate(date = as.Date(paste0(day, month), "%d%b")) %>%
  mutate(week_day = weekdays(date)) %>%
  
# Define actual weather ---------------
  # Drop non-needed characters and create variables out of the strings
  mutate(
    # Drop hash at the beginning
    sky = str_sub(sky, 2),
    
    # Identify whether sun will be at all seen during the day
    sun = ifelse(str_sub(sky, 1, 1) == "d", 1, 0),
    
    # Retrieve the level of cloudiness
    n_events = str_count(sky, "_"),
    clouds = case_when(
      # If clear day
      sun != 0 & n_events == 0 ~ "0",
      # If partially cloudy day, no rain
      sun != 0 & n_events == 1 ~ str_sub(sky, 4, 4),
      # If totally cloudy, no rain
      sun == 0 & n_events == 0 ~ str_sub(sky, 2, 2),
      # If totally cloudy, possible rain
      sun == 0 & n_events == 1 ~ str_sub(sky, 2, 2),
      # If partially cloudy day, possible rain
      n_events == 2            ~ str_sub(sky, 4, 4)
    ),
    clouds = as.numeric(clouds)/4,

    # Retrieve precipitation levels and type
    precipitation = case_when(
      str_detect(sky, "r") ~ "rain",
      str_detect(sky, "s") ~ "snow",
      TRUE ~ "none"
    ),
    precipitation = ifelse(str_detect(sky, "rs"), "slush", precipitation),
    
    prec_intensity = as.numeric(
      ifelse(
        precipitation == "none", 
        0,
        str_sub(sky, str_length(sky), str_length(sky))
        )
      )/4
  ) %>%
  select(-sky, -n_events) %>% 
  write_csv("Tutorials/exampleData.csv")






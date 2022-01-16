# ------------------------------------------------------------------------------
# - Data management with R and RStudio: Examples -------------------------------
# ------------------------------------------------------------------------------
# - Javier Sánchez Bachiller - IDLab - HSE -------------------------------------
# ------------------------------------------------------------------------------

# - Load packages and data -----------------------------------------------------
library(tidyverse)

path_to_data = "Tutorials/exampleData.csv"
weather_data <- read_csv(path_to_data)

View(weather_data)


## Let's focus for now on the temperature, we know in SPb we always have to be
## ready for rain. Thus, the dataset has more columns than we would want to. We
## can keep just a bunch of them by using select()

weather_data %>%
  select(date, week_day, min, max) -> temp_data

temp_data

## Shoud we be interested only on weekends, we can pick observations with 
## filter() and maybe calculate some things
temp_data %>%
  filter(week_day == "Saturday" | week_day == "Sunday")

## Let's first simply calculate the mean minimum temperature on weekends, in two
## different ways (for the sake of understanding how it works)
temp_data %>%
  filter(week_day == "Saturday" | week_day == "Sunday") %>%
  summarise(
    mean_min_1step = mean(min),
    sum_min = sum(min),
    count = n(),
  ) %>%
  mutate(
    mean_min_2steps = sum_min/count
  )
  
## 'Summarise' condenses the dataset into summary statistics. Another example 
## would be to find the coldest temperature of the dataset. For this, we could either 
## just arrange the data or use summarise() to get the minimum temperature:

temp_data %>% 
  arrange(min) %>%
  head() #the head() command shows the first 5 lines of a tibble

temp_data %>% 
  summarise(coldest = min(min))

## As we can see, summarise() drops all non-called columns. We might want, 
## for example, to keep the mean along with the rest of the data to compare it
## to the other days. We do this with the mutate() command, which performs 
## vectorised operations. Let's focus on the minimum temperature again

temp_data %>%
  mutate(mean_min = mean(min)) %>%
  mutate(deviation_min = abs(mean_min - min))

## Mutate can use most R functions and apply them already vectorized to the 
## dataset. We could be interested in knowing the mean temperature's daily 
## change:

temp_data %>%
  mutate(
    mean_temp = (min + max)/2
  ) %>%
  arrange(date) %>%
  mutate(
    temp_change = mean_temp - lag(mean_temp, 1)
  ) -> temp_changes

## Given that we get NA in the first row, we cannot use the same codes above to
## retrieve summary stats, as these commands are by default affected by them. 
## However, we do not need to drop them, but just to activate the option of not
## considering the NAs when perfoming operations with 'na.rm = TRUE'

temp_changes %>%
  summarise(
    mean_change = mean(temp_change, na.rm = TRUE),
    median_change = median(temp_change, na.rm = TRUE),
    max_change = max(temp_change, na.rm = TRUE),
    min_change = min(temp_change, na.rm = TRUE)
  )
  
## However, the true power of tidyverse resides in the fact that it can do these
## operations group-wise as well. Let's get the minimum temperature for each day
## of the week...

temp_data %>%
  group_by(week_day) %>%
  summarise(min_temp = min(min))

## ... or the weekly temperature change by just adding a line of code

temp_data %>%
  mutate(
    mean_temp = (min + max)/2
  ) %>%
  group_by(week_day) %>%
  arrange(date) %>%
  mutate(
    temp_change = mean_temp - lag(mean_temp, 1)
  ) -> temp_changes_weekly

# ------------------------------------------------------------------------------

# annual-number-of-deaths-by-cause

# import raw data
db_annual_deaths <- readr::read_csv("data-raw/annual-number-of-deaths-by-cause.csv")

db_annual_deaths |> 
  names()

# select useful columns only

db_annual_deaths_clean <- db_annual_deaths |> 
  dplyr::select("Entity", "Code", "Year",
                "Deaths - Environmental heat and cold exposure - Sex: Both - Age: All Ages (Number)",
                "Deaths - Lower respiratory infections - Sex: Both - Age: All Ages (Number)",
                "Deaths - Exposure to forces of nature - Sex: Both - Age: All Ages (Number)",
                "Deaths - Chronic respiratory diseases - Sex: Both - Age: All Ages (Number)"
                ) |> 
  janitor::clean_names() |> 
  # names()
  dplyr::rename(
    "qnt_death_heat_cold_exposure" = 4,
    "qnt_death_lower_respiratory_infections" = 5,
    "qnt_death_exposure_to_forces_of_nature" = 6,
    "qnt_death_chronic_respiratory_diseases" = 7
  )

# filter only Germany

# check if is there only 1 Germany
db_annual_deaths_clean |> 
  dplyr::count(entity) |> 
  tibble::view() 

# db_annual_deaths_clean |> 
#   dplyr::filter(stringr::str_detect(entity, "Germany")) |> 
#   tibble::view()

# not necessary, because even though there are 3 Germany, only "Germany"
# has data

db_annual_deaths_clean_germany <- db_annual_deaths_clean |> 
  dplyr::filter(entity == "Germany")


# Plot --------------------------------------------------------------------
library(ggplot2)

db_annual_deaths_clean_germany |> 
  tidyr::pivot_longer(cols = 4:7) |> 
  ggplot(aes(y = value, x = year)) +
  geom_line(aes(color = name))


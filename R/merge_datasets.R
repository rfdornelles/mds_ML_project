# testing the merged datased

# temperature
temp_df <- readr::read_csv("data-raw/nasa_temperature.csv") |> 
  janitor::clean_names() |> 
  dplyr::select(year, glob, n_hem, x24n_90n)

# german pop

wb_pop <- readr::read_csv("data-raw/WBI_population_API_SP.POP.TOTL_DS2_en_csv_v2_4701113.csv",
                          skip = 4) 

wb_pop <- wb_pop |> 
  dplyr::filter(`Country Name` == "Germany") |> 
  dplyr::select(-1:-4) |> 
  tidyr::pivot_longer(
    col = dplyr::everything(), 
    values_to = "population")

# deaths by heat/cold

#TODO decide if we use all columns
#TODO decide if Germany only should be used, or all countries, or all except
db_annual_deaths <- readr::read_csv("data-raw/annual-number-of-deaths-by-cause.csv")

db_annual_deaths <- db_annual_deaths |> 
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

db_annual_deaths <- db_annual_deaths |> 
  dplyr::select(-1:-2) |> 
  dplyr::group_by(year) |> 
  dplyr::summarise(
    dplyr::across(.fns = sum, na.rm = TRUE)
  )

# deaths germany
deaths_germany <- readr::read_csv("data/german_deaths.csv") |> 
  janitor::clean_names()

# projected pop (predict?)
readr::read_csv("data/Projected German Population 2050.csv")
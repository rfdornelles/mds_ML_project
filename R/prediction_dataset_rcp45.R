# boundaries 
# https://data.humdata.org/dataset/bounding-boxes-for-countries
boundaries <- readr::read_csv("data-raw/country-boundingboxes.csv") |> 
  dplyr::select(1, 3:6)

###

ncfile <- "data-raw/mean_Tmean_Yearly_rcp45_mean_v1.0.nc"

rcp45 <- tidync::tidync(ncfile)

time_nc <- rcp45 |>  
  tidync::activate("D2") |> 
  tidync::hyper_array()

tunit <- ncmeta::nc_atts(ncfile, "time") |> 
  tidyr::unnest(cols = c(value)) |> 
  dplyr::filter(name == "units")

time_parts <- RNetCDF::utcal.nc(tunit$value, time_nc$time)

# ## convert to date-time
# ISOdatetime(time_parts[,"year"], 
#             time_parts[,"month"], 
#             time_parts[,"day"], 
#             time_parts[,"hour"], 
#             time_parts[,"minute"], 
#             time_parts[,"second"])

years_ref <- tibble::tibble(
  time = time_nc$time,
  year = time_parts[,"year"]
)

rcp45_tibble <- rcp45 |> 
  tidync::activate("mean_Tmean_Yearly") |> 
  tidync::hyper_tibble() 

# getting the boundaries
json_url <- "https://gist.githubusercontent.com/cplpearce/3bc5f1e9b1187df51d2085ffca795bee/raw/b36904c0c8ea72fdb82f68eb33f29891095deab3/country_codes"

json <- jsonlite::fromJSON(json_url, flatten = TRUE)

json_boundaries <-names(json) |> 
  purrr::map_df(.f = ~{
    
    json |> 
      purrr::pluck(.x) |> 
      purrr::pluck("boundingBox") |> 
      purrr::flatten_dfc() |> 
      dplyr::mutate(
        country = .x
      )
  }
  )

codes <- names(json) |> 
  purrr::map_df(.f = ~{
  
    json |> 
      purrr::pluck(.x) |> 
      purrr::pluck("name") |> 
      tibble::as_tibble() |> 
    #  purrr::flatten_dfc() |> 
      dplyr::mutate(
        code = .x
      )
  }
  )

boundaries <- json_boundaries |> 
  dplyr::rename(
    latmin = `lat...1`,
    longmin = `lon...2`,
    latmax = `lat...3`,
    longmax = `lon...4`
  ) |> 
  dplyr::mutate(
    dplyr::across(
      where(is.numeric),
      round, 1
  )
  )

temp_countries <- purrr::map_df(
  .x = 1:nrow(boundaries),
  .f = ~{
  i = .x
  
  rcp45_tibble |> 
    dplyr::filter(
      lon >= boundaries$longmin[i] & lon <= boundaries$longmax[i] &
        lat >= boundaries$latmin[i] & lon <= boundaries$latmin[i]
    ) |> 
    dplyr::group_by(time) |> 
    dplyr::summarise(
      temp = mean(mean_Tmean_Yearly, na.rm = T)
    ) |> 
    dplyr::mutate(
      country = boundaries$country[i]
    )
})

## merge names
temp_countries <- temp_countries |> 
  dplyr::left_join(codes, by = c("country" = "code"))

## merge years
temp_countries <- temp_countries |> 
  dplyr::left_join(years_ref) |> 
  dplyr::select(
    year, country = value, temp
  ) 

temp_countries <- temp_countries |> 
  dplyr::filter(year > 2019)

## merge population
wb_pop <- readr::read_csv("data-raw/wb_PopulationProjection.csv") 

wb_pop <- wb_pop |> 
  dplyr::rename(country = `Country Name`, code = `Country Code`) |> 
  tidyr::pivot_longer(
    cols = c(-1:-2),
    values_to = "population",
    names_to = "year"
  ) |> 
  dplyr::mutate(
    year = stringr::str_sub(year, 1, 4),
    dplyr::across(
      .cols = c(year, population),
      as.numeric
    )
  )

## deaths

# db_annual_deaths <- readr::read_csv("data-raw/annual-number-of-deaths-by-cause.csv")
# 
# db_annual_deaths <- db_annual_deaths |> 
#   dplyr::select("country" = "Entity", "Code", "Year",
#                 "Deaths - Environmental heat and cold exposure - Sex: Both - Age: All Ages (Number)",
#                 "Deaths - Lower respiratory infections - Sex: Both - Age: All Ages (Number)",
#                 "Deaths - Exposure to forces of nature - Sex: Both - Age: All Ages (Number)",
#                 "Deaths - Chronic respiratory diseases - Sex: Both - Age: All Ages (Number)"
#   ) |> 
#   janitor::clean_names() |> 
#   dplyr::rename(
#     "qnt_death_heat_cold_exposure" = 4,
#     "qnt_death_lower_respiratory_infections" = 5,
#     "qnt_death_exposure_to_forces_of_nature" = 6,
#     "qnt_death_chronic_respiratory_diseases" = 7
#   )

karon_pred <- temp_countries |> 
  dplyr::left_join(wb_pop, by = c("year", "country")) |> 
  # dplyr::left_join(db_annual_deaths) |> 
  dplyr::select(year, 
                country, temp, population) |> 
  na.omit() 
# 
# karon_pred <- karon_pred |> 
#   dplyr::group_by(country) |> 
#   dplyr::arrange(country, year) |> 
#   dplyr::mutate(
#     temp_diff = temp - dplyr::lag(temp, n = 1, default = NA)
#   ) |> 
#   dplyr::filter(!is.na(temp_diff))

# making sure that the datasets are comparable
country_list <- readr::read_csv("data/karon2.csv") |> 
  dplyr::pull(country) |> 
  unique()

karon_pred <- karon_pred |> 
  dplyr::filter(country %in% country_list)

readr::write_csv(karon_pred, "data/pred_y_2022_2050_rcp45.csv") 

# |> 
#   tibble::view() |> 
#   dplyr::filter(is.na(population) | is.na(temp) | is.na(qnt_death_heat_cold_exposure))
  


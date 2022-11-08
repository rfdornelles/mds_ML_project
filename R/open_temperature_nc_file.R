#open temperature datasets

# ref https://ropensci.org/blog/2019/11/05/tidync/

# temp --------------------------------------------------------------------

ncfile <- "data-raw/mean_Tmean_Yearly_rcp45_mean_v1.0.nc"

rcp45 <- tidync::tidync(ncfile)

# rcp45 |> 
#   tidync::activate("mean_Tmean_Yearly") |> 
#   tidync::hyper_tbl_cube()

# ncmeta::nc_grids(ncfile) |> 
#   tidyr::unnest(cols = c(variables))

# ncmeta::nc_atts(ncfile, "time") |> 
#   tidyr::unnest(cols = c(value))

time_nc <- rcp45 |>  
  tidync::activate("D2") |> 
  tidync::hyper_array()

tunit <- ncmeta::nc_atts(ncfile, "time") |> 
  tidyr::unnest(cols = c(value)) |> 
  dplyr::filter(name == "units")

time_parts <- RNetCDF::utcal.nc(tunit$value, time_nc$time)

## convert to date-time
ISOdatetime(time_parts[,"year"], 
            time_parts[,"month"], 
            time_parts[,"day"], 
            time_parts[,"hour"], 
            time_parts[,"minute"], 
            time_parts[,"second"])


years_ref <- tibble::tibble(
   time = time_nc$time,
   year = time_parts[,"year"]
   )

# https://latitude.to/map/de/germany

# long: > 5.4, long < 15.2
# lat < 55, lat 47.25

temperature_rcp_45 <- rcp45 |> 
  tidync::activate("mean_Tmean_Yearly") |> 
  tidync::hyper_tibble() |> 
  dplyr::filter(
    lon >= 5.4 & lon <= 15.2,
    lat <= 55 & lat >= 47.2
  ) |> 
  dplyr::select(time, temp = 1)

temp_rcp_45 <- temperature_rcp_45 |> 
  dplyr::group_by(time) |> 
  dplyr::summarise(
    temp = mean(temp, na.rm = T),
    .groups = "drop"
  ) |> 
  dplyr::left_join(years_ref, by = "time") |> 
  dplyr::select(year, temp_rcp_45 = temp)

readr::write_csv(temp_rcp_45, "data/temp_rcp_45.csv")

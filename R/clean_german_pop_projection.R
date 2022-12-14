## wrangling population projection

db_projection <- readr::read_csv2(
  "data-raw/12421-00021_Projected German Population 2050.csv",
  skip = 7
  )

# drop columns
db_projection_clean <- db_projection |> 
  dplyr::select(-1,-2) 

# rename columns

db_projection_clean <- db_projection_clean |> 
  dplyr::rename("gender" = 1,
                "age" = 2)

# drop total lines
db_projection_clean <- db_projection_clean |> 
  dplyr::filter(gender != "Total" & age != "Total")

# clean age to have only numbers
db_projection_clean |> 
  dplyr::distinct(age)

db_projection_clean <- db_projection_clean |> 
  dplyr::mutate(
    # remove the "year+/over/under, etc"
    age = dplyr::case_when(
      age == "under 1 year" ~ "0",
      age == "100 years and over" ~ "100",
      TRUE ~ stringr::str_remove(age, "year.*")
    ),
    # transform in numeric
    age = as.numeric(age), 
    
    # group the ages
    # break in discrete intervals - mocking categories just to try
    age = dplyr::case_when(
      # age <= 15 ~ "under 15",
      # age > 15 & age <= 30 ~ "15 to 30",
      # age > 30 & age <= 65 ~ "30 to 65",
      # age > 65 & age <= 80 ~ "65 to 80",
      # age > 80 ~ "80+",
      # TRUE ~ as.character(age)
      age <= 25 ~ "age_0_25",
      age > 25 & age <= 50 ~ "age_26_50",
      age > 50 & age <= 75 ~ "age_51_75",
      age > 75 ~ "age_75_100" 
    )
  ) 


# pivot to have years in the rows

db_projection_clean <- db_projection_clean |> 
  tidyr::pivot_longer(cols = dplyr::starts_with("2"), 
                      names_to = "year") 

# merging the similar categories
db_projection_clean <- db_projection_clean |> 
  dplyr::group_by(gender, age, year) |> 
  dplyr::summarise(value = sum(value, na.rm = TRUE), .groups = "drop")


# pivot to have age in the columns
db_projection_clean <- db_projection_clean |> 
  tidyr::pivot_wider(names_from = c(age, gender), values_from = value)


# cleaning year
db_projection_clean <- db_projection_clean |> 
  dplyr::mutate(
    year = stringr::str_sub(year, 0, 4)
  )


# Exporting ---------------------------------------------------------------

readr::write_csv(db_projection_clean, 
                 file = "data/Projected German Population 2050.csv")

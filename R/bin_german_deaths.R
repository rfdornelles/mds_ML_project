## German deaths binning


german_deaths <- readr::read_csv(
  "data/German_deaths_output_binninngNeeded.csv")

# bin the ages
german_deaths <- german_deaths |> 
  dplyr::mutate(
    Age_Demographic = dplyr::case_when(
      # age <= 15 ~ "under 15",
      # age > 15 & age <= 30 ~ "15 to 30",
      # age > 30 & age <= 65 ~ "30 to 65",
      # age > 65 & age <= 80 ~ "65 to 80",
      # age > 80 ~ "80+",
      # TRUE ~ as.character(age)
      Age <= 25 ~ "age_0_25",
      Age > 25 & Age <= 50 ~ "age_26_50",
      Age > 50 & Age <= 75 ~ "age_51_75",
      Age > 75 ~ "age_75_100"
    ),
    # transform in numeric
    dplyr::across(dplyr::ends_with("Germans"), as.numeric)
)

# pivoting

# drop the Age column
german_deaths <- german_deaths |> 
  dplyr::select(-Age) 


# group and sum
german_deaths <- german_deaths |> 
  dplyr::group_by(Year, Age_Demographic) |> 
  dplyr::summarise(.groups = "drop",
    Male_Germans = sum(Male_Germans, na.rm = TRUE),
    Female_Germans = sum(Female_Germans, na.rm = TRUE)
  )

# pivot wider
german_deaths <- german_deaths |> 
  tidyr::pivot_wider(names_from = "Age_Demographic", 
                     values_from = dplyr::ends_with("Germans"))


# Export ------------------------------------------------------------------

readr::write_csv(german_deaths, "data/german_deaths.csv")


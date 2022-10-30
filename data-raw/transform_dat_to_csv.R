df1 <- read.table("data-raw/RCP85_MIDYR_CONC.DAT", skip = 40)

`colnames`(df1) <- c("YEARS", "CO2EQ", "KYOTO-CO2EQ", "CO2", "CH4", "N2O", "FGASSUMHFC134AEQ",
                    "MHALOSUMCFC12EQ", "CF4","C2F6","C6F14", "HFC23", "HFC32", "HFC43_10",
                    "HFC125", "HFC134a", "HFC143a", "HFC227ea", "HFC245fa", "SF6", "CFC_11",
                    "CFC_12", "CFC_113", "CFC_114", "CFC_115","CARB_TET", "MCF",
                    "HCFC_22", "HCFC_141B", "HCFC_142B", "HALON1211", "HALON1202", "HALON1301",
                    "HALON2402", "CH3BR", "CH3CL")

readr::write_csv(df1, "data/RCP85_MIDYR_CONC.csv")


df2 <- read.table("data-raw/RCP3PD_MIDYR_CONC.DAT", skip = 40) 

`colnames`(df2) <- c("YEARS", "CO2EQ", "KYOTO-CO2EQ", "CO2", "CH4", "N2O", "FGASSUMHFC134AEQ",
                     "MHALOSUMCFC12EQ", "CF4","C2F6","C6F14", "HFC23", "HFC32", "HFC43_10",
                     "HFC125", "HFC134a", "HFC143a", "HFC227ea", "HFC245fa", "SF6", "CFC_11",
                     "CFC_12", "CFC_113", "CFC_114", "CFC_115","CARB_TET", "MCF",
                     "HCFC_22", "HCFC_141B", "HCFC_142B", "HALON1211", "HALON1202", "HALON1301",
                     "HALON2402", "CH3BR", "CH3CL")

readr::write_csv(df2, "data/RCP3PD_MIDYR_CONC.csv")

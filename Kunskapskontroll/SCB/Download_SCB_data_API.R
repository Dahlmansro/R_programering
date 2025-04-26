source("packages.R")

# URL till SCB:s API
api_url <- "https://api.scb.se/OV0104/v1/doris/sv/ssd/START/TK/TK1001/TK1001A/PersBilarDrivMedel"

# Skapar query
pxweb_query_list <- list(
  Region = c("00", "01", "03", "04", "05", "06", "07", "08", "09", "10", 
             "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", 
             "22", "23", "24", "25"),
  Drivmedel = c("100", "110", "120", "130", "140", "150", "160", "190"),
  Tid = "*",
  ContentsCode = "*"
)

# Hämta data med pxweb_advanced_get
bildata <- pxweb_advanced_get(
  url = api_url,
  query = pxweb_query_list
)

# Konvertera till dataframe
bildata_df <- as.data.frame(bildata)


# Spara till CSV-fil
write.csv(bildata_df, "personbilar_drivmedel.csv", row.names = FALSE)
getwd()


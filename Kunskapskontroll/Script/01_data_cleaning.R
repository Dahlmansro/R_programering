# Ladda alla paket som projektet behöver
source(here::here("Script", "00_packages.R"))

# Läs in datafilen
data <- read_excel(here("Data", "Volkswagen_data_med_alderskolumn.xlsx"))

# Kolla datan
head(data)
str(data)
summary(data)

# Döper om kolumner (tar bort å, ä, ö och specialtecken)
data <- data %>%
  rename_with(.fn = ~ c(
    "index", "forsaljningspris", "saljare", "bransle", "vaxellada", "miltal", 
    "modellar", "biltyp", "drivning", "hk", "farg", "datum_i_trafik", 
    "bilens_alder", "marke", "modell", "region"
  ))

# Droppar oönskade kolumner
data <- data %>%
  dplyr::select(-c(datum_i_trafik, index, marke, modellar))

# Tar bort rader som har tomma värden
data <- data %>%
  filter(complete.cases(.))

# Tar bort extra mellanslag och gör till små bokstäver (för att undvika nivåskillnader)
data <- data %>%
  mutate(across(where(is.character), ~ str_trim(.) %>% str_to_lower()))

# Gör första bokstaven stor
data <- data %>%
  mutate(across(where(is.character), str_to_title))

# Konvertera till faktorer
data <- data %>%
  mutate(across(c(saljare, bransle, vaxellada, biltyp, drivning, farg, modell, region), as.factor))

# Slår ihop färger
data <- data %>%
  mutate(farg = forcats::fct_collapse(farg,
                                      "Blå" = c("Blå", "Ljusblå", "Mörkblå"),
                                      "Brun" = c("Brun", "Ljusbrun", "Mörkbrun"),
                                      "Grå" = c("Grå", "Ljusgrå", "Mörkgrå"),
                                      "Röd" = c("Röd", "Mörkröd"),
                                      "Grön" = c("Grön", "Mörkgrön", "Ljusgrön")
  ))

# Slår ihop bilmodeller 
data <- data %>%
  mutate(modell = forcats::fct_collapse(modell,
                                        "Up" = c("Up", "Up!")
  ))

# Spara bearbetad data
saveRDS(data, here::here("Data", "Volkswagen_data_stadat.rds"))  

summary(data)
str(data)
levels(data$modell)

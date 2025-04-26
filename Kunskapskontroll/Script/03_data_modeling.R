# Ladda alla paket som projektet behöver
source(here::here("Script", "00_packages.R"))

# Läser in data
data <- readRDS(here::here("Data", "volkswagen_clean.rds"))
summary(data)

# Delar upp datan i träning, validering och test--------------------------
set.seed(42)

train_index <- createDataPartition(data$forsaljningspris, p = 0.7, list = FALSE)
train_data <- data[train_index, ]
temp_data <- data[-train_index, ]

val_index <- createDataPartition(temp_data$forsaljningspris, p = 0.5, list = FALSE)
val_data <- temp_data[val_index, ]
test_data <- temp_data[-val_index, ]

# Kontrollera antal och fördelning
cat("Träning:", nrow(train_data), "\nValidering:", nrow(val_data), "\nTest:", nrow(test_data), "\n")

# Modell 1, endast numeriska variabler
modell_1 <- lm(forsaljningspris ~ bilens_alder + miltal + hk, data = train_data)
summary(modell_1)
plot(modell_1)

# Modell 2, alla variabler
modell_2 <- lm(forsaljningspris ~ ., data = train_data)
summary(modell_2)

# Utför variabelselektering 
stegvis_modell <- stepAIC(modell_2, direction = "both")
summary(stegvis_modell)

# Testar interaktioner på stegvis modell
# Modell med interaktion bransle * vaxellada
modell_2_bransle_vaxel <- lm(forsaljningspris ~ bransle * vaxellada + saljare + miltal + biltyp + drivning + hk + bilens_alder + modell, data = train_data)

# Modell med interaktion bilens ålder * miltal
modell_2_alder_miltal <- lm(forsaljningspris ~ bransle + vaxellada + saljare + bilens_alder * miltal + biltyp + drivning + hk + modell, data = train_data)

# Jämför modellerna med modell 2
anova(modell_2, modell_2_bransle_vaxel)
anova(modell_2, modell_2_alder_miltal)

# Se sammanfattning av modellerna för att utvärdera interaktionerna
summary(modell_2_bransle_vaxel)
summary(modell_2_alder_miltal)

# Bygg slutlig modell med interaktion från stegvis modell
stegvis_med_interaktion <- lm(forsaljningspris ~ saljare + miltal * bilens_alder + drivning + hk + modell, data = train_data)
summary(stegvis_med_interaktion)

# Undersök extrempunkter 
plot(stegvis_med_interaktion, which = 4)  # Cook's Distance
plot(stegvis_med_interaktion, which = 5)  # Leverage vs Residuals

train_data[c(49, 402, 441), ]

# Spara träningsdata och modeller
saveRDS(train_data, here::here("Data", "train_data.rds"))
saveRDS(stegvis_med_interaktion, here::here("Modeller", "stegvis_med_interaktion.rds"))

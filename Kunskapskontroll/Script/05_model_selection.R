# Ladda alla paket som projektet behöver
source(here::here("Script", "00_packages.R"))

# Läser in modeller
modell_utan_extrempunkt_log_clean <- readRDS(here::here("Modeller", "modell_utan_extrempunkt_log_clean.rds"))

# Läs in datan
data <- readRDS(here::here("Data", "volkswagen_clean.rds"))

# Läs in träningsdata
train_data <- readRDS(here::here("Data", "train_data.rds"))

# Delar upp resterande data i validerings- och testmängd
set.seed(42)
train_ids <- rownames(train_data)
remaining_data <- data[!rownames(data) %in% train_ids, ]
val_index <- createDataPartition(remaining_data$forsaljningspris, p = 0.5, list = FALSE)
val_data <- remaining_data[val_index, ]
test_data <- remaining_data[-val_index, ]

# Träna om den enklaste modellen (modell_1)
modell_1_clean <- lm(forsaljningspris ~ bilens_alder + miltal + hk, data = train_data)

# Spara modellen
saveRDS(modell_1_clean, here::here("Modeller", "modell_1_clean.rds"))

# Kontrollera modeller
summary_modell_1 <- summary(modell_1_clean)
summary_modell_2 <- summary(modell_utan_extrempunkt_log_clean)

# Skapa jämförelsetabell
comparison_table <- data.frame(
  Modell = c("Modell 1 (Enkel)", "Modell 2 (Full, log)"),
  R_squared = c(summary_modell_1$r.squared, summary_modell_2$r.squared),
  Adj_R_squared = c(summary_modell_1$adj.r.squared, summary_modell_2$adj.r.squared),
  AIC = c(AIC(modell_1_clean), AIC(modell_utan_extrempunkt_log_clean)),
  BIC = c(BIC(modell_1_clean), BIC(modell_utan_extrempunkt_log_clean))
)

print(comparison_table)

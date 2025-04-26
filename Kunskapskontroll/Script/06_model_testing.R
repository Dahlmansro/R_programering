# Ladda alla paket som projektet behöver
source(here::here("Script", "00_packages.R"))

# Läs in modell och data
modell_utan_extrempunkt_log_clean <- readRDS(here("Modeller", "modell_utan_extrempunkt_log_clean.rds"))
data <- readRDS(here("Data", "volkswagen_clean.rds"))
train_data <- readRDS(here("Data", "train_data.rds"))

# Sammanfatta modellen
summary(modell_utan_extrempunkt_log_clean)

# Dela upp resterande data i validerings- och testmängd
set.seed(42)
train_ids <- rownames(train_data)
remaining_data <- data[!rownames(data) %in% train_ids, ]
val_index <- createDataPartition(remaining_data$forsaljningspris, p = 0.5, list = FALSE)
val_data <- remaining_data[val_index, ]
test_data <- remaining_data[-val_index, ]

# Korrigera modellnamn i validerings- och testdata före filtrering
val_data$modell <- as.character(val_data$modell)
val_data$modell[val_data$modell == "Turan"] <- "Touran"
val_data$modell[val_data$modell == "Phaeton"] <- NA
val_data$modell <- factor(val_data$modell)

test_data$modell <- as.character(test_data$modell)
test_data$modell[test_data$modell == "Turan"] <- "Touran"
test_data$modell[test_data$modell == "Phaeton"] <- NA
test_data$modell <- factor(test_data$modell)

# Förbereder test och valideringsdata ----------------------------------------------

# Filtrera bort modeller som saknas i träningsdatan
val_data_prep <- val_data[val_data$modell %in% levels(train_data$modell), ]
test_data_prep <- test_data[test_data$modell %in% levels(train_data$modell), ]

# Konvertera faktorer till samma nivåer som i träningsdatan
for (col in names(train_data)) {
  if (is.factor(train_data[[col]]) && col %in% names(val_data_prep)) {
    val_data_prep[[col]] <- factor(val_data_prep[[col]], levels = levels(train_data[[col]]))
  }
  if (is.factor(train_data[[col]]) && col %in% names(test_data_prep)) {
    test_data_prep[[col]] <- factor(test_data_prep[[col]], levels = levels(train_data[[col]]))
  }
}

# Validering --------------------------------------------------------------

cat("\n----- VALIDERING -----\n")
pred_log_val <- predict(modell_utan_extrempunkt_log_clean, newdata = val_data_prep)
pred_val <- exp(pred_log_val)
true_val <- val_data_prep$forsaljningspris

# Beräkna felmått för valideringsdata
rmse_val <- sqrt(mean((pred_val - true_val)^2))
mae_val <- mean(abs(pred_val - true_val))
rel_mae_val <- (mae_val / mean(true_val)) * 100

cat("VALIDERING – RMSE:", round(rmse_val, 2), "kr\n")
cat("VALIDERING – MAE: ", round(mae_val, 2), "kr\n")
cat("Relativt MAE:", round(rel_mae_val, 2), "%\n")

# Test --------------------------------------------------------------------

cat("\n----- TEST -----\n")
pred_log_test <- predict(modell_utan_extrempunkt_log_clean, newdata = test_data_prep)
pred_test <- exp(pred_log_test)
true_test <- test_data_prep$forsaljningspris

# Beräkna felmått för testdata
rmse_test <- sqrt(mean((pred_test - true_test)^2))
mae_test <- mean(abs(pred_test - true_test))
rel_mae_test <- (mae_test / mean(true_test)) * 100

cat("TESTDATA – RMSE:", round(rmse_test, 2), "kr\n")
cat("TESTDATA – MAE: ", round(mae_test, 2), "kr\n")
cat("Relativt MAE:", round(rel_mae_test, 2), "%\n")

# Visualisering mellan predikterat och verkligt pris

# Skapa en dataram med verkliga och predikterade priser samt bränsletyp
plot_data <- data.frame(
  Actual = true_test,
  Predicted = pred_test,
  Bränsletyp = test_data_prep$bransle  # Anpassa kolumnnamn om det skiljer sig!
)

# Rita scatterplot med färg per bränsletyp
library(ggplot2)
ggplot(plot_data, aes(x = Actual, y = Predicted, color = Bränsletyp)) +
  geom_point(alpha = 0.6) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "black") +
  labs(
    title = "Predicted vs. Actual Selling Prices (Test Data)",
    x = "Actual Selling Price (kr)",
    y = "Predicted Selling Price (kr)",
    color = "Bränsletyp"
  ) +
  theme_minimal()


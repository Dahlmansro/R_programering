# Ladda modellen och träningsdata
modell_utan_extrempunkt_log_clean <- readRDS(here("Modeller", "modell_utan_extrempunkt_log_clean.rds"))
train_data_clean <- readRDS(here("Data", "train_data_clean.rds"))

# Läs in prediktionsdata
prediktionsdata <- read_excel(here::here("Data", "Prediktionsdata.xlsx"))

# Konvertera kategoriska variabler till faktorer (om det behövs)
categorical_vars <- c("saljare", "bransle", "vaxellada", "biltyp", "drivning", "farg", "modell", "region")
for (var in categorical_vars) {
  if (var %in% names(prediktionsdata)) {
    prediktionsdata[[var]] <- as.factor(prediktionsdata[[var]])
  }
}

# Spara ursprungliga försäljningspriser för senare jämförelse
faktiska_priser <- prediktionsdata$forsaljningspris

# Gör prediktioner med modellen som förväntar sig log-transformerade värden
predictions <- predict(modell_utan_extrempunkt_log_clean, newdata = prediktionsdata)

# Konvertera prediktionerna tillbaka till originalskalan
predictions <- exp(predictions)

# Lägg till prediktionerna till dataframen
prediktionsdata$predicted <- predictions

# Använd de sparade faktiska priserna för jämförelse
prediktionsdata$forsaljningspris <- faktiska_priser
prediktionsdata$predicted <- predictions

# Beräkna felet mellan faktiska och predikterade värden
prediktionsdata$error <- prediktionsdata$forsaljningspris - prediktionsdata$predicted
prediktionsdata$abs_error <- abs(prediktionsdata$error)
prediktionsdata$rel_error <- prediktionsdata$abs_error / prediktionsdata$forsaljningspris * 100

# Sammanfatta resultaten
summary_stats <- prediktionsdata %>%
  summarise(
    RMSE = sqrt(mean(error^2)),
    MAE = mean(abs_error),
    MAPE = mean(rel_error),
    MedianAPE = median(rel_error),
    R2 = cor(forsaljningspris, predicted)^2
  )

# Beräkna ytterligare utvärderingsmått med caret
actual <- prediktionsdata$forsaljningspris
predicted <- prediktionsdata$predicted

# Använd postResample från caret för att få R², RMSE och MAE i ett steg
caret_metrics <- postResample(pred = predicted, obs = actual)
print("Caret utvärderingsmått:")
print(caret_metrics)

print(summary_stats)

# Skapa en dataframe för att jämföra faktiska och predikterade värden
comparison <- data.frame(
  Faktiskt = prediktionsdata$forsaljningspris,
  Predikterat = prediktionsdata$predicted,
  Fel = prediktionsdata$error,
  RelativtFel = prediktionsdata$rel_error
)

# Visa de första raderna i jämförelsen
print(head(comparison))

# Visualisera resultaten
# Skapa en dataframe för plottning
plot_data <- data.frame(
  Faktiskt = prediktionsdata$forsaljningspris,
  Predikterat = prediktionsdata$predicted
)

# Jämförelse mellan faktiska och predikterade värden
p1 <- ggplot(plot_data, aes(x = Faktiskt, y = Predikterat)) +
  geom_point(alpha = 0.7) +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  labs(
    title = "Jämförelse mellan faktiska och predikterade försäljningspriser",
    x = "Faktiskt försäljningspris",
    y = "Predikterat försäljningspris"
  ) +
  theme_minimal()
print(p1)

# Ladda alla paket som projektet behöver
source(here::here("Script", "00_packages.R"))

# Läser in modellen
modell_utan_extrempunkt <- readRDS(here::here("Modeller", "stegvis_med_interaktion.rds"))

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

# Utvärdering av modell "stegvis_med_interaktion" ---------------------------------------------------

# Undersöker multikollinearitet med VIF
vif(modell_utan_extrempunkt, type = "predictor")

# Kontrollera icke-linjära samband
par(mfrow = c(1, 1))
plot(fitted(modell_utan_extrempunkt), residuals(modell_utan_extrempunkt),
     xlab = "Fitted values",
     ylab = "Residualer",
     main = "Residualer vs Förutsagda värden (före logtranformering)")
abline(h = 0, col = "red")

# Logtransformerar den beroende variabeln
modell_utan_extrempunkt_log <- lm(log(forsaljningspris) ~ saljare + miltal * bilens_alder + drivning + hk + modell, data = train_data)

# Kontroll av modellen efter logtransformering
par(mfrow = c(1, 1))
plot(fitted(modell_utan_extrempunkt_log), residuals(modell_utan_extrempunkt_log),
     xlab = "Fitted values",
     ylab = "Residualer",
     main = "Residualer vs Förutsagda värden (efter logtransformering)")
abline(h = 0, col = "red")

# Multikollinearitet efter transformation
vif(modell_utan_extrempunkt_log, type = "predictor")

# Modellens diagnostikplottar
par(mfrow = c(2, 2))
plot(modell_utan_extrempunkt_log)

# Heteroskedasticitet med Breusch-Pagan
bptest(modell_utan_extrempunkt_log)

# Normalfördelning av residualer
res <- residuals(modell_utan_extrempunkt_log)
hist(res, breaks = 30, col = "lightblue", freq = FALSE,
     main = "Histogram över residualer med normalfördelningskurva",
     xlab = "Residualer")
curve(dnorm(x, mean = mean(res), sd = sd(res)), col = "red", lwd = 2, add = TRUE)
shapiro.test(res)

# Kontrollera outliers och leverage
plot(modell_utan_extrempunkt_log, which = 5)  # Residuals vs Leverage
leverage_vals <- hatvalues(modell_utan_extrempunkt_log)
leverage_one <- which(leverage_vals == 1)
print("Punkter med leverage = 1:")
print(leverage_one)
train_data[leverage_one, ]

# Cook's Distance för att identifiera inflytelserika punkter
cooks_dist <- cooks.distance(modell_utan_extrempunkt_log)
n <- length(res)
influential_points <- which(cooks_dist > 4/n)
print("Inflytelserika punkter (Cook's distance > 4/n):")
print(influential_points)
print("Cook's distance för dessa punkter:")
print(cooks_dist[influential_points])

# Sparar modellen
saveRDS(modell_utan_extrempunkt_log, here::here("Modeller", "modell_utan_extrempunkt_log_clean.rds"))

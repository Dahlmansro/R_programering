# Ladda alla paket som projektet behöver
source(here::here("Script", "00_packages.R"))

# Läs in datafilen
data <- readRDS(here::here("Data", "Volkswagen_data_stadat.rds"))

# Korrelationsmatrix för numeriska variabler
vars <- c("forsaljningspris", "bilens_alder", "hk", "miltal")
cor_matrix <- cor(data[, vars], use = "complete.obs")

corrplot(cor_matrix,
         method = "color",        # färgad ruta
         type = "upper",          # visa bara övre triangeln
         addCoef.col = "black",   # visa korrelationsvärden
         tl.col = "black",        # färg på etiketter
         col = colorRampPalette(c("red", "white", "blue"))(200),  # färgskala
         tl.cex = 1.3,            # textstorlek
         number.cex = 2.0,        # textstorlek för siffror
         mar = c(0,0,1,0))        # marginal

# Definiera numeriska variabler (exklusive målvariabeln)
numeric_vars <- names(data)[sapply(data, is.numeric)]
numeric_vars <- setdiff(numeric_vars, "forsaljningspris")

# Scatterplots och regressionslinjer mot försäljningspris
par(mfrow = c(length(numeric_vars), 1), mar = c(4, 4, 3, 2))
for (var in numeric_vars) {
  plot(data[[var]], data$forsaljningspris,
       main = paste("Försäljningspris vs", var),
       xlab = var,
       ylab = "Försäljningspris",
       pch = 19,
       col = "steelblue")
  
  # Lägg till regressionslinje
  model <- lm(forsaljningspris ~ data[[var]], data = data)
  abline(model, col = "red", lwd = 2)
}
par(mfrow = c(1, 1)) # Återställ layout

# Identifiera kategoriska variabler
factor_vars <- names(data)[sapply(data, is.factor)]

# Initiera en dataframe för alla kategoristatistik
all_category_stats <- data.frame()

# För varje kategorisk variabel, beräkna statistik och skapa visualisering
for(var in factor_vars) {
  
  # Frekvenstabeller
  freq_table <- table(data[[var]])
  names(freq_table) <- trimws(names(freq_table)) 
  prop_table <- prop.table(freq_table) * 100
  
  # Sammanställ 
  summary_df <- data.frame(
    Variable = var,
    Category = names(freq_table),
    Count = as.numeric(freq_table),
    Percentage = as.numeric(prop_table),
    CumPercentage = cumsum(as.numeric(prop_table)),
    stringsAsFactors = FALSE
  )
  
  # Lägg till i den samlade statistiken
  all_category_stats <- rbind(all_category_stats, summary_df)
  
  # Visa barplot
  par(mar = c(10, 4, 4, 2) + 0.1)  
  barplot(freq_table, 
          main = paste("Fördelning av", var),
          las = 2, 
          cex.names = 0.8)
}

# Kontrollera att all_category_stats har data
all_category_stats <- unique(all_category_stats)
cat("\nKontrollerar 'modell'-variabeln:\n")
print(all_category_stats[all_category_stats$Variable == "modell", ])

# Identifiera kategorier med låg frekvens (mindre än 5%)
# Loopar igenom varje unik variabel
for (var in unique(all_category_stats$Variable)) {
  # Filtrerar kategorier under 5% för aktuell variabel
  low_freq <- all_category_stats[
    all_category_stats$Variable == var & all_category_stats$Percentage < 5, 
  ]
  
  # Om det finns några låg frekvens-kategorier, skriv ut dem
  if (nrow(low_freq) > 0) {
    cat("\nKategorier med låg frekvens (<5%) för variabel:", var, "\n")
    print(low_freq[, c("Variable", "Category", "Count", "Percentage")])
  }
}

# Loopa igenom varje kategorisk variabel och skapa en boxplot
for (var in factor_vars) {
  # Skapa en läsbar variant av variabelnamnet för titeln
  var_title <- gsub("_", " ", var)
  var_title <- paste(toupper(substr(var_title, 1, 1)), substr(var_title, 2, nchar(var_title)), sep="")
  
  # Skapa en boxplot med modern ggplot2-syntax istället för aes_string
  p <- ggplot(data, aes(x = .data[[var]], y = .data[["forsaljningspris"]], fill = .data[[var]])) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = paste("Försäljningspris per", var_title),
         x = var_title,
         y = "Försäljningspris") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # För variabler med många nivåer, justera plotten
  if (length(levels(data[[var]])) > 7) {
    p <- p + theme(legend.position = "none")
  }
  
  print(p)
}

# Sammanfattning
cat("\nSkapat boxplots för", length(factor_vars), "kategoriska variabler.\n")

# Hantering av outliers
numeric_data <- data[, sapply(data, is.numeric)]

# Funktion för att hitta outliers per variabel med IQR-metoden
find_outliers_iqr <- function(x) {
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  which(x < lower_bound | x > upper_bound)
}

# Samla detaljer om outliers
outlier_details <- data.frame()
for (var in names(numeric_data)) {
  indices <- find_outliers_iqr(numeric_data[[var]])
  if (length(indices) > 0) {
    temp_df <- data.frame(
      Row = indices,
      Variable = var,
      Value = numeric_data[indices, var],
      stringsAsFactors = FALSE
    )
    
    outlier_details <- rbind(outlier_details, temp_df)
  }
}

# Visa sammanfattning
cat("\nDetaljerad outlier-rapport:\n")
print(outlier_details)

# Samla unika rader att exkludera
outlier_indices <- unique(outlier_details$Row)
cat("\nHittade", length(outlier_indices), "unika outlier-observationer.\n")

# Skapa en ny datamängd utan dessa observationer
data_clean <- data[-outlier_indices, ]
saveRDS(data_clean, file = here::here("Data", "volkswagen_clean.rds"))

str(data_cl)

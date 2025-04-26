# Knowledge Assessment - Data Analysis in R

## 🚗 Used Volkswagen Price Prediction

### Project Description
This project aims to predict the selling prices of used Volkswagen cars. The goal is to build and evaluate a predictive model using various data analysis techniques in R.

The project is part of a knowledge assessment within the framework of studies in data analysis/data science.

### 📁 Repository Structure

* **Data/**: Storage for raw data files (e.g., Excel, CSV). Processed versions are also saved here.
* **Models/**: Saved models, such as trained regression models in .rds format.
* **Script/**: All R scripts, organized by purpose:
  * `00_packages.R`: Setup and installation of required packages
  * `01_data_cleaning.R`: Data preparation and cleaning
  * `02_eda.R`: Exploratory data analysis
  * `03_data_modeling.R`: Creating the regression models
  * `04_model_diagnostics.R`: Evaluating model performance
  * `05_model_selection.R`: Comparing and selecting the best model
  * `06_model_testing.R`: Testing the selected model
  * `07_predict_new_data.R`: Using the model for predictions
  * `SCB API`: Use to download data
* **Visualizations/**: Finalized graphs and charts (PNG or PDF format).

### 📊 Used R Packages

```r
# Core data manipulation and visualization
library(tidyverse)
library(ggplot2)
library(readxl)
library(stringr)

# Data retrieval
library(httr)
library(jsonlite)
library(pxweb)
library(lubridate)

# Analysis and modeling
library(corrplot)
library(caret)
library(MASS)
library(lmtest)
library(car)
```

See `Script/install_packages.R` for installation of necessary packages.

### 🚀 How to Run the Project

1. Open `Kunskapskontroll.Rproj` in RStudio.
2. Run the scripts in `Script/` in the following order:
   * `00_packages.R`
   * `01_data_cleaning.R`
   * `02_eda.R`
   * `03_data_modeling.R`
   * `04_model_diagnostics.R`
   * `05_model_selection.R`
   * `06_model_testing.R`
   * `07_predict_new_data.R`

### 📞 Contact

For questions, please contact: camilla.dahlman@utb.ecutbildning.se

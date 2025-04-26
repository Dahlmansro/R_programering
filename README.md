Kunskapskontroll - Dataanlays i R

Projektbeskrivning

Detta projekt syftar till att prediktera försäljningspriser på begagnade Volkswagenbilar. Målet är att bygga och utvärdera en prediktiv modell.

Projektet ingår som en del av en kunskapskontroll inom ramen för studier i dataanalys/data science.

Beskrivning av mappar

Data/: Här lagras rådatafiler (t.ex. Excel, CSV). Även bearbetade versioner sparas här.

Modeller/: Sparade modeller, t.ex. tränade regressionsmodeller i .rds-format.

Script/: Alla R-skript, uppdelade efter syfte.

Visualiseringar/: Färdiga grafer sparas här (t.ex. PNG eller PDF).

SCB/: API till SCB samt data nybilsförsäljning

Använda paket

Projektet använder följande R-paket:

tidyverse

httr

jsonlite

pxweb

lubridate

ggplot2

readxl

stringr

corrplot

caret

MASS

lmtest

car

Se Script/install_packages.R för installation av nödvändiga paket.

Hur man kör projektet

Öppna Kunskapskontroll.Rproj i RStudio.

Kör skripten i Script/ i följande ordning:

00_packages.R

01_data_cleaning.R

02_eda.R

03_data_modeling.R

04_model_diagnostics.R

05_model_selection.R

06_model_testing.R

07_predict_new_data.R

Kontakt

För frågor, kontakta camilla.dahlman@utb.ecutbildning.se

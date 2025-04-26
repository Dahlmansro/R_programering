# Paket som behövs för projektet
packages <- c(
  "tidyverse",  
  "httr",       
  "jsonlite",  
  "pxweb",      
  "lubridate", 
  "ggplot2",    
  "readxl",     
  "stringr",    
  "corrplot",   
  "caret",      
  "MASS",       
  "lmtest",     
  "car",
  "here"
)

# Installera paket som saknas
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Ladda alla paket
invisible(lapply(packages, library, character.only = TRUE))


# scripts/03_procesar_variables.R
# Procesamiento de variables de la EPH:
# - Conversión de ingresos a numérico
# - Creación de variables agregadas
# - Base lista para análisis inferencial

library(dplyr)
library(stringr)

# 1) Cargar base limpia del script 02 --------------------------------------

eph_clean <- readRDS("data/clean/eph_individual_clean.rds")

cat("Dimensiones de la base limpia cargada:\n")
print(dim(eph_clean))

# 2) Procesamiento de ingresos --------------------------------------------

eph_processed <- eph_clean %>%
  mutate(
    # Ingreso de la ocupación principal
    ingreso_principal = as.numeric(P21),
    
    # Ingreso por otras ocupaciones
    ingreso_otras = as.numeric(TOT_P12),
    
    # Ingreso total individual (laboral + no laboral)
    ingreso_total = as.numeric(P47T),
    
    # Ingreso total del hogar
    ingreso_hogar = as.numeric(ITF),
    
    # Ingreso per cápita familiar
    ipcf = as.numeric(IPCF),
    
    # Ingresos no laborales
    ingreso_no_laboral = as.numeric(T_VI),
    
    # Formalidad del empleo (1 = formal, 0 = informal; NA si no ocupado)
    formal = case_when(
      ESTADO == 1 & EMPLEO == 1 ~ 1,
      ESTADO == 1 & EMPLEO == 2 ~ 0,
      TRUE                      ~ NA_real_
    ),
    
    # Log ingreso principal (se calcula después sobre la muestra, pero lo dejamos preparado)
    log_ingreso_principal = if_else(
      !is.na(ingreso_principal) & ingreso_principal > 0,
      log(ingreso_principal),
      NA_real_
    )
  )

# 3) Chequeos rápidos ------------------------------------------------------

cat("\nResumen de ingreso_principal:\n")
print(summary(eph_processed$ingreso_principal))

cat("\nTabla de formalidad (entre ocupados):\n")
print(table(eph_processed$formal, useNA = "ifany"))

# 4) Guardar base procesada -----------------------------------------------

saveRDS(eph_processed, "data/processed/eph_individual_processed.rds")

cat("\nBase procesada guardada en: data/processed/eph_individual_processed.rds\n")


# scripts/02_limpieza.R
# Limpieza básica de la base individual de la EPH
# - Convierte variables clave a numéricas
# - Crea dummies de sexo y condición de actividad
# - Filtra entrevistas individuales realizadas (H15 == 1)

library(dplyr)
library(stringr)

# 1) Cargo la base cruda leída en el script 01 -----------------------------

eph_raw <- readRDS("data/raw/eph_raw.rds")

cat("Dimensiones base cruda (desde RDS):\n")
print(dim(eph_raw))

# 2) Limpieza básica -------------------------------------------------------

eph_individual_clean <- eph_raw %>%
  # saco espacios en blanco por las dudas
  mutate(across(everything(), ~ str_trim(.))) %>%
  
  # convierto a numérico las variables que vamos a usar sí o sí
  mutate(
    ANO4       = as.numeric(ANO4),
    TRIMESTRE  = as.numeric(TRIMESTRE),
    REGION     = as.numeric(REGION),
    AGLOMERADO = as.numeric(AGLOMERADO),
    NRO_HOGAR  = as.numeric(NRO_HOGAR),
    COMPONENTE = as.numeric(COMPONENTE),
    H15        = as.numeric(H15),      # entrevista individual realizada
    CH03       = as.numeric(CH03),     # parentesco
    CH04       = as.numeric(CH04),     # sexo
    CH06       = as.numeric(CH06),     # edad
    NIVEL_ED   = as.numeric(NIVEL_ED), # nivel educativo
    ESTADO     = as.numeric(ESTADO),   # condición de actividad
    CAT_OCUP   = as.numeric(CAT_OCUP),
    CAT_INAC   = as.numeric(CAT_INAC),
    PONDERA    = as.numeric(PONDERA),
    PONDII     = as.numeric(PONDII),
    PONDIH     = as.numeric(PONDIH)
  ) %>%
  
  # 3) Nos quedamos solo con entrevistas individuales realizadas -----------
#    (H15 == 1 según el diseño de registros del INDEC)
filter(H15 == 1) %>%
  
  # 4) Crear variables derivadas -------------------------------------------
mutate(
  # Sexo: 1 = varón, 0 = mujer
  sexo_dummy = case_when(
    CH04 == 1 ~ 1,
    CH04 == 2 ~ 0,
    TRUE      ~ NA_real_
  ),
  
  # Condición de actividad (ver ESTADO en diseño de registros)
  ocupado = if_else(ESTADO == 1, 1, 0, missing = NA_real_),
  desocupado = if_else(ESTADO == 2, 1, 0, missing = NA_real_),
  inactivo   = if_else(ESTADO == 3, 1, 0, missing = NA_real_)
)

# 5) Guardar base limpia ---------------------------------------------------

saveRDS(eph_individual_clean, "data/clean/eph_individual_clean.rds")

cat("\nBase limpia guardada en: data/clean/eph_individual_clean.rds\n")

# 6) Chequeo rápido --------------------------------------------------------

cat("\nMuestra de variables clave:\n")
eph_individual_clean %>%
  select(CODUSU, NRO_HOGAR, COMPONENTE,
         CH04, sexo_dummy,
         ESTADO, ocupado, desocupado, inactivo) %>%
  head() %>%
  print()

cat("\nDimensiones base limpia:\n")
print(dim(eph_individual_clean))


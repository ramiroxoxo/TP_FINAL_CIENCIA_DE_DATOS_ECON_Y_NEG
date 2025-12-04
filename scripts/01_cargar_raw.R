# scripts/01_cargar_raw.R
# Carga la base individual de la EPH cruda y la guarda en RDS
# para usar en los siguientes scripts.

library(vroom)
library(dplyr)

# Ruta al archivo CSV crudo
raw_path <- "data/raw/eph_2025t2_individual.csv"

# Leer la base cruda
eph_raw <- vroom(
  raw_path,
  delim = ";",                      # EPH viene separada por ;
  col_names = TRUE,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "Latin1")   # por tildes y ñ
)

# Chequeos básicos ---------------------------------------------------------

# Dimensiones
cat("Dimensiones base cruda:\n")
print(dim(eph_raw))

# Primeras variables
cat("\nPrimeras columnas:\n")
print(names(eph_raw)[1:20])

# Estructura resumida
cat("\nEstructura de la base:\n")
glimpse(eph_raw)

# Guardar en RDS para trabajar más rápido ---------------------------------

saveRDS(eph_raw, "data/raw/eph_raw.rds")

cat("\nArchivo guardado en: data/raw/eph_raw.rds\n")


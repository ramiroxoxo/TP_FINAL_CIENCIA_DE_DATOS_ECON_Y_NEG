# scripts/04_analisis.R
# Análisis completo:
# - EDA
# - Estadísticas descriptivas
# - Outliers y datos faltantes
# - Impacto de la limpieza
# - Test de hipótesis (formales vs informales)
# - Regresión
# - Gráficos y tablas

library(dplyr)
library(ggplot2)
library(readr)
library(broom)

# Crear carpetas de salida si no existen ----------------------------------

dir.create("output", showWarnings = FALSE)
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# 1) Cargar la base procesada ---------------------------------------------

eph <- readRDS("data/processed/eph_individual_processed.rds")

cat("Dimensiones de la base procesada:\n")
print(dim(eph))

# 2) Construcción de la muestra según la hipótesis ------------------------
# Hipótesis: los trabajadores formales ganan más que los informales.

eph_muestra <- eph %>%
  filter(
    ocupado == 1,                 # solo ocupados
    !is.na(ingreso_principal),
    ingreso_principal > 0,
    !is.na(formal)
  ) %>%
  mutate(
    formal_factor = factor(
      formal,
      levels = c(0, 1),
      labels = c("Informal", "Formal")
    ),
    log_ingreso = log(ingreso_principal)
  )

cat("\nMuestra final (ocupados, ingreso válido, con formalidad definida):\n")
print(dim(eph_muestra))

# 3) EDA ------------------------------------------------------------------

cat("\nPrimeras observaciones de la muestra:\n")
print(
  eph_muestra %>%
    select(CODUSU, COMPONENTE, CH06, sexo_dummy,
           formal_factor, ingreso_principal, log_ingreso) %>%
    head()
)

cat("\nProporción de formales e informales:\n")
print(prop.table(table(eph_muestra$formal_factor)))

cat("\nResumen ingreso_principal (muestra):\n")
print(summary(eph_muestra$ingreso_principal))

# 4) Estadísticas descriptivas por grupo (antes de limpiar outliers) ------

descriptivas_original <- eph_muestra %>%
  group_by(formal_factor) %>%
  summarise(
    n       = n(),
    media   = mean(ingreso_principal, na.rm = TRUE),
    mediana = median(ingreso_principal, na.rm = TRUE),
    sd      = sd(ingreso_principal, na.rm = TRUE),
    p25     = quantile(ingreso_principal, 0.25, na.rm = TRUE),
    p75     = quantile(ingreso_principal, 0.75, na.rm = TRUE)
  )

cat("\nDescriptivas originales por formalidad:\n")
print(descriptivas_original)

write_csv(descriptivas_original, "output/tables/descriptivas_original.csv")

# 5) Outliers y limpieza ---------------------------------------------------
# Detección de outliers con regla de 1.5*IQR

q1 <- quantile(eph_muestra$ingreso_principal, 0.25, na.rm = TRUE)
q3 <- quantile(eph_muestra$ingreso_principal, 0.75, na.rm = TRUE)
iqr <- q3 - q1

lim_inf <- q1 - 1.5 * iqr
lim_sup <- q3 + 1.5 * iqr

cat("\nLímites para detección de outliers en ingreso_principal:\n")
print(c(lim_inf = lim_inf, lim_sup = lim_sup))

eph_muestra_sin_out <- eph_muestra %>%
  filter(
    ingreso_principal >= lim_inf,
    ingreso_principal <= lim_sup
  )

cat("\nDimensiones después de remover outliers:\n")
print(dim(eph_muestra_sin_out))

# 6) Descriptivas después de la limpieza ----------------------------------

descriptivas_limpias <- eph_muestra_sin_out %>%
  group_by(formal_factor) %>%
  summarise(
    n       = n(),
    media   = mean(ingreso_principal, na.rm = TRUE),
    mediana = median(ingreso_principal, na.rm = TRUE),
    sd      = sd(ingreso_principal, na.rm = TRUE),
    p25     = quantile(ingreso_principal, 0.25, na.rm = TRUE),
    p75     = quantile(ingreso_principal, 0.75, na.rm = TRUE)
  )

cat("\nDescriptivas después de remover outliers:\n")
print(descriptivas_limpias)

write_csv(descriptivas_limpias, "output/tables/descriptivas_limpias.csv")

# 7) Impacto de la limpieza -----------------------------------------------

impacto_limpieza <- descriptivas_original %>%
  rename(
    n_original       = n,
    media_original   = media,
    mediana_original = mediana,
    sd_original      = sd,
    p25_original     = p25,
    p75_original     = p75
  ) %>%
  inner_join(
    descriptivas_limpias %>%
      rename(
        n_limpia       = n,
        media_limpia   = media,
        mediana_limpia = mediana,
        sd_limpia      = sd,
        p25_limpia     = p25,
        p75_limpia     = p75
      ),
    by = "formal_factor"
  )

cat("\nImpacto de la limpieza (comparación antes/después):\n")
print(impacto_limpieza)

write_csv(impacto_limpieza, "output/tables/impacto_limpieza.csv")

# 8) Test de hipótesis -----------------------------------------------------
# H1: ingreso formal > ingreso informal
# Usamos log(ingreso_principal) y t-test de Welch

t_test_result <- t.test(
  log_ingreso ~ formal_factor,
  data = eph_muestra_sin_out,
  var.equal = FALSE
)

cat("\nResultado del t-test (log ingreso, formal vs informal):\n")
print(t_test_result)

t_test_tabla <- tibble(
  estadistico_t       = unname(t_test_result$statistic),
  gl                  = unname(t_test_result$parameter),
  p_value             = t_test_result$p.value,
  media_log_informal  = unname(t_test_result$estimate["mean in group Informal"]),
  media_log_formal    = unname(t_test_result$estimate["mean in group Formal"])
)

write_csv(t_test_tabla, "output/tables/t_test_log_ingreso.csv")

# 9) Regresión -------------------------------------------------------------
# Modelo: log(ingreso_principal) ~ formal + sexo + edad + nivel educativo

reg_data <- eph_muestra_sin_out %>%
  filter(
    !is.na(log_ingreso),
    !is.na(sexo_dummy),
    !is.na(CH06),
    !is.na(NIVEL_ED)
  )

modelo <- lm(
  log_ingreso ~ formal + sexo_dummy + CH06 + NIVEL_ED,
  data = reg_data
)

cat("\nResumen del modelo de regresión:\n")
print(summary(modelo))

coef_tabla <- tidy(modelo)
write_csv(coef_tabla, "output/tables/regresion_log_ingreso.csv")

# 10) Gráficos editorializados --------------------------------------------

# 10.1 Boxplot de ingreso por formalidad ----------------------------------

g_box <- ggplot(eph_muestra_sin_out,
                aes(x = formal_factor, y = ingreso_principal)) +
  geom_boxplot() +
  labs(
    title   = "Distribución del ingreso laboral principal\nsegún formalidad del empleo",
    x       = "Condición de formalidad",
    y       = "Ingreso de la ocupación principal",
    caption = "Fuente: EPH INDEC 2025T2, procesamiento propio"
  )

ggsave("output/figures/boxplot_ingreso_formalidad.png",
       plot = g_box, width = 8, height = 5)

# 10.2 Medias de ingreso (log) por sexo y formalidad ----------------------

reg_data <- reg_data %>%
  mutate(
    sexo_factor = factor(sexo_dummy,
                         levels = c(0, 1),
                         labels = c("Mujer", "Varón"))
  )

medias_sexo_formal <- reg_data %>%
  group_by(sexo_factor, formal_factor) %>%
  summarise(
    media_log_ing = mean(log_ingreso, na.rm = TRUE),
    .groups = "drop"
  )

g_media <- ggplot(medias_sexo_formal,
                  aes(x = formal_factor, y = media_log_ing,
                      fill = sexo_factor)) +
  geom_col(position = "dodge") +
  labs(
    title   = "Ingreso laboral (log) promedio\npor formalidad y sexo",
    x       = "Condición de formalidad",
    y       = "Media de log(ingreso)",
    fill    = "Sexo",
    caption = "Fuente: EPH INDEC 2025T2, procesamiento propio"
  )

ggsave("output/figures/media_log_ingreso_formalidad_sexo.png",
       plot = g_media, width = 8, height = 5)

cat("\nAnálisis completo terminado. Tablas en output/tables, gráficos en output/figures.\n")


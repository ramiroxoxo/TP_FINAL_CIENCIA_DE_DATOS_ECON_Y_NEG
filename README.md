Análisis de Ingresos Laborales: Trabajadores Formales vs Informales  
Proyecto Final – Ciencia de Datos para Economía y Negocios

Este proyecto analiza si los trabajadores formales perciben ingresos laborales mayores que los trabajadores informales, utilizando microdatos de la Encuesta Permanente de Hogares (EPH) del INDEC.

La hipótesis a evaluar es:

> H1: Los trabajadores formales ganan más que los trabajadores informales.

Todo el análisis es totalmente reproducible mediante los scripts incluidos en la carpeta `/scripts`.

---

Estructura del Proyecto

El proyecto sigue la estructura solicitada:

```
proyecto/
├── data/
│ ├── raw/ # Datos crudos originales (CSV del INDEC)
│ ├── clean/ # Datos limpios
│ └── processed/ # Datos procesados (listos para análisis)
├── output/
│ ├── tables/ # Resultados en tablas (CSV)
│ └── figures/ # Gráficos del análisis
├── scripts/ # Scripts ejecutables en orden
└── README.md # Este archivo
```

---

Requerimientos

El proyecto utiliza R y los siguientes paquetes:

- tidyverse  
- vroom  
- ggplot2  
- dplyr  
- broom  
- stringr  

Para instalarlos:

install.packages(c("tidyverse", "vroom", "ggplot2", "dplyr", "broom", "stringr"))

---

Cómo reproducir el análisis (paso a paso)

La ejecución debe realizarse en orden, para garantizar la reproducibilidad.

---

Script 01 – Carga de datos crudos
Archivo: `scripts/01_load_raw.R`  
Tareas:
- Lee el archivo CSV original del INDEC.
- Estandariza la codificación.
- Guarda un archivo RDS en `/data/raw/`.

Ejecutar:


source("scripts/01_load_raw.R")


---

Script 02 – Limpieza de la base
Archivo: `scripts/02_limpieza.R`  
Tareas:
- Convierte tipos de datos.
- Normaliza variables clave.
- Crea dummies (`sexo_dummy`, `ocupado`, etc.).
- Filtra entrevistas válidas (H15 == 1).
- Guarda la base limpia en `/data/clean/`.

Ejecutar:

source("scripts/02_limpieza.R")

---

Script 03 – Procesamiento de variables
Archivo: `scripts/03_procesar_variables.R`  
Tareas:
- Convierte ingresos a numérico.
- Crea variables de análisis:
  - ingreso_principal  
  - ingreso_total  
  - formalidad (formal / informal)  
  - log_ingreso
- Guarda la base procesada en `/data/processed/`.

Ejecutar:

source("scripts/03_procesar_variables.R")

---

Script 04 – Análisis completo
Archivo: `scripts/04_analisis.R`  
Incluye:

- Análisis exploratorio (EDA)  
- Estadísticas descriptivas  
- Identificación y remoción de outliers (IQR)  
- Cálculo del impacto de la limpieza  
- Test de hipótesis (t-test de Welch)  
- Modelo de regresión  
- Gráficos editorializados  
- Exportación de tablas y figuras  

Ejecutar:

source("scripts/04_analisis.R")

Los resultados se guardan en:

```
output/tables/
output/figures/
```

---

Dataset utilizado

- EPH – INDEC  
- Trimestre: 2025 T2  
- Unidad de análisis: personas (archivo individual)  
- Variables principales:
  - `P21`: ingreso de la ocupación principal  
  - `EMPLEO`: formalidad  
  - `CH04`: sexo  
  - `CH06`: edad  
  - `NIVEL_ED`: educación  
  - `ESTADO`: condición de actividad  

Valores faltantes y códigos especiales:

- `-9` → No respuesta / dato faltante (excluido de la muestra mediante ingreso_principal > 0)

---

 Reproducibilidad completa

El análisis es completamente reproducible:

1. Los scripts deben ejecutarse en orden 01 → 04.  
2. No se requiere modificar rutas ni parámetros.  
3. Los datos crudos deben estar en `/data/raw/`.  
4. Todas las salidas se generan automáticamente.  
5. Los resultados del test de hipótesis y regresión coincidirán exactamente si se ejecutan nuevamente.

---

Informe

El archivo de presentación (`.pptx`) resume:

- Hipótesis  
- Metodología  
- EDA  
- Outliers  
- Test de hipótesis  
- Regresión  
- Conclusiones  
- Limitaciones  

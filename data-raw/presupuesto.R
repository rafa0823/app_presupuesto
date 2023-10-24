## code to prepare `presupuesto` dataset goes here

library(dplyr)

bd <- readRDS("data-raw/bds_ejercicio_del_gasto_2023_2021.rds")

set.seed(1996)

bd <- bd |>
  sample_n(25000) |>
  select(ciclo,trimestre,entidad_federativa,desc_ramo,
         monto_aprobado,monto_modificado,monto_ejercido,monto_pagado) |>
  mutate(aux_trim = case_when(trimestre == 2 ~ 4,
                              trimestre == 3 ~ 7,
                              trimestre == 4 ~ 10,
                              T~trimestre),
         entidad_federativa = iconv(entidad_federativa, to = "UTF-8"),
         desc_ramo = iconv(desc_ramo, to = "UTF-8")
  )

bd <- bd |>
  mutate(fecha = as.Date(paste(bd$ciclo,
                               bd$aux_trim, "01", sep = "-"),
                         format = "%Y-%m-%d"))

pres <- bd |>
  filter(!is.na(entidad_federativa), !is.na(desc_ramo))

usethis::use_data(pres, overwrite = TRUE)

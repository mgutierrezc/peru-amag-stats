## Data cleaning script for AMAG I grades

# List course folders
files <- list.files(paste0(data_amag_raw, "raw_deidentified/", "02_grades"))

grade_files <- set_names(
  paste0(data_amag_raw, "raw_deidentified/", "02_grades/", files)) %>%
  map(~read_csv(.x))

# Create null dataframe to save results
grade_data <- NULL
# Iterate over courses
for (file in grade_files) {

  if ("tarea_nota_de_la_practica_calificada_parte_1_y_2_real" %in% names(file)) {
    file <- file %>%
      rename(
        nota_practica_1 = tarea_nota_de_la_practica_calificada_parte_1_y_2_real,
        nota_practica_2 = tarea_nota_de_la_practica_calificada_parte_3_y_4_real) %>%
      mutate(doble_practica = 1)
  } else if ("tarea_nota_de_la_practica_calificada_n_1_real" %in% names(file)) {
    file <- file %>%
      rename(
        nota_practica_1 = tarea_nota_de_la_practica_calificada_n_1_real,
        nota_practica_2 = tarea_nota_de_la_practica_calificada_n_2_real) %>%
      mutate(doble_practica = 1)
  } else if ("tarea_practica_calificada_segunda_parte_desde_las_17_00_horas_del_06_de_junio_hasta_las_23_55_horas_del_07_de_junio_2020_suba_aqui_su_documento_real" %in% names(file)) {
    file <- file %>%
      rename(
        nota_practica_1 = total_categoria_real_14,
        nota_practica_2 = total_categoria_real_17) %>%
      mutate(doble_practica = 1)
  } else if ("tarea_practica_calificada_desde_las_16_00_horas_del_11_de_julio_hasta_las_21_00_horas_del_11_de_julio_2020_suba_aqui_su_documento_real" %in% names(file)) {
    file <- file %>%
      rename(
        nota_practica_1 = tarea_practica_calificada_desde_las_16_00_horas_del_11_de_julio_hasta_las_21_00_horas_del_11_de_julio_2020_suba_aqui_su_documento_real,
        nota_practica_2 = tarea_practica_calificada_desde_las_16_00_horas_del_18_de_julio_hasta_las_21_00_horas_del_18_de_julio_2020_suba_aqui_su_documento_real) %>%
      mutate(doble_practica = 1)
  } else if ("tarea_tarea_academica_desde_las_15_20_horas_hasta_las_21_00_horas_del_01_de_agosto_suba_aqui_su_documento_real" %in% names(file)) {
    file <- file %>%
      rename(
        nota_practica_1 = tarea_tarea_academica_desde_las_15_20_horas_hasta_las_21_00_horas_del_01_de_agosto_suba_aqui_su_documento_real,
        nota_practica_2 = tarea_tarea_academica_desde_las_14_30_horas_hasta_las_21_00_horas_del_08_de_agosto_suba_aqui_su_documento_real) %>%
      mutate(doble_practica = 1)
  } else if ("tarea_tarea_academica_desde_las_16_00_horas_hasta_las_23_55_horas_del_08_de_agosto_suba_aqui_su_documento_real" %in% names(file)) {
    file <- file %>%
      rename(
      nota_practica_1 = tarea_tarea_academica_desde_las_15_50_horas_hasta_las_23_55_horas_del_01_de_agosto_suba_aqui_su_documento_real,
      nota_practica_2 = tarea_tarea_academica_desde_las_16_00_horas_hasta_las_23_55_horas_del_08_de_agosto_suba_aqui_su_documento_real) %>%
      mutate(doble_practica = 1)
  } else if ("tarea_tarea_academica_desde_las_15_50_horas_hasta_las_23_55_horas_del_08_de_agosto_suba_aqui_su_documento_real" %in% names(file)) {
    file <- file %>%
      rename(
      nota_practica_1 = tarea_tarea_academica_desde_las_15_50_horas_hasta_las_23_55_horas_del_01_de_agosto_suba_aqui_su_documento_real,
      nota_practica_2 = tarea_tarea_academica_desde_las_15_50_horas_hasta_las_23_55_horas_del_08_de_agosto_suba_aqui_su_documento_real) %>%
      mutate(doble_practica = 1)
  } else {
    file <- file %>%
      mutate(nota_practica_1 = NA,
             nota_practica_2 = NA,
             doble_practica = 0)
  }
  if ("nota_de_tarea_academica_real" %in% names(file)) {
    file <- file %>%
      rename(nota_de_practica_calificada_real = nota_de_tarea_academica_real)
  }

  file <- file %>%
    rename(
      nota_foro = nota_de_foro_real,
      nota_lectura = nota_de_control_de_lectura_real,
      nota_practica_final = nota_de_practica_calificada_real,
      examen_final = nota_examen_final_real,
      promedio_final = promedio_final_real) %>%
    mutate(
      nota_foro = as.numeric(nota_foro),
      nota_lectura = as.numeric(nota_lectura),
      nota_practica_1 = as.numeric(nota_practica_1),
      nota_practica_2 = as.numeric(nota_practica_2),
      nota_practica_final = as.numeric(nota_practica_final),
      examen_final = as.numeric(examen_final),
      promedio_final = as.numeric(promedio_final)) %>%
    select(participant_id, round,
           nota_foro,
           nota_lectura,
           nota_practica_1,
           nota_practica_2,
           nota_practica_final,
           examen_final,
           promedio_final,
           doble_practica)

  # Merge all courses in a single dataset
    grade_data <- bind_rows(grade_data, file)
}

# write grade file to output folder
write_csv(grade_data, paste0(data_amag_int, "02_grades/all_grades.csv"))
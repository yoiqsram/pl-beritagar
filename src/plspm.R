library(plspm)

plspm_autofit <- function(data) {
  # Fungsi untuk memodelkan *Partial Least Square - Path Modeling*.
  # Terbatas untuk model pembentukan indeks **Produktivitas Tenaga Kerja**.
  
  # Model jalur *variabel laten*
  # Dayaguna_TenagaKerja -> Produktivitas_TenagaKerja
  model <- matrix(c(0, 0,
                    1, 0),
                  ncol = 2, byrow = TRUE)
  colnames(model) <- rownames(model) <- c('Dayaguna_TenagaKerja', 'Produktivitas_TenagaKerja')
  
  # `bloks` merupaka list yang berisi nama *variabel manifest* yang digunakan berdasarkan variabel latennya.
  blocks = list(`Daya Guna Tenaga Kerja` = names(data)[grepl('Persentase|Pendidikan|Jam Kerja', names(data))],
                `Produktivitas Tenaga Kerja` = c('PDRB.ADHB.per.Tenaga.Kerja', 'Rata.rata.Gaji.per.Bulan'))
  
  # -------------------------- #
  # --- Pemodelan otomatis --- #
  # -------------------------- #
  pls_model <- list()
  
  # Model pertama menggunakan seluruh variabel manifest pada variabel laten **Daya Guna Tenaga Kerja**
  pls_model$all <- plspm(data, model, blocks, modes = c('A', 'A'))
  
  # Model kedua menghilangkan variabel manifest yang memiliki faktor negatif
  ind_negative <- with(pls_model$all$outer_model, as.character(name[loading < 0]))
  blocks$`Daya Guna Tenaga Kerja` <- with(blocks, `Daya Guna Tenaga Kerja`[`Daya Guna Tenaga Kerja` != ind_negative])
  pls_model$positive <- plspm(data, model, blocks, modes = c('A', 'A'))
  
  # Model kedua menghilangkan variabel manifest yang kurang penting
  ind_lessImportant <- with(pls_model$positive$outer_model, as.character(name[communality < .5]))
  blocks$`Daya Guna Tenaga Kerja` <- with(blocks, `Daya Guna Tenaga Kerja`[!(`Daya Guna Tenaga Kerja` %in% ind_lessImportant)])
  pls_model$important <- plspm(data, model, blocks, modes = c('A', 'A'))
  
  
  return(pls_model)
}

plspm_predict <- function(plspm_model, newdata = NULL) {
  # Fungsi untuk memprediksikan *newdata* pada model *plspm_model*
  # Terbatas pada *newdata* yang sudah sesuai dengan format masukan variabel manifest pada model
  vars <- list()
  
  # Mengambil bobot, titik tengah, dan skala dari model
  weight <- plspm_model$outer_model[, c('name', 'block', 'weight')]
  center <- attr(plspm_model$manifests, 'scaled:center')
  scale <- attr(plspm_model$manifests, 'scaled:scale')
  
  # Transformasi variabel manifest pada *newdata* sesuai dengan kebutuhan model
  vars$manifests <- (as.matrix(newdata[names(center)]) - rep(center, each = nrow(newdata))) %*% ((1 / scale) * diag(length(scale)))
  colnames(vars$manifests) <- names(center)
  
  # Memprediksi variabel laten atau *score*
  vars$scores <- data.frame(Dayaguna_TenagaKerja = rowSums(vars$manifests[, weight$name[weight$block == 'Dayaguna_TenagaKerja']] %*%
                                                                    (weight$weight[weight$block == 'Dayaguna_TenagaKerja'] * diag(sum(weight$block == 'Dayaguna_TenagaKerja')))),
                                   Produktivitas_TenagaKerja = rowSums(vars$manifests[, weight$name[weight$block == 'Produktivitas_TenagaKerja']] %*%
                                                                         (weight$weight[weight$block == 'Produktivitas_TenagaKerja'] * diag(sum(weight$block == 'Produktivitas_TenagaKerja')))))
  colnames(vars$scores) <- c('Dayaguna_TenagaKerja', 'Produktivitas_TenagaKerja')
  
  return(vars)
}

require(dplyr)
require(tibble)
require(tidyr)
require(yaml)

bcbio_final <- "/g/data3/gx8/data/10X/TruSeq/bcbio_original/final"
batch_nms <- list.dirs(bcbio_final, recursive = FALSE)

manta_sv <- list.files(batch_nms, pattern = "batch-manta.vcf.gz$", full.names = TRUE)
svprioritize_sv <- list.files(batch_nms, pattern = "sv-prioritize-manta.vcf.gz$", full.names = TRUE)
ensemble_snv <- list.files(batch_nms, pattern = "ensemble-annotated.vcf.gz$", full.names = TRUE)

fn <- tibble(fn = list.files(batch_nms, pattern = "manta.vcf.gz$|ensemble-annotated.vcf.gz$", full.names = TRUE))
fn2 <- fn %>%
  mutate(batch = case_when(
    grepl("COLO829_20pc-batch", fn) ~ "Colo829_20pc",
    grepl("COLO829_40pc-batch", fn) ~ "Colo829_40pc",
    grepl("COLO829_60pc-batch", fn) ~ "Colo829_60pc",
    grepl("COLO829_80pc-batch", fn) ~ "Colo829_80pc",
    grepl("COLO829_100pc-batch", fn) ~ "Colo829",
    TRUE ~ fn
  )) %>%
  mutate(ftype = case_when(
    grepl("batch-manta.vcf.gz$", fn) ~ "manta",
    grepl("batch-sv-prioritize-manta.vcf.gz$", fn) ~ "svpri",
    grepl("ensemble-annotated.vcf.gz$", fn) ~ "ensemble",
    TRUE ~ fn
  )) %>%
  filter(grepl("^Colo829", batch)) %>%
  spread(ftype, fn)

batch_list <- vector(mode = "list", length = nrow(fn2))
names(batch_list) <- fn2$batch

for (i in 1:nrow(fn2)) {
  ensemble <- fn2$ensemble[i]
  manta <- fn2$manta[i]
  svpri <- fn2$svpri[i]
  batch_list[[i]] <-  list(manta = manta,  svpri = svpri, ensemble = ensemble)
}

cat(yaml::as.yaml(batch_list)) # awesome
write(as.yaml(batch_list), file = "../config/bcbio.yaml")

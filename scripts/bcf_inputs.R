require(tidyverse)

# given a 'final' directory, generate a tibble containing:
# 1. ensembl-batch
# 2. mutect2-batch
# 3. strelka2-batch
# 4. vardict-batch
# 5. ensemble-germ
# 6. gatk-germ
# 7. strelka2-germ
# 8. vardict-germ


generate_snv_inputs <- function(final, run) {
  vcfs <- list.files(final, pattern = "\\.vcf.gz$", recursive = TRUE, full.names = TRUE) %>%
    tibble(fname = .) %>%
    mutate(bname = basename(fname)) %>%
    select(bname, fname)
  vcfs %>%
    mutate(ftype = case_when(
      grepl("germline-ensemble", bname) ~ "ensemble-germ",
      grepl("ensemble", bname) ~ "ensemble-batch",
      grepl("germline-vardict", bname) ~ "vardict-germ",
      grepl("vardict-germline", bname) ~ "OTHER",
      grepl("vardict", bname) ~ "vardict-batch",
      grepl("germline-strelka2", bname) ~ "strelka-germ",
      grepl("strelka2", bname) ~ "strelka-batch",
      grepl("mutect2", bname) ~ "mutect-batch",
      grepl("germline-gatk-haplotype", bname) ~ "gatk-germ",
      grepl("manta", bname) ~ "Manta",
      TRUE ~ "OTHER")) %>%
    select(ftype, fname)
}

root <- "/g/data3/gx8/projects/Diakumis_IPMN/2019-01-22T0233_Research-APGI-Garvan_WGS_2624/2019-01-22T0233_Research-APGI-Garvan_WGS_2624-merged"

native <-
  file.path(root, "final") %>%
  generate_snv_inputs() %>%
  filter(!ftype %in% c("Manta", "OTHER")) %>%
  mutate(run = "native")

cwl <-
  file.path(root, "work_cromwell_rerun/cromwell_work/final") %>%
  generate_snv_inputs() %>%
  filter(!ftype %in% c("Manta", "OTHER")) %>%
  mutate(run = "cwl")

d <-
  bind_rows(native, cwl) %>%
  select(run, ftype, fname) %>%
  spread(run, fname)


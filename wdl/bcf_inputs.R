require(tidyverse)

# given a 'final' directory, generate a tibble containing:
# 1. batch-ensemble
# 2. batch-mutect2
# 3. batch-strelka2
# 4. batch-vardict
# 5. germline-ensemble
# 6. germline-gatk
# 7. germline-strelka2
# 8. germline-vardict


generate_inputs <- function(final) {
  vcfs <- list.files(final, pattern = "\\.vcf.gz$", recursive = TRUE, full.names = TRUE) %>%
    tibble(fname = .) %>%
    mutate(bname = basename(fname)) %>%
    select(bname, fname)
  vcfs %>%
    mutate(ftype = case_when(
      grepl("germline-ensemble", bname) ~ "ensemble-germ",
      grepl("ensemble", bname) ~ "ensemble-batch",
      grepl("germline-vardict", bname) ~ "vardict-germ",
      grepl("vardict-germline", bname) ~ "vardict-germ2",
      grepl("vardict", bname) ~ "vardict-batch",
      grepl("germline-strelka2", bname) ~ "strelka-germ",
      grepl("strelka2", bname) ~ "strelka-batch",
      grepl("mutect2", bname) ~ "mutect-batch",
      grepl("germline-gatk-haplotype", bname) ~ "gatk-germ",
      grepl("manta", bname) ~ "Manta",
      TRUE ~ "OTHER")) %>%
    select(ftype, fname)

}

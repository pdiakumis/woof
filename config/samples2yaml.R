require(tidyverse)
require(yaml)

s1 <- readr::read_csv("samples.csv", col_types = cols(.default = col_character()))
sample_list <- vector(mode = "list", length = nrow(s1))



for (i in 1:nrow(s1)) {
  sample_list[[i]] <- list(
    normal = list(
      bam = s1$bam_normal[i]),
    tumor = list(
      bam = s1$bam_tumor[i],
      vcf_snp = s1$vcf_snp[i],
      vcf_sv = s1$vcf_sv[i])
  )
}
names(sample_list) <- s1$batch

cat(yaml::as.yaml(sample_list)) # awesome
write(as.yaml(sample_list), file = "samples.yaml")

#---- s2 ----#

s2 %>%
  as_tibble() %>%
  separate(value, c("batch", "phenotype", "d"), "-", remove = FALSE) %>%
  separate(batch, c("pr", "batch"), "_") %>%
  mutate(type = case_when(
    grepl("^B", phenotype) ~ "normal",
    grepl("^T", phenotype) ~ "tumor",
    TRUE ~ phenotype)) %>%
  rename(folder = value) %>%
  select(folder, batch, phenotype, type) %>%
  group_by(batch) %>%
  mutate(new_batch = get_new_batch(batch, type)) %>%
  cSplit(splitCols = "new_batch", sep = ";", direction = "long", type.convert = FALSE) %>%
  as_tibble() %>%
  arrange(new_batch, type) -> s2

# For each folder, get the BAM and VCF file

bams <- vector("character", length = nrow(s2))
vcfs <- vector("character", length = nrow(s2))

for (i in seq_len(nrow(s2))) {
  bams[i] <- list.files(file.path(a5_2, s2$folder[i]), pattern = "ready.bam$")
  vcfs[i] <- list.files(file.path(a5_2, s2$folder[i]), pattern = "sv-prioritize-manta.vcf.gz$")
}

s2 <- s2 %>%
  mutate(bam = bams,
         vcf = vcfs) %>%
  mutate(bam = paste(folder, bam, sep = "/"),
         vcf = paste(folder, vcf, sep = "/")) %>%
  select(new_batch, type, bam, vcf) %>%
  gather(file_type, path, -c(new_batch, type)) %>%
  unite(temp, type, file_type) %>%
  spread(temp, path)

sample_list <- vector(mode = "list", length = nrow(s2))


for (i in 1:nrow(s2)) {
  sample_list[[i]] <- list(
    normal = list(
      bam = s2$normal_bam[i],
      vcf = s2$normal_vcf[i]),
    tumor = list(
      bam = s2$tumor_bam[i],
      vcf = s2$tumor_vcf[i])
  )
}
names(sample_list) <- s2$new_batch

sample_list <- list(samples_A5_batch2 = sample_list)
cat(yaml::as.yaml(sample_list)) # awesome
write(as.yaml(sample_list), file = "../workflows/structural/samples_A5_batch2.yaml")


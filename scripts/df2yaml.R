require(tidyverse)
require(yaml)
require(splitstackshape)

a5_1 <- "/data/cephfs/punim0010/data/Results/Tothill-Research/2018-04-09/final"
a5_2 <- "/data/cephfs/punim0010/data/Results/Tothill-Research/2018-05-05/final"

# We want batch | type | bam | vcfs-for-tumor
(s1 <- list.files(a5_1, pattern = "^PR")) # 66 folders
(s2 <- list.files(a5_2, pattern = "^PR")) # 46 folders

# PRJ170158_E143-B01-D is normal; analysed twice since tumors seq in two batches
# I'll just call this one E143-A and E143-B, for batches A/B.
# E122, E146, E159, E169 with multiple tumors
# So let's encode these batches as E122-1, E122-2 etc. The normal will
# become E122-1;E122-2. We can then split and melt probably
s1[s1 %in% s2]
s2[s2 %in% s1]

get_new_batch <- function(batch, type) {
  stopifnot(length(batch) == length(type))
  n <- length(batch)
  new_batch <- vector(mode = "character", length = n)
  x <- table(type)
  if (n > 2) {
    tum_ns <- seq_len(x["tumor"])
    new_batch[type == "tumor"] <- paste0(batch[type == "tumor"], "-", tum_ns)
    # assume only one normal for now
    new_batch[type == "normal"] <- paste0(batch[type == "tumor"], "-", tum_ns, collapse = ";")
  } else {
    new_batch <- batch
  }
  return(new_batch)
}

s1 %>%
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
  cSplit(splitCols = "new_batch", sep = ";", direction = "long") %>%
  arrange(new_batch, type) %>%
  as_tibble() -> s1

# For each folder, get the BAM and VCF file
# We can just ignore the normal VCF file
(f1 <- s1$folder[1])
list.files(file.path(a5_1, f1), pattern = "bam$")
list.files(file.path(a5_1, f1), pattern = "manta.vcf.gz$")

s1 %>%
  mutate(bam = list.files(file.path(a5_1, folder), pattern = "bam$"))

#### Down to here!

sample_list <- vector(mode = "list", length = nrow(bams))
for (i in 1:nrow(bams)) {
  sample_list[[i]] <- list(normal = bams$normal[i],
                           tumor  = bams$tumor[i])
}
names(sample_list) <- bams$sample_id
sample_list <- list(samples = sample_list)
cat(yaml::as.yaml(sample_list)) # awesome
write(as.yaml(sample_list), file = "../workflows/cnv/samples.yaml")

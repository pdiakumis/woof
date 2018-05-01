# construct a data frame with sample | type (tumor/normal) | filename,
# and get a yaml like:
# sampleA:
#    tumor: abcd.bam
#    normal: efgh.bam
# sampleB:
#    tumor: ijkl.bam
#    normal: mnop.bam

require(tidyverse)
require(yaml)

bam_dir <- "../data/bam_a5"
bam_fnames <- list.files(bam_dir, pattern = "bam$")
bam_fnames
bams <- bam_fnames %>%
  as_tibble() %>%
  separate(value, c("sample", "type", "junk1", "junk2"), "-", remove = FALSE) %>%
  rename(fname = value) %>%
  separate(sample, c("junk", "sample_id"), "_") %>%
  select(sample_id, type, fname) %>%
  mutate(type = case_when(
    type == "B01" ~ "normal",
    type == "T01" ~ "tumor",
    TRUE ~ type)) %>%
  arrange(sample_id, type)

bams

# four samples with multiple tumors (14 bams total) - ignore for now
(exclude <- names(which(table(bams$sample_id) > 2)))
bams <- bams %>%
  filter(!sample_id %in% exclude) %>%
  spread(type, fname)

bams

sample_list <- vector(mode = "list", length = nrow(bams))
for (i in 1:nrow(bams)) {
  sample_list[[i]] <- list(normal = bams$normal[i],
                           tumor  = bams$tumor[i])
}
names(sample_list) <- bams$sample_id
sample_list <- list(samples = sample_list)
cat(yaml::as.yaml(sample_list)) # awesome
write(as.yaml(sample_list), file = "../workflows/cnv/samples.yaml")

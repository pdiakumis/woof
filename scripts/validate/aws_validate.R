require(tidyverse)
require(fs)

manifest <-
  read_tsv("../../data/aws_validate/manifest.txt",  skip = 1, col_types = "ccc",
           col_names = c("id", "data_type", "file")) %>%
  arrange(id)

fsizes <-
  read_delim("../../data/aws_validate/file_sizes.txt", delim = ",", col_types = "cc",
             col_names = c("size", "file")) %>%
  mutate(size = readr::parse_number(size))

all(fsizes$file %in% manifest$file)
all(manifest$file %in% fsizes$file)

df <- dplyr::left_join(manifest, fsizes, by = "file")

df <- df %>%
  mutate(size = fs::as_fs_bytes(size)) %>%
  mutate(file_type = case_when(
    grepl("fastq.gz$", file) ~ "FASTQ",
    grepl("bam$", file) ~ "BAM",
    grepl("vcf$", file) ~ "VCF",
    TRUE ~ "Other"))

# file types
df %>%
  pull(file_type) %>%
  table(useNA = 'ifany') %>%
  addmargins()

# all size
df %>%
  group_by(file_type) %>%
  summarise(mean_size = sum(size)/n(),
            med_size = median(size),
            tot_size = sum(size))

# mito size
df %>%
  filter(data_type == "Mitochondrial")
  # pull(size) %>% mean %>% as_fs_bytes()

length(table(df$id))


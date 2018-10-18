require(dplyr)
require(purrr)
require(yaml)

guess_file_type <- function(file) {
  dplyr::case_when(
    grepl("fastq.gz$", file) ~ "FASTQ",
    grepl("fastq$", file) ~ "FASTQ",
    grepl("fq$", file) ~ "FASTQ",
    grepl("fq.gz$", file) ~ "FASTQ",
    grepl("bam$", file) ~ "BAM",
    grepl("sam$", file) ~ "SAM",
    grepl("vcf$", file) ~ "VCF",
    grepl("vcf.gz$", file) ~ "VCF",
    grepl("txt$", file) ~ "TXT",
    grepl("csv$", file) ~ "CSV",
    grepl("md5$", file) ~ "MD5",
    TRUE ~ "Other")
}

# what files do we have in the given directory
# data_dir <- "/Users/pdiakumis/Downloads/batch1"
# data_dir <- "/mnt/agha_data/transfer_20180921162830"
data_dir <- "/mnt/agha_data/vcgs_2018091320405"
d <- data_dir %>%
  list.files(full.names = TRUE) %>%
  dplyr::as_tibble() %>%
  purrr::set_names("abspath") %>%
  dplyr::mutate(fname = basename(abspath),
                ftype = guess_file_type(fname))

stopifnot(!any(duplicated(d$fname)))

l <- vector(mode = "list", length = nrow(d))
names(l) <- d$fname

for (i in 1:nrow(d)) {
  abspath <- d$abspath[i]
  fname <- d$fname[i]
  ftype <- d$ftype[i]

  mini_list <- list(abspath = abspath, fname = fname, ftype = ftype)
  l[[i]] <-  mini_list
}

l <- list(l)
names(l) <- data_dir %>% gsub("\\/", '_', .) %>% sub("_", "", .)

cat(yaml::as.yaml(l))
write(yaml::as.yaml(l), file = "../../config/validate.yaml")

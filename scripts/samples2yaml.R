require(dplyr)
require(readr)
require(purrr)
require(yaml)

# batch | bam_path | alias | phenotype
samp <- read_csv("../config/samples.csv",
                 col_types = cols(.default = col_character()),
                 col_names = TRUE) %>%
  arrange(batch)

# Simple rules for valid samples file:
# - no missing values
# - bam_path exists
# - within each batch:
#   - length = 2
#   - unique bam_path
#   - unique alias
#   - unique phenotype


if (map_int(samp, function(col) sum(is.na(col))) %>% any(. != 0)) {
  stop("No missing values allowed in the samples file!")
}

x <- samp %>%
  group_by(batch) %>%
  summarise(n_rows = n(),
            distinct_pheno = n_distinct(phenotype),
            distinct_bam = n_distinct(bam_path),
            distinct_alias = n_distinct(alias))


prob_ind <- which(x[-1] != 2, arr.ind = TRUE) %>% as.data.frame()

prob_entry <- function(x, prob_ind) {
  batch_nm <- x$batch
  problem <- names(x)[-1]
  prob_ind$batch <- batch_nm[prob_ind$row]
  prob_ind$problem <- problem[prob_ind$col]

  out <- prob_ind %>%
    select(batch, problem) %>%
    arrange(batch) %>%
    mutate(message = paste0(batch, ": ", problem)) %>%
    pull(message)
  out
}

pe <- prob_entry(x, prob_ind)

if (length(pe) > 0) {
  stop("There are issues with the samples file.\n",
       "There should be 2 rows per batch, with tumor + normal phenotypes,\n",
       "and 2 distinct BAMs and aliases per batch",
       "Check the following for indications:\n", paste(pe, collapse = "\n"))
}

bam_exists <- file.exists(paste0(samp$bam_path, ".bam")) %>% rlang::set_names(paste0(samp$bam_path, ".bam"))
if (!all(bam_exists)) {
  stop("The following BAM files do not exist, at least on this system:\n",
       paste(names(bam_exists)[!bam_exists], collapse = "\n"))
}

##---- Export to yaml ----##
samp_m <- samp %>%
  gather(key, value, -one_of('batch', 'phenotype')) %>%
  arrange(batch) %>%
  unite(var, phenotype, key) %>%
  spread(var, value)

sample_list <- vector(mode = "list", length = nrow(samp_m))

for (i in 1:nrow(samp_m)) {
  sample_list[[i]] <- list(
    normal = list(
      bam = samp_m$normal_bam_path[i],
      alias = samp_m$normal_alias[i]),
    tumor = list(
      bam = samp_m$tumor_bam_path[i],
      alias = samp_m$tumor_alias[i])
  )
}
names(sample_list) <- samp_m$batch

cat(yaml::as.yaml(sample_list)) # awesome
write(as.yaml(sample_list), file = "../config/samples.yaml")

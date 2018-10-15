require(dplyr)
require(fs)
require(readr)
require(yaml)
require(rock)

# what files do we have in the given directory
data_dir <- "/Users/pdiakumis/Downloads/fastq_invalid_tests"
d <- data_dir %>%
  fs::dir_ls() %>%
  tibble::as_tibble() %>%
  purrr::set_names("abspath") %>%
  dplyr::mutate(fname = fs::path_file(abspath),
                ftype = rock:::guess_file_type(fname))
  # dplyr::filter(ftype == "FASTQ")

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
names(l) <- basename(data_dir)

cat(yaml::as.yaml(l))
write(yaml::as.yaml(l), file = "../../config/validate.yaml")

require(dplyr)
require(fs)
require(readr)
require(yaml)
require(rock, lib.loc = "~/rock/master")

d <- "/Users/pdiakumis/Downloads/fastq_invalid_tests" %>%
  fs::dir_ls() %>%
  tibble::as_tibble() %>%
  purrr::set_names("abspath") %>%
  dplyr::mutate(fname = fs::path_file(abspath),
                ftype = rock:::guess_file_type(fname)) %>%
  dplyr::filter(ftype == "FASTQ")

stopifnot(!any(duplicated(d$fname)))

l <- vector(mode = "list", length = nrow(d))
names(l) <- d$fname

for (i in 1:nrow(d)) {
  abspath <- d$abspath[i]
  fname <- d$fname[i]
  mini_list <- list(abspath = abspath, fname = fname)
  l[[i]] <-  mini_list
}

cat(yaml::as.yaml(l))
write(yaml::as.yaml(l), file = "../../config/validate.yaml")

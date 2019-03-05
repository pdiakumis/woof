require(woofr)

root <- "/g/data3/gx8/projects/Diakumis_IPMN/2019-01-22T0233_Research-APGI-Garvan_WGS_2624/2019-01-22T0233_Research-APGI-Garvan_WGS_2624-merged"

native <-
  file.path(root, "final") %>%
  woofr::bcbio_outputs() %>%
  dplyr::filter(!ftype %in% c("Manta", "OTHER")) %>%
  dplyr::mutate(run = "native")

cwl <-
  file.path(root, "work_cromwell_rerun/cromwell_work/final") %>%
  woofr::bcbio_outputs() %>%
  dplyr::filter(!ftype %in% c("Manta", "OTHER")) %>%
  dplyr::mutate(run = "cwl")

d <-
  dplyr::bind_rows(native, cwl) %>%
  dplyr::select(run, ftype, fpath) %>%
  tidyr::spread(run, fpath)

readr::write_tsv(d, "../nogit/data/apgi_inputs.tsv", col_names = FALSE)

require(woofr)

root <- "/g/data3/gx8/projects/Diakumis_IPMN/2019-01-22T0233_Research-APGI-Garvan_WGS_2624/2019-01-22T0233_Research-APGI-Garvan_WGS_2624-merged"

native <-
  file.path(root, "final") %>%
  generate_snv_inputs() %>%
  filter(!ftype %in% c("Manta", "OTHER")) %>%
  mutate(run = "native")

cwl <-
  file.path(root, "work_cromwell_rerun/cromwell_work/final") %>%
  generate_snv_inputs() %>%
  filter(!ftype %in% c("Manta", "OTHER")) %>%
  mutate(run = "cwl")

d <-
  bind_rows(native, cwl) %>%
  select(run, ftype, fname) %>%
  spread(run, fname)


version 1.0

import "tasks/validate/md5sum.wdl" as md5sum

workflow validate_files {

  input {
    File input_data_tsv
    Array[Array[File]] input_files = read_tsv(input_data_tsv)
  }

  scatter (f in input_files) {
    call md5sum.md5sum { input: in_file = f[1], prefix = f[0] }
  }
}


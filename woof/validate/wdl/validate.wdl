version 1.0

import "tasks/md5sum.wdl" as md5sum
import "tasks/fqtools.wdl" as fqtools
import "tasks/samtools.wdl" as samtools
import "tasks/bcftools.wdl" as bcftools

workflow validate_files {

  input {
    File input_data_tsv
    Array[Array[File]] input_files = read_tsv(input_data_tsv)
  }

  scatter (f in input_files) {
    call md5sum.md5sum { input: in_file = f[1], prefix = f[0] }

    if (f[2] == "FASTQ") {
      call fqtools.fqtools { input: in_file = f[1], prefix = f[0] }
    }

    if (f[2] == "BAM") {
      call samtools.quickcheck { input: in_file = f[1], prefix = f[0] }
    }

    if (f[2] == "VCF") {
      call bcftools.querysamplenames { input: in_file = f[1], prefix = f[0] }
    }
  }
}


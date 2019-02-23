version 1.0

import "tasks/count_vcf_lines.wdl"

workflow compare_vcf_files {

  input {
    File inputSamplesFile
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  }

  scatter (sample in inputSamples) {
    call count_vcf_lines.all { input: VCF = sample[1] }
    call count_vcf_lines.pass { input: VCF = sample[1] }
  }
}

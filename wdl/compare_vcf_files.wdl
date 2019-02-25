version 1.0

import "tasks/count_vcf_lines.wdl" as count_vcf_lines
import "tasks/bcftools.wdl" as bcftools

workflow compare_vcf_files {

  input {
    File inputSamplesFile
    File inputSamplesFile2
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
    Array[Array[File]] inputSamples2 = read_tsv(inputSamplesFile2)
  }

  scatter (sample in inputSamples) {
    call count_vcf_lines.all { input: VCF = sample[1] }
    call count_vcf_lines.pass { input: VCF = sample[1] }
  }

  scatter (sample in inputSamples2) {
    call bcftools.isec {
      input:
        vcf1 = sample[0],
        vcf2 = sample[1]
    }
  }

}


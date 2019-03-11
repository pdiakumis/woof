version 1.0

import "tasks/count_vcf_lines.wdl" as count_vcf_lines
import "tasks/bcftools.wdl" as bcftools

workflow compare_vcf_files {

  input {
    File inputSamplesFile
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  }

  scatter (sample in inputSamples) {
    call count_vcf_lines.all as count_vcf_lines_all_cwl { input: VCF = sample[1] }
    call count_vcf_lines.all as count_vcf_lines_all_native { input: VCF = sample[2] }
    call count_vcf_lines.pass as count_vcf_lines_pass_cwl { input: VCF = sample[1] }
    call count_vcf_lines.pass as count_vcf_lines_pass_native { input: VCF = sample[2] }
    call bcftools.isec { input: vcf1 = sample[1], vcf2 = sample[2] }
  }


}


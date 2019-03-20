version 1.0

import "tasks/count_vcf_lines.wdl" as count_vcf_lines
import "tasks/bcftools.wdl" as bcftools
import "tasks/eval_vcf.wdl" as eval_vcf

workflow compare_vcf_files {

  input {
    File inputSamplesFile
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  }

  scatter (sample in inputSamples) {
    call count_vcf_lines.all as count_vcf_lines_all_f1 { input: VCF = sample[1] }
    call count_vcf_lines.all as count_vcf_lines_all_f2 { input: VCF = sample[2] }
    call count_vcf_lines.pass as count_vcf_lines_pass_f1 { input: VCF = sample[1] }
    call count_vcf_lines.pass as count_vcf_lines_pass_f2 { input: VCF = sample[2] }

    call bcftools.isec { input: out_dir = sample[0], vcf1 = sample[1], vcf2 = sample[2] }

    call eval_vcf.eval {
      input:
            fp_vcf = bcftools.isec.false_pos,
            fn_vcf = bcftools.isec.false_neg,
            tp_vcf = bcftools.isec.true_pos,
            outdir = sample[0]
                                }
  }


}


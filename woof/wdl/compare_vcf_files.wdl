version 1.0

import "tasks/count_vcf_lines.wdl" as count_vcf_lines
import "tasks/bcftools.wdl" as bcftools
import "tasks/eval_vcf.wdl" as eval_vcf

workflow compare_vcf_files {

  input {
    File inputSamplesFile
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
    String outdir # /abspath/to/woof/final/
    String count_outdir = outdir + "vcf_counts/"
  }

  scatter (sample in inputSamples) {
    call count_vcf_lines.all as nvar_all_f1 { input: vcf = sample[1], outdir = count_outdir + sample[0] }
    call count_vcf_lines.all as nvar_all_f2 { input: vcf = sample[2], outdir = count_outdir + sample[0] }
    call count_vcf_lines.pass as nvar_pass_f1 { input: vcf = sample[1], outdir = count_outdir + sample[0] }
    call count_vcf_lines.pass as nvar_pass_f2 { input: vcf = sample[2], outdir = count_outdir + sample[0] }

    call bcftools.isec {
      input:
        outdir = outdir + "bcftools_isec/" + sample[0],
        vcf1 = sample[1],
        vcf2 = sample[2]
    }

    call eval_vcf.eval {
      input: 
        outdir = outdir + "vcf_eval/" + sample[0],
        fp_vcf = isec.false_pos,
        fn_vcf = isec.false_neg,
        tp_vcf = isec.true_pos 
    } 
  }
}


version 1.0

import "tasks/count_vcf_lines.wdl" as count
import "tasks/bcftools.wdl" as bcftools
import "tasks/eval_snv.wdl" as eval_snv
import "tasks/eval_sv.wdl" as eval_sv
import "tasks/eval_cnv.wdl" as eval_cnv
import "tasks/eval_hrd.wdl" as eval_hrd
import "tasks/conda.wdl" as conda

workflow compare_vcf_files {

  input {
    # sample [0], vartype [1], flabel [2], run1 [3], run2 [4]
    File inputSamplesFile
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
    String outdir # /abspath/to/woof/final/
    String outdir_sample = outdir + "samples/"
  }

  call conda.list { input: outdir = outdir + "conda/"}
  scatter (sample in inputSamples) {
    # SNV VCF handling
    if (sample[1] == "snv") {

      call bcftools.filter_pass as filter_f1 { input: vcf_in = sample[3], outdir = outdir_sample + sample[0] + "/snv_pass/f1/" + sample[2] }
      call bcftools.filter_pass as filter_f2 { input: vcf_in = sample[4], outdir = outdir_sample + sample[0] + "/snv_pass/f2/" + sample[2] }

      call count.count_vars as c_all_f1 {
        input:
          vcf = sample[3], sample = sample[0], flabel = sample[2],
          outdir = outdir_sample + sample[0] + "/snv_counts/f1/" + sample[2] + "/ALL/"}
      call count.count_vars as c_all_f2 {
        input:
          vcf = sample[4], sample = sample[0], flabel = sample[2],
          outdir = outdir_sample + sample[0] + "/snv_counts/f2/" + sample[2] + "/ALL/"}
      call count.count_vars as c_pass_f1 {
        input:
          vcf = filter_f1.out, sample = sample[0], flabel = sample[2],
          outdir = outdir_sample + sample[0] + "/snv_counts/f1/" + sample[2] + "/PASS/"}
      call count.count_vars as c_pass_f2 {
        input:
          vcf = filter_f2.out, sample = sample[0], flabel = sample[2],
          outdir = outdir_sample + sample[0] + "/snv_counts/f2/" + sample[2] + "/PASS/"}

      call bcftools.isec as isec_all  {
        input:
          outdir = outdir_sample + sample[0] + "/snv_bcftools_isec/" + sample[2] + "/ALL",
          vcf1 = sample[3], vcf2 = sample[4] }
      call bcftools.isec as isec_pass {
        input:
          outdir = outdir_sample + sample[0] + "/snv_bcftools_isec/" + sample[2] + "/PASS",
          vcf1 = filter_f1.out, vcf2 = filter_f2.out }

      call eval_snv.eval as eval_snv_all {
        input:
          outdir = outdir_sample + sample[0] + "/snv_eval/" + sample[2] + "/ALL/",
          fp_vcf = isec_all.false_pos,
          fn_vcf = isec_all.false_neg,
          tp_vcf = isec_all.true_pos,
          sample = sample[0],
          flabel = sample[2],
          subset = "ALL"
      }
      call eval_snv.eval as eval_snv_pass {
        input:
          outdir = outdir_sample + sample[0] + "/snv_eval/" + sample[2] + "/PASS/",
          fp_vcf = isec_pass.false_pos,
          fn_vcf = isec_pass.false_neg,
          tp_vcf = isec_pass.true_pos,
          sample = sample[0],
          flabel = sample[2],
          subset = "PASS"
      }
    }

    # SV handling
    if (sample[1] == "sv") {
      call eval_sv.eval as eval_sv {
        input:
          sample = sample[0],
          flabel = sample[2],
          vcf1 = sample[3],
          vcf2 = sample[4],
          outdir = outdir_sample + sample[0] + "/sv_eval/" + sample[2]
      }
    }

    # CNV handling
    if (sample[1] == "cnv") {
      call eval_cnv.eval as eval_cnv {
        input:
          cnv1 = sample[3],
          cnv2 = sample[4],
          outdir = outdir_sample + sample[0] + "/cnv_eval/" + sample[2]
      }
    }

    # HRD handling
    if (sample[1] == "hrd") {
      call eval_hrd.eval as eval_hrd {
        input:
          tool = sample[2],
          hrd1 = sample[3],
          hrd2 = sample[4],
          outdir = outdir_sample + sample[0] + "/hrd_eval/" + sample[2]
      }
    }

  }
}

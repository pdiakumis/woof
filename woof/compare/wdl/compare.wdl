version 1.0

import "tasks/count_vcf_lines.wdl" as count
import "tasks/bcftools.wdl" as bcftools
import "tasks/eval_vcf.wdl" as eval_vcf

workflow compare_vcf_files {

  input {
    # sample, ftype, run1, run2
    File inputSamplesFile = "/g/data3/gx8/projects/Diakumis/woof_compare/bcbio_116a0_GRCh37_native-vs-bcbio_116a0_GRCh38_native/input_samples.tsv"
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
    String outdir = "/g/data3/gx8/projects/Diakumis/woof_compare/bcbio_116a0_GRCh37_native-vs-bcbio_116a0_GRCh38_native/woof/" # /abspath/to/woof/final/
    String count_outdir = outdir + "vcf_counts/"
  }

  scatter (sample in inputSamples) {
    call bcftools.filter_pass as filter_f1 { input: vcf_in = sample[2], outdir = outdir + sample[0] + "/vcf_pass/f1/" + sample[1] }
    call bcftools.filter_pass as filter_f2 { input: vcf_in = sample[3], outdir = outdir + sample[0] + "/vcf_pass/f2/" + sample[1] }

    call count.count_vars as c_all_f1 { input: vcf = sample[2], outdir = count_outdir + sample[0] + "/f1/" + sample[1] + "/ALL/" }
    call count.count_vars as c_all_f2 { input: vcf = sample[3], outdir = count_outdir + sample[0] + "/f2/" + sample[1] + "/ALL/"}
    call count.count_vars as c_pass_f1 { input: vcf = filter_f1.out, outdir = count_outdir + sample[0] + "/f1/" + sample[1] + "/PASS/" }
    call count.count_vars as c_pass_f2 { input: vcf = filter_f2.out, outdir = count_outdir + sample[0] + "/f2/" + sample[1] + "/PASS/" }

    call bcftools.isec as isec_all  { input: outdir = outdir + sample[0] + "/bcftools_isec/" + sample[1] + "/ALL", vcf1 = sample[2], vcf2 = sample[3] }
    call bcftools.isec as isec_pass { input: outdir = outdir + sample[0] + "/bcftools_isec/" + sample[1] + "/PASS", vcf1 = filter_f1.out, vcf2 = filter_f2.out }

    call eval_vcf.eval as eval_all {
      input:
        outdir = outdir + sample[0] + "/vcf_eval/" + sample[1] + "/ALL/",
        fp_vcf = isec_all.false_pos,
        fn_vcf = isec_all.false_neg,
        tp_vcf = isec_all.true_pos
    }
    call eval_vcf.eval as eval_pass {
      input:
        outdir = outdir + sample[0] + "/vcf_eval/" + sample[1] + "/PASS/",
        fp_vcf = isec_pass.false_pos,
        fn_vcf = isec_pass.false_neg,
        tp_vcf = isec_pass.true_pos
    }
  }
}


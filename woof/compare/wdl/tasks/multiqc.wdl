version 1.0

task cmp {
  input {
    File f1
    File f2
    String outdir # woof/final/<sample>/multiqc/<flabel>
    String outf = outdir + "/res.tsv"
    }

  command {
      #conda activate woof

      mkdir -p ~{outdir}

      R --vanilla <<CODE
      library(woofr)
      multiqc_cmp('~{f1}', '~{f2}', '~{outf}')
      CODE
  }

  output {
    File hrd_res = "~{outdir}/res.tsv"
  }
}

workflow tmp {

call cmp {
 input:
   f1 = "/Users/pdiakumis/projects/woof_compare_reports/nogit/umccrise_2.1.2_rc6/umccrised/SEQC50__SEQC-II_tumour/SEQC50__SEQC-II_tumour-multiqc_report_data/multiqc_data.json",
   f2 = "/Users/pdiakumis/projects/woof_compare_reports/nogit/umccrise_2.0.0/umccrised/SEQC50__SEQC-II_tumour/SEQC50__SEQC-II_tumour-multiqc_report_data/multiqc_data.json",
   outdir = "/Users/pdiakumis/projects/woof_compare_reports/nogit/tmp"
 }
}


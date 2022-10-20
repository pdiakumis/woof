version 1.0

task cmp {
  input {
    File f1
    File f2
    String outdir # woof/final/<sample>/canrep_qcsum/<flabel>
    String outf = outdir + "/res.tsv"
    }

  command {
      #conda activate woof

      mkdir -p ~{outdir}

      R --vanilla <<CODE
      library(woofr)
      qc_sum_cmp('~{f1}', '~{f2}', '~{outf}')
      CODE
  }

  output {
    File qc_res = "~{outdir}/res.tsv"
  }
}

workflow tmp {

call cmp {
 input:
   f1 = "/Users/pdiakumis/projects/woof_compare_reports/nogit/umccrise_2.1.2_rc6/umccrised/SEQC50__SEQC-II_tumour/cancer_report_tables/SEQC50__SEQC-II_tumour-qc_summary.tsv.gz",
   f2 = "/Users/pdiakumis/projects/woof_compare_reports/nogit/umccrise_2.0.0/umccrised/SEQC50__SEQC-II_tumour/cancer_report_tables/SEQC50__SEQC-II_tumour-qc_summary.tsv.gz",
   outdir = "/Users/pdiakumis/projects/woof_compare_reports/nogit/tmp"
 }
}



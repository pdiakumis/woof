version 1.0

task eval {
  input {
    File hrd1
    File hrd2
    String tool
    String outdir # woof/final/<sample>/hrd_eval/<flabel>
    String outf = outdir + "/hrd_probs.tsv"
    }

  command {
      #conda activate woof

      mkdir -p ~{outdir}

      R --vanilla <<CODE
      library(woofr)
      hrd_cmp('~{tool}', '~{hrd1}', '~{hrd2}', '~{outf}')
      CODE
  }

  output {
    File hrd_res = "~{outdir}/hrd_probs.tsv"
  }
}

workflow tmp {

call eval {
 input:
   hrd1 = "/Users/pdiakumis/projects/woof_compare_reports/nogit/umccrise_2.0.0/umccrised/SEQC50__SEQC-II_tumour/cancer_report_tables/hrd/SEQC50__SEQC-II_tumour-chord.tsv.gz",
   hrd2 = "/Users/pdiakumis/projects/woof_compare_reports/nogit/umccrise_2.1.2_rc6/umccrised/SEQC50__SEQC-II_tumour/cancer_report_tables/hrd/SEQC50__SEQC-II_tumour-chord.tsv.gz",
   tool = "chord",
   outdir = "/Users/pdiakumis/projects/woof_compare_reports/nogit/tmp"
 }
}



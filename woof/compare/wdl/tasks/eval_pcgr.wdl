version 1.0

task cmp {
  input {
    File f1
    File f2
    String outdir # woof/final/<sample>/pcgr_eval/<flabel>
    String outf = outdir + "/res.rds"
    }

  command {
      #conda activate woof

      mkdir -p ~{outdir}

      R --vanilla <<CODE
      library(woofr)
      l <- pcgr_cmp('~{f1}', '~{f2}')
      saveRDS(l, '~{outf}')
      CODE
  }

  output {
    File pcgr_res = "~{outdir}/res.rds"
  }
}

workflow tmp {

call cmp {
 input:
   f1 = "/Users/pdiakumis/projects/woof/woof_compare_reports/nogit/umccrise_2.3.0rc.4/umccrised/SEQC50__SEQC-II_tumour/small_variants/SEQC50__SEQC-II_tumour-somatic.pcgr.snvs_indels.tiers.tsv",
   f2 = "/Users/pdiakumis/projects/woof/woof_compare_reports/nogit/umccrise_2.2.0/umccrised/SEQC50__SEQC-II_tumour/small_variants/SEQC50__SEQC-II_tumour-somatic.pcgr.snvs_indels.tiers.tsv",
   outdir = "/Users/pdiakumis/projects/woof/woof_compare_reports/nogit/tmp"
 }
}



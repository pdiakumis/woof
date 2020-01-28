version 1.0

task eval {
  input {
    File cnv1
    File cnv2
    String outdir # woof/final/<sample>/cnv_eval/<flabel>
    String out_cn_diff = outdir + "/cn_diff.tsv"
    String out_coord_diff = outdir + "/coord_diff.tsv"
    }

  command {
      #conda activate woof

      R --vanilla <<CODE
      library(woofr)
      compare_purple_gene_files('~{cnv1}', '~{cnv2}', '~{out_cn_diff}', '~{out_coord_diff}')
      CODE
  }

  output {
    File cn_diff = "~{outdir}/cn_diff.tsv"
    File coord_diff = "~{outdir}/coord_diff.tsv"
  }
}

# workflow tmp {

# call eval {
#  input:
#    cnv1 = "/Users/pdiakumis/Desktop/projects/umccr/woof/nogit/data/umccrise_0.15.12/p25/umccrised/p25/2016_249_18_WH_P025__CCR180149_VPT-WH025-E.purple.gene.cnv",
#    cnv2 = "/Users/pdiakumis/Desktop/projects/umccr/woof/nogit/data/umccrise_0.15.6/p25/umccrised/p25/2016_249_18_WH_P025__CCR180149_VPT-WH025-E.purple.gene.cnv",
#    outdir = "/Users/pdiakumis/Desktop/projects/umccr/woofr/nogit/cnv"

#  }

# }


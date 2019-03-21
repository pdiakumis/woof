version 1.0

task eval {
  input {
    File fp_vcf
    File fn_vcf
    File tp_vcf
    String outdir # woof/final/<vcf-type>
    String tsv = outdir + "_eval_stats.tsv"
  }

  command {

  conda activate woof

  python <<CODE
  from woof.compare import eval
  eval.eval("~{fp_vcf}", "~{fn_vcf}", "~{tp_vcf}", "~{tsv}")
  CODE
  }

  output {
      File tsv = "~{tsv}"
  }
}


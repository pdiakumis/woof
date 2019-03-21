version 1.0

task eval {
  input {
    File fp_vcf
    File fn_vcf
    File tp_vcf
    String out
  }

  command {

  conda activate woof

  python <<CODE
  from woof.compare import eval
  eval.eval("~{fp_vcf}", "~{fn_vcf}", "~{tp_vcf}", "~{out}_eval_stats.tsv")
  CODE
  }

  output {
      File eval_stats = "~{out}_eval_stats.tsv"
  }
}


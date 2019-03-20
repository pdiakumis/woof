version 1.0

task eval {
  input {
    File fp_vcf
    File fn_vcf
    File tp_vcf
    String outdir
  }

  command {

  python <<CODE
  from woof.compare import eval
  eval.eval("~{fp_vcf}", "~{fn_vcf}", "~{tp_vcf}", "~{outdir}")
  CODE
  }

  output {
      File eval_stats = "~{outdir}" + "eval_stats.tsv"
  }
}

workflow eval_vcf {
    call eval
}

version 1.0

task eval {
  input {
    File fp_vcf
    File fn_vcf
    File tp_vcf
    String outdir # woof/final/<sample>/vcf_eval/<flabel>/<pass-or-all>/
    String tsv = outdir + "eval_stats.tsv"
  }

  command {

    conda activate woof
    mkdir -p ~{outdir}

    python <<CODE
    from woof.compare import eval
    eval.eval("~{fp_vcf}", "~{fn_vcf}", "~{tp_vcf}", "~{tsv}")
    CODE
  }

  output {
      File out = "~{tsv}"
  }
}


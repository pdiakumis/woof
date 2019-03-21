version 1.0

task isec {
  input {

    File vcf1
    File vcf2
    # indices required
    File vcf1_tbi = vcf1 + ".tbi"
    File vcf2_tbi = vcf2 + ".tbi"
    String outdir
  }

  command {
    conda activate woof
    bcftools isec ~{vcf1} ~{vcf2} -p ~{outdir}
  }

  output {
    File false_pos = "~{outdir}/0000.vcf"
    File false_neg = "~{outdir}/0001.vcf"
    File true_pos = "~{outdir}/0002.vcf"
  }
}


version 1.0

task isec {
  input {

    File vcf1
    File vcf2
    # indices required
    File vcf1_tbi = vcf1 + ".tbi"
    File vcf2_tbi = vcf2 + ".tbi"
    String out_dir
  }

  command {
    bcftools isec ~{vcf1} ~{vcf2} -p ~{out_dir}
  }

  output {
    File false_pos = "~{out_dir}/0000.vcf"
    File false_neg = "~{out_dir}/0001.vcf"
    File true_pos = "~{out_dir}/0002.vcf"
  }
}


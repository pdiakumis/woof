task count_vcf_variants_all {
  File VCF
  String out = basename(VCF, ".vcf.gz")

  command {
    gunzip -c ${VCF} | grep -v "^#" | wc -l > ${out}_variants_all.txt
  }

  output {
    File counts = "${out}_variants_all.txt"
  }
}

workflow get_lines {
  File inputSamplesFile
  Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)

  scatter (sample in inputSamples) {
    call count_vcf_variants_all {
      input:
        VCF = sample[1]
    }
  }
}

version 1.0

task grch37_to_hg19 {
  input {
    File vcf_in
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>
    String vcf_name = basename(vcf_in)
    String vcf_out = outdir + "/" + vcf_name
  }

  command {
    conda activate woof
    gunzip -c ~{vcf_in} \
    | py -x "x.replace('##contig=<ID=', '##contig=<ID=chr') if x.startswith('#') else 'chr' + x" \
    | py -x "x.replace('chrMT', 'chrM')" \
    | grep -v "chrG" \
    | gzip -c > ~{vcf_out}
  }

  output {
    File vcf_out = "~{vcf_out}"
  }
}

task hg19_to_hg38_unsorted {

  input {
    File vcf_in
    File chain_hg19tohg38
    File hg38_fasta
    String vcf_out
  }

  command {
    conda activate crossmap
    CrossMap.py vcf ~{chain} ~{vcf_in} ~{hg38_fasta} ~{vcf_out}
  }

  output {
    File vcf_out = "~{vcf_out}"
  }
}

workflow test {
  call grch37_to_hg19 {
    input:
      vcf_in = "~/Desktop/projects/umccr/woof/nogit/data/f1/final/CUP-Pairs8-ensemble-annotated.vcf.gz"

  }
  call hg19_to_hg38_unsorted {
    input:
      vcf_in = grch37_to_hg19.out,
      chain_hg19tohg38 = "~/Desktop/projects/umccr/woof/nogit/data/hg19ToHg38.over.chain.gz",
      hg38_fasta = "~/Desktop/projects/umccr/woof/nogit/data/hg38.fa.gz",
      vcf_out = "~/Desktop/projects/umccr/woof/nogit/data/f1/final/CUP-Pairs8-ensemble-annotated_hg38_unsorted.vcf.gz"

  }
}


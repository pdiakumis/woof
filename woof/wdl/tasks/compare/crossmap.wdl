version 1.0

task grch37_to_hg19 {
  input {
    File vcf_in
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, ".vcf.gz") + "_hg19.vcf.gz"
  }

  command {
    #conda activate woof

    mkdir -p ~{outdir}

    gunzip -c ~{vcf_in} \
    | py -x "x.replace('##contig=<ID=', '##contig=<ID=chr') if x.startswith('#') else 'chr' + x" \
    | py -x "x.replace('chrMT', 'chrM')" \
    | grep -v "chrG" \
    | gzip -c > ~{vcf_out}
  }

  output {
    File out = "~{vcf_out}"
  }
}

task hg19_to_hg38_unsorted {

  input {
    File vcf_in
    File chain_hg19tohg38
    File hg38_fasta
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, ".vcf.gz") + "_hg38_unsorted.vcf"
  }

  command {
    #conda activate woof

    CrossMap.py vcf ~{chain_hg19tohg38} ~{vcf_in} ~{hg38_fasta} ~{vcf_out}
  }

  output {
    File out = "~{vcf_out}"
  }
}

workflow test {
  input {
    String woofdir = "/Users/pdiakumis/Desktop/tmp/woof/"
  }

  call grch37_to_hg19 {
    input:
      vcf_in = "/Users/pdiakumis/Desktop/projects/umccr/woof/nogit/data/f1/final/CUP-Pairs8-ensemble-annotated.vcf.gz",
      outdir = woofdir
  }
  call hg19_to_hg38_unsorted {
    input:
      vcf_in = grch37_to_hg19.out,
      chain_hg19tohg38 = "/Users/pdiakumis/Desktop/projects/umccr/woof/nogit/data/hg19ToHg38.over.chain.gz",
      hg38_fasta = "/Users/pdiakumis/Desktop/projects/umccr/woof/nogit/data/hg38.fa.gz",
      outdir = woofdir

  }
}


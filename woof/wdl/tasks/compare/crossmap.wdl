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
    String vcf_out_unmap = outdir + basename(vcf_in, ".vcf.gz") + "_hg38_unsorted.vcf.unmap"
  }

  command {
    #conda activate woof

    CrossMap.py vcf ~{chain_hg19tohg38} ~{vcf_in} ~{hg38_fasta} ~{vcf_out}
  }

  output {
    File out = "~{vcf_out}"
    File out_unmap = "~{vcf_out_unmap}"
  }
}

task hg38_sort {

  input {
    File vcf_in
    File hg38_noalt_bed = "/g/data3/gx8/extras/hg38_noalt.bed"
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, "_hg19_hg38_unsorted.vcf") + ".vcf.gz" # give same name as original input
  }

  command {
    bcftools view ~{vcf_in} -T ~{hg38_noalt_bed} | \
    bcftools sort -Oz -o ~{vcf_out} && tabix -p vcf ~{vcf_out}
  }

  output {
    File out = "~{vcf_out}"
  }
}


workflow test {
  input {
    File inputSamplesFile = "inputs_grch37-to-hg38.tsv"
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile) # samplename, varcaller, filepath
    String woofdir = "/g/data3/gx8/projects/Diakumis/woof/woof/wdl/tasks/compare/test/"
  }

  scatter (sample in inputSamples) {
    call grch37_to_hg19 { input: vcf_in = sample[2], outdir = woofdir + sample[0] + "/" + sample[1] + "/" }

    call hg19_to_hg38_unsorted {
      input:
        vcf_in = grch37_to_hg19.out,
        chain_hg19tohg38 = "/g/data3/gx8/extras/hg19ToHg38.over.chain.gz",
        hg38_fasta = "/g/data/gx8/local/development/bcbio/genomes/Hsapiens/hg38/seq/hg38.fa",
        outdir = woofdir
    }

    call hg38_sort { input: vcf_in = hg19_to_hg38_unsorted.out, outdir = woofdir }
  }
}


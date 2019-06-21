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

task crossmap_hg19_to_hg38_unsorted {

  input {
    File vcf_in
    File chain_hg19tohg38
    File hg38_fasta
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, ".vcf.gz") + "_to_hg38_unsorted.vcf"
    String vcf_out_unmap = outdir + basename(vcf_in, ".vcf.gz") + "_to_hg38_unsorted.vcf.unmap"
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

task hg38_filter_noalt {

  input {
    File vcf_in
    File hg38_noalt_bed = "/g/data3/gx8/extras/hg38_noalt.bed"
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, "_hg19_to_hg38_unsorted.vcf") + "_hg38_unsorted_noalt.vcf.gz"
  }

  command {
    bcftools view -Oz -o ~{vcf_out} ~{vcf_in} -T ~{hg38_noalt_bed}
  }

  output {
    File out = "~{vcf_out}"
  }
}

task hg38_sort_final {

  input {
    File vcf_in
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, "_hg38_unsorted_noalt.vcf") + "_hg38_final.vcf.gz"
  }

  command {
    bcftools sort -Oz -o ~{vcf_out} ~{vcf_in} && \
    tabix -p vcf ~{vcf_out}
  }

  output {
    File out = "~{vcf_out}"
  }
}


workflow test {
  input {
    File inputSamplesFile = "/g/data3/gx8/projects/Diakumis/woof/test_woof/compare/inputs_grch37-to-hg38_10.tsv"
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile) # samplename, varcaller, filepath
    String woofdir = "/g/data3/gx8/projects/Diakumis/woof/test_woof/crossmap/"
  }

  scatter (sample in inputSamples) {

    call grch37_to_hg19 { input: vcf_in = sample[2], outdir = woofdir + sample[0] + "/" + sample[1] + "/" }

    call crossmap_hg19_to_hg38_unsorted {
      input:
        vcf_in = grch37_to_hg19.out,
        chain_hg19tohg38 = "/g/data3/gx8/extras/hg19ToHg38.over.chain.gz",
        hg38_fasta = "/g/data/gx8/local/development/bcbio/genomes/Hsapiens/hg38/seq/hg38.fa",
        outdir = woofdir + sample[0] + "/" + sample[1] + "/"
    }
    call hg38_filter_noalt {
      input:
        vcf_in = crossmap_hg19_to_hg38_unsorted.out,
        outdir = woofdir + sample[0] + "/" + sample[1] + "/"
    }

    call hg38_sort_final {
      input:
        vcf_in = hg38_filter_noalt.out,
        outdir = woofdir + sample[0] + "/" + sample[1] + "/"
    }
  }
}


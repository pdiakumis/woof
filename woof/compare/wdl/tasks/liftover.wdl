version 1.0

# input: VCF in GRCh37
#
# process:
# gatk/picard liftover from GRCh37 to hg38
# gatk selectvariants noalt
#
# output: VCF in hg38 with noalt

task gatk_liftover_grch37_to_hg38 {
  input {
    File vcf_in
    File chain_grch37_to_hg38
    File hg38_ref
    File hg38_refindex
    File hg38_refdict
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, ".vcf.gz") + "_hg38.vcf.gz"
    String vcf_out_rejected = outdir + basename(vcf_in, ".vcf.gz") + "_rejected_liftover.vcf.gz"
  }

  command {
    #conda activate woof

    mkdir -p ~{outdir}

    gatk LiftoverVcf \
      --INPUT=~{vcf_in} \
      --OUTPUT=~{vcf_out} \
      --REJECT=~{vcf_out_rejected} \
      --CHAIN=~{chain_grch37_to_hg38} \
      --REFERENCE_SEQUENCE=~{hg38_ref}
  }

  output {
    File out = vcf_out
    File out_rejected = vcf_out_rejected
  }
}

task gatk_selectvariants_noalt {

  input {
    File vcf_in
    File hg38_ref
    File hg38_refindex
    File hg38_refdict
    File hg38_noalt_bed = "/g/data3/gx8/extras/hg38_noalt.bed"
    String outdir # woof/final/crossmap/<f1-or-f2>/<vcf_type>/grch37_to_hg19
    String vcf_out = outdir + basename(vcf_in, "_hg38.vcf.gz") + "_hg38_noalt.vcf.gz"
  }

  command {
    gatk SelectVariants \
      --variant ~{vcf_in} \
      --output ~{vcf_out} \
      --reference ~{hg38_ref} \
      --intervals ~{hg38_noalt_bed}
  }

  output {
    File out = vcf_out
    File out_index = vcf_out + ".tbi"
  }
}

workflow liftover {
  input {
    File inputSamplesFile = "/g/data3/gx8/projects/Diakumis/woof/test_woof/compare/inputs_grch37-to-hg38_10.tsv"
    Array[Array[File]] inputSamples = read_tsv(inputSamplesFile) # samplename, varcaller, filepath
    String woofdir = "/g/data3/gx8/projects/Diakumis/woof/test_woof/crossmap/"
    File hg38_ref = "/g/data/gx8/local/development/bcbio/genomes/Hsapiens/hg38/seq/hg38.fa"
    File hg38_refindex = "/g/data/gx8/local/development/bcbio/genomes/Hsapiens/hg38/seq/hg38.fa.fai"
    File hg38_refdict = "/g/data/gx8/local/development/bcbio/genomes/Hsapiens/hg38/seq/hg38.dict"
  }

  scatter (sample in inputSamples) {

    call gatk_liftover_grch37_to_hg38 {
      input:
        vcf_in = sample[2],
        outdir = woofdir + sample[0] + "/" + sample[1] + "/",
        chain_grch37_to_hg38 = "/g/data3/gx8/extras/liftover_chains/b37ToHg38.over.chain"
    }

    call gatk_selectvariants_noalt {
      input:
        vcf_in = gatk_liftover_grch37_to_hg38.out,
        outdir = woofdir + sample[0] + "/" + sample[1] + "/"
    }

  }
}


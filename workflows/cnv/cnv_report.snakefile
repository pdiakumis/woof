configfile: 'config.yaml'

shell.prefix("set -euo pipefail; ")
shell.prefix("module load SAMtools; ")
shell.prefix("module load HTSlib; ")


localrules: all, test

SAMPLES_HCC2218 = ["HCC2218"]
SAMPLES_A5 = ["E019", "E120", "E121", "E123", "E124", "E125",
              "E129", "E130", "E131", "E133", "E134", "E140",
              "E141", "E142", "E143", "E144", "E153", "E155",
              "E156", "E158", "E162", "E163", "E164", "E165",
              "E168", "E170"]

rule all:
    input:
        expand(config["out_dir"] + config["facets"]["out_dir"] + "{project}/{sample}_cov.csv.gz", sample = SAMPLES_HCC2218, project = "HCC2218"),
        expand(config["out_dir"] + config["facets"]["out_dir"] + "{project}/{sample}_cov.csv.gz", sample = SAMPLES_A5, project = "A5")



rule facets_coverage:
    input:
        vcf    = config["data_dir"] + config["facets"]["vcf"],
        normal = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["normal"],
        tumor  = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["tumor"]
    output:
        coverage = config["out_dir"] + config["facets"]["out_dir"] + "{project}/{sample}_cov.csv.gz"
    params:
        pileup = config["facets"]["snp-pileup"]
    shell:
        "{params.pileup} -g -q 30 -Q 30 -r 10,10 "
        "{input.vcf} "
        "{output.coverage} "
        "{input.normal} {input.tumor}"


rule test:
    input:
        vcf    = config["data_dir"] + config["facets"]["vcf"],
        normal = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["normal"],
        tumor  = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["tumor"]
    output:
        txt = "out/{project}_{sample}_tmp.txt"
    shell:
        "echo 'VCF: {input.vcf}\nTumor: {input.tumor}\nNormal: {input.normal}' > {output.txt}"

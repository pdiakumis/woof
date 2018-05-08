configfile: 'config.yaml'

shell.prefix("set -euo pipefail; ")
#shell.prefix("module load SAMtools; ")
#shell.prefix("module load HTSlib; ")


localrules: all, test

SAMPLES_HCC2218 = ["HCC2218"]
SAMPLES_A5 = ["E019", "E120", "E121", "E123", "E124", "E125",
              "E129", "E130", "E131", "E133", "E134", "E140",
              "E141", "E142", "E143", "E144", "E153", "E155",
              "E156", "E158", "E162", "E163", "E164", "E165",
              "E168", "E170"]

rule all:
    input:
        expand(config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_{type}.png", sample = SAMPLES_A5, project = "A5", cval = [150, 500], type = ["cnv", "spider"])


rule facets_coverage:
    input:
        vcf    = config["data_dir"] + config["facets"]["vcf"],
        normal = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["normal"],
        tumor  = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["tumor"]
    output:
        snpfile = config["out_dir"] + config["facets"]["cov_dir"] + "{project}/{sample}_cov.csv.gz"
    params:
        pileup = config["facets"]["snp-pileup"]
    shell:
        "{params.pileup} -g -q 30 -Q 30 -r 10,10 "
        "{input.vcf} "
        "{output.snpfile} "
        "{input.normal} {input.tumor}"

rule facets_run:
    input:
        snpfile = config["out_dir"] + config["facets"]["cov_dir"] + "{project}/{sample}_cov.csv.gz"
    output:
        fit = config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
    params:
        outdir = config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}",
        run_facets = "/data/cephfs/punim0010/projects/Diakumis_woof/scripts/structural/run_facets.R"
    log:
        log = config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_run_facets_cval_{cval}.log"
    shell:
        "/usr/local/easybuild/software/R/3.5.0-GCC-4.9.2/bin/Rscript {params.run_facets} "
        "-s {wildcards.sample} -f {input.snpfile} -c {wildcards.cval} -o {params.outdir} 2> {log.log}"

rule pdf2png:
    input:
        pdf = "{sample}.pdf"
    output:
        png = "{sample}.png"
    shell:
        "module load ImageMagick; convert -antialias -density 300 {input.pdf} {output.png}"

rule test:
    input:
        vcf    = config["data_dir"] + config["facets"]["vcf"],
        normal = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["normal"],
        tumor  = lambda wildcards: config["data_dir"] + config["bam_dir"][wildcards.project] + config["samples"][wildcards.sample]["tumor"]
    output:
        txt = "out/{project}_{sample}_tmp.txt"
    shell:
        "echo 'VCF: {input.vcf}\nTumor: {input.tumor}\nNormal: {input.normal}' > {output.txt}"

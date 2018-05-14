configfile: 'config.yaml'

shell.prefix("set -euo pipefail; ")

localrules: all

SAMPLES_HCC2218 = ["HCC2218"]
SAMPLES_A5_batch1 = ["E019", "E120", "E121", "E123", "E124", "E125", "E129",
                     "E130", "E131", "E133", "E134", "E140", "E141", "E142",
                     "E143", "E144", "E153", "E155", "E156", "E158", "E162",
                     "E163", "E164", "E165", "E168", "E170",
                     "E122-1", "E122-2", "E146-1", "E146-2",
                     "E159-1", "E159-2", "E159-3", "E159-4",
                     "E169-1", "E169-2"]


rule all:
    input:
        expand(config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds", project = "A5_batch1", sample = SAMPLES_A5_batch1, cval = 150),
        expand(config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_{type}.png", project = "A5_batch1", sample = SAMPLES_A5_batch1, cval = 150, type = ["cnv", "spider"])




rule facets_coverage:
    input:
        vcf    = config["data_dir"] + config["facets"]["vcf"],
        normal = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples_A5_batch1"][wildcards.sample]["normal"]["bam"],
        tumor  = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples_A5_batch1"][wildcards.sample]["tumor"]["bam"]
    output:
        snpfile = config["out_dir"] + config["facets"]["cov_dir"] + "{project}/{sample}_cov.csv.gz"
    params:
        pileup = config["facets"]["snp-pileup"]
    shell:
        "module load SAMtools; module load HTSlib; "
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


rule facets_report:
    input:
        fit = config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
    params:
        outdir = config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}",
    log:
        log = config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_run_facets_cval_{cval}.log"
    shell:
        "Rscript ../../templates/structural/render_facets_report.R "
        "-r ../../templates/structural/facets_report.Rmd "
        "-s {wildcards.sample} -c {wildcards.cval} -o {params.outdir} 2> {log.log}"


rule pdf2png:
    input:
        pdf = "{sample}.pdf"
    output:
        png = "{sample}.png"
    shell:
        "module load ImageMagick; convert -antialias -density 300 {input.pdf} {output.png}"

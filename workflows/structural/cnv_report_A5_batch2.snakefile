configfile: 'config.yaml'

shell.prefix("set -euo pipefail; ")

localrules: all

SAMPLES = [ "E126", "E127", "E128-1", "E128-2", "E132-1", "E132-2", "E135",
            "E136", "E138", "E143-1", "E143-2", "E145", "E147", "E148",
            "E149", "E150", "E152", "E154", "E157", "E160", "E161",
            "E166", "E167-1", "E167-2", "E171"]

rule all:
    input:
        expand(config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds", project = "A5_batch2", sample = SAMPLES, cval = 150),
        expand(config["out_dir"] + config["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_{type}.png", project = "A5_batch2", sample = SAMPLES, cval = 150, type = ["cnv", "spider"])



rule facets_coverage:
    input:
        vcf    = config["data_dir"] + config["facets"]["vcf"],
        normal = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples_A5_batch2"][wildcards.sample]["normal"]["bam"],
        tumor  = lambda wildcards: config["bam_dir"][wildcards.project] + config["samples_A5_batch2"][wildcards.sample]["tumor"]["bam"]
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

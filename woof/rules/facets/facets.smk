include: 'facets_settings.py'

config['tools']['facets']['run'] = {
    'outdir' : join(config['tools']['facets']['outdir'], 'results')
}


rule facets_run:
    input:
        pileup = join(config['tools']['facets']['pileup']['outdir'], '{batch}.pileup.csv.gz')
    output:
        segs = join(config['tools']['facets']['run']['outdir'], '{batch}/{batch}_cval_{cval}_segs.tsv')
    params:
        outdir = join(config['tools']['facets']['run']['outdir']),
        run_facets_script = join(config['woof']['root_dir'], 'scripts/structural/facets', 'run_facets.R')
    log:
        log = join(config['tools']['facets']['run']['outdir'], '{batch}_cval_{cval}.log')
    shell:
        'module load R; '
        'Rscript {params.run_facets_script} '
        '-b {wildcards.batch} '
        '-f {input.pileup} '
        '-c {wildcards.cval} '
        '-o {params.outdir} > {log.log} 2>&1'


#rule facets_report:
#    input:
#        fit = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_cval_{cval}_fit.rds"
#    params:
#        outdir = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}",
#    log:
#        log = config["out_dir"] + config["tools"]["facets"]["results_dir"] + "{project}/{sample}/{sample}_run_facets_cval_{cval}.log"
#    shell:
#        'module load R; '
#        'Rscript params'
#        "Rscript ../../templates/structural/render_facets_report.R "
#        "-r ../../templates/structural/facets_report.Rmd "
#        "-s {wildcards.sample} -c {wildcards.cval} -o {params.outdir} 2> {log.log}"
#
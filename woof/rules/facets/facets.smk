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
        log = join(config['tools']['facets']['run']['outdir'], '{batch}_cval_{cval}_facets_run.log')
    shell:
        'module load R; '
        'Rscript {params.run_facets_script} '
        '-b {wildcards.batch} '
        '-f {input.pileup} '
        '-c {wildcards.cval} '
        '-o {params.outdir} > {log.log} 2>&1'


rule facets_report:
    input:
        segs = join(config['tools']['facets']['run']['outdir'], '{batch}/{batch}_cval_{cval}_segs.tsv'),
        rmd_template = join(config['woof']['root_dir'], 'templates/structural', 'facets_report.Rmd')
    output:
        html = join(config['tools']['facets']['run']['outdir'], '{batch}/{batch}_cval_{cval}_report.html')
    params:
        results_dir = join(config['tools']['facets']['run']['outdir'])
    log:
        log = join(config['tools']['facets']['run']['outdir'], '{batch}/{batch}_cval_{cval}_report.html.log')
    shell:
        'module load R; '
        'Rscript -e "rmarkdown::render(\'{input.rmd_template}\', '
        'output_file = \'{output.html}\', '
        'params = list('
        'results_dir = \'{params.results_dir}\', '
        'batchname = \'{wildcards.batch}\', '
        'cval = \'{wildcards.cval}\'))" '
        '> {log.log} 2>&1'

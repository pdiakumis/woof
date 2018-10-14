include: 'purple_settings.py'

rule purple_report:
    input:
        segs = join(config['tools']['purple']['outdir'], '{batch}', 'purple/{tumor_alias}.purple.cnv'),
        rmd_template = join(config['woof']['root_dir'], 'templates/structural', 'purple_report.Rmd')
    output:
        html = join(config['tools']['purple']['outdir'], '{batch}', 'purple/{tumor_alias}.purple_report.html')
    params:
        results_dir = join(config['tools']['purple']['outdir'], '{batch}', 'purple'),
        tumor_alias = lambda wc: alias_from_pheno(config, wc.batch, 'tumor')
    threads:
        1
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{tumor_alias}_purple_report.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'Rscript -e "rmarkdown::render(\'{input.rmd_template}\', '
        'output_file = \'{output.html}\', '
        'params = list('
        'results_dir = \'{params.results_dir}\', '
        'tumor_name = \'{params.tumor_alias}\'))" '
        '>> {log.log} 2>&1; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '



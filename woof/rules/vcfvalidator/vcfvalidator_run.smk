
include: 'vcfvalidator_settings.py'

rule vcfvalidator_run:
    input:
        vcf = lambda wc: abspath_from_fname(config, wc.batch, wc.fname)
    output:
        summary = join(config['tools']['vcfvalidator']['outdir'], '{batch}/{fname}_valid_summary.txt')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}', '{fname}_vcfvalidator.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '( vcf_validator -i {input.vcf} -r summary -o $( dirname {output.summary} ) || true ) >> {log.log} 2>&1; '
        'mv $( dirname {output.summary} )/{wildcards.fname}.errors_summary.*.txt {output.summary}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

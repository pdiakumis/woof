include: 'md5sum_settings.py'

rule md5sum_run:
    input:
        f = lambda wc: abspath_from_fname(config, wc.batch, wc.fname)
    output:
        txt = join(config['tools']['md5sum']['outdir'], '{batch}/{fname}_md5sum.txt')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{fname}_md5sum_validate.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'md5sum {input.f} > {output.txt} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

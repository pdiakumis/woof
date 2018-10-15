include: 'fqtools_settings.py'

config['tools']['fqtools']['validate'] = {
    'outdir' : join(config['tools']['fqtools']['outdir'], 'validate')
}


rule fqtools_validate:
    input:
        f = lambda wc: abspath_from_fname(config, wc.batch, wc.fname)
    output:
        txt = join(config['tools']['fqtools']['validate']['outdir'], '{batch}', '{fname}_valid.txt')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}', '{fname}_fqtools_validate.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '( fqtools validate {input.f} || true ) > {output.txt} 2>&1; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

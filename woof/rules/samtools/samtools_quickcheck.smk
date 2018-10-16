include: 'samtools_settings.py'

config['tools']['samtools']['quickcheck'] = {
    'outdir' : join(config['woof']['final_dir'], 'validate/samtools_quickcheck'),
}


rule samtools_quickcheck:
    input:
        bam = lambda wc: abspath_from_fname(config, wc.batch, wc.fname)
    output:
        summary = join(config['tools']['samtools']['quickcheck']['outdir'], '{batch}/{fname}_valid_summary.txt')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}', '{fname}_samtools_quickcheck.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '( samtools quickcheck -q {input.bam} && echo "ok" || echo "fail" ) > {output.summary} 2>&1; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '



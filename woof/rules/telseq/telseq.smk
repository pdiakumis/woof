
config['tools']['telseq'] = {
    'outdir' : join(config['woof']['final_dir'], 'structural/telseq')
}



rule telseq_run:
    input:
        bam = lambda wc: bam_from_alias(config, wc.batch, wc.alias) + '.bam'
    output:
        tsv = join(config['tools']['telseq']['outdir'], '{batch}/{alias}_telseq.tsv')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_telseq.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'telseq -k 9 -r 150 -m -o {output.tsv} {input.bam} >> {log.log} 2>&1; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '
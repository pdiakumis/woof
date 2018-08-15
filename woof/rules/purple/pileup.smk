include: 'purple_settings.py'


rule amber_pileup:
    input:
        bam = lambda wc: bam_from_alias(config, wc.batch, wc.alias) + '.bam'
    output:
        mpileup = join(config['tools']['purple']['outdir'], '{batch}', 'amber/{alias}.mpileup')
    params:
        snp_bed = config['tools']['purple']['hmf_data']['snp_bed'],
        fasta = config['HPC']['ref_fasta']
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_amber-pileup.log')
    threads: 32
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'sambamba mpileup '
        '-t {threads} '
        '-L {params.snp_bed} '
        '{input.bam} '
        '--samtools -q 1 '
        '-f {params.fasta} '
        '> {output.mpileup} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

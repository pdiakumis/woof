include: 'purple_settings.py'

config['tools']['purple']['amber_pileup'] = {
    'outdir' : join(config['tools']['purple']['outdir'], 'amber'),
}

rule amber_pileup:
    input:
        bam = lambda wc: bam_from_alias(config, wc.batch, wc.alias) + '.bam'
    output:
        mpileup = join(config['tools']['purple']['amber_pileup']['outdir'], '{batch}/{alias}.mpileup')
    params:
        snp_bed = config['tools']['purple']['hmf_data']['snp_bed'],
        fasta = config['HPC']['ref_fasta']
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_amber.log')
    threads: 24
    shell:
        'sambamba mpileup '
        '-t {threads} '
        '-L {params.snp_bed} '
        '{input.bam} '
        '--samtools -q 1 '
        '-f {params.fasta} '
        '> {output.mpileup} 2> {log.log}'

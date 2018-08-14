include: 'facets_settings.py'

config['tools']['facets']['pileup'] = {
    'outdir' : join(config['tools']['facets']['outdir'], 'pileup')
}


rule facets_pileup:
    input:
        vcf = join(config['HPC']['woof_data'], 'facets/00-common_all_GRCh37.vcf.gz'),
        normal_bam = lambda wc: bam_from_pheno(config, wc.batch, 'normal') + '.bam',
        tumor_bam = lambda wc: bam_from_pheno(config, wc.batch, 'tumor') + '.bam'
    output:
        pileup = join(config['tools']['facets']['pileup']['outdir'], '{batch}.pileup.csv.gz')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{batch}_facets_pileup.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'snp-pileup -g -q 30 -Q 30 -r 10,10 '
        '{input.vcf} '
        '{output.pileup} '
        '{input.normal_bam} {input.tumor_bam} '
        ' >> {log.log} 2>&1 ; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

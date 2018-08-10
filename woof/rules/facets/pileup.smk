include: 'facets_settings.py'

config['tools']['facets']['pileup'] = {
    'outdir' : join(config['tools']['facets']['outdir'], 'pileup'),
    'command': join(config['HPC']['extras'], 'woof/r-pkgs/current/facets/extcode', 'snp-pileup')
}


rule facets_pileup:
    input:
        vcf = join(config['HPC']['woof_data'], 'facets/00-common_all_GRCh37.vcf.gz'),
        normal_bam = lambda wc: bam_from_pheno(config, wc.batch, 'normal') + '.bam',
        tumor_bam = lambda wc: bam_from_pheno(config, wc.batch, 'tumor') + '.bam'
    output:
        pileup = join(config['tools']['facets']['pileup']['outdir'], '{batch}.pileup.csv.gz')
    params:
        pileup_cmd = config['tools']['facets']['pileup']['command'],
        htslib = config['HPC']['htslib_module']
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{batch}_facets_pileup.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'module load {params.htslib}; '
        '{params.pileup_cmd} -g -q 30 -Q 30 -r 10,10 '
        '{input.vcf} '
        '{output.pileup} '
        '{input.normal_bam} {input.tumor_bam} '
        ' >> {log.log} 2>&1 ; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

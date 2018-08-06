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
        pileup_cmd = config['tools']['facets']['pileup']['command']
    shell:
        'module load HTSlib; '
        '{params.pileup_cmd} -g -q 30 -Q 30 -r 10,10 '
        '{input.vcf} '
        '{output.pileup} '
        '{input.normal_bam} {input.tumor_bam}'

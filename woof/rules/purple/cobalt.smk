include: 'purple_settings.py'

config['tools']['purple']['cobalt'] = {
    'outdir' : join(config['tools']['purple']['outdir'], 'cobalt'),
    'jar' : join(config['tools']['purple']['hmf_data']['dir'], 'cobalt-1.4.jar')
}


rule :
    input:
        normal_bam = lambda wc: bam_from_pheno(config, wc.batch, 'normal') + '.bam',
        tumor_bam = lambda wc: bam_from_pheno(config, wc.batch, 'tumor') + '.bam'
    output:
        tumor_cobalt = join(config['tools']['purple']['cobalt']['outdir'], '{batch}', '{tumor_alias}.cobalt')
    params:
        normal_alias = lambda wc: alias_from_pheno(config, wc.batch, 'normal'),
        tumor_alias = lambda wc: alias_from_pheno(config, wc.batch, 'tumor'),
        java = config['HPC']['java'],
        gc = config['tools']['purple']['hmf_data']['gc_profile'],
        outdir = join(config['tools']['purple']['cobalt']['outdir'], '{batch}'),
        jar = config['tools']['purple']['cobalt']['jar']
    log:
        log = join(config['tools']['purple']['cobalt']['outdir'], '{batch}/{batch}.{tumor_alias}_cobalt.log')
    threads: 30
    shell:
        'module load {params.java} ; '
        'java -jar {params.jar} '
        '-reference {params.normal_alias} '
        '-reference_bam {input.normal_bam} '
        '-tumor {params.tumor_alias} '
        '-tumor_bam {input.tumor_bam} '
        '-threads {threads} '
        '-gc_profile {params.gc} '
        '-output_dir {params.outdir} > {log.log} 2>&1'

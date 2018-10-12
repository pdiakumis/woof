include: 'purple_settings.py'

config['tools']['purple']['cobalt'] = {
    'jar' : join(config['tools']['purple']['hmf_data']['dir'], 'cobalt-1.4.jar')
}


rule cobalt_run:
    input:
        normal_bam = lambda wc: bam_from_pheno(config, wc.batch, 'normal') + '.bam',
        tumor_bam = lambda wc: bam_from_pheno(config, wc.batch, 'tumor') + '.bam'
    output:
        tumor_cobalt = join(config['tools']['purple']['outdir'], '{batch}', 'cobalt/{tumor_alias}.cobalt')
    params:
        normal_alias = lambda wc: alias_from_pheno(config, wc.batch, 'normal'),
        tumor_alias = lambda wc: alias_from_pheno(config, wc.batch, 'tumor'),
        gc = config['tools']['purple']['hmf_data']['gc_profile'],
        outdir = join(config['tools']['purple']['outdir'], '{batch}', 'cobalt'),
        jar = config['tools']['purple']['cobalt']['jar']
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{tumor_alias}_cobalt.log')
    threads: 32
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'java -jar {params.jar} '
        '-reference {params.normal_alias} '
        '-reference_bam {input.normal_bam} '
        '-tumor {params.tumor_alias} '
        '-tumor_bam {input.tumor_bam} '
        '-threads {threads} '
        '-gc_profile {params.gc} '
        '-output_dir {params.outdir} >> {log.log} 2>&1; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

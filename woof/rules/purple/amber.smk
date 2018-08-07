include: 'purple_settings.py'

config['tools']['purple']['amber'] = {
    'outdir' : join(config['tools']['purple']['outdir'], 'amber'),
    'jar' : join(config['tools']['purple']['hmf_data']['dir'], 'amber-1.5.jar'),
}


rule amber_run:
    input:
        normal_mpileup = lambda wc: join(config['tools']['purple']['amber_pileup']['outdir'], wc.batch, alias_from_pheno(config, wc.batch, 'normal') + '.mpileup'),
        tumor_mpileup = lambda wc: join(config['tools']['purple']['amber_pileup']['outdir'], wc.batch, alias_from_pheno(config, wc.batch, 'tumor') + '.mpileup')
    output:
        tumor_amber = join(config['tools']['purple']['amber']['outdir'], '{batch}', '{tumor_alias}.amber.baf')
    params:
        tumor_alias = lambda wc: alias_from_pheno(config, wc.batch, 'tumor'),
        outdir = join(config['tools']['purple']['amber']['outdir'], '{batch}'),
        jar = config['tools']['purple']['amber']['jar']
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{tumor_alias}_amber.log')
    shell:
        'module load R; '
        'java -jar {params.jar} '
        '-sample {params.tumor_alias} '
        '-reference {input.normal_mpileup} '
        '-tumor {input.tumor_mpileup} '
        '-output_dir {params.outdir} > {log.log} 2>&1'

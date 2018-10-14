include: 'purple_settings.py'

config['tools']['purple']['purple'] = {
    'jar' : join(config['tools']['purple']['hmf_data']['dir'], 'purple-2.14.jar'),
}

rule purple_run:
    input:
        cobalt_dummy = lambda wc: join(config['tools']['purple']['outdir'], wc.batch, 'cobalt', alias_from_pheno(config, wc.batch, 'tumor') + '.cobalt'),
        amber_dummy = lambda wc: join(config['tools']['purple']['outdir'], wc.batch, 'amber', alias_from_pheno(config, wc.batch, 'tumor') + '.amber.baf'),
        manta_sv_filtered = lambda wc: join(config['tools']['purple']['outdir'], wc.batch, 'purple', alias_from_pheno(config, wc.batch, 'tumor') + '.manta_filtered.vcf')
    output:
        segs = join(config['tools']['purple']['outdir'], '{batch}', 'purple/{tumor_alias}.purple.cnv')
    params:
        rundir = join(config['tools']['purple']['outdir'], '{batch}'),
        outdir = join(config['tools']['purple']['outdir'], '{batch}', 'purple'),
        jar = config['tools']['purple']['purple']['jar'],
        tumor_alias = lambda wc: alias_from_pheno(config, wc.batch, 'tumor'),
        normal_alias = lambda wc: alias_from_pheno(config, wc.batch, 'normal'),
        gc = config['tools']['purple']['hmf_data']['gc_profile'],
        ensemble_snv = lambda wc: config['bcbio'][wc.batch]['ensemble']
    threads:
        2
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{tumor_alias}_purple.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'circos_path=$(which circos); '
        'java -jar {params.jar} '
        '-run_dir {params.rundir} '
        '-output_dir {params.outdir} '
        '-ref_sample {params.normal_alias} '
        '-tumor_sample {params.tumor_alias} '
        '-threads {threads} '
        '-gc_profile {params.gc} '
        '-structural_vcf {input.manta_sv_filtered} '
        '-somatic_vcf {params.ensemble_snv} '
        '-circos ${{circos_path}} >> {log.log} 2>&1; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '


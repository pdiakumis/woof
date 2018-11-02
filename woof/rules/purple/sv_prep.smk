include: 'purple_settings.py'


# courtesy of Vlad Saveliev
rule manta_sv_prep:
    input:
        manta_sv = lambda wc: config['bcbio'][wc.batch]['manta_svpri']
    output:
        manta_sv_filtered = join(config['tools']['purple']['outdir'], '{batch}', 'purple/{tumor_alias}.manta_filtered.vcf')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{tumor_alias}_purple_manta_sv_prep.log')
    priority: -50
    shell: """
        echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log};
        gunzip -c {input.manta_sv} |
          py -x "x if x.startswith('#') or all(filt_val in ['PASS', '.', 'Intergenic', 'MissingAnn'] for filt_val in x.split('\\t')[6].split(';')) else None" |
          py -x "x if x.startswith('#') or not x.startswith('GL') else None" > {output.manta_sv_filtered};
        echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log};
    """

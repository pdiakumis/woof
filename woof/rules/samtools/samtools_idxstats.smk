include: 'samtools_settings.py'

config['tools']['samtools']['idxstats'] = {
    'outdir' : join(config['tools']['samtools']['outdir'], 'idxstats'),
}


rule samtools_idxstats:
    input:
        bam = lambda wc: woof.utils.bam_from_alias(config, wc.batch, wc.alias) + '.bam'
    output:
        txt = join(config['tools']['samtools']['idxstats']['outdir'],
        '{batch}/{alias}_idxstats.txt')
    shell:
        'samtools idxstats {input.bam} > {output.txt}'


include: '../main_settings.py'


config['woof']['tool']['samtools_idxstats'] = join(config['woof']['final'], 'qc/samtools_idxstats')


rule all:
    input:
        expand(
            join(config['woof']['tool']['samtools_idxstats'], "{batch}", "{alias}_idxstats.txt"),
            batch = config['samples'].keys(),
            alias = config['samples']['batch1'].keys())

rule samtools_idxstats:
    """Run samtools idxstats"""
    input:
        bam = lambda wc: config['samples'][wc.batch][wc.alias]['bam'] + '.bam'
    output:
        txt = join(config['woof']['tool']['samtools_idxstats'], "{batch}",  "{alias}_idxstats.txt")
    shell:
        "samtools idxstats {input.bam} > {output.txt}"

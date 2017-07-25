configfile: 'config.yaml'
shell.prefix("set -euo pipefail; ")

rule all:
    input:
        expand('{bam_dir}/{s}_sort_{chrom}.sam',
                bam_dir = config['bam_dir'],
                s = ['A', 'B', 'C'],
                chrom = ['1', '13', '22', 'X'])

rule samtools_subset:
    input:
        config['bam_dir'] + '{sample}_sort.bam'
    output:
        config['bam_dir'] + '{sample}_sort_{chrom}.bam'
    log:
        config['bam_dir'] + 'logs/{sample}_sort_{chrom}.bam.log'
    shell:
        'samtools view -b {input} {wildcards.chrom} > {output} 2> {log}'

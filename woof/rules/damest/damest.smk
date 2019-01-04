
include: 'damest_settings.py'

rule damest_subsample_bam:
    input:
        bam = lambda wc: bam_from_alias(config, wc.batch, wc.alias) + '.bam'
    output:
        bam = join(config['tools']['damest']['outdir'], 'bam/{batch}/{alias}_subsample.bam')
    threads: 8
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_subsample.log')
    run:
        shell("echo '[$(date)] start {rule} with wildcards: {wildcards}' > {log.log}")
        tot_reads = shell("samtools idxstats {input.bam} | cut -f3", iterable=True)
        tot_reads = sum([int(i) for i in tot_reads])
        frac = 5_000_000 / tot_reads
        cmd1 = f'sambamba view -f bam -t {threads} --subsampling-seed=42 ' \
               f'-s {frac} {input.bam} -o {output.bam} 2>> {log.log};'
        shell(cmd1)
        shell('echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; ')


#rule damest_split_bam:
#    """Filter BAM based on flag"""
#    input:
#        bam = lambda wc: bam_from_alias(config, wc.batch, wc.alias) + '.bam'
#    output:
#        bam = join(config['tools']['damest']['outdir'], 'bam/{batch}/{alias}_f{flag}_chr21.bam')
#    threads: 8
#    params:
#        fasta = config['HPC']['ref_fasta']
#    log:
#        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_subset_f{flag}_chr21.log')
#    shell:
#        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
#        'samtools view -b '
#        '--threads {threads} '
#        '-f {wildcards.flag} '
#        '--reference {params.fasta} '
#        '{input.bam} '
#        '{params.region} '
#        '> {output.bam} && samtools index {output.bam} 2>> {log.log}; '
#        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '
#
#
#
#        
#rule damest_mpileup1:
#    input:
#        bam = join(config['tools']['damest']['outdir'], 'bam/{batch}/{alias}_f{flag}_chr21.bam')
#    output:
#        mpileup = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f{flag}_chr21.mpileup')
#    params:
#        fasta = config['HPC']['ref_fasta']
#    log:
#        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_pileup_f{flag}_chr21.log')
#    threads: 8
#    shell:
#        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
#        'sambamba mpileup '
#        '-t {threads} '
#        '{input.bam} '
#        '--samtools '
#        '-q 10 -Q 0 '
#        '-O -s '
#        '-f {params.fasta} '
#        '> {output.mpileup} 2>> {log.log}; '
#        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '
#

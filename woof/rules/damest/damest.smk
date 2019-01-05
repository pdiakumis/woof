
include: 'damest_settings.py'

rule damest_subsample_bam:
    """Use sambamba view to sample reads"""
    input:
        bam = lambda wc: bam_from_alias(config, wc.batch, wc.alias) + '.bam'
    output:
        bam = join(config['tools']['damest']['outdir'], 'bam/{batch}/{alias}_subsample.bam')
    threads: 8
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_subsample.log')
    run:
        shell('echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; ')
        tot_reads = shell("samtools idxstats {input.bam} | cut -f3", iterable=True)
        tot_reads = sum([int(i) for i in tot_reads])
        frac = 5_000_000 / tot_reads
        cmd1 = f'sambamba view -f bam -t {threads} --subsampling-seed=42 ' \
               f'-s {frac} {input.bam} -o {output.bam} 2>> {log.log};'
        shell(cmd1)
        shell('echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; ')


rule damest_split_bam:
    """Filter BAM based on flag"""
    input:
        bam = rules.damest_subsample_bam.output.bam
    output:
        bam = join(config['tools']['damest']['outdir'], 'bam/{batch}/{alias}_subsample_f{flag}.bam')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_split_f{flag}.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'samtools view -b -f {wildcards.flag} {input.bam} > {output.bam} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

rule damest_mpileup:
    input:
        bam = rules.damest_split_bam.output.bam
    output:
        mpileup = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f{flag}.mpileup')
    params:
        fasta = config['HPC']['ref_fasta']
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_pileup_f{flag}.log')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        'sambamba mpileup -o {output.mpileup} {input.bam} '
        '--samtools -q 10 -Q 0 -O -s -f {params.fasta} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

rule damest_run1:
    input:
        mp1 = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f64.mpileup'),
        mp2 = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f128.mpileup')
    output:
        txt = join(config['tools']['damest']['outdir'], 'results/{batch}/{alias}_damage_estimate.txt')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_damage_estimate.log')
    params:
        perl_script = join(config['tools']['damest']['scripts'], 'estimate_damage.pl')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '{params.perl_script} '
        '--mpileup1 {input.mp1} '
        '--mpileup2 {input.mp2} '
        '--id {wildcards.alias} > {output.txt} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

rule damest_run2:
    input:
        mp1 = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f64.mpileup'),
        mp2 = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f128.mpileup')
    output:
        txt = join(config['tools']['damest']['outdir'], 'results/{batch}/{alias}_damage_estimate_pos.txt')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_damage_estimate_pos.log')
    params:
        perl_script = join(config['tools']['damest']['scripts'], 'estimate_damage_location.pl')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '{params.perl_script} '
        '--mpileup1 {input.mp1} '
        '--mpileup2 {input.mp2} '
        '--min_coverage_limit 10 '
        '--max_coverage_limit 150 '
        '--id {wildcards.alias} '
        '--out {output.txt} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

rule count_mut:
    """Count mutations in read pileup"""
    input:
        mpileup = join(config['tools']['damest']['outdir'], 'mpileup/{batch}/{alias}_f{flag}.mpileup')
    output:
        counts_tot = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f{flag}_counts_tot.tsv'),
        counts_pos = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f{flag}_counts_pos.tsv'),
        counts_con = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f{flag}_counts_con.tsv')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_counts_f{flag}.log')
    params:
        perl_script = join(config['tools']['damest']['scripts'], 'count_mut.pl')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '{params.perl_script} --in_mp {input.mpileup} '
        '--out_ct {output.counts_tot} --out_cp {output.counts_pos} '
        '--out_cc {output.counts_con} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '

rule estimate_damage:
    """Estimate damage scores"""
    input:
        ct1 = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f64_counts_tot.tsv'),
        ct2 = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f128_counts_tot.tsv'),
        cp1 = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f64_counts_pos.tsv'),
        cp2 = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f128_counts_pos.tsv'),
        cc1 = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f64_counts_con.tsv'),
        cc2 = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_f128_counts_con.tsv')
    output:
        tot = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_tot_damage.tsv'),
        pos = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_pos_damage.tsv'),
        con = join(config['tools']['damest']['outdir'], 'results2/{batch}/{alias}_con_damage.tsv')
    log:
        log = join(config['woof']['final_dir'], 'logs', '{batch}/{alias}_damest_run.log')
    params:
        perl_script = join(config['tools']['damest']['scripts'], 'damest.pl')
    shell:
        'echo "[$(date)] start {rule} with wildcards: {wildcards}" > {log.log}; '
        '{params.perl_script} '
        '--ct1 {input.ct1} --ct2 {input.ct2} '
        '--cp1 {input.cp1} --cp2 {input.cp2} '
        '--cc1 {input.cc1} --cc2 {input.cc2} '
        '--out_tot {output.tot} --out_pos {output.pos} '
        '--out_con {output.con} --id {wildcards.alias} 2>> {log.log}; '
        'echo "[$(date)] end {rule} with wildcards: {wildcards}" >> {log.log}; '


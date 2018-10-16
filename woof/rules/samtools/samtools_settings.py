
# by default goes to qc/samtools. Change within the rule for alternative directory.

config['tools']['samtools'] = {
    'outdir' : join(config['woof']['final_dir'], 'qc/samtools'),
}


config['tools']['purple'] = {
    'outdir' : join(config['woof']['final_dir'], 'structural/purple'),
    'hmf_data' : {
        'dir' : join(config['HPC']['woof_data'], 'hmf'),
    },
}

config['tools']['purple']['hmf_data']['gc_profile'] = join(config['tools']['purple']['hmf_data']['dir'], 'GC_profile.GRCh37.1000bp.cnp')
config['tools']['purple']['hmf_data']['snp_bed'] = join(config['tools']['purple']['hmf_data']['dir'], 'GermlineHetPon.GRCh37.bed')

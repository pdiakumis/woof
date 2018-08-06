def pheno(config, batch, sample):
    return config['samples'][batch][sample]['phenotype']

def alias_from_pheno(config, batch, phenotype):
    d = config['samples'][batch]
    samples = d.keys()
    pheno_d = {pheno(config, batch, sample) : sample for sample in samples}
    return pheno_d[phenotype]

def bam_from_pheno(config, batch, phenotype):
    d = config['samples'][batch]
    sample = alias_from_pheno(config, batch, phenotype)
    return d[sample]['bam']

def bam_from_alias(config, batch, alias):
    d = config['samples'][batch]
    return d[alias]['bam']

def aliases_from_batch(config, batch):
    d = config['samples'][batch]
    return [*d]
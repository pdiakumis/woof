
<!-- vim-markdown-toc GFM -->

* [woof](#woof)
    * [quick start](#quick-start)
        * [example runs](#example-runs)
* [Workflows](#workflows)
    * [validation](#validation)
        * [FASTQ](#fastq)
        * [BAM](#bam)
        * [VCF](#vcf)

<!-- vim-markdown-toc -->

# woof
Woofing workflows using [WDL](https://software.broadinstitute.org/wdl/) and
[Cromwell](https://snakemake.readthedocs.io/en/stable/index.html).


## quick start
* `environment.yaml`: contains conda tools you want to use in the pipeline.
    * Run `conda env create --name woof --file environment.yaml` to create the conda
      environment

### example runs

# Workflows

* `woof` consists of several WDL workflows, written in
  separate WDL files
* each workflow calls several tasks

validation
----------

### FASTQ

- [fqtools validate](https://github.com/alastair-droop/fqtools)

### BAM

- GATK ValidateSamFile [link1](https://software.broadinstitute.org/gatk/documentation/article.php?id=7571),
  [link2](http://broadinstitute.github.io/picard/command-line-overview.html#ValidateSamFile)
- [UMich BamUtil validate](https://genome.sph.umich.edu/wiki/BamUtil:_validate)
- [samtools quickcheck](http://www.htslib.org/doc/samtools.html)

### VCF

- [EBI vcf-validator](https://github.com/EBIvariation/vcf-validator)


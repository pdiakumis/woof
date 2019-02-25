
# woof
Woofing workflows using [WDL](https://software.broadinstitute.org/wdl/) and
[Cromwell](https://snakemake.readthedocs.io/en/stable/index.html).

Contents
--------

<!-- vim-markdown-toc GFM -->

* [Quick Start](#quick-start)
    * [Run Cromwell](#run-cromwell)
* [Installation](#installation)
* [Repo Structure](#repo-structure)
* [Workflows](#workflows)
    * [bcbio Comparison](#bcbio-comparison)
    * [AGHA Data Validation](#agha-data-validation)

<!-- vim-markdown-toc -->


# Quick Start

## Run Cromwell

* From within the `woof/wdl` directory:

```
cromwell run \
  -i inputs.json \
  -Dconfig.file=conf/cromwell.conf \
  --metadata-output meta.json \
  --options options.json \
  compare_vcf_files.wdl
```

# Installation

# Repo Structure

* `environment.yaml`: contains conda tools you want to use in the pipeline.
    * `conda env create --name woof --file environment.yaml` to create the conda environment


# Workflows

* `woof` consists of several WDL workflows, written in
  separate WDL files
* each workflow calls several tasks

bcbio Comparison
----------------

AGHA Data Validation
--------------------

* __FASTQ__

- [fqtools validate](https://github.com/alastair-droop/fqtools)

* __BAM__

- GATK ValidateSamFile [link1](https://software.broadinstitute.org/gatk/documentation/article.php?id=7571),
  [link2](http://broadinstitute.github.io/picard/command-line-overview.html#ValidateSamFile)
- [UMich BamUtil validate](https://genome.sph.umich.edu/wiki/BamUtil:_validate)
- [samtools quickcheck](http://www.htslib.org/doc/samtools.html)

* __VCF__

- [EBI vcf-validator](https://github.com/EBIvariation/vcf-validator)



# woof
Woofing workflows using [WDL](https://software.broadinstitute.org/wdl/) and
[Cromwell](https://snakemake.readthedocs.io/en/stable/index.html).

Contents
--------

<!-- vim-markdown-toc GFM -->

* [Quick Start](#quick-start)
    * [Run Cromwell](#run-cromwell)
* [Installation](#installation)
        * [woof](#woof)
        * [Conda](#conda)
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

### woof

```
# clone repo, create conda env
git clone git@github.com:pdiakumis/woof.git
```

### Conda

* Download and install Miniconda

```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh
conda update -n base -c defaults conda
```

* Create `woof` conda environment

```
conda env create -f woof/env/woof.yaml
```

# Repo Structure





# Workflows

* `woof` consists of several WDL workflows, written in separate WDL files
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


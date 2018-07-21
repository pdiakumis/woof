Workflows
=========

Introduction
------------

* `woof` consists of several Snakemake workflows, written in
  separate snakefiles
* each workflow consists of several rules, which are `include`d
  in the snakefile
* Each rule can consist of `input`, `output`,
  `params`, `shell`, `run`, `threads`, `log` and `message` directives.


Contents
---------

- [Workflows](#workflows)
  - [Introduction](#introduction)
  - [Contents](#contents)
  - [structural](#structural)
    - [PURPLE](#purple)
    - [FACETS](#facets)
    - [Titan](#titan)
    - [CNVkit](#cnvkit)
  - [qc](#qc)
    - [FastQC](#fastqc)
    - [MultiQC](#multiqc)
    - [samtools](#samtools)
  - [coverage](#coverage)
    - [mosdepth](#mosdepth)
    - [indexcov](#indexcov)


structural
----------

### PURPLE

* Description: tumor purity & ploidy estimator
* GitHub Repo:
  <https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator>

#### Steps

1. [sambamba-pileup](https://github.com/hartwigmedical/hmftools/tree/master/amber#prerequisites):
  generate pileups for AMBER using sambamba (or samtools)
2. [AMBER](https://github.com/hartwigmedical/hmftools/tree/master/amber):
  estimate BAF
3. [COBALT](https://github.com/hartwigmedical/hmftools/tree/master/count-bam-lines):
  count number of read starts within 1kb windows
4. [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator):
  estimate purity & ploidy, and plot circos


### FACETS

* Description: fraction and allele specific copy number estimator
* Paper: <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5027494/>
* GitHub Repo: <https://github.com/mskcc>

#### Steps

* [facets-pileup](https://github.com/mskcc/facets/tree/master/inst/extcode):
  given a VCF file containing SNP locations, generate
  the read counts of the reference nucleotide, alternate nucleotide,
  errors, and deletions.

* [facets](https://github.com/mskcc/facets):


### Titan

### CNVkit

qc
--

### FastQC

### MultiQC

### samtools

coverage
--------

### mosdepth

### indexcov

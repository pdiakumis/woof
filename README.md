
<!-- vim-markdown-toc GFM -->

* [woof](#woof)
    * [quick start](#quick-start)
        * [example runs](#example-runs)
        * [expand](#expand)
* [Workflows](#workflows)
    * [Introduction](#introduction)
    * [structural](#structural)
        * [PURPLE](#purple)
            * [Steps](#steps)
        * [FACETS](#facets)
            * [Steps](#steps-1)
        * [Titan](#titan)
        * [CNVkit](#cnvkit)
    * [qc](#qc)
        * [FastQC](#fastqc)
        * [MultiQC](#multiqc)
        * [samtools](#samtools)
    * [coverage](#coverage)
        * [mosdepth](#mosdepth)
        * [indexcov](#indexcov)
    * [resources](#resources)

<!-- vim-markdown-toc -->

# woof
Woofing workflows using
[Snakemake](https://snakemake.readthedocs.io/en/stable/index.html).


## quick start
* `environment.yaml`: contains tools you want to use in the pipeline.
    * Run `conda env create --name woof --file environment.yaml` to create conda
      environment
* `rule.snakefile`: contains one or more pipeline steps (called 'rules'). Each
  rule can run for multiple samples, thus creating multiple 'jobs'.
* `cluster.json`: cluster configuration file to specify partition, time etc.

### example runs

* Dry run and print shell command used:

```bash
snakemake -s rule.snakefile -np
```

* Plot DAG:

```bash
snakemake -s rule.snakefile --dag | dot -Tsvg > dag.svg
```

* Run on multiple cores:

```bash
snakemake -s rule.snakefile -j 4
```

* Run on PBS/TORQUE cluster:
    - Each job will be compiled into a shell script that is submitted with the
      given command (e.g. `qsub`). The `--jobs 100` flag limits the number of
      concurrently submitted jobs to 100.
    - You can decorate the specified submission command with parameters from the
      submitted job (e.g. `threads`).

```bash
snakemake -s rule.snakefile --cluster qsub --jobs 100
snakemake -s rule.snakefile --cluster "qsub -pe threaded {threads}" --jobs 100
```

* Run on SLURM cluster:

```bash
snakemake -j 999 \
          --cluster-config cluster.json \
          --cluster "sbatch -A {cluster.account} \
          -p {cluster.partition} \
          -n {cluster.n} \
          -t {cluster.time}"
```

where `cluster.json` is:

```
{
    "__default__" :
    {
        "account" : "my account",
        "time" : "00:15:00",
        "n" : 1,
        "partition" : "core"
    },
    "compute1" :
    {
        "time" : "00:20:00"
    }
}
```

### expand
Snakemake has a function in `snakemake.io` called `expand` which helps you
'expand' different
file lists as in the following:

```
PLOTFORMATS = ["pdf", "png"]
DATASETS = ["ds1", "ds2"]
```
* `expand("{dataset}/file.txt", dataset = DATASETS)`

Output:
```
["ds1/file.txt", "ds2/file.txt"]
```

* `expand("{dataset}/file.{ext}", dataset=DATASETS, ext=PLOTFORMATS)`

Output:
```
["ds1/file.pdf", "ds2/file.pdf", "ds1/file.png", "ds2/file.pdf"]
```

* `expand(["{dataset}/plot1.{ext}", "{dataset}/plot2.{ext}"], dataset=DATASETS, ext=PLOTFORMATS)`

Output:
```
["ds1/plot1.pdf", "ds1/plot2.pdf", "ds2/plot1.pdf", "ds2/plot2.pdf",
"ds1/plot1.png", "ds1/plot2.png", "ds2/plot1.png", "ds2/plot2.png"]
```

* `expand("{dataset}/plot1.{ext} {dataset}/plot2.{ext}".split(), zip, dataset=DATASETS, ext=PLOTFORMATS)`

Output:
```
["ds1/plot1.pdf", "ds1/plot2.pdf", "ds2/plot1.png", "ds2/plot2.png"]
```

* `expand("{{dataset}}/plot1.{ext}", ext=PLOTFORMATS)`

Output:
```
['{dataset}/plot1.pdf', '{dataset}/plot1.png']
```

# Workflows


Introduction
------------

* `woof` consists of several Snakemake workflows, written in
  separate snakefiles
* each workflow consists of several rules, which are `include`d
  in the snakefile
* Each rule can consist of `input`, `output`,
  `params`, `shell`, `run`, `threads`, `log` and `message` directives.

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

## resources

* Snakemake docs: <https://snakemake.readthedocs.io/en/stable/>
* Snakemake code examples: <https://codegists.com/code/snakefile/>
* Useful rules repo: <https://github.com/percyfal/snakemake-rules>
* Snakemake on SLURM: <https://hpc.nih.gov/apps/snakemake.html>

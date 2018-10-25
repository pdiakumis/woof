Telomere Length Estimation
==========================

<!-- vim-markdown-toc GFM -->

* [Telomere Tools](#telomere-tools)
* [TelomereCat paper](#telomerecat-paper)
    * [Competitors](#competitors)
    * [Telomere read types](#telomere-read-types)

<!-- vim-markdown-toc -->

## Telomere Tools

* [TelomereCat](https://github.com/jhrf/telomerecat)
* [TelSeq](https://github.com/zd1/telseq)


## TelomereCat paper

### Competitors
* TelSeq:
    - assumes a fixed number of chromosomes -> doesn't account for aneuploidy
* TelomereHunter:
    - reports telomere content, not telomere length
    - classifies reads based on their location within the BAM
    - outputs statistics relating to variations of the canonic telomere hexamer

### Telomere read types
* TelomereCat sorts read-pairs into the following categories:
    - F1: complete (both reads within the telomere)
    - F2: boundary (only one read completely within the telomere)
    - F3: none (no reads are completely within the telomere, only one over the boundary)
    - F4: similar to F2 (I think)

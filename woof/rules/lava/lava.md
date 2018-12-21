LAVA
====
* Lightweight Assignment of Variant Alleles
* Website: <http://cb.csail.mit.edu/cb/lava/>
* GitHub: <https://github.com/arshajii/lava>

Summary
-------
* Given a set of SNPs, LAVA quickly determines if a read belongs to a particular
  SNP as either a wildtype or mutant
* Matches k-mers in the reads to k-mers in precomputed reference + SNP dictionaries
* k-mers are analogous to SNP array probes
* Can choose only relevant reads, without doing a full alignment of all reads to
  the reference genome
* Call SNPs in the aggregated reads

Method
------

### Input
- Reference genome
- List of SNPs of interest
- Set of reads

### Pre-processing
* Use reference genome and list of SNPs to produce dictionaries of:
    - all reference k-mers
    - k-mers containing mutant SNP alleles
* reference position `<->` k-mer.
* SNP dict also contains ref/alt alleles

### Processing
* Split each read into k-mers, get Hamming neighbours, and query them in the two dictionaries
* For each read, combine the query results to predict which SNPs it overlaps
* Once all reads have been processed, the final pileup table is used to call variants

### Output
- Predicted genotypes for SNPs (hom-ref, het, hom-alt)

Installation
------------
* Just clone the repo, enter it, then type `make` ;-)

```
$ cd /data/cephfs/punim0010/projects/Diakumis/lava/lava-git

$ ls -la
total 8.5K
drwxrwsr-x 6 pdiakumis punim0010 129K Dec 19 17:05 .
drwxrwsr-x 3 pdiakumis punim0010 129K Dec 19 17:05 ..
drwxrwsr-x 8 pdiakumis punim0010  59K Dec 19 17:05 .git
-rw-rw-r-- 1 pdiakumis punim0010  547 Dec 19 17:05 .gitignore
drwxrwsr-x 2 pdiakumis punim0010 5.5K Dec 19 17:05 include
-rw-rw-r-- 1 pdiakumis punim0010 1.1K Dec 19 17:05 LICENSE
-rw-rw-r-- 1 pdiakumis punim0010  601 Dec 19 17:05 Makefile
drwxrwsr-x 2 pdiakumis punim0010   15 Dec 19 17:05 obj
-rw-rw-r-- 1 pdiakumis punim0010 1.6K Dec 19 17:05 README.md
drwxrwsr-x 2 pdiakumis punim0010  62K Dec 19 17:05 src

$ make
gcc -std=c99 -march=native -O3 -flto -fstrict-aliasing -Wall -Wextra -Werror -Iinclude -c src/pileup.c -o obj/pileup.o
gcc -std=c99 -march=native -O3 -flto -fstrict-aliasing -Wall -Wextra -Werror -Iinclude -c src/lava.c -o obj/lava.o
gcc -std=c99 -march=native -O3 -flto -fstrict-aliasing -Wall -Wextra -Werror -Iinclude -c src/dict_filt.c -o obj/dict_filt.o
gcc -std=c99 -march=native -O3 -flto -fstrict-aliasing -Wall -Wextra -Werror -Iinclude -c src/dictgen.c -o obj/dictgen.o
gcc -std=c99 -march=native -O3 -flto -fstrict-aliasing -Wall -Wextra -Werror -Iinclude -c src/util.c -o obj/util.o
gcc -std=c99 -march=native -O3 -flto -fstrict-aliasing -Wall -Wextra -Werror -Iinclude -c src/fasta_parser.c -o obj/fasta_parser.o
gcc -march=native -O3 -flto  obj/pileup.o  obj/lava.o  obj/dict_filt.o  obj/dictgen.o  obj/util.o  obj/fasta_parser.o -lm -o lava

$ ls -la
total 49K
drwxrwsr-x 6 pdiakumis punim0010 129K Dec 19 17:07 .
drwxrwsr-x 3 pdiakumis punim0010 129K Dec 19 17:05 ..
drwxrwsr-x 8 pdiakumis punim0010  59K Dec 19 17:05 .git
-rw-rw-r-- 1 pdiakumis punim0010  547 Dec 19 17:05 .gitignore
drwxrwsr-x 2 pdiakumis punim0010 5.5K Dec 19 17:05 include
-rwxrwxr-x 1 pdiakumis punim0010  40K Dec 19 17:07 lava
-rw-rw-r-- 1 pdiakumis punim0010 1.1K Dec 19 17:05 LICENSE
-rw-rw-r-- 1 pdiakumis punim0010  601 Dec 19 17:05 Makefile
drwxrwsr-x 2 pdiakumis punim0010 176K Dec 19 17:07 obj
-rw-rw-r-- 1 pdiakumis punim0010 1.6K Dec 19 17:05 README.md
drwxrwsr-x 2 pdiakumis punim0010  62K Dec 19 17:05 src

$ ./lava --help
Usage: lava <option> [option parameters ...]
Option  Description                   Parameters
------  -----------                   ----------
dict    Generate dictionary files     <input FASTA> <input SNPs> <output ref dict> <output SNP dict>
filt    Filter reference dictionary   <ref dict> <snp_pos file> <output ref dict>
lava    Perform genotyping            <input ref dict> <input SNP dict> <input FASTQ> <chrlens file> <output file>
```

Running
-------

* Make sure FASTQ is unzipped

```
REF=hg19.fa
SNP=Affymetrix_6_SNPs.txt
OUT_DIR=../../data/out
REF_DICT=${OUT_DIR}/ref_dict
SNP_DICT=${OUT_DIR}/snp_dict
FASTQ=../../data/SRR622461.filt.fastq
$ lava dict $REF $SNP $REF_DICT $SNP_DICT

[Fri Dec 21 01:00:51 AEDT 2018] start lava dict

SNP Dictionary
Total k-mers:        25319680
Unambig k-mers:      25016522
Ambig unique k-mers: 73769
Ambig total k-mers:  303158

Ref Dictionary
Total k-mers:        2897295167
Unambig k-mers:      2483952495
Ambig unique k-mers: 70732240
Ambig total k-mers:  413342672
[Fri Dec 21 01:26:27 AEDT 2018] end lava dict

$ lava lava $REF_DICT $SNP_DICT $FASTQ ${REF}.chrlens ${OUT_DIR}/lava_results.txt
[Fri Dec 21 12:26:31 AEDT 2018] start lava lava
Initializing...
Processing...
Time: 252.460000 sec
[Fri Dec 21 12:30:44 AEDT 2018] end lava lava
```

### lava dict output

```
 34G ../data/out/ref_dict # binary
389M ../data/out/snp_dict # binary
2.0K path/to/wherever/hg19/is/yes/that/is/correct/hg19.fa.chrlens # txt
```

### lava lava output

```
../data/out/lava_results.txt

* 137KB size
* 4068 rows


* head:

chr1 3108517 0.00320309673299974
chr1 3732707 0.00383962210416971
chr1 4022244 0.00467626118246151
chr1 4280170 0.00440047430918131
chr1 5022767 0.00491158277570098
chr1 5596138 0.0049032398530237
chr1 7379198 0.00462469504227126
chr1 8899305 0.00446068688961341
chr1 9039022 0.00462469504227126
chr1 16440392 0.00442001134038322
```

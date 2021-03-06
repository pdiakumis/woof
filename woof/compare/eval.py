import os
import sys
import subprocess
import gzip
import csv
from woof import utils

# Mostly from umccr/vcf_stuff


def eval(fp_vcf, fn_vcf, tp_vcf, out, sample, flab, subset):
    fpc = count_variants(fp_vcf)
    fnc = count_variants(fn_vcf)
    tpc = count_variants(tp_vcf)

    fp_snp, fp_ind = (fpc["snps"], fpc["indels"])
    fn_snp, fn_ind = (fnc["snps"], fnc["indels"])
    tp_snp, tp_ind = (tpc["snps"], tpc["indels"])

    snp_truth = tp_snp + fn_snp
    snp_recall = tp_snp / snp_truth if snp_truth else 0
    snp_called = tp_snp + fp_snp
    snp_precision = tp_snp / snp_called if snp_called else 0

    ind_truth = tp_ind + fn_ind
    ind_recall = tp_ind / ind_truth if ind_truth else 0
    ind_called = tp_ind + fp_ind
    ind_precision = tp_ind / ind_called if ind_called else 0

    snp_f1 = f_measure(1, snp_precision, snp_recall)
    snp_f2 = f_measure(2, snp_precision, snp_recall)
    snp_f3 = f_measure(3, snp_precision, snp_recall)

    ind_f1 = f_measure(1, ind_precision, ind_recall)
    ind_f2 = f_measure(2, ind_precision, ind_recall)
    ind_f3 = f_measure(3, ind_precision, ind_recall)

    with open(out, "w") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow(
            [
                "sample",
                "flabel",
                "subset",
                "SNP_Truth",
                "SNP_TP",
                "SNP_FP",
                "SNP_FN",
                "SNP_Recall",
                "SNP_Precision",
                "SNP_f1",
                "SNP_f2",
                "SNP_f3",
                "IND_Truth",
                "IND_TP",
                "IND_FP",
                "IND_FN",
                "IND_Recall",
                "IND_Precision",
                "IND_f1",
                "IND_f2",
                "IND_f3",
            ]
        )
        writer.writerow(
            [
                sample,
                flab,
                subset,
                snp_truth,
                tp_snp,
                fp_snp,
                fn_snp,
                snp_recall,
                snp_precision,
                snp_f1,
                snp_f2,
                snp_f3,
                ind_truth,
                tp_ind,
                fp_ind,
                fn_ind,
                ind_recall,
                ind_precision,
                ind_f1,
                ind_f2,
                ind_f3,
            ]
        )


def f_measure(b, prec, recall):
    return (
        (1 + b ** 2) * prec * recall / (b ** 2 * prec + recall)
        if prec + recall > 0
        else 0
    )


def count_variants(vcf):
    snps = 0
    indels = 0
    with (gzip.open(vcf, "rt") if vcf.endswith(".gz") else open(vcf)) as f:
        for l in [l for l in f if not l.startswith("#")]:
            chrom, pos, _, ref, alt = l.split("\t")[:5]
            if len(ref) == len(alt) == 1:
                snps += 1
            else:
                indels += 1
    return {"snps": snps, "indels": indels}


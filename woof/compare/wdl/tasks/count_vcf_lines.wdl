version 1.0

task count_vars {

    input {
        File vcf
        File vcf_tbi = vcf + ".tbi"
        String outdir # woof/final/<sample>/vcf_counts/<f1-or-f2>/<flabel>/<all-or-pass>/
        String txt = outdir + "count_vars.txt"
        String sample
        String flabel
    }

    command {
        mkdir -p ~{outdir}
        count=$(gunzip -c ~{vcf} | grep -v "^#" | wc -l | xargs )
        printf "sample\tflabel\tcount\n" > ~{txt}
        printf "~{sample}\t~{flabel}\t$count\n" >> ~{txt}
    }

    output {
        File out = "~{txt}"
    }
}


# workflow foo {

#   call count_vars {
#       input:
#         vcf = "/Users/pdiakumis/Desktop/projects/umccr/woof/nogit/data/umccrise_0.15.6/p25/umccrised/p25/2016_249_18_WH_P025__CCR180149_VPT-WH025-E-manta.vcf.gz",
#         sample = "P025",
#         flab = "manta-um-bc",
#         outdir = "/Users/pdiakumis/Desktop/projects/umccr/woofr/nogit/foo/"
#   }
# }
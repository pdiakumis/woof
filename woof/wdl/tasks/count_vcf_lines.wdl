version 1.0

task all {

    input {
        File vcf
        String outdir # woof/final/vcf_counts/<vcf-typeX>
        String txt = outdir + "_count_all.txt"
    }

    command {
        gunzip -c ~{VCF} | grep -v "^#" | wc -l > ~{txt}
    }

    output {
        File txt = "~{txt}"
    }
}

task pass {
    input {
        File vcf
        String outdir
        String txt = outdir + "_count_pass.txt"
    }

    command {
        conda activate woof
        bcftools view -f .,PASS -H ~{VCF} | wc -l > ~{txt}
    }

    output {
        File txt = "~{txt}"
    }
}


version 1.0

task all {

    input {
        File vcf
        String outdir # woof/final/vcf_counts/<vcf-typeX>
        String txt = outdir + "/count_all.txt"
    }

    command {
        mkdir -p ~{outdir}
        gunzip -c ~{vcf} | grep -v "^#" | wc -l > ~{txt}
    }

    output {
        File out = "~{txt}"
    }
}

task pass {
    input {
        File vcf
        String outdir
        String txt = outdir + "/count_pass.txt"
    }

    command {
        conda activate woof

        mkdir -p ~{outdir}
        bcftools view -f .,PASS -H ~{vcf} | wc -l > ~{txt}
    }

    output {
        File out = "~{txt}"
    }
}


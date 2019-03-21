version 1.0

task all {

    input {
        File VCF
        String out = "count_all_" + basename(VCF, ".vcf.gz") + ".txt"
    }

    command {
        gunzip -c ~{VCF} | grep -v "^#" | wc -l > ~{out}
    }

    output {
        File result = "~{out}"
    }
}

task pass {
    input {
        File VCF
        String out = "count_pass_" + basename(VCF, ".vcf.gz") + ".txt"
    }

    command {
        conda activate woof
        bcftools view -f .,PASS -H ~{VCF} | wc -l > ~{out}
    }

    output {
        File result = "~{out}"
    }
}


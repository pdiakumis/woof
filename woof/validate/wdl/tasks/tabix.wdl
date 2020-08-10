version 1.0

task tabix {
    input {
        File inputFile
        String outputFilePath = "indexed.vcf.gz"
    }

    command {
        set -e
        if [ ! -f ~{outputFilePath} ]
        then
            ln ~{inputFile} ~{outputFilePath}
        fi
        tabix ~{outputFilePath} -p "vcf"
    }

    output {
        File indexedFile = outputFilePath
        File index = outputFilePath + ".tbi"
    }


    runtime {
        docker: "quay.io/biocontainers/tabix:0.2.6--ha92aebf_0"
        memory: "3GB"
        cpu: 1
    }

}

task bgzipTabix {
    input {
        File inputFile
        String outputDir
    }

    String outputGz = outputDir + "/" + basename(inputFile) + ".gz"

    command {
        set -e
        mkdir -p "$(dirname ~{outputGz})"
        bgzip -c ~{inputFile} > ~{outputGz}
        tabix ~{outputGz} -p "vcf"
    }

    output {
        File compressed = outputGz
        File index = outputGz + ".tbi"
    }

    runtime {
        docker: "quay.io/biocontainers/tabix:0.2.6--ha92aebf_0"
        memory: "3GB"
        cpu: 1
    }

}

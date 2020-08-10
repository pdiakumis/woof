version 1.0

task tabix {
    input {
        File inputFile
    }

    String inputFileBasename = basename(inputFile)

    command {
        ln ~{inputFile} ~{inputFileBasename}
        tabix ~{inputFileBasename} -p "vcf"
    }

    output {
        File index = inputFileBasename + ".tbi"
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

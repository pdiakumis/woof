version 1.0

task read_S3file {
  input {
    File file
    String txt = "cat_foo.txt"
  }

  command {
    cat ~{file} > ~{txt}
  }

  output {
    File out = "~{txt}"
  }

  runtime {
    docker: "ubuntu:latest"
  }
}

workflow ReadS3File {
  call read_S3file
}


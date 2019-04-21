version 1.0

task read_file {
  input {
    File file
  }

  command {
    cat ${file}
  }

  output {
    String contents = read_string(stdout())
  }

  runtime {
    docker: "ubuntu:latest"
  }
}

workflow ReadFile {
  call read_file
}

version 1.0

task list {
  input {
    String env = "woof"
    String outdir # woof/final/<sample>/conda/<flabel>/<all-or-pass>
  }

  command <<<
    mkdir -p ~{outdir}
    conda list --name ~{env} | awk -v var=~{env} '{{ print $0, var }}' | grep -v "^#" > "~{outdir}/conda_pkg_list.txt"
    >>>

  output {
      File out = "~{outdir}/conda_pkg_list.txt"
  }
}

workflow test {
    call list {
        input:
          outdir = "/Users/pdiakumis/Desktop/projects/umccr/woofr/nogit/conda"
    }
}
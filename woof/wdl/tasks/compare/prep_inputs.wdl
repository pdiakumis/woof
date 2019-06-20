version 1.0

# Create a task that takes as input a json file with the following elements:
# - 'batch_name', 'tumor_name', 'normal_name': String
# - 'analysis_type': String
# - 'aligners': Map[String, String] (e.g. { "run1": "bwa", "run2": "dragen" }
# - 'genome_builds': Map[String, String] (e.g. { "run1": "GRCh37", "run2": "hg38" }
# - 'variant_files': Map[String, Pair[File, File]] (e.g. {"vardict_som": { "run1": "/path/to/vcf1", "run2": "path/to/vcf2"}}


# Other idea:
# Make woofr output multiple files:

# 1. batch_info
# batch_name foo
# tumor_name bar
# normal_name baz
# analysis_type bing

# 2. aligners + genome_builds
# run1 bwa GRCh37
# run2 bwa hg38

# 3. variant_files
# sample_name | file_type | run1_file_path | run2_file_path

# CrossMap:
# if (genome["run1"] == genome["run2"]) do nothing
# if (genome["run1"] == "GRCh37" && genome["run2"] == "hg38") run CrossMap with run1 files as input
# if (genome["run1"] == "hg38" && genome["run2"] == "GRCh37") run CrossMap with run2 files as input


struct Run1Run2Files {
    File run1
    File run2
}

struct VarcallerFiles {
    Map[String, Run1Run2Files] vc
}

task cat_both2 {
  input {
    VarcallerFiles varcaller_map
    String out1 = basename(varcaller_map["vc"]["run1"]) + "_output1.txt"
    String out2 = basename(varcaller.vc["run2"]) + "_output2.txt"
  }

  command {
    cat ~{varcaller.vc["run1"]} > ~{out1}
    cat ~{varcaller.vc["run2"]} > ~{out2}
  }

  output {
    File out_file1 = out1
    File out_file2 = out2 
  }
}

task cat_both {
  input {
    Run1Run2Files varcaller
    String out1 = basename(varcaller.run1) + "_output1.txt"
    String out2 = basename(varcaller.run2) + "_output2.txt"
  }

  command {
    cat ~{varcaller.run1} > ~{out1}
    cat ~{varcaller.run2} > ~{out2}
  }

  output {
    File out_file1 = out1
    File out_file2 = out2 
    }
}

workflow test {
  input {
    Map[String, VarcallerFiles] varcallers = read_json("/Users/pdiakumis/Desktop/projects/umccr/woof/woof/wdl/tasks/compare/tmp.json")
    }

    scatter (vc in varcallers) {
      call cat_both2 { input: varcaller = vc }
    }
}


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


workflow test {
  input {
    Map[String, VarcallerFiles] varcallers = read_json("/Users/pdiakumis/Desktop/projects/umccr/woof/woof/compare/wdl/test/tmp.json")
    }
}


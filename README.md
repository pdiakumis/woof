
# woof
Woofing workflows using
[WDL](https://software.broadinstitute.org/wdl/),
[CWL](https://www.commonwl.org/) and
[Cromwell](https://cromwell.readthedocs.io/en/stable/).

Documentation: <https://pdiakumis.github.io/woof/>


Multi-Sample Mode
-----------------

If you want to run `woof compare` on multiple samples (say, A & B), you can hack it in the following (relatively) simple way:

`woof compare --justprep path/to/run1/A/final path/to/run2/A/final -s SAMPLE_A -o woof`
`woof compare --justprep path/to/run1/B/final path/to/run2/B/final -s SAMPLE_B -o woof`

Each of the above runs prints out a cromwell command, and 'just prepares' a directory structure like the following:

```
woof
├── final/ # empty
└── work
    ├── SAMPLE_A
    │   ├── cromwell_config.conf
    │   ├── cromwell_inputs.json
    │   ├── cromwell_opts.json
    │   ├── cromwell_samples.tsv
    │   └── wdl
    │       ├── compare.wdl
    │       └── tasks/[...]
    └── SAMPLE_B
        ├── cromwell_config.conf
        ├── cromwell_inputs.json
        ├── cromwell_opts.json
        ├── cromwell_samples.tsv
        └── wdl
            ├── compare.wdl
            └── tasks/[...]
```

The `cromwell_samples.tsv` file contains rows with the sample name (e.g. `SAMPLE_A`), VCF name (e.g. `ensemble`), 
and paths to VCF1 and VCF2. You need to simply concatenate those files for each sample you want into one, then run the Cromwell command:

```
cd woof/final/work/SAMPLE_A
cat ../SAMPLE_B/cromwell_samples.tsv >> cromwell_samples.tsv

cromwell -Xms1g -Xmx3g run -Dconfig.file=cromwell_config.conf \
  -DLOG_LEVEL=ERROR -DLOG_LEVEL=WARN \
  --metadata-output cromwell_meta.json \
  --options cromwell_opts.json \
  --inputs cromwell_inputs.json \
  wdl/compare.wdl 2>&1 | tee -a cromwell_log.log
```

That would fill up the `final` directory shown in the above file tree.




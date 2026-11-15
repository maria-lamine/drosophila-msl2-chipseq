#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/raw data/tmp references logs/task_01

# Download and validate SRA run
prefetch SRR495368 --output-directory data/raw
vdb-validate data/raw/SRR495368 2>&1 | tee logs/task_01/vdb_validate.SRR495368.log

# Convert to gzipped FASTQ and checksum
fasterq-dump SRR495368 --outdir data/raw --temp data/tmp --threads 4
gzip -f data/raw/SRR495368.fastq
md5sum data/raw/SRR495368.fastq.gz > logs/task_01/SRR495368.fastq.md5

# Download dm6 reference and build Bowtie2 index if not already present
if [ ! -f references/dm6.fa ]; then
  curl -L https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.fa.gz -o references/dm6.fa.gz
  md5sum references/dm6.fa.gz > logs/task_01/dm6.fa.gz.md5
  gunzip -k references/dm6.fa.gz
fi

if [ ! -f references/dm6.1.bt2 ]; then
  bowtie2-build --threads 4 references/dm6.fa references/dm6 2>&1 | tee logs/task_01/bowtie2_build.dm6.log
fi

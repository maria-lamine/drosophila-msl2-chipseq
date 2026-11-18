#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/raw data/tmp references logs/task_01

# 1. Download and validate SRA run
prefetch SRR495368 --output-directory data/raw
SRA_FILE=$(find data/raw/SRR495368 -type f \( -name "*.sra" -o -name "*.sralite" \) | head -n 1)
if [ -z "${SRA_FILE}" ]; then
  echo "ERROR: Could not locate downloaded SRA file for SRR495368" >&2
  exit 1
fi
vdb-validate "${SRA_FILE}" 2>&1 | tee logs/task_01/vdb_validate.SRR495368.log

# 2. Convert validated SRA file to gzipped FASTQ, verify read count/length, and checksum
fasterq-dump "${SRA_FILE}" --outdir data/raw --temp data/tmp --threads 4
gzip -f data/raw/SRR495368.fastq
md5sum data/raw/SRR495368.fastq.gz > logs/task_01/SRR495368.fastq.md5

READ_COUNT=$(zcat data/raw/SRR495368.fastq.gz | awk 'END {print NR/4}')
READ_LEN=$(zcat data/raw/SRR495368.fastq.gz | awk 'NR==2 {print length($0); exit}')
if [ "${READ_COUNT}" -ne 59200042 ] || [ "${READ_LEN}" -ne 36 ]; then
  echo "ERROR: Expected 59200042 reads of 36 bp, got ${READ_COUNT} reads of ${READ_LEN} bp" >&2
  exit 1
fi

# 3. Download dm6 reference, verify UCSC MD5, and build Bowtie2 index
if [ ! -f references/dm6.fa ]; then
  curl -fL https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.fa.gz -o references/dm6.fa.gz
  curl -fsL https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/md5sum.txt | grep "dm6.fa.gz" > logs/task_01/dm6.fa.gz.md5
  (cd references && awk '{print $1 "  dm6.fa.gz"}' ../logs/task_01/dm6.fa.gz.md5 | md5sum -c -)
  gunzip -k references/dm6.fa.gz
fi

if [ ! -f references/dm6.1.bt2 ]; then
  bowtie2-build --threads 4 references/dm6.fa references/dm6 2>&1 | tee logs/task_01/bowtie2_build.dm6.log
fi

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
READ_LEN=$(zcat data/raw/SRR495368.fastq.gz | awk 'NR%4==2{print length($0)}' | sort -u | paste -sd,)
if [ "${READ_COUNT}" -ne 59200042 ] || [ "${READ_LEN}" != "36" ]; then
  echo "ERROR: Expected 59200042 reads of 36 bp, got ${READ_COUNT} reads of ${READ_LEN} bp" >&2
  exit 1
fi

# 3. Download dm6 reference, verify UCSC MD5, and build Bowtie2 index
UCSC=https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips
[ -s references/dm6.fa.gz ] || curl -fL "$UCSC/dm6.fa.gz" -o references/dm6.fa.gz
curl -fsL "$UCSC/md5sum.txt" | grep ' dm6.fa.gz$' > logs/task_01/dm6.fa.gz.ucsc_md5.txt
md5sum references/dm6.fa.gz | tee logs/task_01/dm6.fa.gz.md5
(cd references && md5sum -c ../logs/task_01/dm6.fa.gz.ucsc_md5.txt) | tee logs/task_01/dm6.fa.gz.md5check.txt
[ -s references/dm6.fa ] || gunzip -k references/dm6.fa.gz
md5sum references/dm6.fa | tee logs/task_01/dm6.fa.md5

if [ ! -f references/dm6.1.bt2 ]; then
  bowtie2-build --threads 4 references/dm6.fa references/dm6 2>&1 | tee logs/task_01/bowtie2_build.dm6.log
fi

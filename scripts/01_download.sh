#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/raw data/tmp references logs/task_01

col() { awk -F'\t' -v c="$1" 'NR==1{for(i=1;i<=NF;i++) if($i==c) k=i} NR==2{print $k}' metadata/samples.tsv; }
RUN=$(col sra_run)
EXP_READS=$(col n_spots)
EXP_LEN=$(col read_length_bp)

# 1. Check disk space, download and validate SRA run
df -h . | tee logs/task_01/disk_space.txt
if [ ! -s "data/raw/${RUN}.fastq.gz" ]; then
  mkdir -p "data/raw/${RUN}"
  LOG="logs/task_01/download.${RUN}.log"
  URL="https://sra-pub-run-odp.s3.amazonaws.com/sra/${RUN}/${RUN}"
  echo "# $(date -u +%FT%TZ) prefetch ${RUN} --output-directory data/raw" > "${LOG}"
  if command -v prefetch >/dev/null 2>&1 && prefetch "${RUN}" --output-directory data/raw >> "${LOG}" 2>&1; then
    echo "# method: prefetch" >> "${LOG}"
  else
    {
      echo "# $(date -u +%FT%TZ) prefetch unavailable or failed; fallback: curl -sS -fL -C - --retry 10 -o data/raw/${RUN}/${RUN}.sra ${URL}"
      curl -sS -fL -C - --retry 10 -o "data/raw/${RUN}/${RUN}.sra" "${URL}" 2>&1
      echo "# method: curl (NCBI AWS S3 mirror)"
    } >> "${LOG}"
  fi
  SRA_FILE=$(find "data/raw/${RUN}" -type f \( -name "*.sra" -o -name "*.sralite" \) | head -n 1)
  if [ -z "${SRA_FILE}" ]; then
    echo "ERROR: Could not locate downloaded SRA file for ${RUN}" >&2
    exit 1
  fi
  { ls -l "${SRA_FILE}"; md5sum "${SRA_FILE}"; } >> "${LOG}"
  vdb-validate "${SRA_FILE}" 2>&1 | tee "logs/task_01/vdb_validate.${RUN}.log"
  # 2. Convert validated SRA file to deterministic gzipped FASTQ (keep local SRA archive)
  fasterq-dump "${SRA_FILE}" --outdir data/raw --temp data/tmp --threads 4 2>&1 | tee "logs/task_01/fasterq_dump.${RUN}.log"
  gzip -nf "data/raw/${RUN}.fastq"
else
  SRA_FILE=$(find "data/raw/${RUN}" -type f \( -name "*.sra" -o -name "*.sralite" \) 2>/dev/null | head -n 1 || true)
  if [ -n "${SRA_FILE}" ]; then
    vdb-validate "${SRA_FILE}" 2>&1 | tee "logs/task_01/vdb_validate.${RUN}.log"
  fi
fi

md5sum "data/raw/${RUN}.fastq.gz" > "logs/task_01/${RUN}.fastq.md5"
READ_COUNT=$(zcat "data/raw/${RUN}.fastq.gz" | awk 'END {print NR/4}')
READ_LEN=$(zcat "data/raw/${RUN}.fastq.gz" | awk 'NR%4==2{print length($0)}' | sort -u | paste -sd,)
printf 'reads\t%s\nread_lengths\t%s\n' "${READ_COUNT}" "${READ_LEN}" | tee "logs/task_01/fastq_check.${RUN}.tsv"
if [ "${READ_COUNT}" -ne "${EXP_READS}" ] || [ "${READ_LEN}" != "${EXP_LEN}" ]; then
  echo "ERROR: Expected ${EXP_READS} reads of ${EXP_LEN} bp, got ${READ_COUNT} reads of ${READ_LEN} bp" >&2
  exit 1
fi

# 3. Download dm6 reference, verify UCSC MD5, and build/verify Bowtie2 index
UCSC=https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips
[ -s references/dm6.fa.gz ] || curl -fsL "${UCSC}/dm6.fa.gz" -o references/dm6.fa.gz
[ -s logs/task_01/dm6.fa.gz.ucsc_md5.txt ] || curl -fsL "${UCSC}/md5sum.txt" | grep ' dm6.fa.gz$' > logs/task_01/dm6.fa.gz.ucsc_md5.txt
md5sum references/dm6.fa.gz | tee logs/task_01/dm6.fa.gz.md5
(cd references && md5sum -c ../logs/task_01/dm6.fa.gz.ucsc_md5.txt) | tee logs/task_01/dm6.fa.gz.md5check.txt

[ -s references/dm6.fa ] || gunzip -k references/dm6.fa.gz
md5sum references/dm6.fa | tee logs/task_01/dm6.fa.md5

if [ ! -f references/dm6.1.bt2 ]; then
  bowtie2-build --threads 4 references/dm6.fa references/dm6 2>&1 | tee logs/task_01/bowtie2_build.dm6.log
fi
bowtie2-inspect -n references/dm6 | wc -l | tee logs/task_01/bowtie2_index.dm6.n_sequences.txt

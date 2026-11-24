#!/usr/bin/env bash
set -euo pipefail

mkdir -p logs/task_01 data/tmp

col() { awk -F'\t' -v c="$1" 'NR==1{for(i=1;i<=NF;i++) if($i==c) k=i} NR==2{print $k}' metadata/samples.tsv; }
RUN=$(col sra_run)
SAMPLE=$(col geo_sample)

SRA_FILE=$(find "data/raw/${RUN}" -type f \( -name "*.sra" -o -name "*.sralite" \) 2>/dev/null | head -n 1 || true)
{
  echo "FASTQ Reconversion Check (${RUN})"
  date -u +"%Y-%m-%dT%H:%M:%SZ"
  if [ -n "${SRA_FILE}" ] && [ -s "data/raw/${RUN}.fastq.gz" ]; then
    fasterq-dump "${SRA_FILE}" --outdir data/tmp --temp data/tmp --threads 4 >/dev/null 2>&1
    gzip -nf "data/tmp/${RUN}.fastq"
    ORIG_MD5=$(md5sum "data/raw/${RUN}.fastq.gz" | awk '{print $1}')
    RECONV_MD5=$(md5sum "data/tmp/${RUN}.fastq.gz" | awk '{print $1}')
    rm -f "data/tmp/${RUN}.fastq.gz"
    echo "Original MD5:    ${ORIG_MD5}"
    echo "Reconverted MD5: ${RECONV_MD5}"
    [ "${ORIG_MD5}" = "${RECONV_MD5}" ] && echo "STATUS: MATCH" || { echo "STATUS: MISMATCH"; exit 1; }
  else
    echo "STATUS: SKIPPED (SRA archive or FASTQ not present locally)"
  fi
} | tee logs/task_01/fastq_reconversion_check.txt

{
  echo "# Local Artifacts Manifest (Task 01)"
  echo ""
  echo "| Artifact | Path | Size | MD5 Checksum |"
  echo "| :--- | :--- | :--- | :--- |"
  for f in \
    "${SRA_FILE}" \
    "data/raw/${RUN}.fastq.gz" \
    "results/task_01/bam/${SAMPLE}.dm6.sorted.bam" \
    "results/task_01/bam/${SAMPLE}.dm6.primary_q30.bam" \
    "results/task_01/tracks/${SAMPLE}.dm6.CPM.bw"; do
    if [ -n "${f}" ] && [ -s "${f}" ]; then
      SZ=$(du -h "${f}" | awk '{print $1}')
      MD5=$(md5sum "${f}" | awk '{print $1}')
      echo "| \`$(basename "${f}")\` | \`${f}\` | ${SZ} | \`${MD5}\` |"
    fi
  done
} > logs/task_01/local_files_manifest.md

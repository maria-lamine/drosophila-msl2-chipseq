#!/usr/bin/env bash
# Post-run checks: FASTQ reconversion from the SRA archive and checksum manifest (same format as report.md)
set -euo pipefail

mkdir -p logs/task_01 data/tmp

col() { awk -F'\t' -v c="$1" 'NR==1{for(i=1;i<=NF;i++) if($i==c) k=i} NR==2{print $k}' metadata/samples.tsv; }
RUN=$(col sra_run)
SAMPLE=$(col geo_sample)

SRA_FILE=$(find "data/raw/${RUN}" -type f \( -name "*.sra" -o -name "*.sralite" \) 2>/dev/null | head -n 1 || true)

# 1. FASTQ reconversion: compare uncompressed content (independent of the gzip version)
if [ -n "${SRA_FILE}" ] && [ -s "data/raw/${RUN}.fastq.gz" ]; then
  fasterq-dump "${SRA_FILE}" --outdir data/tmp --temp data/tmp --threads 4 > "logs/task_01/fasterq_dump.reconversion.${RUN}.log" 2>&1
  EXISTING=$(zcat "data/raw/${RUN}.fastq.gz" | md5sum | cut -d' ' -f1)
  RECONVERTED=$(md5sum < "data/tmp/${RUN}.fastq" | cut -d' ' -f1)
  rm -f "data/tmp/${RUN}.fastq"
  printf 'existing:    %s\nreconverted: %s\n' "${EXISTING}" "${RECONVERTED}" | tee logs/task_01/fastq_reconversion_check.txt
  if [ "${EXISTING}" != "${RECONVERTED}" ]; then
    echo "ERROR: reconverted FASTQ differs from data/raw/${RUN}.fastq.gz" >&2
    exit 1
  fi
else
  echo "SKIPPED: SRA archive or FASTQ not present locally; fastq_reconversion_check.txt left unchanged" >&2
fi

# 2. Manifest: MD5 for every file; the manifest does not list itself
TRACKED=(
  logs/task_01/software_versions.txt "logs/task_01/download.${RUN}.log" "logs/task_01/vdb_validate.${RUN}.log"
  logs/task_01/fastq_reconversion_check.txt "logs/task_01/${RUN}.fastq.md5" "logs/task_01/fastq_check.${RUN}.tsv"
  logs/task_01/dm6.fa.gz.md5check.txt "logs/task_01/bowtie2.${SAMPLE}.log" "logs/task_01/bamCoverage.${SAMPLE}.log"
  "logs/task_01/${SAMPLE}.bigwig_maxima.tsv" results/task_01/qc/multiqc_report.html
  reports/task_01/igv/fig1_session.json reports/task_01/igv/fig2_session.json reports/task_01/igv/fig3_session.json
  reports/task_01/figures/raw/fig1_roX1_CES_raw.png reports/task_01/figures/raw/fig2_Act5C_X_gene_raw.png
  reports/task_01/figures/raw/fig3_RpL32_autosomal_control_raw.png
  reports/task_01/figures/fig1_roX1_CES.png reports/task_01/figures/fig2_Act5C_X_gene.png
  reports/task_01/figures/fig3_RpL32_autosomal_control.png
)
LOCAL=(
  "${SRA_FILE:-data/raw/${RUN}/${RUN}.sra}|Ignored (local SRA archive)"
  "data/raw/${RUN}.fastq.gz|Ignored (raw FASTQ)"
  "results/task_01/bam/${SAMPLE}.dm6.sorted.bam|Ignored (coordinate-sorted BAM)"
  "results/task_01/bam/${SAMPLE}.dm6.primary_q30.bam|Ignored (filtered primary MAPQ >= 30 BAM)"
  "results/task_01/tracks/${SAMPLE}.dm6.CPM.bw|Ignored (CPM-normalized bigWig track)"
)

hsize() {
  awk -v b="$(stat -c %s "$1")" 'BEGIN {
    if (b < 1024) printf "%d B", b
    else if (b < 1048576) printf "%.1f KB", b / 1024
    else if (b < 1073741824) printf "%.1f MB", b / 1048576
    else printf "%.2f GB", b / 1073741824 }'
}
# shellcheck disable=SC2016  # backticks are Markdown, not command substitution
row() { printf '| `%s` | %s | `%s` | %s |\n' "$1" "$(hsize "$1")" "$(md5sum "$1" | cut -d' ' -f1)" "$2"; }

MANIFEST=logs/task_01/local_files_manifest.md
missing=0
{
  echo "# Local & Tracked Artifact Manifest (\`${SAMPLE}\` / \`${RUN}\`)"
  echo
  echo "| Artifact | Size | MD5 | Status |"
  echo "| :--- | ---: | :--- | :--- |"
  for f in "${TRACKED[@]}"; do row "$f" "Tracked"; done
  for e in "${LOCAL[@]}"; do
    f=${e%%|*}
    if [ -s "$f" ]; then row "$f" "${e#*|}"; else missing=1; fi
  done
} > "${MANIFEST}.tmp"

if [ "${missing}" -eq 0 ]; then
  mv "${MANIFEST}.tmp" "${MANIFEST}"
  echo "Manifest written: ${MANIFEST}"
else
  rm -f "${MANIFEST}.tmp"
  echo "SKIPPED: large local files missing; ${MANIFEST} left unchanged" >&2
fi

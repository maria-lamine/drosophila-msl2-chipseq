#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p logs/task_01

{
  printf 'curl: %s\n' "$(curl --version | head -n 1 | awk '{print $2}')"
  python3 -c 'import sys, PIL, pyBigWig; print(f"Python: {sys.version.split()[0]}\nPillow: {PIL.__version__}\npyBigWig: {pyBigWig.__version__}")'
  for t in prefetch fasterq-dump fastqc multiqc bowtie2 samtools bamCoverage; do
    printf '%s: %s\n' "$t" "$("$t" --version 2>&1 | grep -m1 -E '[0-9]+\.[0-9]+')"
  done
  printf 'IGV-Web: 2.4.10 (igv.js 3.8.8) (web application, https://igv.org/app)\n'
} > logs/task_01/software_versions.txt

for s in 01_download 02_fastq_qc 03_align_and_filter 04_coverage; do
  bash "scripts/$s.sh"
done
python3 scripts/05_annotate_igv_figures.py

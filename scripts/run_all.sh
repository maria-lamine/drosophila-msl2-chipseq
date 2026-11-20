#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p logs/task_01

{
  for t in prefetch fasterq-dump fastqc multiqc bowtie2 samtools bamCoverage; do
    printf '%s: %s\n' "$t" "$("$t" --version 2>&1 | grep -m1 -E '[0-9]+\.[0-9]+')"
  done
} > logs/task_01/software_versions.txt

for s in 01_download 02_fastq_qc 03_align_and_filter 04_coverage; do
  bash "scripts/$s.sh"
done

#!/usr/bin/env bash
set -euo pipefail

mkdir -p results/task_01/qc logs/task_01

col() { awk -F'\t' -v c="$1" 'NR==1{for(i=1;i<=NF;i++) if($i==c) k=i} NR==2{print $k}' metadata/samples.tsv; }
RUN=$(col sra_run)

fastqc "data/raw/${RUN}.fastq.gz" \
  --outdir results/task_01/qc \
  --threads 4 \
  2>&1 | tee "logs/task_01/fastqc.${RUN}.log"

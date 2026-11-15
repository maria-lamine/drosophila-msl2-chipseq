#!/usr/bin/env bash
set -euo pipefail

mkdir -p results/task_01/qc logs/task_01

fastqc data/raw/SRR495368.fastq.gz \
  --outdir results/task_01/qc \
  --threads 4 \
  2>&1 | tee logs/task_01/fastqc.SRR495368.log

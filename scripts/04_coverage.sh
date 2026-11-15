#!/usr/bin/env bash
set -euo pipefail

mkdir -p results/task_01/tracks logs/task_01

bamCoverage \
  --bam results/task_01/bam/GSM929149.dm6.primary_q30.bam \
  --outFileName results/task_01/tracks/GSM929149.dm6.CPM.bw \
  --outFileFormat bigwig \
  --binSize 10 \
  --normalizeUsing CPM \
  --extendReads 150 \
  --numberOfProcessors 4 \
  2>&1 | tee logs/task_01/bamCoverage.GSM929149.log

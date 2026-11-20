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

python3 - results/task_01/tracks/GSM929149.dm6.CPM.bw <<'PY' | tee logs/task_01/GSM929149.bigwig_maxima.tsv
import sys, pyBigWig
bw = pyBigWig.open(sys.argv[1])
print("region\tlocus\tmax_CPM\tmean_CPM")
for n, c, s, e in [("roX1", "chrX", 3850000, 3870000), ("Act5C", "chrX", 5893000, 5913000), ("RpL32", "chr3R", 30035000, 30055000)]:
    print(f"{n}\t{c}:{s}-{e}\t{bw.stats(c, s, e, type='max')[0]:.2f}\t{bw.stats(c, s, e)[0]:.3f}")
PY

#!/usr/bin/env bash
set -euo pipefail

mkdir -p results/task_01/tracks logs/task_01

col() { awk -F'\t' -v c="$1" 'NR==1{for(i=1;i<=NF;i++) if($i==c) k=i} NR==2{print $k}' metadata/samples.tsv; }
SAMPLE=$(col geo_sample)

FILT_BAM="results/task_01/bam/${SAMPLE}.dm6.primary_q30.bam"
BW_OUT="results/task_01/tracks/${SAMPLE}.dm6.CPM.bw"

bamCoverage \
  --bam "${FILT_BAM}" \
  --outFileName "${BW_OUT}" \
  --outFileFormat bigwig \
  --binSize 10 \
  --normalizeUsing CPM \
  --extendReads 150 \
  --numberOfProcessors 4 \
  --verbose \
  2>&1 | tee "logs/task_01/bamCoverage.${SAMPLE}.log"

python3 - "${BW_OUT}" <<'PY' | tee "logs/task_01/${SAMPLE}.bigwig_maxima.tsv"
import sys, pyBigWig
bw = pyBigWig.open(sys.argv[1])
print("region\tlocus\tmax_CPM\tmean_CPM")
for n, c, s, e in [("roX1", "chrX", 3850000, 3870000), ("Act5C", "chrX", 5893000, 5913000), ("RpL32", "chr3R", 30035000, 30055000)]:
    print(f"{n}\t{c}:{s}-{e}\t{bw.stats(c, s, e, type='max')[0]:.2f}\t{bw.stats(c, s, e, type='mean')[0]:.3f}")
PY

#!/usr/bin/env bash
set -euo pipefail

mkdir -p results/task_01/bam results/task_01/qc logs/task_01 data/tmp

RAW_BAM="results/task_01/bam/GSM929149.dm6.sorted.bam"
FILT_BAM="results/task_01/bam/GSM929149.dm6.primary_q30.bam"

# 1. Align single-end reads and coordinate-sort
bowtie2 -p 4 -x references/dm6 -U data/raw/SRR495368.fastq.gz \
  2> logs/task_01/bowtie2.GSM929149.log \
  | samtools sort -@ 4 -o "${RAW_BAM}" -
samtools index "${RAW_BAM}"
samtools quickcheck -v "${RAW_BAM}"

# 2. QC metrics on unfiltered BAM (full idxstats without head!)
samtools flagstat "${RAW_BAM}" > results/task_01/qc/GSM929149.sorted.flagstat.txt
samtools idxstats "${RAW_BAM}" > results/task_01/qc/GSM929149.sorted.idxstats.txt
samtools stats "${RAW_BAM}" > results/task_01/qc/GSM929149.sorted.stats.txt

# 3. Inspect unmapped reads (flag 0x4) to explain the unaligned fraction
samtools fastq -f 4 "${RAW_BAM}" | gzip > data/tmp/SRR495368.unmapped.fastq.gz
fastqc data/tmp/SRR495368.unmapped.fastq.gz --outdir results/task_01/qc --threads 4
rm -f data/tmp/SRR495368.unmapped.fastq.gz

# 4. Filter: remove unmapped (0x4), secondary (0x100), supplementary (0x800); keep MAPQ >= 30
samtools view -@ 4 -b -F 0x904 -q 30 -o "${FILT_BAM}" "${RAW_BAM}"
samtools index "${FILT_BAM}"
samtools quickcheck -v "${FILT_BAM}"

# 5. QC metrics on filtered BAM
samtools flagstat "${FILT_BAM}" > results/task_01/qc/GSM929149.primary_q30.flagstat.txt
samtools idxstats "${FILT_BAM}" > results/task_01/qc/GSM929149.primary_q30.idxstats.txt
samtools stats "${FILT_BAM}" > results/task_01/qc/GSM929149.primary_q30.stats.txt

# 6. Measure PCR duplication rate without discarding duplicates
samtools markdup -@ 4 -s \
  -f results/task_01/qc/GSM929149.primary_q30.markdup_stats.txt \
  "${FILT_BAM}" data/tmp/markdup.tmp.bam
rm -f data/tmp/markdup.tmp.bam

# 7. Aggregate all FastQC + Bowtie2 + Samtools logs with MultiQC
multiqc results/task_01/qc logs/task_01 \
  --outdir results/task_01/qc \
  --filename multiqc_report.html \
  --force

# Drosophila melanogaster MSL2 ChIP-seq Analysis (`GSM929149` / `SRR495368`)

Reproducible bioinformatics pipeline and visual verification of MSL2-FLAG ChIP-seq in male *Drosophila melanogaster* S2 cells aligned to the UCSC `dm6` reference genome.

## Repository Structure
- `environment.yml`: Pinned Conda environment (`bowtie2`, `samtools`, `deeptools`, `fastqc`, `multiqc`, `sra-tools`).
- `metadata/`: Sample provenance (`samples.tsv`) and reference genome checksums (`reference.tsv`).
- `scripts/`: Modular bash scripts (`01_download.sh`, `02_fastq_qc.sh`, `03_align_and_filter.sh`, `04_coverage.sh`).
- `logs/task_01/`: Full `samtools` alignment, filtering (`MAPQ >= 30`), and PCR duplication metrics.
- `reports/task_01/`: Technical report (`report.md`) and IGV visual verification screenshots (`figures/`).

## Reproduction Instructions
1. Create and activate the Conda environment:
   - `conda env create -f environment.yml`
   - `conda activate msl2-chipseq`
2. Run the pipeline scripts sequentially:
   - `bash scripts/01_download.sh`
   - `bash scripts/02_fastq_qc.sh`
   - `bash scripts/03_align_and_filter.sh`
   - `bash scripts/04_coverage.sh`

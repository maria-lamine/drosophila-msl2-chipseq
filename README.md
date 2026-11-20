# Drosophila S2 MSL2 ChIP-seq Pipeline (`GSM929149`)

Reproducible bioinformatics pipeline processing *Drosophila melanogaster* S2 male MSL2 ChIP-seq data (`GSE37864` / `GSM929149` / `SRR495368`, Straub et al. 2013) on the UCSC `dm6` reference genome.

## Repository Structure
- `metadata/`: Sample sheet (`samples.tsv`) and `dm6` reference manifest (`reference.tsv`).
- `scripts/`: Modular shell scripts (`01_download.sh`–`04_coverage.sh`) and end-to-end runner (`run_all.sh`).
- `logs/task_01/`: Software versions, MD5 verification logs, Bowtie2/bamCoverage execution logs, and `pyBigWig` signal maxima.
- `results/task_01/qc/`: FastQC, SAMtools (`stats`, `flagstat`, `idxstats`, `markdup`), and MultiQC summary (`multiqc_report.html`).
- `reports/task_01/`: Full analytical report (`report.md`) and fixed-scale (`[0 - 25]` CPM) IGV figures (`figures/`).

## Quickstart
```bash
conda env create -f environment.yml
conda activate msl2-chipseq
bash scripts/run_all.sh
```

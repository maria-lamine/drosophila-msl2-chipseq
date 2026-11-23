# Drosophila S2 MSL2 ChIP-seq Pipeline (`GSM929149`)

Reproducible bioinformatics pipeline processing *Drosophila melanogaster* S2 male MSL2 ChIP-seq data (`GSE37864` / `GSM929149` / `SRR495368`, Straub *et al.* 2013) on the UCSC `dm6` reference genome.

## Key Deliverables & Results
- **Analytical Report:** [`reports/task_01/report.md`](reports/task_01/report.md) — covers dosage-compensation biology, provenance, Bowtie2 alignment (`71.44%`; `32,530,464` primary `MAPQ >= 30` reads), `samtools markdup` (`25.46%` retained), `chrX`/autosome density (`0.75`), and IGV inspection (`roX1`, `Act5C`, `RpL32`).
- **Aggregated QC Dashboard:** [`results/task_01/qc/multiqc_report.html`](results/task_01/qc/multiqc_report.html)
- **Annotated IGV Figures:** [`reports/task_01/figures/`](reports/task_01/figures/)
- **Large Local Artifacts (git-ignored, checksummed in `report.md` §10):** `SRR495368.sra`, `SRR495368.fastq.gz`, `GSM929149.dm6.sorted.bam`, `GSM929149.dm6.primary_q30.bam`, `GSM929149.dm6.CPM.bw`

## Repository Structure
- `metadata/`: Sample sheet (`samples.tsv`) and `dm6` reference manifest (`reference.tsv`).
- `scripts/`: Dynamic shell scripts (`01_download.sh`–`04_coverage.sh`) and runner (`run_all.sh`).
- `logs/task_01/`: Software versions, `vdb-validate`, FASTQ checks, `samtools quickcheck`, disk audit, Bowtie2/bamCoverage logs, and `pyBigWig` maxima.
- `results/task_01/qc/`: FastQC HTML reports, SAMtools QC tables, and `multiqc_report.html`.
- `reports/task_01/`: Full analytical report (`report.md`) and annotated IGV figures (`figures/`).

## Quickstart
    conda env create -f environment.yml
    conda activate msl2-chipseq
    bash scripts/run_all.sh

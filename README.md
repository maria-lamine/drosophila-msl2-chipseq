# Drosophila S2 MSL2 ChIP-seq Pipeline (`GSM929149`)

Reproducible bioinformatics pipeline processing *Drosophila melanogaster* S2 male MSL2 ChIP-seq data (`GSE37864` / `GSM929149` / `SRR495368`, Straub *et al.* 2013) on the UCSC `dm6` reference genome.

## Key Deliverables & Results
- **Analytical Report:** [`reports/task_01/report.md`](reports/task_01/report.md) — covers dosage-compensation biology, provenance (`prefetch`, with `curl` fallback to the NCBI AWS S3 mirror that was used for the actual retrieval), Bowtie2 alignment (`71.44%`; `32,530,464` primary `MAPQ >= 30` reads), `samtools markdup` (`25.46%` position-based duplicates, retained), `chrX`/autosome density (`0.75`), quantitative `pyBigWig` maxima, and IGV-Web inspection (`roX1`, `Act5C`, `RpL32`).
- **Aggregated QC Dashboard:** [`results/task_01/qc/multiqc_report.html`](results/task_01/qc/multiqc_report.html)
- **Annotated & Raw IGV Figures:** [`reports/task_01/figures/`](reports/task_01/figures/) (raw captures in `figures/raw/` + per-figure IGV-Web sessions in [`reports/task_01/igv/`](reports/task_01/igv/))
- **Version History:** [`CHANGELOG.md`](CHANGELOG.md) (the latest release tag is listed at the top of the changelog)
- **Large Local Artifacts (git-ignored, checksummed in `report.md` §10):** `SRR495368.sra`, `SRR495368.fastq.gz`, `GSM929149.dm6.sorted.bam`, `GSM929149.dm6.primary_q30.bam`, `GSM929149.dm6.CPM.bw`

## Repository Structure
- `metadata/`: Sample sheet (`samples.tsv`) and `dm6` reference manifest (`reference.tsv`).
- `scripts/`: Dynamic shell scripts (`01_download.sh`–`04_coverage.sh`), IGV figure banner annotator (`05_annotate_igv_figures.py`), post-run checks (`06_checks.sh`: FASTQ reconversion and checksum manifest), and end-to-end runner (`run_all.sh`).
- `logs/task_01/`: Software versions (`curl`, `Python`, `Pillow`, `pyBigWig`, `IGV-Web`, `SRA-Tools`, `FastQC`, `MultiQC`, `Bowtie2`, `SAMtools`, `deepTools`), download log (`download.SRR495368.log`), `vdb-validate`, FASTQ checks and reconversion check (`fastq_reconversion_check.txt`), `samtools quickcheck`, disk audit, Bowtie2/`bamCoverage` logs, `pyBigWig` maxima, and the checksum manifest (`local_files_manifest.md`).
- `results/task_01/qc/`: FastQC HTML reports, SAMtools QC tables, and `multiqc_report.html`.
- `reports/task_01/`: Full analytical report (`report.md`), IGV-Web sessions (`igv/fig1_session.json`-`igv/fig3_session.json`), raw screenshots (`figures/raw/`), and annotated IGV figures (`figures/`).

## Quickstart
```bash
conda env create -f environment.yml
conda activate msl2-chipseq
bash scripts/run_all.sh                                 # steps 01-04, then 06_checks.sh
bash scripts/run_all.sh --rebuild-figures # same, then re-annotates the IGV figures from figures/raw/
```

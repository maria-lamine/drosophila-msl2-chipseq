# Changelog

## [task-01-v10] - 2026-11-23
- **Download reproducibility (`R1`, `R2`):** Replaced `prefetch` in `scripts/01_download.sh` with NCBI AWS S3 `curl` retrieval (`curl -C - --retry 10 -L`) and aligned `logs/task_01/download.SRR495368.log` header date to `2026-11-23`.
- **Figure & IGV provenance (`R3`):** Version-controlled Pillow annotation script (`scripts/05_annotate_igv_figures.py`), uncropped raw IGV captures (`reports/task_01/figures/raw/`), and IGV-Web session (`reports/task_01/igv_session.json`).
- **Documentation & software manifest (`R4`, `R5`, `R6`):** Updated `README.md`, added `CHANGELOG.md`, and recorded `curl` (`8.23.0`), `Python` (`3.13.18`), `Pillow` (`13.0.0`), `pyBigWig` (`0.3.29`), and `IGV-Web` (`2.4.10` / `igv.js` `3.8.8`) in `logs/task_01/software_versions.txt` and `reports/task_01/report.md`.

## [task-01-v9] - 2026-11-23
- Clarified Bowtie2 `MAPQ >= 30` multi-mapper filtering, synchronized MD5 checksums, added `chrX`/`chr4`/`chrY`/`chrM` read-density table, and regenerated deduplicated MultiQC dashboard.

## [task-01-v1..v8] - 2026-11-18 to 2026-11-23
- Initial repository scaffold, Conda lockfiles, `dm6` reference verification, Bowtie2 alignment, `samtools` QC/markdup, deepTools `bamCoverage` CPM track, `pyBigWig` quantitative maxima, and Task 01 report.

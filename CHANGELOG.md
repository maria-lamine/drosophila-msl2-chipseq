# Changelog

## [task-01-v13] - 2026-11-24
- **Deterministic alignment & offline reference checks (`D6`, `D8`):** Added `--reorder` to `bowtie2` in `scripts/03_align_and_filter.sh` for bit-for-bit reproducible BAM outputs across threads, and guarded UCSC `md5sum.txt` retrieval in `scripts/01_download.sh` so offline reruns reuse the cached checksum.
- **Automated verification & local artifact manifest (`D5`):** Added `scripts/06_checks.sh` (wired into `scripts/run_all.sh`) to verify deterministic FASTQ reconversion (`logs/task_01/fastq_reconversion_check.txt`) and generate `logs/task_01/local_files_manifest.md`.
- **Documentation & tag history (`D10`, `D11`, `D12`):** Corrected `README.md` (`74.54%` unique reads retained after `samtools markdup`, per-figure IGV sessions, `06_checks.sh`), fixed historical dates in `CHANGELOG.md`, and restored `task-01-v9` to its original commit.

## [task-01-v12] - 2026-11-24
- **Version & environment consistency (`D3`, `D9`):** Unified IGV-Web version reporting as `IGV-Web 2.4.10 (igv.js 3.8.8)` across scripts, logs, and documentation, and explicitly declared `python=3.13.18`, `curl=8.23.0`, `pillow=13.0.0`, and `pybigwig=0.3.29` in `environment.yml`.

## [task-01-v11] - 2026-11-24
- **IGV figures, sessions & SRA download (`D1`, `D2`, `D4`):** Replaced the single multi-locus session with per-figure IGV-Web sessions (`reports/task_01/igv/fig1_session.json`–`fig3_session.json`), aligned figure captures with the published report, and restored `prefetch` as primary retrieval with NCBI AWS S3 `curl` fallback in `scripts/01_download.sh`.

## [task-01-v10] - 2026-11-23
- **Provenance & documentation (`R1`–`R6`):** Added `scripts/05_annotate_igv_figures.py`, initial IGV-Web session export, `CHANGELOG.md`, and software version logging in `logs/task_01/software_versions.txt`.

## [task-01-v9] - 2026-11-23
- Clarified Bowtie2 `MAPQ >= 30` multi-mapper filtering, updated MD5 checksums, added `chrX`/`chr4`/`chrY`/`chrM` read-density table, and regenerated deduplicated MultiQC dashboard.

## [task-01-v1..v8] - 2026-11-12 to 2026-11-23
- Initial repository scaffold, Conda lockfiles, `dm6` reference verification, Bowtie2 alignment, `samtools` QC/markdup, deepTools `bamCoverage` CPM track, `pyBigWig` quantitative maxima, and Task 01 report.

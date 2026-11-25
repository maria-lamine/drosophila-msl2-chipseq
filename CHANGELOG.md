# Changelog

## [task-01-v14] - 2026-11-25
- **IGV figures (N1):** recaptured the three IGV-Web views with the filtered BAM and its index loaded (coverage and reads visible), regenerated the annotated figures from `figures/raw/` with `scripts/05_annotate_igv_figures.py`, and re-exported the per-figure sessions in `reports/task_01/igv/`.
- **Download log (N2):** restored the date and `curl` command of the actual 2026-11-23 retrieval; `scripts/01_download.sh` now writes the date, the method used (`prefetch` or `curl` fallback), the archive size and its MD5.
- **Checksums (N3, N9):** rewrote `scripts/06_checks.sh` (reconversion check in the committed format, full MD5 manifest, proper if/else), ran it on the full data (reconversion identical, `ca17f2bdfb248389cf0aaf9bb455550d`), and rebuilt `report.md` section 10 from the manifest; all checksums are MD5 and match the files.
- **BAM checksums (N6):** section 10 states that the committed BAM checksums predate `--reorder`.
- **README (N4):** fixed the broken link to the removed `igv_session.json` and its other mention, the ambiguous `25.46%` wording, the scripts and logs lists, and documented `--rebuild-figures`.
- **Report (N10):** documented `--reorder`, `scripts/06_checks.sh`, `--rebuild-figures` and the per-figure IGV sessions.
- **Version capture (N7):** `run_all.sh` ignores stderr when reading `--version` and writes the IGV-Web line as committed.
- **Tags (N8):** `task-01-v9` recreated as an annotated tag on `a08ef8d`.

## [task-01-v13] - 2026-11-24
- Added `--reorder` to `bowtie2` in `scripts/03_align_and_filter.sh` (D6); the committed BAM checksums predate this change.
- Cached the UCSC `md5sum.txt` in `scripts/01_download.sh` so offline reruns reuse it (D8).
- Added `scripts/06_checks.sh`, wired into `scripts/run_all.sh` (D5); its outputs were not committed in this release.
- Restored 'task-01-v9' to its original commit 'a88ef8d' (D10; subsequently recreated as an annotated tag in 'task-01-v14').
- Note: this release did not change `README.md` or the version capture in `run_all.sh` (D7, D12), contrary to an earlier wording of this entry and of the tag message.

## [task-01-v12] - 2026-11-24
- **Version & environment consistency (`D3`, `D9`):** Unified IGV-Web version reporting as `IGV-Web 2.4.10 (igv.js 3.8.8)` across scripts, logs, and documentation, and explicitly declared `python=3.13.18`, `curl=8.23.0`, `pillow=13.0.0`, and `pybigwig=0.3.29` in `environment.yml`.

## [task-01-v11] - 2026-11-24
- **IGV figures, sessions & SRA download (`D1`, `D2`, `D4`):** Replaced the single multi-locus session with per-figure IGV-Web sessions (`reports/task_01/igv/fig1_session.json`–`fig3_session.json`), aligned figure captures with the published report, and restored `prefetch` as primary retrieval with NCBI AWS S3 `curl` fallback in `scripts/01_download.sh`.
- Note: the recaptured figures initially showed an empty BAM track (no coverage, no reads); resolved in 'task-01-v14' ('M1').

## [task-01-v10] - 2026-11-23
- **Provenance & documentation (`R1`–`R6`):** Added `scripts/05_annotate_igv_figures.py`, initial IGV-Web session export, `CHANGELOG.md`, and software version logging in `logs/task_01/software_versions.txt`.

## [task-01-v9] - 2026-11-23
- Clarified Bowtie2 `MAPQ >= 30` multi-mapper filtering wording, corrected MD5 and GC values, added the four-level QC table, suspicious IGV features and open questions, regenerated the deduplicated MultiQC dashboard (5 samples) and the manifest, and replaced the hand-written download note with the real retrieval log.

## [task-01-v1..v8] - 2026-11-12 to 2026-11-23
- Initial repository scaffold (chrX/chr4/chrY/chrM read-density table added in task-01-v3, 2026-11-14), Conda lockfiles, `dm6` reference verification, Bowtie2 alignment, `samtools` QC/markdup, deepTools `bamCoverage` CPM track, `pyBigWig` quantitative maxima, and Task 01 report.

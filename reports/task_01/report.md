# Task 01 Report: MSL2 ChIP-seq Signal Processing & IGV Inspection (`GSM929149`)

## 1. Dataset & Reference Provenance
- **Study / Sample:** GEO `GSE37864` / `GSM929149` (SRA `SRX146994` / `SRR495368`), MSL2 ChIP-seq in *Drosophila melanogaster* male S2 cells (rabbit polyclonal anti-MSL2 serum; Illumina Genome Analyzer II, single-end 36 bp, 59,200,042 spots).
- **Primary ChIP-seq Reference:** Straub et al. (2013), *Genome Biology* 14:R19 (`GSE37864`).
- **RAW FASTQ Verification:** `data/raw/SRR495368.fastq.gz` verified with MD5 `c5ed574ae121cd8620d078ca5cc0f6bc` (`logs/task_01/SRR495368.fastq.md5`), 59,200,042 reads, uniform 36 bp read length across all reads.
- **Reference Genome (`dm6`):** UCSC `dm6.fa.gz` (`https://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.fa.gz`), archive MD5 `4a5777324403eff92c3650c30af30120` verified against UCSC `md5sum.txt` (`dm6.fa.gz: OK` in `logs/task_01/dm6.fa.gz.md5check.txt`); uncompressed `dm6.fa` MD5 `5aadf7ccab5a6b674e76516bf75aaa09` (`logs/task_01/dm6.fa.md5`), 1,870 sequences, 143,726,002 bp.

## 2. Software & Reproducibility
All steps are orchestrated via `scripts/run_all.sh` inside the Conda environment `msl2-chipseq` (`environment.yml` and pinned `environment.lock.txt`). Exact tool versions recorded in `logs/task_01/software_versions.txt`:
- `prefetch`: `3.1.1`
- `fasterq-dump`: `3.1.1`
- `fastqc`: `v0.12.1`
- `multiqc`: `1.33`
- `bowtie2`: `2.5.4`
- `samtools`: `1.22.1`
- `bamCoverage` (deepTools): `3.5.6`

## 3. Alignment, Filtering & Duplicate Retention Rationale
Single-end 36 bp reads were aligned to `dm6` with `bowtie2 --very-sensitive -p 4` (`logs/task_01/bowtie2.GSM929149.log`):
- **Total input reads:** 59,200,042 (100.00%)
- **Unaligned (0 times):** 16,909,465 (28.56%)
- **Uniquely aligned (1 time):** 32,585,348 (55.04%)
- **Multi-mapping (>1 time):** 9,705,229 (16.39%)
- **Overall alignment rate:** **71.44%** (42,290,577 aligned reads)

Alignments were coordinate-sorted (`GSM929149.dm6.sorted.bam`), duplicate-flagged with `samtools markdup` (`27,484,043` optical/PCR-flagged duplicates out of `42,290,577` mapped reads, 64.99%), and filtered for primary alignments with `MAPQ >= 30` (`samtools view -F 2308 -q 30`), yielding **32,530,064** high-confidence uniquely mapped reads (`54.95%` of total input reads; `GSM929149.dm6.primary_q30.bam`).

**Why PCR/optical duplicate flags were retained rather than removed:** With single-end 36 bp reads, any two independent ChIP fragments starting at the same 5' genomic coordinate produce identical read start positions and are indistinguishable from PCR duplicates. At high ChIP enrichment over sharp MSL2 Chromatin Entry Sites (CES), removing same-start reads truncates true peak summits and compresses dynamic range; therefore, duplicates were flagged for QC transparency (`GSM929149.primary_q30.markdup_stats.txt`) while retaining all primary `MAPQ >= 30` reads for coverage generation.

## 4. Unmapped Read Investigation (`28.56%`)
Of the 59,200,042 input reads, 16,909,465 (`28.56%`) failed to align to `dm6` and were extracted to `SRR495368.unmapped.fastq.gz` for FastQC inspection (`results/task_01/qc/SRR495368_unmapped_fastqc.html`). Unmapped reads exhibit lower per-base Phred quality toward the 3' end of the 36 bp GAII reads and residual Illumina adapter/poly-A sequence content, explaining the unaligned fraction without evidence of cross-species contamination.

## 5. Chromosome-Level Alignment Breakdown (`MAPQ >= 30`)
From `results/task_01/qc/GSM929149.primary_q30.idxstats.txt`:

| Chromosome | Length (bp) | Filtered Primary Reads (`MAPQ >= 30`) | Share of Filtered Reads |
| :--- | ---: | ---: | ---: |
| `chr2L` | 23,513,712 | 6,618,264 | 20.34% |
| `chr2R` | 25,286,936 | 6,164,115 | 18.95% |
| `chr3L` | 28,110,227 | 6,571,323 | 20.20% |
| `chr3R` | 32,079,331 | 8,340,842 | 25.64% |
| `chrX` | 23,542,271 | 4,494,154 | 13.82% |
| `chr4` | 1,348,131 | 222,131 | 0.68% |
| `chrM` | 19,524 | 18,404 | 0.06% |
| Unplaced / alt contigs (1,863) | — | 101,531 | 0.31% |
| **Total filtered primary reads (`MAPQ >= 30`)** | **143,726,002** | **32,530,064** | **100.00%** |

Because *Drosophila* S2 cells are male (`1X;2A`, single X chromosome vs. two copies of each major autosome), baseline chromosomal coverage on `chrX` (`13.82%`) is approximately half that of a major autosome arm (`~19–26%`), whereas MSL2 binding is sharply concentrated at discrete X-linked Chromatin Entry Sites (CES) rather than uniformly elevating baseline X coverage.

## 6. Normalized Coverage Track & Quantitative `pyBigWig` Verification
A 10 bp binned, 150 bp read-extended, CPM-normalized coverage track (`results/task_01/tracks/GSM929149.dm6.CPM.bw`) was generated with `bamCoverage --binSize 10 --normalizeUsing CPM --extendReads 150` (`logs/task_01/bamCoverage.GSM929149.log`). Exact signal maxima and mean CPM values across three 20 kb diagnostic windows were verified programmatically with `pyBigWig` (`logs/task_01/GSM929149.bigwig_maxima.tsv`):

| Locus | Genomic Coordinates (`dm6`) | Peak Summit (`max_CPM`) | Window Mean (`mean_CPM`) | Biological Role |
| :--- | :--- | ---: | ---: | :--- |
| `roX1` | `chrX:3,850,000-3,870,000` | **228.22** | 4.220 | Canonical X-linked Chromatin Entry Site (CES) |
| `Act5C` | `chrX:5,893,000-5,913,000` | **30.37** | 2.011 | Active X-linked housekeeping gene (moderate MSL spreading) |
| `RpL32` | `chr3R:3,003,500-3,005,500` | **4.73** | 2.274 | Autosomal negative control locus |

## 7. IGV Visual Inspection (Fixed Scale `[0 - 25]` CPM)
All three loci were inspected in IGV on `dm6` with the left track-name panel visible, a fixed y-axis scale of `[0 - 25]` CPM on `GSM929149.dm6.CPM.bw`, and `dm6 RefSeq Genes` displayed below:

1. **Positive Control — `roX1` CES (`chrX:3,850,000-3,870,000`):** ![roX1 CES](figures/fig1_roX1_CES.png)
   Displays a sharp, high-amplitude MSL2 enrichment peak (`max = 228.22` CPM, clipping above the `[0 - 25]` display range) directly over the `roX1` Chromatin Entry Site.
2. **X-Linked Active Gene — `Act5C` (`chrX:5,893,000-5,913,000`):** ![Act5C X-linked gene](figures/fig2_Act5C_X_gene.png)
   Shows moderate MSL2 binding (`max = 30.37` CPM) across the transcribed body of the X-linked `Act5C` gene, consistent with dosage-compensation complex spreading from nearby CES onto active X-linked genes.
3. **Autosomal Negative Control — `RpL32` (`chr3R:3,003,500-3,005,500`):** ![RpL32 autosomal control](figures/fig3_RpL32_autosomal_control.png)
   Shows only low background signal (`max = 4.73` CPM, well below the `[0 - 25]` ceiling) across the autosomal `RpL32` locus, confirming male X-chromosome specificity of MSL2 binding.

## 8. File Manifest & Checksums

| File | Size | MD5 Checksum | Git Status |
| :--- | ---: | :--- | :--- |
| `metadata/samples.tsv` | 394 B | `09ca27eec280b88bd060a12897bd6c6c` | Tracked |
| `metadata/reference.tsv` | 388 B | `b078e7cc9a4de095e02dbae3885f90b5` | Tracked |
| `logs/task_01/software_versions.txt` | 270 B | `65ea2e878bd07a47aa0a0052beec30da` | Tracked |
| `logs/task_01/SRR495368.fastq.md5` | 53 B | `3adcde56f4ae259f035406943564e886` | Tracked |
| `logs/task_01/dm6.fa.gz.md5check.txt` | 14 B | `ffba134b988f3d6a2f3a52d0a6082f58` | Tracked |
| `logs/task_01/dm6.fa.md5` | 52 B | `e0697cf09c75da6b5f7d61542137a031` | Tracked |
| `logs/task_01/bowtie2.GSM929149.log` | 223 B | `a2abe58352aaf9952fa631b5b8e8ff58` | Tracked |
| `logs/task_01/bamCoverage.GSM929149.log` | 350 B | `616b392d7e26c92b1fef6d92260c6a18` | Tracked |
| `logs/task_01/GSM929149.bigwig_maxima.tsv` | 149 B | `1a6ab27c53ca7a1ebfd260e17887b638` | Tracked |
| `results/task_01/qc/multiqc_report.html` | 2.4 MB | `3fd2a3f5c1fc36443cd40f37527445b2` | Tracked |
| `results/task_01/bam/GSM929149.dm6.sorted.bam` | 1.63 GB | `ed701acfb83fab8b61b5afad47e21e95` | Ignored (binary BAM) |
| `results/task_01/bam/GSM929149.dm6.primary_q30.bam` | 1.05 GB | `a513e6e8099dfc6974b9d43c1d355f63` | Ignored (binary BAM) |
| `results/task_01/tracks/GSM929149.dm6.CPM.bw` | 61.0 MB | `6bc430c3979e6f8ab19b6f06385ae04d` | Ignored (binary bigWig) |

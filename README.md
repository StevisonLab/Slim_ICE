# ICE-SLiM: Inversion Chromosome Evolution — SLiM Simulation Suite

Forward-time population genetic simulations in [SLiM](https://messerlab.org/slim/) modeling the evolutionary fate of chromosomal inversions in *Drosophila melanogaster*, with explicit interchromosomal effects and a full-scale genome architecture.

---

## Overview

This repository contains a suite of SLiM scripts and a SLURM-compatible shell driver for simulating how new chromosomal inversions accumulate deleterious mutations over time. The project is inspired by and directly extends the simulation framework of **Berdan et al. (2021)**:

> Berdan EL, Blanckaert A, Butlin RK, Bank C. *Deleterious mutation accumulation and the long-term fate of chromosomal inversions.* PLoS Genetics 17(3): e1009411. https://doi.org/10.1371/journal.pgen.1009411

Berdan et al. used SLiM simulations to show that inverted chromosomal regions accumulate excess recessive deleterious mutations relative to the rest of the genome, generating overdominance in heterokaryotypes and driving long-term inversion polymorphism. This work updates and extends their core simulation framework in three key ways: compatibility with the current SLiM API, a mechanistically richer model of inversion recombination dynamics including interchromosomal effects, and a genome architecture rebuilt from scratch to match empirical *D. melanogaster* parameters at full scale.

---

## Key Updates from Berdan et al. (2021)

### 1. Updated SLiM Compatibility
The original scripts used SLiM syntax and API conventions that have since changed. All models have been revised to run under the current SLiM version, including updates to how inversions are initialized (the inversion is now represented by two marker mutations at the breakpoint positions, as recommended in the current SLiM manual, rather than a single marker mutation as in the original Berdan et al. code).

### 2. Interchromosomal Effect on Recombination
The original Berdan et al. framework modeled recombination suppression only within the inverted segment in heterokaryotypes. This repository introduces a third model (`m3`) that explicitly models the **interchromosomal effect (ICE)** — the empirical observation that inversions in heterokaryotypes reduce recombination not only in the region spanning the inversion, but genome-wide, including on non-homologous chromosomes.

The `recombination()` callback in `m3` partitions crossover breakpoints by chromosome arm and applies genotype-dependent thinning probabilities derived from published empirical estimates:
- Inversion heterozygotes experience strongly reduced recombination on the chromosome arm carrying the inversion (~0.84% of breakpoints retained inside the inversion region on 2R), moderate suppression on the homologous arm (2L, ~92.45% retained), and partial suppression on non-homologous chromosomes (chrX and chr3, ~87% retained).
- Inversion homozygotes and standard homozygotes experience a uniform genome-wide reduction in crossing over (~81.29% of breakpoints retained), reflecting the baseline interchromosomal effect documented for this karyotypic class.

### 3. Full-Scale *Drosophila melanogaster* Genome Architecture
The original Berdan et al. models used a simplified, scaled-down genome. All three models in this repository use a **full-size genome** modeled after *D. melanogaster* with empirically derived parameter values, eliminating potential scaling artifacts in drift, selection efficacy, and mutation accumulation.

Key genome parameters sourced from published literature (citations in code comments):

| Parameter | Value | Source |
|---|---|---|
| Deleterious mutation rate | 3.3 × 10⁻⁹ per bp per generation | Wang et al. 2023 (PMID: 37037625) |
| DFE shape (gamma) | mean *s* = −0.000266, α = 0.299 | Loewe & Charlesworth 2006 |
| Recombination rate (m1, m2) | 2.26 × 10⁻⁸ per bp per generation | Wang et al. 2023 (PMID: 37037625) |
| Recombination rate (m3) | 2.78 × 10⁻⁸ per bp per generation | Wang et al. 2023 (PMID: 37037625) |
| Genome structure | 5 chromosome arms (X, 2L, 2R, 3L, 3R), ~88 Mb total, ~5,000 genes of 2 kb each with realistic intergenic spacing | *D. melanogaster* reference |
| Inversion span | ~5 Mb on chromosome 2R (breakpoints at 55,047,499 and 60,019,275), encompassing ~227 genes | Sturtevant and Beadle 1936 based on _In(2R)NS_ Inversion |

The inversion spans a ~5 Mb region on chromosome arm 2R and captures 227 genes, consistent with the size range of a natural inversion segregating in *D. melanogaster* populations.

---

## Models

Three inversion models are included, each representing a different hypothesis about how inversion karyotype affects genome-wide recombination:

### `inversion_forall_nogc-m1.slim` — Baseline Model (No Recombination Modification)
Recombination proceeds uniformly across the genome regardless of inversion karyotype. This model serves as a null baseline: the inversion marker exists and conveys the heterokaryotype fitness advantage, but no recombination suppression is implemented. Used to isolate the contribution of fitness differences from recombination dynamics.

### `inversion_forall_nogc-m2.slim` — Simple Inversion Suppression
The recombination callback suppresses crossovers within the inverted segment only in inversion heterokaryotypes, following the logic of the original Berdan et al. approach but updated to use two-breakpoint marker mutations and the improved recombination callback structure from Schaal, Buffalo, Ralph & Kern. Inversion homozygotes recombine freely across the genome (including within the inversion), and standard homozygotes are unaffected. This corresponds to the classical "recombination arrest in heterokaryotypes" model.

### `inversion_forall_nogc-m3.slim` — Full Interchromosomal Effect Model
The most mechanistically complete model. In addition to suppressing crossovers inside the inversion in heterokaryotypes, this model modulates crossover rates on each chromosome arm as a function of inversion karyotype, explicitly modeling the interchromosomal effect. Breakpoint thinning probabilities differ between inversion-bearing and non-inversion-bearing chromosome arms and between homologous and non-homologous chromosomes, based on empirically estimated ICE magnitudes. This model is the primary novel contribution of this repository.

---

## Simulation Design

All models follow the same overall structure:

1. **Burn-in**: A pre-existing population burn-in file (`burn_in.txt`) is read at generation 500,000, representing a population at mutation-selection-drift equilibrium prior to inversion origin.
2. **Inversion introduction**: At generation 500,000, a new inversion is introduced as a pair of marker mutations (`m6`) on a single haplotype of a specified individual. The individual (`indv`) and haplotype (`haplo`, 0 or 1) are passed as runtime parameters, enabling systematic sweeps across all individuals in the population.
3. **Fitness model**: Heterokaryotypes (one standard, one inverted haplotype) receive a multiplicative fitness advantage (`s_het = 1.03`). Inversion homozygotes do not receive this advantage.
4. **Simulation tracking**: The simulation runs for up to 500,000 post-introduction generations (ending at cycle 1,000,001) or terminates early if the inversion is lost. Deleterious mutation content (`m5`) and final population state are exported at termination.
5. **Output**: At each replicate termination (loss or end of run), the script outputs the full deleterious mutation catalog and, if the inversion is still segregating, a full population snapshot.

---

## Repository Structure

```
.
├── inversion_forall_nogc-m1.slim   # Baseline model (no recombination modification)
├── inversion_forall_nogc-m2.slim   # Simple inversion suppression model
├── inversion_forall_nogc-m3.slim   # Full interchromosomal effect model
├── run_slim.sh                     # SLURM array job driver
└── README.md
```

The following files are required but not included in this repository (generated separately):

- `burn_in.txt` — SLiM population output from the burn-in simulation
- `mutation_parse_updated.pl` — Perl script to parse deleterious mutation output and assign mutations to genomic regions

---

## Running the Simulations

### Prerequisites

- [SLiM](https://messerlab.org/slim/) (current version)
- Python 3 (for random seed generation in the shell driver)
- Perl (for mutation parsing)
- SLURM workload manager (for HPC array job submission)

### Direct SLiM Execution

```bash
slim -seed 42 \
     -d indv=0 \
     -d haplo=0 \
     -d s_het=1.03 \
     -d rec=2.26e-8 \
     inversion_forall_nogc-m2.slim
```

**Parameters:**

| Flag | Description |
|---|---|
| `-seed` | Random seed for reproducibility |
| `indv` | Index of the individual in which the inversion arises (0-based) |
| `haplo` | Haplotype (genome) within the individual: 0 or 1 |
| `s_het` | Fitness of inversion heterokaryotypes (e.g., 1.03) |
| `rec` | Per-base recombination rate (overrides default; m3 uses 2.78e-8) |

### SLURM Array Job

The provided `run_slim.sh` script runs all three models for a given individual index (set by `$SLURM_ARRAY_TASK_ID`), iterating over 100 replicates and both haplotypes per replicate.

```bash
sbatch --array=0-2499 run_slim.sh
```

This will submit jobs for individuals 0–2499, producing output in per-individual directories under the working directory. Results are appended to three master CSV files (`master_file_nogc_m1.csv`, `_m2.csv`, `_m3.csv`).

### Output Files (per replicate)

| File | Contents |
|---|---|
| `*_del_mutations.txt` | Deleterious mutation catalog at simulation end |
| `*_final_population.txt` | Full population snapshot (if inversion still segregating at generation 1,000,000) |
| `chrX_del.txt`, `chr2L_del.txt`, etc. | Per-chromosome-arm mutation counts (from Perl parser) |
| `inversion_del.txt` | Mutation counts within the inverted region |

### Consolidated CSV Columns

```
Individual, Seed, indv, haplo, s_het, replicate, time_end, chrX, chr2L, chr2R, inv, chr3L, chr3R
```

Mutation densities are normalized by the number of genes in each genomic region.

## Findings

This work was presented at the [Evolution Meetings in Montreal in 2024 by Dr. Spencer Koury](https://www.youtube.com/watch?v=GmcUzgrUA_g&list=PLnl_pi1g6Uve0ZkdmIUjGw3fu91avxcE3&index=122). The code was collaboratively developed with input from Dr. Koury by Dr. Stevison who wrote the slim models, ran the code and shared summarized outputs. 

We found that modeling the inversion more realistically using ICE did NOT decrease the genome-wide mutational load suggesting that the interchromosomal effect, which balancing the distribution of crossing over on a single generation time-scale, does NOT have the power to overcome the genetic load of inversions on a longer time-scale.

---

## Citations

If you use or adapt these scripts, please cite both the original Berdan et al. paper that inspired this framework and the relevant empirical parameter sources cited in the code comments:

- Berdan EL, Blanckaert A, Butlin RK, Bank C (2021). Deleterious mutation accumulation and the long-term fate of chromosomal inversions. *PLoS Genetics* 17(3): e1009411. https://doi.org/10.1371/journal.pgen.1009411.

- Wang W, et al. (2023). Direct estimation of *de novo* mutation rates in *Drosophila melanogaster*. *PMID: 37037625.*

- Loewe L, Charlesworth B (2006). Inferring the distribution of mutational effects on fitness in *Drosophila*. *Biology Letters* 2(3): 426–430.
  
- Koury SA and LS Stevison. 2024. Pre-registration: The interchromosomal effect of inversion heterozygosity on meiotic recombination in Drosophila melanogaster: A meta-analysis. https://osf.io/rd3a7.
  
- Sturtevant, A. H., & Beadle, G. W. (1936). The Relations of Inversions in the X Chromosome of Drosophila Melanogaster to Crossing over and Disjunction. Genetics, 21(5), 554–604. https://doi.org/10.1093/genetics/21.5.554.
  
- Ramel C. (1968). The effect of the curly inversions on meiosis in Drosophila melanogaster. II. Interchromosomal effects on males, carrying heterochromatin deficient X chromosome. Hereditas, 60(1), 211–222. https://doi.org/10.1111/j.1601-5223.1968.tb02202.x.

- Koury S. A. (2023). Predicting recombination suppression outside chromosomal inversions in Drosophila melanogaster using crossover interference theory. Heredity, 130(4), 196–208. https://doi.org/10.1038/s41437-023-00593-x.
  
- Grell R. F. (1978). A Comparison of Heat and Interchromosomal Effects on Recombination and Interference in DROSOPHILA MELANOGASTER. Genetics, 89(1), 65–77. https://doi.org/10.1093/genetics/89.1.65

---

## License

This project is released under the MIT License. See `LICENSE` for details.

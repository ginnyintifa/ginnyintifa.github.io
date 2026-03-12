---
layout: distill

title: Thoughts on single cell sequencing 
description: Before we start to work on the data matrices
giscus_comments: true
date: 2026-03-12


toc:
  - name: Foreword
  - name: What happens at the sequencing step?
    subsections:
      - name: Why amplify?
      - name: Why use UMI?
      - name: Why not using UMI for bulk RNA-seq?
      - name: Why amplify even for bulk RNA?
      - name: Why 10X (not other microfluidic device-based strategies)?
      - name: Why only sequence ends (for tag-based)?
  - name: What happens at the raw data processing step?
---
## Foreword
As a computational biologist, I typically begin my single-cell analyses from data that has already been processed through the Cell Ranger pipeline — delivered either as a `SingleCellExperiment` object in R or an `.h5ad` file ready to load into AnnData in Python. I rarely have the opportunity to work from raw FASTQ files, and the upstream processing steps are not something I usually need to worry about. Nevertheless, I find it valuable to understand what happens before the data reaches my hands — and to draw comparisons with how the equivalent steps work in bulk RNA-seq.
## What happens at the sequencing step?
Briefly, we have these steps:
- Cell dissociation (no need to do in bulk)
- Cell capture (no need to do in bulk)
- Cell Lysis (all cells are lysed together in bulk)
- Reverse transcription  (additional steps before reverse transcription happens)
- Amplification (more agressive in scRNA-seq)
- library preparation (tag-based scRNA-seq only sequences one end)
- Sequencing (similar)
- Alignment and quatification (demuliplex by cell barbode and count UMI rather than reads)

The core differences between bulk and single-cell RNA-seq are noted in parentheses above. Each step has its own nuances worth paying attention to, but I will focus on the most important ones below.


### Why amplify?
Because there are only a tiny amount of transcripts within EACH cell. Through PCR (usually), we will generate enough material for the sequencer to detect. 
### Why UMI?
Becuase amplification will cause a problem. It doesnt' copy every molecule equally, some get amplified more than others by chance, in other words, PCR replicates stochastically at low counts.  This amplification bias will distort count data and mkes it hard to know the true original quantities. So if we tag the original RNA molecule with a random short barcode (UMI), we will need to count the unique UMIs after amplification and sequencing to know the number of reads in each cell (instead of counting total reads). 

### Why not using UMI for bulk RNA-seq?
But why is this amplifcation bias not a concern for bulk RNA-seq? 
Because we start with RNA from millions of cells pooled together. Each gene is represented by thousands to millions of molecules. So the low count stochasticity won't be applicable here. It will be a noise that would be averged out across so many molecules. 

### Why amplify even for bulk RNA?
You may wonder why amplification is still needed in bulk, since there are already millions of cells to start with. The anwser is simple: still not enough. 
Even with millions of cells, the actual amount of RNA is still tiny in absolute terms — typically nanograms (ng) of total RNA. Modern sequencers need a specific range of DNA input (usually nanomoles of library material) to work reliably.
The steps that make amplification necessary are:

RNA → cDNA conversion (reverse transcription) is inefficient — you lose a lot of material
Library prep (fragmentation, adapter ligation) loses more material at each step
Sequencers need a minimum input concentration to cluster properly on the flow cell

So by the time you get through all the prep steps, you don't have enough material without PCR amplification at the end.

### Why 10X Genomics (not other microfluidic device-based strategies)?
I have only analyzed data outof the 10X Chromium protocal. According to Zhang et al 2019, compared to inDrop and Drop-seq, 10X has the best bead quality, the proportion of reads originating from valid barcodes was 75% for 10X Genomics, compared to only 25% for InDrop and 30% for Drop-seq. Also,10X is more sensitive. 10X Genomics captured about 17000 transcripts from 3000 genes on average, compared to 8000 transcripts from 2500 genes for Drop-seq and 2700 transcripts from 1250 genes for InDrop. Technical noise was the lowest for 10X Genomics, followed by Drop-seq and InDrop. But it is also twice as expensive. 

### Why only sequence ends (for tag-based)?
In tag-based protocols, the bead primer has a poly-T tail that binds to the poly-A tail of mRNA, which is always at the 3' end. Reverse transcription therefore starts from the 3' end and proceeds inward toward the 5' end. The resulting cDNA has the barcode and UMI anchored at the 3' end, with the rest of the transcript extending from there.

You might ask: why not sequence the whole transcript? There are three reasons:

First, it is unnecessary for gene expression quantification — you only need to know which gene a read came from, not its full sequence.

Second, sequencing full-length transcripts across thousands of cells would be prohibitively expensive.

Third, the droplet chemistry does not easily permit it — fragmentation and internal adapter ligation are not feasible inside a droplet, though they are possible in plate-based protocols.

Some protocols, such as the 10x 5' kit, instead capture the 5' end using a different chemistry that anchors at the other end of the transcript. This is particularly useful for immune repertoire sequencing (TCR/BCR), where the informative region resides at the 5' end.

As you might expect, sequencing only the ends of transcripts comes at the cost of losing isoform information (i.e. splice variants).

## What happens at the raw data processing step?

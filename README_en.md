# 📘  Activity – Genome Mapping and Assembly
**Choose your language**:  
[Portuguese](#atividade--mapeamento-e-montagem-de-genoma) | [English](#activity--genome-mapping-and-assembly)

Project developed in the Bioinformatics course at PUC Minas, as part of the discipline **Algorithms in Bioinformatics**.

---
Activity Summary
- You are a bioinformatician who received sequencing data from an unknown biological sample provided by a partner laboratory.  
- Your goal is to analyze the sequencing data and identify which organisms/microorganisms are present in the sample.  
- Create a report explaining how you reached the result and which tools were used.

## Provided Files
The input files are available in the *reads/* folder:
- **mock.R1.fq / mock.R2.fq** → raw sequencing reads (FASTQ).  
- **database.dmnd** → DIAMOND database already processed, containing protein sequences from NCBI.

## Methodological Summary
- **Tools used**: Micromamba, FastQC, Fastp, MEGAHIT, Bowtie2, Samtools, DIAMOND, R.  
- **Workflow**: QC → trimming → QC → assembly → annotation → mapping → statistical analysis.  
- **Expected results**: identification of organisms present in the sample, assembly metrics, abundance graphs and tables.  
- **Reproducibility**: YAML environments ensure that anyone can recreate the same setup.  

## 1. Create micromamba environments
The project uses two environments managed with **micromamba**:

Main environment for assembly and processing:
```bash
# assembly_pipeline_env.yaml
micromamba create -n assembly_pipeline_env -f environment/assembly_pipeline_env.yaml
```
Downstream analysis environment (R):
```bash
# data_analysis_env.yaml
micromamba create -n data_analysis_env -f environment/data_analysis_env.yaml
```
## 2. Run the main pipeline

```bash
# Activate the environment 
micromamba activate assembly_pipeline_env
```
```bash
# Run the script
bash upstream/script.sh
```
This script automatically performs the following steps of the pipeline:

- **Initial QC** → read quality analysis with *FastQC* and consolidation with *MultiQC*.
- **Trimming** → removal of low-quality bases and adapters using *Fastp*.
- **Assembly** → contig reconstruction from reads with *MEGAHIT*.
- **Annotation** → functional and taxonomic identification of sequences with *DIAMOND*.
- **Mapping** → alignment of reads against contigs using *Bowtie2* and processing with *Samtools*
- **Consolidated reports** → generation of statistics and integrated summaries for overall evaluation.

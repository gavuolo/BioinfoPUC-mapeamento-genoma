#!/bin/bash
# Pipeline - Mapeamento e Montagem de Genoma

# Organizar pastas de saída conforme nova arquitetura
mkdir -p upstream \
    upstream/fastqc \
    upstream/fastqc_post \
    upstream/multiqc_report \
    upstream/trimming \
    upstream/assembly \
    upstream/annotation \
    upstream/mapping

# ETAPA 1. Controle de qualidade inicial (FastQC)
fastqc reads/mock.R1.fq reads/mock.R2.fq \
       -o upstream/fastqc/  

# ETAPA 2. Trimming e filtragem (fastp)
fastp -i reads/mock.R1.fq -I reads/mock.R2.fq \
      -o upstream/trimming/mock.R1.trimmed.fq -O upstream/trimming/mock.R2.trimmed.fq \
      -h upstream/trimming/fastp.html -j upstream/trimming/fastp.json

# ETAPA 3. Reavaliação da qualidade (FastQC + MultiQC)
#   FastQC (pós-trimming)
fastqc upstream/trimming/mock.R1.trimmed.fq upstream/trimming/mock.R2.trimmed.fq \
       -o upstream/fastqc_post/

#   MultiQC (relatório com todos os dados)
multiqc upstream/fastqc upstream/fastqc_post upstream/trimming \
       -o upstream/multiqc_report/

# ETAPA 4. Montagem de novo (MEGAHIT)
#   Limitei o uso de memória e de CPU
rm -rf upstream/megahit_out
megahit \
    -1 upstream/trimming/mock.R1.trimmed.fq \
    -2 upstream/trimming/mock.R2.trimmed.fq \
    --memory 0.5 --num-cpu-threads 4 \
    -o upstream/megahit_out

# Caracterização da montagem (SeqKit)
seqkit stats --all upstream/megahit_out/final.contigs.fa \
             > upstream/assembly/assembly_stats.txt 

# ETAPA 5. Anotação funcional e taxonômica (DIAMOND)
diamond blastx -d reads/database.dmnd \
               -q upstream/megahit_out/final.contigs.fa \
               -o upstream/annotation/diamond.tax.tsv \
               -f 6 qseqid sseqid pident length evalue bitscore staxids sscinames 

# ETAPA 6. Mapeamento das reads contra os contigs (Bowtie2 + Samtools)
# Construção do índice dos contigs
bowtie2-build upstream/megahit_out/final.contigs.fa upstream/mapping/contigs_index

# Alinhamento das reads filtradas contra os contigs
bowtie2 -x upstream/mapping/contigs_index \
        -1 upstream/trimming/mock.R1.trimmed.fq \
        -2 upstream/trimming/mock.R2.trimmed.fq \
  | samtools view -Sb - \
  | samtools sort -o upstream/mapping/alinhamento_sorted.bam

# Indexação do arquivo BAM
samtools index upstream/mapping/alinhamento_sorted.bam

# Profundidade de cobertura
samtools depth upstream/mapping/alinhamento_sorted.bam > upstream/mapping/depth.txt

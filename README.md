# 📘  Atividade – Mapeamento e Montagem de Genoma
**Escolha seu idioma:**  
[Português](#atividade--mapeamento-e-montagem-de-genoma) | [English](#activity--genome-mapping-and-assembly)

Projeto desenvolvido no curso de Bioinformática da PUC Minas, como parte da disciplina **Algoritmos em Bioinformática**.

---
Resumo do enunciado da atividade
- Você é um bioinformata que recebeu dados de uma amostra biológica desconhecida de um laboratório parceiro.  
- Seu objetivo é analisar os dados de sequenciamento e identificar quais organismos/microorganismos estão presentes na amostra.  
- Criar um relatório explicando como chegou ao resultado e quais ferramentas utilizou.

## Arquivos disponibilizados
Os arquivos de entrada estão disponíveis na pasta **reads/**:
- **mock.R1.fq / mock.R2.fq** → leituras de sequenciamento brutas (FASTQ).  
- **database.dmnd** → base de dados do DIAMOND já processada, contendo sequências de proteínas do NCBI.

## Resumo metodológico
- **Ferramentas utilizadas**: FastQC, Fastp, MEGAHIT, Bowtie2, Samtools, DIAMOND, R.
- **Fluxo de trabalho**: QC → trimming → QC → montagem → anotação → mapeamento → análise estatística.
- **Resultados esperados**: identificação dos organismos presentes na amostra, métricas de montagem, gráficos e tabelas de abundância.
- **Reprodutibilidade**: ambientes YAML garantem que qualquer pessoa consiga recriar o mesmo setup.

## Executar do início
Os resultados já estão incluídos neste repositório, mas é possível refazer todo o pipeline desde o começo.  
Para isso, basta limpar as saídas anteriores e seguir os passos abaixo:
```bash
rm -rf upstream/fastqc/ \
       upstream/fastqc_post/ \
       upstream/trimming/ \
       upstream/megahit_out/ \
       upstream/multiqc_report/ \
       upstream/mapping/ \
       upstream/annotation/ \
       upstream/assembly_stats.txt \
       downstream-analysis/figures/
```

## 1. Criar os ambientes micromamba
O projeto utiliza dois ambientes gerenciados com **micromamba**:
Ambiente principal de montagem e processamento
```bash
# assembly_pipeline_env.yaml
micromamba create -n assembly_pipeline_env -f environment/assembly_pipeline_env.yaml
```
Ambiente de análise downstrem (R)
```bash
# data_analysis_env.yaml
micromamba create -n data_analysis_env -f environment/data_analysis_env.yaml
```

## 2. Rodar o pipeline principal

```bash
# Ativar o ambiente 
micromamba activate assembly_pipeline_env
```
```bash
# Rodar o script
upstream/atividade-final.sh
```
Esse script realiza automaticamente as seguintes etapas do pipeline:

- **QC inicial** → análise da qualidade das leituras com *FastQC* e consolidação com *MultiQC*.  
- **Trimming** → remoção de bases de baixa qualidade e adaptadores usando *Fastp*.  
- **Montagem** → reconstrução dos contigs a partir das leituras com *MEGAHIT*.  
- **Anotação** → identificação funcional e taxonômica das sequências com *DIAMOND*.  
- **Mapeamento** → alinhamento das leituras contra os contigs usando *Bowtie2* e processamento com *Samtools*.  
- **Relatórios consolidados** → geração de estatísticas e sumários integrados para avaliação geral.  

## 3. Rodar a análise downstream
```bash
# Ativar o ambiente 
micromamba activate data_analysis_env
```
```bash
# Rodar o script
Rscript downstream-analysis/downstream.R
```
Esse script gera estatísticas, gráficos e tabelas, que ficam salvos em:

### downstream-analysis/figures/
- **read_quality.png** → distribuição da qualidade das leituras após trimming.  
- **assembly_stats.png** → métricas da montagem (número de contigs, N50, tamanho total).  
- **mapping_coverage.png** → cobertura dos alinhamentos por contig.  
- **annotation_summary.png** → distribuição taxonômica das proteínas anotadas.  

### downstream-analysis/tables/
- **assembly_stats.tsv** → estatísticas detalhadas da montagem.  
- **mapping_summary.tsv** → resumo dos alinhamentos (reads mapeados, taxa de cobertura).  
- **annotation_results.tsv** → resultados da anotação com DIAMOND (hits, e-values, taxonomia).  

## Arquitetura do Projeto
A organização das pastas foi planejada para garantir modularidade, padronização e clareza semântica:
```bash
mapeamento-e-montagem-genoma/
├── environment/             # arquivos YAML dos ambientes micromamba
│   ├── assembly_pipeline_env.yaml
│   └── data_analysis_env.yaml
├── reads/                   # dados de entrada
│   ├── mock.R1.fq
│   ├── mock.R2.fq
│   └── database.dmnd
├── upstream/                # scripts e saídas do processamento (pipeline principal)
│   ├── atividade-final.sh   # pipeline em Bash
│   ├── fastqc/              # QC inicial
│   ├── fastqc_post/         # QC pós-trimming
│   ├── trimming/            # saídas do fastp
│   ├── megahit_out/         # montagem (contigs)
│   ├── multiqc_report/      # relatório consolidado
│   ├── mapping/             # alinhamentos (BAM, índices)
│   ├── annotation/          # resultados do DIAMOND
│   └── assembly_stats.txt   # estatísticas da montagem
├── downstream-analysis/     # scripts e saídas de análise pós-processamento
│   ├── downstream.R         # script em R para análise dos resultados
│   └── figures/             # gráficos gerados em R
│   └── tables/              # tabelas geradas em R
└── README.md                # instruções de uso
```

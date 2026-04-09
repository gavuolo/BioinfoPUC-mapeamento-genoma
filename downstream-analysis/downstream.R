# ============================================================
# Pipeline de análise downstream dos resultados do DIAMOND
# Gera tabelas e gráficos organizados em downstream-analysis/
# ============================================================

# Criar pastas organizadas para os resultados
dir.create("downstream-analysis/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("downstream-analysis/figures", recursive = TRUE, showWarnings = FALSE)

# Carregar pacotes
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(knitr)
})

# Ler o arquivo gerado pelo DIAMOND
df <- readr::read_tsv("upstream/annotation/diamond.tax.tsv",
                      col_names = FALSE,
                      show_col_types = FALSE)

# Renomear colunas
colnames(df) <- c("contig","accession","pident","aln_len",
                  "evalue","bitscore","taxid","organism")

# Prévia dos dados
cat("\n📋 Prévia dos dados:\n")
print(knitr::kable(head(df)))

# 1. Tabela completa em CSV 
write.csv(df, "downstream-analysis/tables/diamond_table.csv", row.names = FALSE)
cat("\n📂 Arquivo CSV completo gerado com", nrow(df),
    "registros em downstream-analysis/tables/diamond_table.csv\n")

# 2. Filtro por organismo
df_summary <- df %>%
  dplyr::group_by(organism) %>%
  dplyr::summarise(count = dplyr::n()) %>%
  dplyr::arrange(dplyr::desc(count))

write.csv(df_summary, "downstream-analysis/tables/summary_hits_por_organismo.csv", row.names = FALSE)
cat("📂 Resumo por organismo salvo em downstream-analysis/tables/summary_hits_por_organismo.csv\n")

p_summary <- ggplot(df_summary, aes(x = reorder(organism, -count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Distribuição de hits por organismo",
       x = "Organismo",
       y = "Número de hits")

ggsave("downstream-analysis/figures/hits_por_organismo.png", plot = p_summary, width = 8, height = 6)
cat("📊 Gráfico salvo em downstream-analysis/figures/hits_por_organismo.png\n\n")

# ------------------------------------------------------------
# 3. %Identidade
# ------------------------------------------------------------
p_ident <- ggplot(df, aes(x = pident)) +
  geom_histogram(binwidth = 5, fill = "darkgreen", color = "white") +
  labs(title = "Distribuição da identidade percentual",
       x = "Identidade (%)",
       y = "Número de hits")

ggsave("downstream-analysis/figures/distribuicao_pident.png", plot = p_ident, width = 8, height = 6)
cat("📊 Gráfico de identidade percentual salvo em downstream-analysis/figures/distribuicao_pident.png\n")

# ------------------------------------------------------------
# 4. Bitscore por organismo
# ------------------------------------------------------------
p_bitscore <- ggplot(df, aes(x = organism, y = bitscore)) +
  geom_boxplot(fill = "orange") +
  coord_flip() +
  labs(title = "Distribuição de bitscore por organismo",
       x = "Organismo",
       y = "Bitscore")

ggsave("downstream-analysis/figures/bitscore_por_organismo.png", plot = p_bitscore, width = 8, height = 6)
cat("📊 Boxplot de bitscore salvo em downstream-analysis/figures/bitscore_por_organismo.png\n")

# ------------------------------------------------------------
# 5. Ranking dos hits
# ------------------------------------------------------------
top_hits <- df %>%
  dplyr::arrange(dplyr::desc(bitscore)) %>%
  head(10)

write.csv(top_hits, "downstream-analysis/tables/top_hits.csv", row.names = FALSE)
cat("📂 Top 10 hits salvos em downstream-analysis/tables/top_hits.csv\n")

library(tidyverse)
library(stringr)
library(here)

tic <- Sys.time() # giusto per vedere quanto ci mettiamo :-)

raw_input <- read_lines(
  here("raw-data/snvs.tsv")
)
head(raw_input, 2)

extract_genes_name <- function(x) {
  # str_split restituisce una lista con una sola cella con dentro il
  # risultato. Con [[1]] estraggo il cpontenuto della cella, che è
  # il vettore dei geni
  res <- str_split(x, "\\t")[[1]]
  # tolgo il PID dal vettore e lo uso come nome per tutti gli elementi
  set_names(res[-1], res[[1]])
}

extract_genes_name(raw_input[[1]]) # quali geni il primo paziente?
length(extract_genes_name(raw_input[[1]])) # quanti?

# questi sono i geni estratti da tutti i pazienti, presi dalla lista
# ottenuta dal map, "slistata" in un vettore lungo unico, presi solo
# gli elementi unici, e poi ordinati in ordine alfabetico
genes_list <- map(raw_input, extract_genes_name)
genes <- genes_list |>
  unlist() |>
  unique() |>
  sort()

# per ogni elemento, prendo nome del primo elemento (il PID)
pids <- map_chr(raw_input, ~names(extract_genes_name(.x)[1]))

# creo la struttura del mio dataframe finale (inizialmente come tabella)
mtx <- matrix(
  0, # matrice tutta di zeri! (poi metterò gli 1 quando serve)
  nrow = length(pids),
  ncol = length(genes),
  dimnames = list(pids, genes)
)

mtx[1:2, 1:5] # solo un esempio per vedere com'è fatto

sum(genes %in% genes_list[[1]]) # quanti geni il primo paziente?

pid <- character(1)
for (pid_data in genes_list) {
  pid[[1]] <- names(pid_data[1])
  # seleziono usando i nomi delle colonne e delle righe, la riga
  # con il nome del pid, e le colonne che coincidono con i geni di
  # quel pid! e riempio tutte quelle celle con un 1
  mtx[pid, pid_data] <- 1
}

sum(mtx[1, ]) # quanti geni il primo paziente?
dim(mtx)
genes_db <- as_tibble(mtx, rownames = "PID")
dim(genes_db) # una colonna in più per il PID

genes_db # final result

# quanto ci abbiamo messo?
toc <- Sys.time()
toc - tic # mio PC: circa 4 secondi

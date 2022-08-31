library(tidyverse)
library(stringr)
library(here)

tic <- Sys.time() # giusto per vedere quanto ci mettiamo :-)


raw_input <- read_lines(
  here("raw-data/snvs.tsv")
)
head(raw_input)
str(raw_input, 1)
class(raw_input)

first_patient <- raw_input[[1]]
first_patient


db_first_pt <- read_tsv(I(first_patient))
db_first_pt[1, ] <- "TCGA-D1-A0ZS"
db_first_pt
names(db_first_pt)[1] <- "PID"

read_patient <- function(patient_raw) {
  db_vuoto <- read_tsv(
    I(patient_raw),
    show_col_types = FALSE
  )
  db_vuoto[1, ] <- names(db_vuoto)[[1]]
  db_vuoto
  names(db_vuoto)[1] <- "PID"
  db_vuoto
}
read_patient(raw_input[[14]]) # esempio



# Una lista di 3110 celle, in cui in ogni
# cella c'è un data.frame contenente una sola
# riga riempita tutta con l'id del paziente
# (scritto come testo) e con tante colonne
# quanti sono i suoi propri geni tumorali il cui
# nome/codice è riportato nel nome della colonna
# stessa. Tutti questi dataframe hanno una colonna
# "comune" che si chiama "PID" (chiaramente
# anch'essa riempita con il Patient ID)
# ... già questo è piuttosto lento
patient_list <- map(raw_input, read_patient)


class(patient_list)
length(patient_list)
class(patient_list[[1]])

# questa riga ESTREMAMENTE INEFFICIENTE fa tutta
# la magia da sola!
db_na <- bind_rows(patient_list)
db_final <- db_na |>
  mutate(
    across(everything(), ~replace_na(.x, "0")),
    across(-PID, ~str_replace_all(.x, "..+", "1")),
    across(-PID, as.integer)
  )

db_final


# quanto ci abbiamo messo?
toc <- Sys.time()
toc - tic # mio PC: circa 19 minuti










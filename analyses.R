# setup -----------------------------------------------------------

## Attach ALL your packages here
library(tidyverse)
library(janitor)
library(usethis)
library(here)

## If not already done,
## put your (project, personally created) OPENAI_API_KEY in the
## project-level .Renviron file as:
##
## OPENAI_API_KEY="your-key-here"
##
## WARNING: do not share your API_KEY with others
##          do not include it in your code
##          do not commit it to repositories
##          do not expose it in any way
##          if you share the project, delete the token from .Renviron
if (
  !file.exists(here(".Renviron")) ||
  !any(
    readLines(here(".Renviron")) |>
      str_detect("OPENAI_API_KEY *= *.+")
  )
) {
  edit_r_environ("project")
}




# Custom functions ------------------------------------------------

## source all the scripts in the `R/` directory.
## If you need to define other custom functions, simply put them in an
##   R script inside the `R/` folder.
list.files("R/", full.names = TRUE) |>
  walk(source)




# Usage example ---------------------------------------------------
#
# db <- tibble(
#   commenti = c(
#     "Che barba, che noia!",
#     "Un po' noioso, ma interessante",
#     "Che bello, mi è piaciuto molto!"
#   )
# )
#
# role <- "Sei l'assistente di un docente universitario."
# context <- "State analizzando i commenti degli studenti dell'ultimo corso."
#
# task <- "Il tuo compito è capire se sono soddisfatti del corso."
# instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
# output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
# style <- "Non aggiungere nessun commento, restituisci solo ed esclusivamente la classificazione."
#
# examples <- "
# commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
# classificazione_1: 'soddisfatto'
# commento_2: 'Non mi è piaciuto per niente; una noia mortale'
# classificazione_2: 'insoddisfatto'
# "
#
# res <- db |>
#  query_gpt_on_column(
#    "commenti",
#    role = role,
#    context = context,
#    task = task,
#    instructions = instructions,
#    output = output,
#    style = style,
#    examples = examples
#  )
# res




# data ------------------------------------------------------------

## We expect to find the data in the `data-raw/` directories
input_db_path <- here("data-raw/db.csv")
db_raw <- read_csv(input_db_path)




# preprocessing ---------------------------------------------------

db <- db_raw |>
  clean_names() |>
  select(
    # which columns to keep
  ) |>
  mutate(
    # some preprocessing
  ) |>
  filter(
    # which rows to keep
  )




# prompt ----------------------------------------------------------

## NOTE: Not all the following variables are needed, use only the ones
##       that are useful for your specific task.
##       Keep the others empty strings, i.e. "".

### System (i.e., GPT)
role <- "" # Who GPT is in this context
context <- "" # What GPT knows about your project

### User (i.e., you)
task <- "" # What you want GPT to do?
instructions <- "" # How to do it?
output <- "" # Which output do you want?
style <- "" # Further specification on the tone/style of the output
examples <- "" # Examples of the input/output you want




# analyses --------------------------------------------------------

res <- db |>
  query_gpt_on_column(
    text_column = "<text_column_name>",
    role = role,
    context = context,
    task = task,
    instructions = instructions,
    output = output,
    style = style,
    examples = examples,
    # include_source_text = FALSE # TRUE by default
  )

merged_db <- left_join(db, res)




# output ----------------------------------------------------------

output_db_path <- here("output/merged_db.csv")
write_csv(merged_db, output_db_path)

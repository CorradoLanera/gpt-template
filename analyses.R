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
## The following code will check if the .Renviron file exists and if it
## contains the OPENAI_API_KEY. If not, it will open the .Renviron file
## for you to edit it. If the file does not exist, it will create it.
## So you can execute it safely even if you are not sure if the .Renviron
## file exists or if it contains the OPENAI_API_KEY.
##
## Only if you need to add the key, after you have added it, restart
## your R session.
## You need to do this only once (so, after the first time, you can
## delete or comment out this code).
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
#   commenti = c(          # you can name this column as you prefer
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
# output <- "Riporta 'soddisfatto' o 'insoddisfatto', in caso di dubbio o impossibilità riporta 'NA'."
# style <- "Non aggiungere nessun commento, restituisci solo ed esclusivamente una delle classificazioni possibile."
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

## We expect to find the data in the `data-raw/` directories.
## If you have the data in a different location, you can change the
## path accordingly.
input_db_path <- here("data-raw/db.csv")
db_raw <- read_csv(input_db_path)




# preprocessing ---------------------------------------------------

db <- db_raw |>
  clean_names() |>
  select(
    # columns to keep
  ) |>
  mutate(
    # creates new columns that are functions of existing variables. You
    # can also modify (if the name is the same as an existing column)
    # and delete columns (by setting their value to NULL).
  ) |>
  filter(
    # rows to keep, retaining all rows that satisfy your conditions
  ) |>
  drop_na(
    # columns to check for NAs, removing the rows with NAs in any of them.
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
    # model = "gpt-4-turbo", # "gpt-3.5-turbo" by default
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

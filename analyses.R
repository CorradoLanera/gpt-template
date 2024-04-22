## Put your OPENAI_API_KEY in the project-level .Renviron file as:
##
## OPENAI_API_KEY="your-key-here"
##
## You can open your .Renviron file with:
##
## # install.packages("usethis")
## usethis::edit_r_environ("project")
##
## After you have added it, restart your R session.

library(tidyverse)
library(janitor)
library(usethis)
library(here)

# install.packages("devtools")
# devtools::install_github("UBESP-DCTV/ubep.gpt")
library(ubep.gpt)


# data ------------------------------------------------------------
input_db_path <- here("data-raw/db.csv")
db_raw <- read_csv(input_db_path)


# preprocessing ---------------------------------------------------
db <- db_raw |>
  clean_names() |>
  select() |>
  mutate() |>
  filter() |>
  drop_na()


# prompt ----------------------------------------------------------
# The following functions simply paste together their args; they are not
# necessary, just to remind/suggest best prectices on how to compose the
# prompts.
sys_prompt <- compose_prompt_system(
  role = "role.",
  context = "context."
)
usr_prompt <- compose_prompt_user(
  task = "task.",
  instructions = "instructions.",
  output = "output.",
  style = "style.",
  examples = "examples."
)


# analyses --------------------------------------------------------
res <- db |>
  query_gpt_on_column(
    text_column = "<text_column_name>",
    # model = "gpt-4-turbo", # "gpt-3.5-turbo" by default
    sys_prompt = sys_prompt, # you can use plain text here
    usr_prompt = usr_prompt  # you can use plain text here
  )

merged_db <- left_join(db, res)


# output ----------------------------------------------------------
output_db_path <- here("output/merged_db.csv")
write_csv(merged_db, output_db_path)

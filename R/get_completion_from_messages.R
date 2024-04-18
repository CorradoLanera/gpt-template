#' Get completion from chat messages
#'
#' @param messages (list) in the following format: `⁠list(list("role" =
#'   "user", "content" = "Hey! How old are you?")` (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-model)
#' @param model (chr, default = "gpt-3.5-turbo") a length one character
#'   vector indicating the model to use (see:
#'   <https://platform.openai.com/docs/models/continuous-model-upgrades>)
#' @param temperature (dbl, default = 0) a value between 0 (most
#'   deterministic answer) and 2 (more random). (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-temperature)
#' @param max_tokens (dbl, default = 500) a value greater than 0. The
#'   maximum number of tokens to generate in the chat completion. (see:
#'   https://platform.openai.com/docs/api-reference/chat/create#chat/create-max_tokens)
#'
#' @details For argument description, please refer to the [official
#'   documentation](https://platform.openai.com/docs/api-reference/chat/create).
#'
#'   Lower values for temperature result in more consistent outputs,
#'   while higher values generate more diverse and creative results.
#'   Select a temperature value based on the desired trade-off between
#'   coherence and creativity for your specific application. Setting
#'   temperature to 0 will make the outputs mostly deterministic, but a
#'   small amount of variability will remain.
#'
#' @return (list) of two element: `content`, which containt the chr
#'   vector of the response, and `tokens`, which is a list of number of
#'   tokens used for the request (`prompt_tokens`), answer
#'   (`completion_tokens`), and overall (`total_tokens`, the sum of the
#'   other two)
#' @export
#'
#' @examples
#' if (FALSE) {
#'   prompt <- list(
#'     list(
#'       role = "system",
#'       content = "you are an assistant who responds succinctly"
#'     ),
#'     list(
#'       role = "user",
#'       content = "Return the text: 'Hello world'."
#'     )
#'   )
#'   res <- get_completion_from_messages(prompt)
#'   answer <- get_content(res) # "Hello world."
#'   token_used <- get_tokens(res) # 30
#' }
#'
#' if (FALSE) {
#'   msg_sys <- compose_prompt_system(
#'     role = "Sei l'assistente di un docente universitario.",
#'     context = "Tu e lui state preparando un workshop sull'utilizzo di ChatGPT per biostatisitci ed epidemiologi."
#'   )
#'
#'   msg_usr <- compose_prompt_user(
#'     task = "Il tuo compito è trovare cosa dire per spiegare cosa sia una chat di ChatGPT agli studenti, considerando che potrebbe esserci qualcuno che non ne ha mai sentito parlare (e segue il worksho incuriosito dal titolo o dagli amici).",
#'     output = "Riporta un potenziale dialogo tra il docente e gli studenti che assolva ed esemplifichi lo scopo descritto.",
#'     style = "Usa un tono amichevole, colloquiale, ma preciso."
#'   )
#'
#'   prompt <- compose_prompt_api(msg_sys, msg_usr)
#'   res <- get_completion_from_messages(prompt, "4-turbo")
#'   answer <- get_content(res)
#'   token_used <- get_tokens(res) # 957
#' }
get_completion_from_messages <- function(
    messages,
    model = c("gpt-3.5-turbo", "gpt-4-turbo"),
    temperature = 0,
    max_tokens = 1000
) {

  model <- match.arg(model)
  model <- switch(model,
    "gpt-3.5-turbo" = "gpt-3.5-turbo",
    "gpt-4-turbo" = "gpt-4-1106-preview"
  )

  res <- openai::create_chat_completion(
    model = model,
    messages = messages,
    temperature = temperature,
    max_tokens = max_tokens,
  )

  list(
    content = res[["choices"]][["message.content"]],
    tokens = res[["usage"]]
  )
}


#' Get content of a chat completion
#'
#' @param completion the output of a `get_completion_from_messages` call
#' @describeIn get_completion_from_messages
#'
#' @return (chr) the output message returned by the assistant
#' @export
get_content <- function(completion) {
  completion[["content"]]
}

#' Get the number of token of a chat completion
#'
#' @param completion the number of tokens used for output of a
#'   `get_completion_from_messages` call
#' @param what (chr) one of "total" (default), "prompt", or "completion"
#' @describeIn get_completion_from_messages
#'
#' @return (int) number of token used in completion for prompt or completion part, or overall (total)
#' @export
get_tokens <- function(
    completion,
    what = c("total", "prompt", "completion")
) {
  what <- match.arg(what)
  sel <- paste0(what, "_tokens")

  completion[["tokens"]][[sel]]
}


query_gpt <- function(
    prompt,
    model = c("gpt-3.5-turbo", "gpt-4-turbo"),
    quiet = TRUE,
    max_try = 10,
    temperature = 0,
    max_tokens = 1000
) {
  model <- match.arg(model)
  done <- FALSE
  tries <- 0L
  while (!done && tries <= max_try) {
    tries[[1]] <- tries[[1]] + 1L
    if (tries > 1 && !quiet) {
      usethis::ui_info("Error: {res}.")
      usethis::ui_info("Try: {tries}...")
      Sys.sleep(0.2 * 2^tries)
    }
    res <- tryCatch({
      aux <- prompt |>
        get_completion_from_messages(
          model = model,
          temperature = temperature,
          max_tokens = max_tokens
        )
      done <- TRUE
      aux
    }, error = function(e) e)
  }

  if (tries > max_try) {
    usethis::ui_info("Max unsucessfully tries ({tries}) reached.")
    usethis::ui_stop("Last error: {res}")
  }

  if (!quiet) {
    usethis::ui_info("Tries: {tries}.")
    usethis::ui_info("Prompt token used: {get_tokens(res, 'prompt')}.")
    usethis::ui_info("Response token used: {get_tokens(res, 'completion')}.")
    usethis::ui_info("Total token used: {get_tokens(res)}.")
  }
  res
}



#' Compose the ChatGPT System prompt
#'
#' @param db (data.frame) the data to use
#' @param text_column (chr) the name of the column containing the text data
#' @param role (chr) the role of the assistant in the context
#' @param context (chr) the context of the assistant in the context
#' @param task (chr) the task to perform
#' @param instructions (chr) the instructions to follow
#' @param output (chr) the output required
#' @param style (chr) the style to use in the output
#' @param examples (chr) some examples of correct output
#' @param model (chr, default = "gpt-3.5-turbo") the model to use
#' @param quiet (lgl, default = TRUE) whether to print information
#' @param max_try (int, default = 10) the maximum number of tries
#' @param temperature (dbl, default = 0) the temperature to use
#' @param max_tokens (dbl, default = 1000) the maximum number of tokens
#' @param simplify (lgl, default = TRUE) whether to simplify the output
#'
#' @return (tibble) the result of the query
#' @export
#'
#' @examples
#' if (FALSE) {
#'
#'  db <- tibble(
#'    commenti = c(
#'      "Che barba, che noia!",
#'      "Un po' noioso, ma interessante",
#'      "Che bello, mi è piaciuto molto!"
#'    )
#'  )
#'
#'  role <- "Sei l'assistente di un docente universitario."
#'  context <- "State analizzando i commenti degli studenti dell'ultimo corso."
#'  task <- "Il tuo compito è capire se sono soddisfatti del corso."
#'  instructions <- "Analizza i commenti e decidi se sono soddisfatti o meno."
#'  output <- "Riporta 'soddisfatto' o 'insoddisfatto'."
#'  style <- "Non aggiungere nessun commento, restituisci solo ed esclusivamente la classificazione."
#'  examples <- "
#'  commento_1: 'Mi è piaciuto molto il corso; davvero interessante.'
#'  classificazione_1: 'soddisfatto'
#'  commento_2: 'Non mi è piaciuto per niente; una noia mortale'
#'  classificazione_2: 'insoddisfatto'
#'  "
#'  res <- db |>
#'   query_gpt_on_column(
#'     "commenti",
#'     role = role,
#'     context = context,
#'     task = task,
#'     instructions = instructions,
#'     output = output,
#'     style = style,
#'     examples = examples
#'   )
#'  res
#'
query_gpt_on_column <- function(
    db,
    text_column,
    role = role,
    context = context,
    task = task,
    instructions = instructions,
    output = output,
    style = style,
    examples = examples,
    model = c("gpt-3.5-turbo", "gpt-4-turbo"),
    quiet = TRUE,
    max_try = 10,
    temperature = 0,
    max_tokens = 1000,
    include_source_text = TRUE,
    simplify = TRUE
) {
  model <- match.arg(model)

  sys_prompt <- compose_prompt_system(
    role = role,
    context = context
  )

  usr_data_prompter <- create_usr_data_prompter(
    task = task,
    instructions = instructions,
    output = output,
    style = style,
    examples = examples
  )

  gpt_answers <- db[[text_column]] |>
    purrr::map(\(txt) {
      usr_prompt <- usr_data_prompter(txt)
      prompt <- compose_prompt_api(sys_prompt, usr_prompt)
      query_gpt(
        prompt = prompt,
        model = model,
        quiet = quiet,
        max_try = max_try,
        temperature = temperature,
        max_tokens = max_tokens
      )
    })

  answers <- if (simplify) {
    purrr::map_chr(gpt_answers, get_content)
  } else {
    gpt_answers
  }

  if (include_source_text) {
    tibble::tibble(
      {{text_column}} := db[[text_column]],
      gpt_res = answers
    )
  } else {
    tibble::tibble(gpt_res = answers)
  }
}


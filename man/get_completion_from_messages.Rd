% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_completion_from_messages.R
\name{get_completion_from_messages}
\alias{get_completion_from_messages}
\alias{get_content}
\alias{get_tokens}
\title{Get completion from chat messages}
\usage{
get_completion_from_messages(
  messages,
  model = c("gpt-3.5-turbo", "gpt-4-turbo"),
  temperature = 0,
  max_tokens = 1000
)

get_content(completion)

get_tokens(completion, what = c("total", "prompt", "completion"))
}
\arguments{
\item{messages}{(list) in the following format: \verb{⁠list(list("role" = "user", "content" = "Hey! How old are you?")} (see:
https://platform.openai.com/docs/api-reference/chat/create#chat/create-model)}

\item{model}{(chr, default = "gpt-3.5-turbo") a length one character
vector indicating the model to use (see:
\url{https://platform.openai.com/docs/models/continuous-model-upgrades})}

\item{temperature}{(dbl, default = 0) a value between 0 (most
deterministic answer) and 2 (more random). (see:
https://platform.openai.com/docs/api-reference/chat/create#chat/create-temperature)}

\item{max_tokens}{(dbl, default = 500) a value greater than 0. The
maximum number of tokens to generate in the chat completion. (see:
https://platform.openai.com/docs/api-reference/chat/create#chat/create-max_tokens)}

\item{completion}{the number of tokens used for output of a
\code{get_completion_from_messages} call}

\item{what}{(chr) one of "total" (default), "prompt", or "completion"}
}
\value{
(list) of two element: \code{content}, which containt the chr
vector of the response, and \code{tokens}, which is a list of number of
tokens used for the request (\code{prompt_tokens}), answer
(\code{completion_tokens}), and overall (\code{total_tokens}, the sum of the
other two)

(chr) the output message returned by the assistant

(int) number of token used in completion for prompt or completion part, or overall (total)
}
\description{
Get completion from chat messages

Get content of a chat completion

Get the number of token of a chat completion
}
\details{
For argument description, please refer to the \href{https://platform.openai.com/docs/api-reference/chat/create}{official documentation}.

Lower values for temperature result in more consistent outputs,
while higher values generate more diverse and creative results.
Select a temperature value based on the desired trade-off between
coherence and creativity for your specific application. Setting
temperature to 0 will make the outputs mostly deterministic, but a
small amount of variability will remain.
}
\section{Functions}{
\itemize{
\item \code{get_content()}: 

\item \code{get_tokens()}: 

}}
\examples{
if (FALSE) {
  prompt <- list(
    list(
      role = "system",
      content = "you are an assistant who responds succinctly"
    ),
    list(
      role = "user",
      content = "Return the text: 'Hello world'."
    )
  )
  res <- get_completion_from_messages(prompt)
  answer <- get_content(res) # "Hello world."
  token_used <- get_tokens(res) # 30
}

if (FALSE) {
  msg_sys <- compose_prompt_system(
    role = "Sei l'assistente di un docente universitario.",
    context = "Tu e lui state preparando un workshop sull'utilizzo di ChatGPT per biostatisitci ed epidemiologi."
  )

  msg_usr <- compose_prompt_user(
    task = "Il tuo compito è trovare cosa dire per spiegare cosa sia una chat di ChatGPT agli studenti, considerando che potrebbe esserci qualcuno che non ne ha mai sentito parlare (e segue il worksho incuriosito dal titolo o dagli amici).",
    output = "Riporta un potenziale dialogo tra il docente e gli studenti che assolva ed esemplifichi lo scopo descritto.",
    style = "Usa un tono amichevole, colloquiale, ma preciso."
  )

  prompt <- compose_prompt_api(msg_sys, msg_usr)
  res <- get_completion_from_messages(prompt, "4-turbo")
  answer <- get_content(res)
  token_used <- get_tokens(res) # 957
}
}

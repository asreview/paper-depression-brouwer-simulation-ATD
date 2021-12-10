#' Concatenate output files of all runs into a single dataframe.
#'
#' @param output_path The directory your flattened state files are located
#' @param dataset Character, the name of your dataset.
#'     Should correspond to the character string in your flattened state files,
#'     run_{dataset}_0_flat.csv")
#' @param n_prior The number of prior inclusions used in this simulation study
#'     (numeric)
#'
#' @return A data frame containing all records in their screening order, prior
#'     knowledge included. With the following columns:
#' \describe{
#'   \item{iteration}{Number of records that have been screened. Note that this
#'      variable starts at 0}
#'   \item{record_id}{Identifier, points to the row index of the record in the
#'       input data. Note that this variable starts at 0}
#'   \item{n_inclusions}{Number of relevant records found}
#'   \item{label}{Whether a record is relevant (1) or irrelevant (0)}
#'   \item{prior}{Logical vector, whether a record was used as a prior inclusion
#'       (\code{TRUE}) or not (\code{FALSE})}

#'   }

#' @export
#'
read_recall_curves <- function(output_path, dataset, n_prior){

  # locate the files
  files <- list.files(output_path, pattern = ".csv", full.names = TRUE)

  # read the files into a list of data.frames
  data.list <- lapply(files, readr::read_csv)
  # add identifier for run
  runnames <- gsub(
    pattern = c("_*_flat.csv"),
    x = files,
    replacement = ""
  )

  runnames <- gsub(
    runnames,
    pattern = glue("{output_path}/run_{dataset}_"),
    replacement = ""
  )
  # add identifier for run
  names(data.list) <- runnames

  # concatenate into 1 dataframe
  df_trials <- bind_rows(data.list, .id = "trial") %>%
    mutate(prior = ifelse(
      iteration < (n_prior), TRUE, FALSE),
      ) %>%
    mutate(trial = as.numeric(trial))

  return(df_trials)
}




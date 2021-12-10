#' Descriptives on dataset
#'
#' @export
#' @import janitor
#'
create_descriptives <- function(df){
  ################
  ## Dictionary ##
  ################

  # The column with labeling decisions should always be named: "label"
  # The column containing the record title should always be named: "title"
  # The column containing the record abstract should always be named: "abstract"
  # The column containing the record keywords should always be named: "keywords"

  #################
  ## Preparation ##
  #################

  # removing all capitals of the column names
  df <- clean_names(df)

  .p <- function(x){ # easy calculation of percentages for the table
    round(((x/n_records)*100),2) # by adding "." it will not show up in global environment
  }

  # Create table which indicates number of relevant and irrelevant records
  incl_table <- c(table(df$label)) #Needed for shorter code for n_incl, n_excl, n_unl

  ####################################
  ## Obtaining the elements we need ##
  ####################################
  # Number of records
  n_records <- nrow(df)

  # Estimated number of duplicates
  est_nd <- sum(duplicated(df$title))
  p_est_nd <- .p(est_nd)

  # number of relevant records
  n_incl <- incl_table[2]
  p_incl <- .p(n_incl)

  # number of irrelevant records
  n_excl <- incl_table[1]
  p_excl <- .p(n_excl)

  # number of unlabeled
  n_unl <- n_records - sum(incl_table) # all records, minus those labelled
  p_unl <- .p(n_unl)

  # It could be the case that either title or abstracts is missing:
  if("title" %in% colnames(df)) {

    # number of missing titles:
    m_t <- sum(is.na(df$title))

    # which have been included?
    incl_m_t <- df %>%
      filter(label == 1 & is.na(title)) %>%
      nrow(.)

  } else { # If no title returns the following:
    m_t <- "None"
    incl_m_t <- "None"
  }

  df1 <- df #so the original dataframe does not get changed

  if("abstract" %in% colnames(df1)){

    # number of missing abstracts, or less than 20 words
    # change NA to ""
    df1$abstract[is.na(df1$abstract)] <- as.character("")

    # Count the number of spaces in the abstracts to determine words:
    # An abstract is counted as missing when there are less than 20 words.
    m_abstracts <- df1 %>% filter(str_count(df1$abstract,  " ") < 19)
    m_a <- nrow(m_abstracts)
    # which have been included?
    incl_m_a <- m_abstracts %>%
      filter(label == 1) %>%
      nrow(.)

  } else { # If no abstract column present
    m_a <- "None"
    incl_m_a <- "None"
  }


  results <- as.data.frame(
    cbind(
      n_records,
      est_nd,
      p_est_nd,
      n_incl,
      p_incl,
      n_excl,
      p_excl,
      n_unl,
      p_unl,
      m_t,
      incl_m_t,
      m_a,
      incl_m_a))

  return(results)
}


#' Create output table
#'
#' @export
#' @import knitr

create_latex_table <- function(d_r, name){
  # Create each column
  c1 <-
    c(
      "Number of records:",
      "Number of relevant records:",
      "Number of irrelevant records:",
      "Number of unlabeled records:",
      "Number of missing titles:",
      "Number of missing abstracts:",
      "Estimated number of duplicates:"
    )

  c2 <- c(d_r$n_records,
          d_r$n_incl,
          d_r$n_excl,
          d_r$n_unl,
          d_r$m_t,
          d_r$m_a,
         d_r$est_nd
          )

  c3 <-
    c(
      " ",
      glue('({d_r$p_incl}%)'),
      glue('({d_r$p_excl}%)'),
      glue('({d_r$p_unl}%)'),
      glue('(of which {d_r$incl_m_t} included)'),
      glue('(of which {d_r$incl_m_a} included)'),
      glue('({d_r$p_est_nd}%)')
    )

  output <- cbind(c1, c2, c3)

  output <- kable(
    output,
    caption =
      paste0(
        "Dataset characteristics on ",
        name
        ),
    align = c('l', 'c', 'l'),
    booktabs = TRUE,
    format = "latex",
    col.names = NULL,
    linesep = ""
  ) %>% kable_styling(latex_options = c("hold_position"))

  return(output)
}


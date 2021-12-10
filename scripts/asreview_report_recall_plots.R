#' Theme for ggplot recall curves
#'
#' @export
#'
theme_paper <- function(){

  ggplot2::theme_bw() %+replace%    #replace elements we want to change

    ggplot2::theme(
      text = element_text(size = 11),
      axis.ticks = element_line(colour = "black", size = 0.5),
      axis.text.x = element_text(
        vjust = 0.5,
        hjust = 0.5
      )
    )
}


#' Generate random line
#'
#' @export
random_performance <- function(iteration, n_inclusions){
  max_n_inclusions <- max(n_inclusions)
  irate <-  max_n_inclusions/max(iteration)
  random <- irate*iteration + 0.5
  return(floor(random))
}



#' Recall when screening data in chronological order
#'
#' This function order a dataset with records in chronological order, from most
#' recent to least recent publication year. With the output one can create a
#' reference line in a recall plot, that shows when relevant records would have
#' been found when screening in chronological order.
#'
#' @param dataset a dataframe with records, for example 'van_de_schoot_2017'.
#'
#' @return a dataframe in 'recall' format, where records are ordered by publication year.
#' @export
#'
chronological_inclusion_rate <- function(dataset){

  # check if year column exists
  stopifnot(
    "Column 'year' doesn't exist in your dataset." = "year" %in% names(dataset))

  # check missing values in year column.
  # print warning, NA' values are read last
  if(anyNA(dataset$year)){
    warning("Column 'year' has NA values. These papers will be last in order. \n
            But this will not show from the plot.")}

  recall_with_time <- dataset %>%
    select(label, record_id, year) %>%
    arrange(-year) %>%
    rownames_to_column() %>%
    mutate(
      n_inclusions = cumsum(label),
      iteration = as.numeric(rowname)-1,
    ) %>%
    select(
      n_inclusions,
      label,
      year,
      iteration
    )

  recall_with_time_and_year_position <- recall_with_time %>%
    # select position if we go to the previous year
    mutate(year_position = ifelse(year-lag(year)==-1, iteration, NA)) %>%
    # give the first year also a position
    mutate(year_position = ifelse(row_number()==1, iteration, year_position))

  return(recall_with_time_and_year_position)
}

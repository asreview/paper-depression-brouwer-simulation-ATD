#' Correct prior articles
#'
#' @export
#'
correct_n_prior <- function(iteration, n_inclusions, n_prior_inc,
                            n_prior_exc){

  n_prior <- n_prior_inc + n_prior_exc
  # throw out prior inclusions
  if(n_prior > 0){
    iteration <- iteration[-(1:n_prior)]
    n_inclusions <- n_inclusions[-(1:n_prior)]
    if(n_prior_inc > 0){
      n_inclusions <- n_inclusions - n_prior_inc
    }
  }
  return(tibble(iteration = iteration,
              n_inclusions = n_inclusions))
}

#' Relevant References Found (RRF)
#'
#' @export
#'
rrf <- function(iteration, n_inclusions, at = 10, format = "numeric",
                n_prior_inc,
                n_prior_exc
                ) {
  n_prior <- n_prior_inc + n_prior_exc

  if(format == "numeric"){
    # get rid of prior inclusions
    dat <- correct_n_prior(iteration, n_inclusions, n_prior_inc, n_prior_exc)
    x_perc <- row_number(dat$iteration)/length(dat$iteration)*100
    y_perc <- dat$n_inclusions/max(dat$n_inclusions)*100

  } else {
    x_perc <- iteration
    y_perc <- n_inclusions
  }

  i <- max(which(x_perc <= at))
  i <- min(which(x_perc >= (at - 1e-6)))
  rrf_res <- y_perc[i]
  names(rrf_res) <- paste0("RRF@", at)
  return(rrf_res)
}

#' Work Saved over Sampling (WSS)
#'
#' @export
#'
wss <- function(iteration, n_inclusions, at = 95, format = "numeric",
                n_prior_inc,
                n_prior_exc
                ){
  if(format == "numeric"){
    dat <- correct_n_prior(iteration, n_inclusions, n_prior_inc, n_prior_exc)
    x_perc <- row_number(dat$iteration)/length(dat$iteration)*100
    y_perc <- dat$n_inclusions/max(dat$n_inclusions)*100
  } else {
    x_perc <- iteration
    y_perc <- n_inclusions
  }

  # point at which you've found 95% of relevant publications
  i <- min(which(y_perc >= at-1e-06))

  # time saved = the random rate minus the rate by ASReview
  wss_res <- y_perc[i] - x_perc[i]

  # coordinates for recall curves
  xco <- c(x_perc[i], x_perc[i])
  yco <- c(x_perc[i], y_perc[i])

  names(wss_res) <- paste0("WSS@", at)

  ## wss_value, x position, y_position
  return(list(wss = wss_res,
              coords = data.frame(x = xco,
                                  y = yco)))
}


#' Time to Discovery (TD)
#'
#' @export
#'
td <- function(recall, n_prior){

  # all inclusions that weren't used as starting paper at least once
  discovered_incl <- recall %>%
    group_by(trial) %>%
    mutate(n_iterations = max(iteration),
           n_papers_screened = max(iteration) + 1) %>%
    ungroup() %>%

    # all records that were not used as prior knowledge at least once
    filter(iteration > n_prior-1,
           label == 1) %>%
    # number of records it took to discover of paper i
    mutate(n_papers_to_discovery = iteration + 1 - n_prior)

  # compute time to discovery for every inclusion (average over all runs)
  time_to_discovery <- discovered_incl %>%
    group_by(record_id) %>%
    summarise(
      # number of trials in which i was discovered (a.k.a. not used as prior)
      n_trials_discovered = length(trial),
      # total number of records that were screened
      n_papers_screened = first(n_papers_screened) - n_prior,
      # the number of records it took to discover i
      average_n_papers_to_discovery = sum(n_papers_to_discovery)/length(trial)
    ) %>%
    ungroup() %>%
    mutate(
      # the percentage of records it took to discover i, over all trials
      time_to_discovery = average_n_papers_to_discovery/n_papers_screened) %>%
    arrange(time_to_discovery)

  return(time_to_discovery)
}

library(readr)
library(tidyverse)
library(glue)
set.seed(42)

dataset <- list.files("data")
data_name <- tools::file_path_sans_ext(dataset)
dat <- read_csv("data/brouwer_deduplicated.csv")

# correct record_ids
inclusions <-
  dat %>%
  filter(included == 1)

# detect inclusions in this data (by key)
keys <- inclusions$key
indices <- which(dat$key %in% keys)

# sample 10 exclusions
excl_keys <- dat %>% 
  filter(included == 0,
         !is.na(abstract)) %>%
  pull(key)
excl_indices <- which(dat$key %in% excl_keys)
exclusions <- sample(excl_indices-1,
                     10)

# save IDs of inclusions
ids <- data.frame(run = seq_along(indices),
                  incl_id = indices-1,
                  excl_id = paste(exclusions, collapse = " "),
                  seed = 42)

# script for generating simulation 
lines <- ids %>%
  mutate(
    command = glue(
      "sh scripts/run_simulation.sh {data_name} {run} {incl_id} \"{excl_id}\" {seed}"
      )
    )

# store simulation commands in run_all.sh file
write_lines(
  lines$command, 
  "scripts/run_all.sh"
  )

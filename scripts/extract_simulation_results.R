## -----------------------------------------------------------------------------
# load packages
library(tidyverse)
library(glue)
library(knitr)
library(asreview)
library(readr)
library(kableExtra)

# datasets 
datasets <- list.dirs(
  "output", recursive = FALSE, full.names = FALSE)
# insert data name
data_name <- datasets # render automatically from data.csv 

# specify data directory 
data_files <- glue("data/{datasets}.csv")

# specify output directory simulations 
output_dir <- glue("output/{datasets}/simulation")

# specify output for creating wss and rrf csv
results_dir <- glue("output/{data_name}")


## ----data statistics---------------------------------------------------------------------------------------------
# load data
dat <- read_csv(data_files) %>%
  rownames_to_column() %>%
  mutate(record_id = as.numeric(rowname)-1) %>%
  rename(label = included)

# print summary
data_characteristics <- create_descriptives(dat)

data_characteristics %>%
  create_latex_table(data_name)

# save statistics 
n <- nrow(dat)
nr <- sum(dat$label)

## ----simulation results----------------------------------------------------------------------------------------
# number of priors
n_prior_included <- 1
n_prior_excluded <- 10
n_prior <- n_prior_included + n_prior_excluded

# load simulation results 
recall <- read_recall_curves(
  output_dir, 
  dataset = datasets,
  n_prior = n_prior)

# compute number of trials
n_trials <- recall %>%
  summarise(n_trials = length(unique(trial))) %>%
  pull()

## ----------------------------------------------------------------------------------------------------------------
# correct for prior inclusions yes/no
priors <- recall %>% 
  filter(prior)

## ----prior table-------------------------------------------------------------------------------------------------
priors_text <- dat %>%
  # to do: select first 20 words of abstract to add.
  select(-label, -abstract, -rowname)

priors_table <- 
left_join(priors %>%
            select(record_id, trial, label), 
          priors_text, 
          by = "record_id") %>%
  group_by(trial) %>%
  select(trial, title, label, record_id) 

## ----------------------------------------------------------------------------------------------------------------
# set wanted levels for metrics
wssat <- 95
rrfat <- 10

## ----prepare information for plot--------------------------------------------------------------------------------
# add random line 
recall <- recall %>%
  group_by(trial) %>%
  mutate(random = random_performance(iteration, n_inclusions)) %>%
  ungroup()

# wss line coordinates
wss_lines <- recall %>%
  group_by(trial) %>%
  arrange(iteration) %>%
  summarise(coords = wss(iteration, n_inclusions, at = wssat, 
                        n_prior_inc = 0,
                        n_prior_exc = 0)$coords,
            n_iterations = max(iteration)) %>%
  ungroup() %>%
  summarise(x_percentage = mean(coords$x),
            x_absolute = x_percentage/100*mean(n_iterations))


## ----metrics-----------------------------------------------------------------------------------------------------
# compute WSS@95 and RRF@10 
metrics <- recall %>%
  group_by(trial) %>%  
  arrange(iteration) %>%
  summarise(wss_vals = wss(iteration, 
                      n_inclusions, 
                      at = wssat, 
                      n_prior_inc = n_prior_included, 
                      n_prior_exc = n_prior_excluded)$wss, 
            rrf_vals = rrf(iteration, 
                      n_inclusions,
                      at = rrfat,
                      n_prior_inc = n_prior_included,
                      n_prior_exc = n_prior_excluded
                      ),
            recall_vals =  wss(iteration, n_inclusions, at = wssat, 
                               n_prior_inc = 0,
                               n_prior_exc = 0)$coords$x
)

# build metrics table
metricstab <- metrics %>%
  summarise(
    wss = round(mean(wss_vals),0),
    sd_wss = round(sd(wss_vals),2),
    rrf = round(mean(rrf_vals),0),
    sd_rrf = round(sd(rrf_vals),2)
  )


## ----------------------------------------------------------------------------------------------------------------
# compute difficulty 
time_to_discovery <- td(recall, n_prior_included + n_prior_excluded) 

# add titles from the dataset
td_table <- left_join(
  time_to_discovery,
  dat %>% 
    select(record_id, title, key, search, doi)
  ) %>%
  mutate(
    row_in_brouwer_2019.csv = record_id+1,
    time_to_discovery = time_to_discovery*100) %>%
  select(-record_id,
         -n_papers_screened)

## ----plot recall curve-------------------------------------------------------------------------------------------
recall_plot <- recall %>%
  ggplot(aes(iteration, n_inclusions, group = trial)) +
  # Recall
  geom_line(
    aes(color = "Recall"),
    size = .5,
    alpha = 0.8,
    key_glyph = "rect"
  ) +
  # Random line
  geom_line(
    aes(x = iteration, y = random, color = "Random"),
    size = .3,
    key_glyph = "rect"
  ) +
  # WSS line
  geom_vline(
    aes(xintercept = x_absolute, color = "WSS"),
    size = .7 ,
    data = wss_lines,
    key_glyph = "rect"
  ) +
  # Specify colors to be used
  scale_color_manual(
    values = colors,
    name = "",
    labels = c(
      "Random",
      glue("Recall curve(s)"),
      glue("{wssat}% recall")
    )
  ) +
  theme_paper() +
  scale_x_continuous(n.breaks = 6) +
  labs(x = "Records read", 
       y = "Relevant records found")

recall_plot + # adding more ticks to the x-axis
  labs(title = glue("Simulation of screening the {data_name} dataset"), 
       subtitle = glue("Searching a set of {n} papers for {nr} relevant ones"),
       x = "Records read", 
       y = "Relevant records found") + 
  ggsave(glue(results_dir, "/recall.png"),
         height=6, width=8)


## ----------------------------------------------------------------------------------------------------------------
# print time to discovery table table (row numbers start at 1)
td_table <- td_table %>%
  mutate(
    time_to_discovery = round(time_to_discovery, 4),
    average_n_papers_to_discovery = round(average_n_papers_to_discovery, 2)) %>%
  rename(
    average_number_records_to_discovery = average_n_papers_to_discovery,
    average_percentage_records_to_discovery = time_to_discovery) %>%
  # change the order 
  select(
    row_in_brouwer_2019.csv,
    title,
    average_number_records_to_discovery,
    average_percentage_records_to_discovery,
    n_trials_discovered,
    search,
    key,
    doi
  )

## ----drop data---------------------------------------------------------------------------------------------------
# RRF and WSS values
# assign names to WSS and RRF metrics
wssname <- glue("WSS@", wssat)
rrfname <- glue("RRF@", rrfat)
recallname <- glue("Recall@", wssat)

write_csv(
  metrics %>%
  rename(
    {{wssname}} := wss_vals,
    {{rrfname}} := rrf_vals,
    {{recallname}} := recall_vals
    ), 
  file = glue("{results_dir}/wss_and_rrf_values.csv")
)

# time to discovery table
write_excel_csv(
  td_table,
  file = glue("{results_dir}/time_to_discovery.csv")
)



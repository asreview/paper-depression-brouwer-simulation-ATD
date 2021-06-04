# Scripts for simulation study on obtaining average time to discovery 

This repository contains the scripts for a simulation study performed on data from the systematic review by [Brouwer et al. (2019)](https://doi.org/10.1016/j.cpr.2019.101773). T

The simulation study has the following characteristics:

- The number of runs is equal to the number of inclusions in the dataset;
- Every run starts with 1 prior inclusion and 10 prior exclusions;
- The prior inclusion is different for every run, e.g. all inclusions in the data are used as a prior inclusion once;
- The 10 prior exclusions are the same for every run, and they are randomly sampled from the dataset.

The systematic review data used for this study can be found on the Open Science Framework: https://osf.io/r45yz/


## Execute simulation study
To reproduce the results presented in this study, run the following in your
terminal:

```
# install required software (such as ASReview)
pip install requirements.txt

# run all simulations
sh run_all.sh.sh
```

## Extract results 
First, install the required R-packages by executing the
following in your CLI: `Rscript scripts/install.R`.
If you run into any errors, open the `install.R` file and try to install
the packages manually.

Next, you can extract the results from the simulation output by executing the
following in your CLI:

```
Rscript scripts/extract_simulation_results.R
```

The output (in the folder `output/brouwer_2019`) consists of
- All inclusions in the dataset, ordered by their time to discovery - the `time_to_discovery.csv` file. The column *row* corresponds to the position of the inclusion in the original dataset. Note that the position starts at 1;
- A table with WSS and RRF values for every run - the `wss_and_rrf_values.csv` file;
- A plot with recall curves for all runs of this simulation study - the `recall.png` file.


# References
Brouwer, M. E., Williams, A. D., Kennis, M., Fu, Z., Klein, N. S., Cuijpers,
P., & Bockting, C. L. H. (2019). Psychological theories of depressive relapse
and recurrence: A systematic review and meta-analysis of prospective studies.
Clinical Psychology Review, 74, 101773. https://doi.org/10.1016/j.cpr.2019.101773

DATA=$1
RUN=$2
PRIOR_INCL=$3
PRIOR_EXCL=$4
SEED=$5

# run a simulation
rm output/${DATA}/simulation/run_${DATA}_final_${RUN}.h5
asreview simulate data/${DATA}.csv -s output/${DATA}/simulation/run_${DATA}_${RUN}.h5 --prior_idx ${PRIOR_INCL} ${PRIOR_EXCL} --seed $SEED
python scripts/flatten_state.py output/${DATA}/simulation/run_${DATA}_${RUN}.h5 output/${DATA}/simulation/run_${DATA}_${RUN}_flat.csv
rm output/${DATA}/simulation/run_${DATA}_${RUN}.h5

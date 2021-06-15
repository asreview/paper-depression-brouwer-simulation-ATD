---
name: basic
name_long: Basic simulation for N runs

scripts:
  - get_atd.py
  - merge_descriptives.py
  - merge_metrics.py

---



# version 0.1.1+23.g6c9401b


##################################
### DATASET: brouwer_2019
##################################

# Create folder structure. By default, the folder 'output' is used to store output.
mkdir output
mkdir output/simulation
mkdir output/simulation/brouwer_2019/


# Collect descriptives about the dataset
mkdir output/simulation/brouwer_2019/descriptives
asreview stat data/brouwer_2019.csv -o output/simulation/brouwer_2019/descriptives/data_stats_brouwer_2019.json
asreview wordcloud data/brouwer_2019.csv -o output/simulation/brouwer_2019/descriptives/wordcloud_brouwer_2019.png --width 800 --height 500
asreview wordcloud data/brouwer_2019.csv -o output/simulation/brouwer_2019/descriptives/wordcloud_brouwer_2019_relevant.png --width 800 --height 500 --relevant
asreview wordcloud data/brouwer_2019.csv -o output/simulation/brouwer_2019/descriptives/wordcloud_brouwer_2019_irrelevant.png --width 800 --height 500 --irrelevant

# Simulation.
# Make folders: 
mkdir output/simulation/brouwer_2019/state_files

# Simulate runs, maps in alphabetical order:

# Classifier = logistic , Feature extraction = doc2vec , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/logistic_d2v
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/logistic_d2v/logistic_d2v_brouwer_2019.h5 --model logistic --query_strategy max --feature_extraction doc2vec --prior_idx 0 3107 --seed 165 -r 1

# Classifier = logistic , Feature extraction = sbert , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/logistic_sbert
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/logistic_sbert/logistic_sbert_brouwer_2019.h5 --model logistic --query_strategy max --feature_extraction sbert --prior_idx 0 3107 --seed 165 -r 1

# Classifier = logistic , Feature extraction = tfidf , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/logistic_tfidf
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/logistic_tfidf/logistic_tfidf_brouwer_2019.h5 --model logistic --query_strategy max --feature_extraction tfidf --prior_idx 0 3107 --seed 165 -r 1

# Classifier = nb , Feature extraction = tfidf , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/nb_tfidf
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/nb_tfidf/nb_tfidf_brouwer_2019.h5 --model nb --query_strategy max --feature_extraction tfidf --prior_idx 0 3107 --seed 165 -r 1

# Classifier = rf , Feature extraction = doc2vec , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/rf_d2v
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/rf_d2v/rf_d2v_brouwer_2019.h5 --model rf --query_strategy max --feature_extraction doc2vec --prior_idx 0 3107 --seed 165 -r 1

# Classifier = rf , Feature extraction = sbert , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/rf_sbert
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/rf_sbert/rf_sbert_brouwer_2019.h5 --model rf --query_strategy max --feature_extraction sbert --prior_idx 0 3107 --seed 165 -r 1

# Classifier = rf , Feature extraction = tfidf , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/rf_tfidf
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/rf_tfidf/rf_tfidf_brouwer_2019.h5 --model rf --query_strategy max --feature_extraction tfidf --prior_idx 0 3107 --seed 165 -r 1

# Classifier = svm , Feature extraction = doc2vec , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/svm_d2v
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/svm_d2v/svm_d2v_brouwer_2019.h5 --model svm --query_strategy max --feature_extraction doc2vec --prior_idx 0 3107 --seed 165 -r 1

# Classifier = svm , Feature extraction = sbert , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/svm_sbert
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/svm_sbert/svm_sbert_brouwer_2019.h5 --model svm --query_strategy max --feature_extraction sbert --prior_idx 0 3107 --seed 165 -r 1

# Classifier = svm , Feature extraction = tfidf , Query strategy = max
mkdir output/simulation/brouwer_2019/state_files/svm_tfidf
asreview simulate-batch data/brouwer_2019.csv -s output/simulation/brouwer_2019/state_files/svm_tfidf/svm_tfidf_brouwer_2019.h5 --model svm --query_strategy max --feature_extraction tfidf --prior_idx 0 3107 --seed 165 -r 1

# plots
python scripts/plots.py

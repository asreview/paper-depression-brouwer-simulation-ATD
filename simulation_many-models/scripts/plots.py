
# version {{ version }}

import os
from asreviewcontrib.visualization import Plot


dic = { "output/simulation/brouwer_2019/state_files/logistic_d2v/logistic_d2v_brouwer_2019_0.h5" : "Log + D2V",
        "output/simulation/brouwer_2019/state_files/logistic_sbert/logistic_sbert_brouwer_2019_0.h5" : "Log + sBert",
        "output/simulation/brouwer_2019/state_files/logistic_tfidf/logistic_tfidf_brouwer_2019_0.h5" : "Log + Tf-idf",
        "output/simulation/brouwer_2019/state_files/nb_tfidf/nb_tfidf_brouwer_2019_0.h5" : "Nb + Tf-idf",
        "output/simulation/brouwer_2019/state_files/rf_d2v/rf_d2v_brouwer_2019_0.h5" : "Rf + D2V",
        "output/simulation/brouwer_2019/state_files/rf_sbert/rf_sbert_brouwer_2019_0.h5" : "Rf + sBert",
        "output/simulation/brouwer_2019/state_files/rf_tfidf/rf_tfidf_brouwer_2019_0.h5" : "Rf + Tf-idf",
        "output/simulation/brouwer_2019/state_files/svm_d2v/svm_d2v_brouwer_2019_0.h5" : "Svm + D2V",
        "output/simulation/brouwer_2019/state_files/svm_sbert/svm_sbert_brouwer_2019_0.h5" : "Svm + sBert",
        "output/simulation/brouwer_2019/state_files/svm_tfidf/svm_tfidf_brouwer_2019_0.h5" : "Svm + Tf-idf"
       
      }

with Plot.from_paths(dic) as plot:
    all_files = all(plot.is_file.values())
    inc_plot = plot.new("inclusion")
    inc_plot.set_grid()
    for key in list(plot.analyses):
        if all_files or not plot.is_file[key]:
            inc_plot.add_WSS(key, 95, add_text = False)
            inc_plot.add_RRF(key, 10, add_text = False)
    #inc_plot.set_xlim(0, 50)
    inc_plot.set_ylim(0, 101)
    inc_plot.add_random(add_text = False)
    inc_plot.set_legend()
    inc_plot.save("brouwer_2019.png")
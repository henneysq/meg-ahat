import logging
import unittest

from tests.test_util import set_git_executable_path
set_git_executable_path()

from experiment_management import experiment_va_settings as evas
from experiment_management import experiment_wm_settings as ewms
from tests.__init__ import log_file

logging.basicConfig(filename=log_file, level=logging.INFO, filemode="w")

class TestConfigs(unittest.TestCase):
    def test_total_conf(self):
        total_in_mins = int(evas.total_experiment_duration/60 + ewms.total_experiment_duration/60)
        total_in_secs = int((evas.total_experiment_duration + ewms.total_experiment_duration) % 60)
        logging.info(f"Total duration for both experiments: {total_in_mins} min, {total_in_secs} sec.\n")
        
    def test_va_config(self):
        logging.info("update\n")
        logging.info(f"\nVisual Attention Experiment Configs:")
        logging.info(f"Expected single trial duration: {evas.expected_max_single_trial_duration} s.")
        logging.info(f"Number of trials: {evas.total_experiment_trials}.")
        total_in_mins = int(evas.total_experiment_duration/60)
        total_in_secs = int(evas.total_experiment_duration % 60)
        logging.info(f"Total duration: {total_in_mins} min, {total_in_secs} sec.\n")
        
    def test_wm_config(self):
        logging.info(f"\nWorking Memory Experiment Configs:")
        logging.info(f"Expected single trial duration: {ewms.expected_max_single_trial_duration} s.")
        logging.info(f"Number of trials: {ewms.total_experiment_trials}.")
        total_in_mins = int(ewms.total_experiment_duration/60)
        total_in_secs = int(ewms.total_experiment_duration % 60)
        logging.info(f"Total duration: {total_in_mins} min, {total_in_secs} sec.\n")
        
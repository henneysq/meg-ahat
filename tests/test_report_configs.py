import logging
import unittest
from pathlib import Path

import git

from experiment_management import experiment_va_settings as evas
from experiment_management import experiment_wm_settings as ewms

test_log_dir = filename=Path(__file__).parent / "test_logs"
test_log_dir.mkdir(exist_ok=True)

repo = git.Repo(search_parent_directories=True)
sha = repo.head.object.hexsha[:8]
logging.basicConfig(filename=test_log_dir/ f"conf_{sha}.log", level=logging.INFO, filemode="w")

class TestConfigs(unittest.TestCase):
    def test_total_conf(self):
        pass
    
    def test_va_config(self):
        logging.info(f"Visual Attention Experiment Configs:")
        logging.info(f"Expected single trial duration: {evas.expected_max_single_trial_duration} s.")
        logging.info(f"Number op trials: {evas.total_experiment_trials}.")
        total_in_mins = int(evas.total_experiment_duration/60)
        total_in_secs = int(evas.total_experiment_duration % 60)
        logging.info(f"Total duration: {total_in_mins} min, {total_in_secs} sec.\n")
        
    
    def test_wm_config(self):
        logging.info(f"Working Memory Experiment Configs:")
        logging.info(f"Expected single trial duration: {ewms.expected_max_single_trial_duration} s.")
        logging.info(f"Number op trials: {ewms.total_experiment_trials}.")
        total_in_mins = int(ewms.total_experiment_duration/60)
        total_in_secs = int(ewms.total_experiment_duration % 60)
        logging.info(f"Total duration: {total_in_mins} min, {total_in_secs} sec.\n")
        
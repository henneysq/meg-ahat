from pathlib import Path
import unittest

from numpy import random

from experiment_manager import VisualAttentionExperimentManager

SUB = 42
SES = 42
RUN = 42

BLOCKS = 1
STIMULI = ("con", "isf", "strobe")
TASKS = ("left", "right")
REPETITIONS = 1
TARGET_CONGRUENCE = (1, 0)

DATA_PATH = Path(__file__).parent / "test_data"

class TestVisualAttention(unittest.TestCase):
    def test_1_make_and_save_experiment_data(self) -> None:
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=DATA_PATH
        )

        experiment_manager.make_and_save_experiment_data(
            blocks=BLOCKS,
            stimuli=STIMULI,
            tasks=TASKS,
            repetitions=REPETITIONS,
            target_congruence=TARGET_CONGRUENCE,
            overwrite=True,
        )

        with self.assertRaises(FileExistsError):
            experiment_manager.make_and_save_experiment_data(
                blocks=BLOCKS,
                stimuli=STIMULI,
                tasks=TASKS,
                repetitions=REPETITIONS,
                target_congruence=TARGET_CONGRUENCE,
                overwrite=False,
            )

    def test_2_load_experiment_data(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=DATA_PATH
        )
        
        experiment_manager.load_experiment_data()

    def test_3_set_trial_response(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=DATA_PATH
        )
        
        experiment_manager.load_experiment_data()
        
        experiment_manager.set_current_trial_response(response=1, reaction_time=125)
        
    def test_4_complete_experiment(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=DATA_PATH
        )
        
        experiment_manager.load_experiment_data()

        for _ in range(len(experiment_manager)):
            experiment_manager.set_current_trial_response(
                response=random.choice((0, 1)), reaction_time=random.poisson(lam=200)
            )
            experiment_manager.increment_trial_progress()
            experiment_manager.save_experiment_data()
            
        self.assertTrue(experiment_manager.end_of_experiment_flag)
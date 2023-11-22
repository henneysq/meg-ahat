from pathlib import Path
import unittest

from numpy import random

from experiment_manager_va import VisualAttentionExperimentManager

SUB = 42
SES = 42
RUN = 42
ROOT = Path(__file__).parent / "test_data"

class TestVisualAttention(unittest.TestCase):
    def test_1_make_and_save_experiment_data(self) -> None:
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.make_and_save_experiment_data(
            overwrite=True,
        )

        with self.assertRaises(FileExistsError):
            experiment_manager.make_and_save_experiment_data(
                overwrite=False,
            )

    def test_2_load_experiment_data(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.load_experiment_data()

    def test_3_set_trial_response(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.load_experiment_data()

        experiment_manager.set_current_trial_response(response=1, reaction_time=125)

    def test_4_set_complete_experiment_data(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.load_experiment_data()

        for _ in range(len(experiment_manager)):
            experiment_manager.set_current_trial_response(
                response=random.choice((0, 1)), reaction_time=random.poisson(lam=200)
            )
            experiment_manager.increment_trial_progress()
            experiment_manager.save_experiment_data()

        self.assertTrue(experiment_manager.end_of_experiment_flag)

    def test_5_single_trial(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.load_experiment_data()

        current_trial = experiment_manager.get_current_trial_data()
        attention_side = current_trial.task
        stimulus = current_trial.stimulus_condition
        task_congruence = current_trial.task_congruence
        _ = experiment_manager.execute_current_trial(
            grating_side=attention_side,
            grating_congruence=task_congruence,
            stimulus=stimulus,
            instruction_duration=0.1,
            fixation_duration_range=(0.05, 0.1),
        )

    def test_6_run_experiment_externally(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.load_experiment_data()

        for _ in range(len(experiment_manager)):
            current_trial = experiment_manager.get_current_trial_data()
            attention_side = current_trial.task
            stimulus = current_trial.stimulus_condition
            task_congruence = current_trial.task_congruence
            response, reaction_time = experiment_manager.execute_current_trial(
                grating_side=attention_side,
                grating_congruence=task_congruence,
                stimulus=stimulus,
                instruction_duration=0.001,
                fixation_duration_range=(0.0005, 0.001),
                response_timeout=0.001,
            )
            experiment_manager.set_current_trial_response(
                response=response, reaction_time=reaction_time
            )
            experiment_manager.increment_trial_progress()
            experiment_manager.save_experiment_data()

        self.assertTrue(experiment_manager.end_of_experiment_flag)

    def test_7_run_experiment_internally(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.load_experiment_data()

        experiment_manager.run_experiment(
            instruction_duration=0.001,
            fixation_duration_range=(0.0005, 0.001),
            response_timeout=0.001
        )

        self.assertTrue(experiment_manager.end_of_experiment_flag)

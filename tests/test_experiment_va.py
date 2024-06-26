import logging
from pathlib import Path
import unittest
from unittest.mock import MagicMock

from numpy import random

from experiment_management.experiment_manager_va import VisualAttentionExperimentManager
from tests.test_util import check_is_lc_connected, check_is_trigger_connected
from tests.__init__ import log_file

logging.basicConfig(filename=log_file, level=logging.INFO, filemode="w")

SUB = 42
SES = 42
RUN = 1
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
        
        experiment_manager.show_start_screen = MagicMock()
        experiment_manager.show_pause_screen = MagicMock()

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
        experiment_manager.show_start_screen = MagicMock()
        experiment_manager.show_pause_screen = MagicMock()
        
        experiment_manager = check_is_trigger_connected(experiment_manager)
        experiment_manager = check_is_lc_connected(experiment_manager)

        experiment_manager.load_experiment_data()
        experiment_manager.prepare_psychopy()

        current_trial = experiment_manager.get_current_trial_data()
        attention_side = current_trial.task
        stimulus = current_trial.stimulus_condition
        task_congruence = current_trial.task_congruence
        response, rt = experiment_manager.execute_current_trial(
            grating_side=attention_side,
            grating_congruence=task_congruence,
            stimulus=stimulus,
        )

        experiment_manager.set_current_trial_response(
            response=response, reaction_time=rt
        )
        experiment_manager.increment_trial_progress()
        experiment_manager.save_experiment_data()

    def test_6_run_experiment_externally(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )
        experiment_manager.show_start_screen = MagicMock()
        experiment_manager.show_pause_screen = MagicMock()

        experiment_manager = check_is_trigger_connected(experiment_manager)
        experiment_manager = check_is_lc_connected(experiment_manager)
        
        experiment_manager.load_experiment_data()
        experiment_manager.prepare_psychopy()

        for _ in range(len(experiment_manager)):
            current_trial = experiment_manager.get_current_trial_data()
            attention_side = current_trial.task
            stimulus = current_trial.stimulus_condition
            task_congruence = current_trial.task_congruence
            response, reaction_time = experiment_manager.execute_current_trial(
                grating_side=attention_side,
                grating_congruence=task_congruence,
                stimulus=stimulus,
                rest_duration=0.0001,
                fixation_pre_duration=0.0001,
                instruction_duration=0.0001,
                fixation_duration_range=(0.0001, 0.0001),
                response_timeout=0.0001,
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
        experiment_manager.show_start_screen = MagicMock()
        experiment_manager.show_pause_screen = MagicMock()

        experiment_manager = check_is_trigger_connected(experiment_manager)
        experiment_manager = check_is_lc_connected(experiment_manager)
        
        experiment_manager.load_experiment_data()
        experiment_manager.prepare_psychopy()

        try:
            experiment_manager.trigger.prepare_trigger()
        except Exception as e:
            logging.info("Caught exception while connecting serial port:\n" + str(e))
            experiment_manager.trigger.ser = MagicMock()
            experiment_manager.trigger.ser.write = MagicMock()
            experiment_manager.trigger.ser.read = MagicMock(return_value=bytearray([42]))

        experiment_manager.run_experiment(
            rest_duration=0.0001,
            fixation_pre_duration=0.0001,
            instruction_duration=0.001,
            fixation_duration_range=(0.0005, 0.001),
            response_timeout=0.001,
        )

        self.assertTrue(experiment_manager.end_of_experiment_flag)
        self.assertTrue(experiment_manager.experiment_data.at[len(experiment_manager) - 1, "completed"])

    def test_8_check_unique_triggers(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )
        
        trigger_names = []
        trigger_values = []
        for k, v in experiment_manager.trigger_map.items():
            trigger_names.append(k)
            trigger_values.append(v)
            
        self.assertEqual(len(trigger_names), len(set(trigger_names)))
        self.assertEqual(len(trigger_values), len(set(trigger_values)))

    def test_10_ten_trials(self):
        experiment_manager = VisualAttentionExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )
        experiment_manager.show_start_screen = MagicMock()
        experiment_manager.show_pause_screen = MagicMock()
        
        experiment_manager = check_is_trigger_connected(experiment_manager)
        experiment_manager = check_is_lc_connected(experiment_manager)

        experiment_manager.load_experiment_data()
        experiment_manager.prepare_psychopy()

        for _ in range(10):
            current_trial = experiment_manager.get_current_trial_data()
            attention_side = current_trial.task
            stimulus = current_trial.stimulus_condition
            task_congruence = current_trial.task_congruence
            
            try:
                _, _ = experiment_manager.execute_current_trial(
                    grating_side=attention_side,
                    grating_congruence=task_congruence,
                    stimulus=stimulus,
                )
                experiment_manager.increment_trial_progress()
            except SystemExit:
                break

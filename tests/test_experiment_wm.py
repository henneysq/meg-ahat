import logging
from pathlib import Path
import unittest
from unittest.mock import MagicMock

from experiment_management.experiment_manager_wm import WorkingMemoryExperimentManager
from tests.test_util import check_is_lc_connected, check_is_trigger_connected
from tests.__init__ import log_file

logging.basicConfig(filename=log_file, level=logging.INFO, filemode="w")

SUB = 42
SES = 42
RUN = 2
ROOT = Path(__file__).parent / "test_data"


class TestWorkingMemory(unittest.TestCase):
    def test_1_make_and_save_experiment_data(self) -> None:
        experiment_manager = WorkingMemoryExperimentManager(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )

        experiment_manager.make_and_save_experiment_data(
            overwrite=True,
        )

        with self.assertRaises(FileExistsError):
            experiment_manager.make_and_save_experiment_data(
                overwrite=False,
            )

    def test_5_single_trial(self):
        experiment_manager = WorkingMemoryExperimentManager(
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
            import time; time.sleep(3)
            experiment_manager.trigger.ser.reset_input_buffer()
        except Exception as e:
            logging.info("Caught exception while connecting serial port:\n" + str(e))
            experiment_manager.trigger.ser = MagicMock()
            experiment_manager.trigger.ser.write = MagicMock()
            experiment_manager.trigger.ser.read = MagicMock(return_value=bytearray([0]))
            experiment_manager.trigger.trigger_ready = True

        current_trial = experiment_manager.get_current_trial_data()
        stimulus = current_trial.stimulus_condition
        task_difficulty = current_trial.task_difficulty
        presented_sum_correctness = current_trial.presented_sum_correctness
        _ = experiment_manager.execute_current_trial(
            presented_sum_correctness=presented_sum_correctness,
            stimulus=stimulus,
            task_difficulty=task_difficulty
        )

    def test_7_run_experiment_internally(self):
        experiment_manager = WorkingMemoryExperimentManager(
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
            experiment_manager.trigger.ser.read = MagicMock(return_value=42)

        experiment_manager.run_experiment(
            pre_fixation_duration=0.001,
            wm_task_duration=0.001,
            fixation_duration_range=(0.0005, 0.001),
            response_timeout=0.001,
        )

        self.assertTrue(experiment_manager.end_of_experiment_flag)

    def test_8_check_unique_triggers(self):
        experiment_manager = WorkingMemoryExperimentManager(
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
        experiment_manager = WorkingMemoryExperimentManager(
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
            import time; time.sleep(3)
            experiment_manager.trigger.ser.reset_input_buffer()
        except Exception as e:
            logging.info("Caught exception while connecting serial port:\n" + str(e))
            experiment_manager.trigger.ser = MagicMock()
            experiment_manager.trigger.ser.write = MagicMock()
            experiment_manager.trigger.ser.read = MagicMock(return_value=bytearray([0]))
            experiment_manager.trigger.trigger_ready = True

        for _ in range(4):
            current_trial = experiment_manager.get_current_trial_data()
            stimulus = current_trial.stimulus_condition
            task_difficulty = current_trial.task_difficulty
            presented_sum_correctness = current_trial.presented_sum_correctness
            try:
                _ = experiment_manager.execute_current_trial(
                    presented_sum_correctness=presented_sum_correctness,
                    stimulus=stimulus,
                    task_difficulty=task_difficulty
                )
                experiment_manager.increment_trial_progress()
            except SystemExit:
                break
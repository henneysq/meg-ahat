from pathlib import Path
import time
import unittest
from unittest.mock import MagicMock

from dotmap import DotMap
import pandas as pd

from experiment_management.experiment_manager_base import ExperimentManagerBase
from tests.test_util import check_is_trigger_connected, check_is_lc_connected

SUB = 42
SES = 42
RUN = 0

ROOT = Path(__file__).parent / "test_data"


class TestExperimentBase(unittest.TestCase):
    def test_1_make_and_save_experiment_data(self) -> None:
        experiment_manager = ExperimentManagerBase(sub=SUB, ses=SES, run=RUN, root=ROOT)

        with self.assertRaises(NotImplementedError):
            experiment_manager.make_and_save_experiment_data(
                root=ROOT,
                overwrite=False,
            )

    def test_trial_progress(self) -> None:
        data = self._make_exp_dat()
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN, root=ROOT, experiment_data=data
        )

        self.assertFalse(experiment_manager.end_of_experiment_flag)
        self.assertAlmostEqual(experiment_manager.trial_progress, 0)

        experiment_manager.increment_trial_progress()
        self.assertAlmostEqual(experiment_manager.trial_progress, 1)

        experiment_manager.set_trial_progress(2)
        self.assertAlmostEqual(experiment_manager.trial_progress, 2)

        experiment_manager.set_trial_progress(len(experiment_manager) - 1)
        self.assertTrue(experiment_manager.end_of_experiment_flag)

        with self.assertRaises(RuntimeError):
            experiment_manager.increment_trial_progress()

        with self.assertRaises(TypeError):
            experiment_manager.set_trial_progress(1.1)

        with self.assertRaises(ValueError):
            experiment_manager.set_trial_progress(len(experiment_manager))

        with self.assertRaises(ValueError):
            experiment_manager.set_trial_progress(-1)

    def test_properties(self) -> None:
        experiment_manager = ExperimentManagerBase(sub=SUB, ses=SES, run=RUN)

        self.assertEqual(experiment_manager.sub, SUB)
        self.assertEqual(experiment_manager.ses, SES)
        self.assertEqual(experiment_manager.run_, RUN)
        self.assertEqual(experiment_manager.trial_progress, 0)

        bids_like_str = f"sub-{SUB:03}_ses-{SES:03}_run-{RUN:03}"
        self.assertEqual(experiment_manager.bids_kv_pair_str, bids_like_str)

    def test_set_response(self):
        data = self._make_exp_dat()
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN, experiment_data=data
        )

        with self.assertRaises(NotImplementedError):
            experiment_manager.set_current_trial_response()

    def _make_exp_dat(self) -> pd.DataFrame:
        trial_numbers = tuple(range(10))
        block_numbers = (0, 0, 0, 0, 0, 1, 1, 1, 1, 1)
        stimulus_conditions = (
            "con",
            "strobe",
            "isf",
            "con",
            "strobe",
            "isf",
            "con",
            "strobe",
            "isf",
            "con",
        )
        tasks = ("l", "r", "l", "r", "l", "r", "l", "r", "l", "r")
        task_congruence = (0, 1, 0, 1, 0, 1, 0, 1, 0, 1)
        responses = [None] * len(trial_numbers)
        reaction_times = [None] * len(trial_numbers)
        completed = (0,) * len(trial_numbers)

        return pd.DataFrame.from_dict(
            {
                "trial_number": trial_numbers,
                "block_number": block_numbers,
                "stimulus_condition": stimulus_conditions,
                "task": tasks,
                "task_congruence": task_congruence,
                "response": responses,
                "reaction_time": reaction_times,
                "completed": completed,
            }
        )

    def test_start_screen(self):
        from dotmap import DotMap
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN
        )
        
        experiment_manager = check_is_trigger_connected(experiment_manager)
        experiment_manager.prepare_psychopy()
        try:
            experiment_manager.show_start_screen(timeout=10)
        except TimeoutError:
            pass
        
        with self.assertRaises(TimeoutError):
            experiment_manager.show_start_screen(timeout=.01)
        
        with self.assertRaises(SystemExit):
            key = DotMap()
            key.value = "q"
            return_val = [key,]
            experiment_manager.keyboard.getKeys = MagicMock(return_value=return_val)
            experiment_manager.show_start_screen(timeout=1)

    def test_pause_screen(self):
        data = self._make_exp_dat()
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN, experiment_data=data
        )
        
        experiment_manager = check_is_trigger_connected(experiment_manager)
        experiment_manager.prepare_psychopy()
        
        experiment_manager.increment_trial_progress()
        experiment_manager.show_pause_screen()
        
    def test_led_controller(self):
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN
        )
        
        experiment_manager = check_is_lc_connected(experiment_manager)
        
        experiment_manager.lc_left.display_preset(3)
        experiment_manager.lc_right.display_preset(3)
        experiment_manager.lc_left.turn_on()
        experiment_manager.lc_right.turn_on()
        time.sleep(3)
        
        experiment_manager.lc_left.display_preset(2)
        experiment_manager.lc_right.display_preset(2)
        time.sleep(3)
        
        experiment_manager.lc_left.display_preset(1)
        experiment_manager.lc_right.display_preset(1)
        time.sleep(3)
        
    def test_scout_lights(self):
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN
        )
        
        experiment_manager = check_is_lc_connected(experiment_manager)
        
        experiment_manager.lc_left.display_preset(3)
        experiment_manager.lc_left.turn_on()
        time.sleep(3)
        experiment_manager.lc_left.turn_off()
        
        experiment_manager.lc_right.display_preset(3)
        experiment_manager.lc_right.turn_on()
        time.sleep(3)
        experiment_manager.lc_right.turn_off()
        
    def test_manager_dump_versions(self):
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )
        mdump_path = Path(
            experiment_manager.root /
            experiment_manager.exp_dat_mandump_fname
        )
        mdump_path.touch()
        
        experiment_manager._update_manager_dump()
        new_mdump_path = Path(
            experiment_manager.root /
            experiment_manager.exp_dat_mandump_fname
        )
        new_mdump_path.touch()
        
        self.assertTrue(mdump_path.exists())
        self.assertTrue(new_mdump_path.exists())
        self.assertIsNot(mdump_path.absolute(), new_mdump_path.absolute())
        
        new_mdump_path.unlink()
        self.assertFalse(new_mdump_path.exists())
        
        experiment_manager = ExperimentManagerBase(
            sub=SUB, ses=SES, run=RUN, root=ROOT
        )
        
        paths = []
        with self.assertRaises(FileExistsError):
            for n in range(11):
                fname = f"{experiment_manager.exp_dat_mandump_fname[:-4]}_{n:02}.csv"
                mdump_path_ = Path(
                    experiment_manager.root /
                    fname
                )
                mdump_path_.touch()
                paths.append(mdump_path_)
                
            experiment_manager._update_manager_dump()
        
        for path in paths:
            path.unlink()
        
        mdump_path.unlink()
        self.assertFalse(mdump_path.exists())
        
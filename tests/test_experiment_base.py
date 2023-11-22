import unittest
from pathlib import Path

import pandas as pd

from experiment_manager_base import ExperimentManagerBase

SUB = 42
SES = 42
RUN = 42

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

        experiment_manager.set_trial_progress(len(experiment_manager))
        self.assertTrue(experiment_manager.end_of_experiment_flag)

        with self.assertRaises(RuntimeError):
            experiment_manager.increment_trial_progress()

        with self.assertRaises(TypeError):
            experiment_manager.set_trial_progress(1.1)

        with self.assertRaises(ValueError):
            experiment_manager.set_trial_progress(len(experiment_manager) + 1)

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

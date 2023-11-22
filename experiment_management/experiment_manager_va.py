from __future__ import annotations
from itertools import product
import time

from numpy import random
import pandas as pd

from .experiment_manager_base import ExperimentManagerBase
from . import experiment_va_settings as evas

from psychopy import core


class VisualAttentionExperimentManager(ExperimentManagerBase):
    def _make_and_save_experiment_data(self) -> pd.DataFrame:
        # Experiment-specific subroutine that overwrites the
        # ExperimentManagerBase._make_and_save_experiment_data method
        stimuli = evas.STIMULI
        tasks = evas.TASKS
        target_congruence = evas.TASK_CONGRUENCE
        repetitions = evas.REPETITIONS
        blocks = evas.BLOCKS

        # Create all unique combinations of stimuli, tasks, and target_congruence.
        # NOTE: combinations are contained in a tuple, making this a list of
        # tuples each with length 3.
        combinations = list(product(stimuli, tasks, target_congruence))

        # Count the number of unique combinations
        n_combinations = len(combinations)

        # Create a variable to index unique combinations a number of
        # time specified by the number of within-block `repetitions`.
        within_block_combination_indices = list(range(n_combinations)) * repetitions

        # Count number of trials in a block, given unique
        # combinations and repetitions within block
        trials_in_block = n_combinations * repetitions

        # Count total number of trials in experiment
        total_trials = blocks * trials_in_block

        # Make list of trials
        # NOTE: These are 0-indexed
        trial_numbers = list(range(total_trials))

        # Prepare a list to contain conditions of each trial
        conditions_ = [None] * total_trials

        # Prepare a list of block number for each trial
        block_numbers = []

        # Iterate over blocks
        for b in range(blocks):
            # Add block number to the number of trials within block
            block_numbers += [b] * trials_in_block

            # Randomly select the order of trial combinations
            indices_ = random.choice(
                within_block_combination_indices, trials_in_block, replace=False
            )

            # Use the randomised indeces to set the randomised condtions
            # for the given block
            conditions_[b * trials_in_block : (b + 1) * trials_in_block] = [
                combinations[i] for i in indices_
            ]

        # Unpack the combination contents into stimuli, tasks, and congruence
        stimulus_conditions = [c[0] for c in conditions_]
        tasks = [c[1] for c in conditions_]
        task_congruences = [c[2] for c in conditions_]

        # Prepare empty list of responses
        responses = [None] * total_trials

        # Prepare empty list of reaction times
        reaction_times = [None] * total_trials

        # Prepare empty list of `completed` flags
        completed = [0] * total_trials

        # Create the experiment data table as DataFrame
        experiment_data = pd.DataFrame.from_dict(
            {
                "trial_number": trial_numbers,
                "block_number": block_numbers,
                "stimulus_condition": stimulus_conditions,
                "task": tasks,
                "task_congruence": task_congruences,
                "response": responses,
                "reaction_time": reaction_times,
                "completed": completed,
            }
        )
        return experiment_data

    def _set_trial_response(self, trial_number: int, response, reaction_time) -> None:
        """Set the response of a given trial

        Args:
            trial_number (int): Trial number to set response for.
            response (_type_): Reponse value.
            reaction_time (_type_): Reaction time.
        """

        self.experiment_data.at[trial_number, "response"] = response
        self.experiment_data.at[trial_number, "reaction_time"] = reaction_time

    def execute_current_trial(
        self,
        grating_side: str,
        grating_congruence: bool,
        stimulus: str,
        instruction_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        if instruction_duration is None:
            instruction_duration = evas.INSTRUCTION_DURATION
        if fixation_duration_range is None:
            fixation_duration_range = evas.FIXATION_DURATION_RANGE
        if response_timeout is None:
            response_timeout = evas.RESPONSE_TIMEOUT
            
        msg = evas.text_stim(evas.WINDOW, text=f"Attend to the {grating_side} light")
        msg.draw()
        evas.WINDOW.flip()
        core.wait(instruction_duration)

        # Fixation point
        evas.FIXATION_GRATING.ori = evas.GRATING_ORIENTATION_MAP[grating_side]
        evas.FIXATION_GRATING.draw()
        evas.WINDOW.flip()
        
        # Stimulus
        # ledc_left.set_stimuli(stimulus)
        # ledc_right.set_stimuli(stimulus)

        core.wait(random.uniform(*fixation_duration_range))

        evas.FIXATION_GRATING.draw()
        evas.DETECTION_GRATING.pos = evas.GRATING_POSITION_MAP[grating_side]
        if grating_congruence:
            detection_grating_orientation = evas.FIXATION_GRATING.ori
        else:
            detection_grating_orientation = evas.FIXATION_GRATING.ori * -1

        evas.DETECTION_GRATING.ori = detection_grating_orientation
        evas.DETECTION_GRATING.draw()
        evas.WINDOW.flip()

        correct_key = evas.RESPONSE_KEYS[grating_congruence]

        evas.KEYBOARD.getKeys()
        return _get_response_and_reaction_time(correct_key, response_timeout)

    def run_experiment(self,
        instruction_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        if self.experiment_data is None:
            error_msg = f"Please set `experiment_data` before running experiment"
            raise RuntimeError(error_msg)
        
        if instruction_duration is None:
            instruction_duration = evas.INSTRUCTION_DURATION
        if fixation_duration_range is None:
            fixation_duration_range = evas.FIXATION_DURATION_RANGE
        if response_timeout is None:
            response_timeout = evas.RESPONSE_TIMEOUT
            
        for _ in range(len(self) - self.trial_progress):
            current_trial = self.get_current_trial_data()
            attention_side = current_trial.task
            stimulus = current_trial.stimulus_condition
            task_congruence = current_trial.task_congruence
            response, reaction_time = self.execute_current_trial(
                grating_side=attention_side,
                grating_congruence=task_congruence,
                stimulus=stimulus,
                instruction_duration=instruction_duration,
                fixation_duration_range=fixation_duration_range,
                response_timeout=response_timeout
            )
            self.set_current_trial_response(
                response=response, reaction_time=reaction_time
            )
            self.increment_trial_progress()
            self.save_experiment_data()
            
        
        


def _get_response_and_reaction_time(target_key, timeout=5) -> tuple[int, float]:
    """Evaluate keyboard input and reaction time

    Args:
        target_key (_type_): Target key press.
        timeout (int, optional): How long to wait for input. Defaults to 5.

    Returns:
        tuple[bool, float]: Tuple of (response, reaction_time) where response
            indicates a correct (`1`) or incorrect (`0`) key press, w.r.t. `target_key`,
            and reaction time [s] is the delay of response. If no response is given within
            `timeout`, (-1, `timeout`) is returned.
    """
    t_start = time.time()
    while 1:
        rt = time.time() - t_start
        if rt > timeout:
            return -1, timeout

        keys = evas.KEYBOARD.getKeys()
        if len(keys) > 0:
            for key_ in keys:
                k = key_
                if k == target_key:
                    return 1, rt
                elif k == "q":
                    evas.WINDOW.close()
                    exit()
                else:
                    return 0, rt

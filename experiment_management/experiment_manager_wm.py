from __future__ import annotations
from itertools import product
from pathlib import Path
import json

from numpy import random
from pandas import DataFrame

from .experiment_manager_base import ExperimentManagerBase
from . import experiment_wm_settings as ewms


class WorkingMemoryExperimentManager(ExperimentManagerBase):
    def __init__(
        self,
        sub: int | str,
        ses: int | str,
        run: int | str,
        experiment_data: DataFrame | None = None,
        trial_progress: int = 0,
        root: str | Path | None = None,
    ) -> None:
        super().__init__(sub, ses, run, experiment_data, trial_progress, root)

        # Load the trigger values
        trigger_map_file = Path(__file__).parent / "trigger_map_wm.json"
        with open(trigger_map_file) as json_file:
            self.trigger_map = json.load(json_file)

    def prepare_psychopy(self) -> None:
        """Prepare the psychopy dependencies

        Psychopy runs some unwanted code at import
        which we would like to avoid, so we move the
        imports to runtime, requiring this function to
        be run prior to running experiment.
        """

        # Import the dependencies shared by experiments
        self._prepare_psychopy()

        self.psychopy_ready = True

    def _make_and_save_experiment_data(self) -> DataFrame:
        # Experiment-specific subroutine that overwrites the
        # ExperimentManagerBase._make_and_save_experiment_data method
        stimuli = ewms.STIMULI
        task_difficulty = ewms.TASK_DIFFICULTY
        repetitions = ewms.REPETITIONS
        blocks = ewms.BLOCKS
        presented_sum_correctness_ = ewms.PRESENTED_SUM_CORRECTNESS

        # Create all unique combinations of stimuli, tasks, and target_congruence.
        # NOTE: combinations are contained in a tuple, making this a list of
        # tuples each with length 3.
        combinations = list(
            product(stimuli, task_difficulty, presented_sum_correctness_)
        )

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
        task_difficulties = [c[1] for c in conditions_]
        presented_sum_correctness = [c[2] for c in conditions_]

        # Prepare empty list of responses
        responses = [None] * total_trials

        # Prepare empty list of reaction times
        reaction_times = [None] * total_trials

        # Prepare empty list of `completed` flags
        completed = [0] * total_trials

        # Create the experiment data table as DataFrame
        experiment_data = DataFrame.from_dict(
            {
                "trial_number": trial_numbers,
                "block_number": block_numbers,
                "stimulus_condition": stimulus_conditions,
                "task_difficulty": task_difficulties,
                "presented_sum_correctness": presented_sum_correctness,
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
        stimulus: str,
        task_difficulty: str,
        presented_sum_correctness: bool,
        pre_fixation_duration: float | None = None,
        wm_task_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        # Check that all dependencies are available
        # at runtime
        self._check_dependencies_ready()

        # Check which input parameters where given,
        # and set None values to defaults
        (
            pre_fixation_duration,
            wm_task_duration,
            fixation_duration_range,
            response_timeout,
        ) = self._check_experiment_duration_args(
            pre_fixation_duration,
            wm_task_duration,
            fixation_duration_range,
            response_timeout,
        )
        
        # Look up the difficulty of the arithmetic task
        # and sample two corresponding integers.
        # At this point sample also an offset in a
        # suitible range compared to the sum
        if task_difficulty == "low":
            values = random.randint(low=1, high=9, size=2)
            offset = random.randint(low=1, high=2)
        elif task_difficulty == "high":
            values = random.randint(low=100, high=400, size=2)
            offset = random.randint(low=10, high=20)

        # Calculate their true sum
        true_sum = values[0] + values[1]

        # Define the presented sum with or without
        # the addition of the offset
        if presented_sum_correctness:
            presented_sum = true_sum
        else:
            presented_sum = true_sum + offset * random.choice((-1, 1))

        # Fixation point
        self.fixation_mark.draw()
        self.window.mouseVisible = False
        self.window.flip()
        self.trigger.send_trigger(self.trigger_map["rest"])
        self.core.wait(wm_task_duration)

        # Light Stimulus turns on
        self.lc_left.display_preset(self.stimulation_map[stimulus])
        self.lc_right.display_preset(self.stimulation_map[stimulus])
        self.lc_left.turn_on()
        self.lc_right.turn_on()
        self.trigger.send_trigger(self.trigger_map["start-of-trial"])
        self.core.wait(pre_fixation_duration)
        
        # Present the sum
        msg = self.text_stim(
            self.window,
            text=f" {values[0]}\n+{values[1]}",
            languageStyle="RTL",
            height=100,
        )
        msg.draw()
        self.window.mouseVisible = False
        self.window.flip()
        self.trigger.send_trigger(self.trigger_map["sum"])
        self.core.wait(wm_task_duration)

        # Fixation point
        self.fixation_mark.draw()
        self.window.mouseVisible = False
        self.window.flip()
        self.trigger.send_trigger(self.trigger_map["fixation-wait"])
        self.core.wait(random.uniform(*fixation_duration_range))
        # core.wait(instruction_duration)
        
        # Present the result (correct or not)
        msg = self.text_stim(self.window, text=f"{presented_sum}", height=100)
        msg.draw()
        self.trigger.send_trigger(self.trigger_map["result"])
        self.window.mouseVisible = False
        self.window.flip()

        # Read the response and reaction time
        reponse, rt = self._get_response_and_reaction_time(
            self.keyboard, self.window, response_timeout
        )
        self.trigger.send_trigger(self.trigger_map["response"])
        
        self.lc_right.display_preset(self.stimulation_map["con"])
        self.lc_left.display_preset(self.stimulation_map["con"])
        return reponse, rt

    def run_experiment(
        self,
        pre_fixation_duration: float | None = None,
        wm_task_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        # Check if experiment data has been created or loaded
        if self.experiment_data is None:
            error_msg = f"Please set `experiment_data` before running experiment"
            raise RuntimeError(error_msg)

        # Check which input parameters where given,
        # and set None values to defaults
        (
            pre_fixation_duration,
            wm_task_duration,
            fixation_duration_range,
            response_timeout,
        ) = self._check_experiment_duration_args(
            pre_fixation_duration,
            wm_task_duration,
            fixation_duration_range,
            response_timeout,
        )

        self.prepare_psychopy()
        self.prepare_led_controllers()
        self.trigger.prepare_trigger()
        # Send a trigger for the start of the experiment
        self.show_start_screen()
        self.trigger.send_trigger(self.trigger_map["initial-trigger"])

        for _ in range(len(self) - self.trial_progress):
            current_trial = self.get_current_trial_data()
            stimulus = current_trial.stimulus_condition
            task_difficulty = current_trial.task_difficulty
            presented_sum_correctness = current_trial.presented_sum_correctness
            response, reaction_time = self.execute_current_trial(
                presented_sum_correctness=presented_sum_correctness,
                stimulus=stimulus,
                task_difficulty=task_difficulty,
                wm_task_duration=wm_task_duration,
                fixation_duration_range=fixation_duration_range,
                response_timeout=response_timeout,
            )
            self.set_current_trial_response(
                response=response, reaction_time=reaction_time
            )
            self.increment_trial_progress()
            self.save_experiment_data()

        self.trigger.send_trigger(self.trigger_map["final-trigger"])

    def _check_experiment_duration_args(
        self,
        pre_fixation_duration: float | None = None,
        wm_task_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        # Check which input parameters where given,
        # and set None values to defaults
        
        if pre_fixation_duration is None:
            pre_fixation_duration = ewms.PRE_FIXATION_DURATION
        if wm_task_duration is None:
            wm_task_duration = ewms.WM_TASK_DURATION
        if fixation_duration_range is None:
            fixation_duration_range = ewms.FIXATION_DURATION_RANGE
        if response_timeout is None:
            response_timeout = ewms.RESPONSE_TIMEOUT

        return (
            pre_fixation_duration,
            wm_task_duration,
            fixation_duration_range,
            response_timeout,
        )

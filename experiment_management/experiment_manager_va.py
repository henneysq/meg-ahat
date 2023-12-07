from __future__ import annotations
from itertools import product
from pathlib import Path
import json

from numpy import random
from pandas import DataFrame

from .experiment_manager_base import ExperimentManagerBase
from . import experiment_va_settings as evas

ATT_SIDE_INSTRUCTION_MAP = {
    "left": "<- <- <-",
    "right": "-> -> ->"
}

class VisualAttentionExperimentManager(ExperimentManagerBase):
    def __init__(self, sub: int | str, ses: int | str, run: int | str, experiment_data: DataFrame | None = None, trial_progress: int = 0, root: str | Path | None = None) -> None:
        super().__init__(sub, ses, run, experiment_data, trial_progress, root)
        
        # Load the trigger values
        trigger_map_file = Path(__file__).parent / "trigger_map_va.json"
        with open(trigger_map_file) as json_file:
            self.trigger_map = json.load(json_file)
            

    def prepare_psychopy(self) -> None:
        """Prepare the psychopy dependencies
        
        Psychopy runs some unwanted code at import
        which we would like to avoid, so we move the
        imports to runtime, requiring this function to
        be run prior to running experiment.
        """
        from psychopy.visual import grating
        
        # Import the dependencies shared by experiments
        self._prepare_psychopy()
            
        self.fixation_grating = grating.GratingStim(
            self.window, tex="sin", mask="gauss", units="pix", contrast=1, sf=0.05, size=300
        )
        self.detection_grating = grating.GratingStim(
            self.window, tex="sin", mask="gauss", units="pix", contrast=1, sf=0.05, size=300
        )
        
        self.psychopy_ready = True
        
    def _make_and_save_experiment_data(self) -> DataFrame:
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
        experiment_data = DataFrame.from_dict(
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
        if not self.psychopy_ready:
            raise RuntimeError("Please use `prepare_psychopy` before running " + \
                "a trial")
            
        if instruction_duration is None:
            instruction_duration = evas.INSTRUCTION_DURATION
        if fixation_duration_range is None:
            fixation_duration_range = evas.FIXATION_DURATION_RANGE
        if response_timeout is None:
            response_timeout = evas.RESPONSE_TIMEOUT

        msg = self.text_stim(self.window, text=ATT_SIDE_INSTRUCTION_MAP[grating_side])
        msg.draw()
        self.window.flip()
        self.core.wait(instruction_duration)

        # Fixation point
        self.fixation_grating.ori = evas.GRATING_ORIENTATION_MAP[grating_side]
        self.fixation_grating.draw()
        self.window.flip()

        # Stimulus
        # ledc_left.set_stimuli(stimulus)
        # ledc_right.set_stimuli(stimulus)

        self.core.wait(random.uniform(*fixation_duration_range))

        self.fixation_grating.draw()
        self.detection_grating.pos = evas.GRATING_POSITION_MAP[grating_side]
        if grating_congruence:
            detection_grating_orientation = self.fixation_grating.ori
        else:
            detection_grating_orientation = self.fixation_grating.ori * -1

        self.detection_grating.ori = detection_grating_orientation
        self.detection_grating.draw()
        self.window.flip()

        correct_key = evas.RESPONSE_KEYS[grating_congruence]

        self.keyboard.getKeys()
        return self._get_response_and_reaction_time(
            self.keyboard, self.window, correct_key, response_timeout
        )

    def run_experiment(
        self,
        instruction_duration: float | None = None,
        fixation_duration_range: tuple[float, float] | None = None,
        response_timeout: float | None = None,
    ):
        if self.experiment_data is None:
            error_msg = f"Please set `experiment_data` before running experiment"
            raise RuntimeError(error_msg)
        
        self.prepare_psychopy()
        self.trigger.prepare_trigger()
        # Send a trigger for the start of the experiment
        self.trigger.send_trigger(
            self.trigger_map["initial-trigger"]
        )

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
                response_timeout=response_timeout,
            )
            self.set_current_trial_response(
                response=response, reaction_time=reaction_time
            )
            self.increment_trial_progress()
            self.save_experiment_data()

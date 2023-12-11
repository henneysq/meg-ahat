from __future__ import annotations
from pathlib import Path
from typing import Final

import pandas as pd
from numpy import random

from .experiment_trigger import ExperimentTrigger
from .dondersLEDController import DondersLEDController

class ExperimentManagerBase:
    """Base class for experiment management

    Intended to be inherited by a child class for a given experiment
    to manage experiment specific variables.

    See `ExperimentOneManager` class

    """
    
    SERIAL_DEVICES: Final[tuple[str]] = ("FT32TWG5", "FT51RDMI")

    stimulation_map = {
        "con":3,
        "isf": 2,
        "strobe": 1
    }

    def __init__(
        self,
        sub: int | str,
        ses: int | str,
        run: int | str,
        experiment_data: pd.DataFrame | None = None,
        trial_progress: int = 0,
        root: str | Path | None = None,
    ) -> None:
        """Initialise class

        Args:
            sub (int | str): Subject number.
            ses (int | str): Session number.
            run (int | str): Run number
            experiment_data (pd.DataFrame | None, optional): Experiment data describing
                each trial and its conditions across an experiment. Can be loaded or
                created after initialisation. Defaults to None.
            trial_progress (int, optional): State of the experiment (i.e. the trial
                number). This is incremented with progression, but can be set at initialisation
                or later. Defaults to 0.
        """
        self.__sub = int(sub)
        self.__ses = int(ses)
        self.__run = int(run)
        self.__trial_progress: int = trial_progress
        self.experiment_data = experiment_data

        self.__root = root

        # Create a BIDS-like string for the run
        self.__bids_kv_pair_str = (
            f"sub-{self.sub:03}_ses-{self.ses:03}_run-{self.run_:03}"
        )
        
        # Set initial flags for experiment control
        # at runtime
        self.end_of_experiment_flag = False
        self.psychopy_ready = False
        self.led_controllers_ready = False
        
        # Define trigger
        self.trigger = ExperimentTrigger()
        
        # Define LED controllers
        self.lc_left = DondersLEDController(port=self.SERIAL_DEVICES[0])
        self.lc_right = DondersLEDController(port=self.SERIAL_DEVICES[1])

    @property
    def sub(self):
        return self.__sub

    @property
    def ses(self):
        return self.__ses

    @property
    def run_(self):
        return self.__run

    @property
    def trial_progress(self):
        return self.__trial_progress

    @property
    def bids_kv_pair_str(self):
        return self.__bids_kv_pair_str

    @property
    def root(self):
        return self.__root

    def make_and_save_experiment_data(
        self,
        # repetitions: int = 1,
        # target_congruence: any = (1, 0),
        root: str | Path | None = None,
        rng_seed: int = None,
        overwrite: bool = False,
        return_df: bool = False,
        **kwargs,
    ) -> None | pd.DataFrame:
        """Creates and saves randomised experiment data

        Will create a `pd.DataFrame` with experiment data describing
        each trial and its conditions across an experiment. The conditions
        are randomised using the specified `seed`. If no seed is specified,
        the unique combination of subject, session, and run numbers is hashed
        to create a unique seed.

        The created dataframe is also outputted to a .csv file in the provided
        root directory with the a BIDS-like name and '_experimentdata' suffix.

        NOTE: This method does *NOT* set the self.experiment_data value. That
        is done explicitly afterwards.



        Args:
            root (str | Path | None): Directory to store the experiment data in.
                Must be specified if not `root` was specified at instantiation.
            blocks (int): Number of blocks in experiment.
            stimuli (any): Names of the stimuli in the experiment.
            tasks (any): Names of tasks performed in the experiment.
            rng_seed (int, optional): Seed for randomisation. If no seed is
                specified, the unique combination of subject-, session-, and run-
                numbers is hashed to create a unique seed. Defaults to None.
            overwrite (bool, optional): Whether or not to overwrite
                experiment data. Defaults to False.

        Returns:
            None | pd.DataFrame: Returns the experiment_data as a dataframe
                only if return_df = True.

        Raises:
            FileExistsError: If overwrite is attemped with `overwrite=False`.
        """

        # Check if root is given now or at instantiation
        root = self._check_root(root)

        # Specify path to outputted experiment data file
        file_path = Path(root / f"{self.bids_kv_pair_str}_experimentdata.csv")

        # If no seed is provided, hash the unique experiment metadata
        if rng_seed is None:
            seed_str = self.bids_kv_pair_str
            rng_seed = abs(hash(seed_str)) % (10**8)
        random.default_rng(seed=rng_seed)

        # Create the table of experimental conditions for the
        # specific experiment.
        # NOTE: As the table varies between experiments, this
        # private method is a dead-end for the `ExperimentManagerBase` class
        # and is intended to be overwritten by experiment-specific child classes.
        experiment_data = self._make_and_save_experiment_data(**kwargs)

        # Save the experiment data, making sure not to
        # overwrite unintendedly
        root.mkdir(exist_ok=True)
        if file_path.exists():
            if not overwrite:
                raise FileExistsError
        experiment_data.to_csv(file_path, index=False)

        # Update the instance root if none was specified previously.
        if self.root is None:
            self.__root = root

        # Return the experiment data only if specified
        if return_df:
            return experiment_data

    def _make_and_save_experiment_data(self, *args, **kwargs) -> None:
        # To be overwritten by child class specific to the experiment
        error_msg = (
            f"The {type(self)} class does not implement this function. "
            + "It should be overwritten by experiment specific child classes."
        )
        raise NotImplementedError(error_msg)

    def load_experiment_data(self, root: str | Path | None = None) -> None:
        """Load the experiment data from file

        Based on the BIDS meta provided at instantiation,
        the experiment data is loaded from the .csv file in
        the root directory.

        Args:
            root (str | Path | None): Directory to store the experiment data in.
                Must be specified if not `root` was specified at instantiation.
        """

        # Check if root is given now or at instantiation
        root = self._check_root(root)

        file_path = Path(root / f"{self.bids_kv_pair_str}_experimentdata.csv")
        self.experiment_data = pd.read_csv(file_path)

        if self.root is None:
            self.__root = root

    def save_experiment_data(self, root: str | Path | None = None) -> None:
        """Save experiment data with updated progress.

        The experiment data is saved to disk with updates made
        throughout the experiment so far.

        A suffix '_managerdump' is added to the .csv file to
        avoid overwriting the prespecification file.

        Args:
            root (str | Path | None, optional): Destination directory.
                If none is provided, the root specified at instantiation
                is used. Defaults to None.
        """

        # Check if root is given now or at instantiation
        root = self._check_root(root)
        file_path = Path(
            root / f"{self.bids_kv_pair_str}_experimentdata_managerdump.csv"
        )

        # Save the experiment data to csv
        self.experiment_data.to_csv(file_path, index=False)

    def set_trial_progress(self, trial_progress: int) -> None:
        """Set trial progress (i.e. trial number)

        Modifies the instance property `trial_progress` which
        keeps books for the progress of the experiment.

        This may be handy, if the experiment is disrupted.


        Args:
            trial_progress (int): The trial progress (i.e. trial number)
        """

        arg_error_msg = "Trial progress must be non-negative integer"
        if not isinstance(trial_progress, int):
            raise TypeError(arg_error_msg)

        if trial_progress < 0:
            raise ValueError(arg_error_msg)

        if trial_progress > self.__len__():
            error_msg = (
                f"Got value `trial_progress` of {trial_progress}, which"
                + f" or exceeds that length of the experiment, {self.__len__()}"
            )
            raise ValueError(error_msg)

        self.__trial_progress = trial_progress

        # Check whether the end of the experiment is reached,
        # and return flag for the status
        self._check_end_of_trial()

    def _check_end_of_trial(self) -> None:
        # Check whether the end of the experiment is reached
        self.end_of_experiment_flag = self.__trial_progress >= self.__len__()

        if self.__trial_progress > self.__len__():
            raise RuntimeError(
                "Trial progress overshoot:\n"
                + f"Trial progress reached {self.__trial_progress}, which is beyond "
                + f"the experiment length of {self.__len__()}"
            )

    def increment_trial_progress(self) -> None:
        """Increment trial progress (i.e. trial number)

        Increament the trial progress (i.e. trial number) and keep
        books on the `experiment_data` by setting the 'completed'
        variable for that trial to 1.

        Also checks whether the end of the experiment has been reached,
        indicated by the flag returned.

        Returns:
            bool: Flag that indicates whether the end of the experiment
                has been reached.
        """

        # Set current trial to completed in the experiment data
        self.experiment_data.at[self.trial_progress, "completed"] = 1

        if self.end_of_experiment_flag:
            raise RuntimeError(
                "Can not increment trial progress as "
                + f"trial progress {self.__trial_progress} reached the length "
                + f"of the experiment {self.__len__()}."
            )

        # Check if end of a block is reached
        if self._check_end_of_block():
            self.show_pause_screen()
            self.show_start_screen()
            
        # Increment trial progress number
        self.__trial_progress += 1

        # Check whether the end of the experiment is reached,
        # and return flag for the status
        self._check_end_of_trial()
        

    def get_current_trial_data(self) -> pd.Series:
        """Get the conditions for the current trial

        Returns:
            pd.Series: conditions for the current trial.
        """
        return self.get_trial_data(self.trial_progress)

    def get_trial_data(self, trial_number: int | slice) -> pd.Series:
        """Get the conditions for a given trial

        Args:
            trial_number (int | slice): Number of the requested trial.

        Returns:
            pd.Series: conditions for a given trial.
        """
        return self.experiment_data.iloc[trial_number]

    def set_trial_response(self, trial_number: int, **kwargs) -> None:
        """Set the response of a given trial

        Args:
            trial_number (int): Trial number to set response for
        """

        self._set_trial_response(trial_number, **kwargs)

    def _set_trial_response(self, *args, **kwargs) -> None:
        # To be overwritten by child class specific to the experiment
        error_msg = (
            f"The {type(self)} class does not implement this function. "
            + "It should be overwritten by experiment specific child classes."
        )
        raise NotImplementedError(error_msg)

    def set_current_trial_response(self, **kwargs) -> None:
        """Set the response of current trial

        Args:
            trial_number (int): Trial number to set response for
        """
        self.set_trial_response(self.trial_progress, **kwargs)

    def _check_root(self, root: str | Path) -> str | Path:
        if root is None:
            if self.root is None:
                raise ValueError(
                    f"If not `root` was specified at instantiation, root can not be `None`."
                )
            root = self.root
        return root

    def _get_response_and_reaction_time(
        self, keyboard, window, timeout=5
    ) -> tuple[int, float]:
        """Evaluate keyboard input and reaction time

        Args:
            timeout (int, optional): How long to wait for input. Defaults to 5.

        Returns:
            tuple[bool, float]: Tuple of (response, reaction_time) where response
                indicates a correct (`1`) or incorrect (`0`) key press, w.r.t. `target_key`,
                and reaction time [s] is the delay of response. If no response is given within
                `timeout`, (-1, `timeout`) is returned.
        """
        self.timer.reset()
        keyboard.clock.reset()
        
        # Wait for keyboard or button box (FORP) input
        while 1:
            # Set timestamp
            t = self.timer.getTime()
            # Read the keyboard buffer
            key_response = keyboard.getKeys()
            # Read the BITSI buffer
            forp_response = self.trigger.read_response()
            
            # BITSI returns 0 while empty; check that
            # the response is not 0
            if forp_response != 0:
                # Return the timestamp and response
                return forp_response, t
            
            # The keyboard buffer returns and
            # empty iterable when empty; check if contains anything
            # it contains any
            elif len(key_response) > 0:
                key_ = key_response[0]
                if key_.value == "q":
                    window.close()
                    exit()
                return key_.value, key_.rt
            
            # Check if we have superceded the timout durations
            if t > timeout:
                return -1, -1
                        
    def _prepare_psychopy(self):
        """Prepare the psychopy dependencies
        
        Psychopy runs some unwanted code at import
        which we would like to avoid, so we move the
        imports to runtime, requiring this function to
        be run prior to running experiment.
        
        The child classes add additional needed features
        to the public function and refers to this
        function for shared dependencies.
        """
        from psychopy.hardware import keyboard
        from psychopy.visual import Window, TextStim
        from psychopy import core
        
        self.core = core
        self.timer = self.core.Clock()
        self.text_stim = TextStim
        self.window = Window(size=(1920, 1200), fullscr=True, units="pix")
        self.keyboard = keyboard.Keyboard()
        self.fixation_mark = TextStim(self.window, text=f"+", height=100)

    def prepare_led_controllers(self):
        self.lc_left.connect_and_restore_defaults()
        self.lc_right.connect_and_restore_defaults()
        
        # Check that the sides were allocated to
        # the corect variable; otherwise switch them
        if self.lc_left.device_side == "left":
            if not self.lc_right.device_side == "right":
                raise ConnectionError("Devices are same side")
        else:
            self.lc_left, self.lc_right = self.lc_right, self.lc_left
            
        self.led_controllers_ready = True
        
    def prepare_psychopy(self):
        self._prepare_psychopy()
        self.psychopy_ready = True

    def _check_dependencies_ready(self):
        if all((
            self.psychopy_ready,
            self.trigger.trigger_ready,
            self.led_controllers_ready
        )):
            return
        
        error_msg = f"""
        Not all dependencies were ready at runtime:
        `self.psychopy_ready`: {self.psychopy_ready},
        `self.trigger.trigger_ready`: {self.trigger.trigger_ready},
        `self.led_controllers_ready`: {self.led_controllers_ready}
        """
        raise RuntimeError(error_msg)
        
    def _check_end_of_block(self):
        current_block = self.experiment_data.at[self.trial_progress, "block_number"]
        next_block = self.experiment_data.at[self.trial_progress + 1, "block_number"]
        
        return current_block != next_block

    def show_pause_screen(self):
        self.window.flip()
        self.core.wait(2)
        
        current_block = self.experiment_data.at[self.trial_progress, "block_number"]
        total_blocks = self.experiment_data.at[len(self) - 1, 'block_number'] + 1
        print(current_block)
        msg = self.text_stim(
            self.window,
            text=f"Completed block number: {current_block + 1}" + \
                f" of {total_blocks}",
            height=50
        )
        msg.draw()
        self.window.flip()
        self.core.wait(2)
        
    def show_start_screen(self, timeout: int = 60*10):
        msg = self.text_stim(self.window, text="Press any button to continue", height=50)
        msg.draw()
        self.window.flip()
        
        response, _ = self._get_response_and_reaction_time(self.keyboard, self.window, timeout)
        if response == -1:
            raise TimeoutError("Took too long to respond, exiting.")

        self.window.flip()
        self.core.wait(1)
        msg = self.text_stim(self.window, text="Starting", height=50)
        msg.draw()
        self.window.flip()
        self.core.wait(2)
    
    def __len__(self) -> int:
        return self.experiment_data.__len__()

    def __del__(self):
        if self.psychopy_ready:
            self.window.close()

# %%
from __future__ import annotations
import time
from pathlib import Path

import numpy as np
from psychopy import visual, core
from psychopy.hardware import keyboard

from experiment_manager import VisualAttentionExperimentManager

# Experiment variables
SUB = 42
SES = 1

RUN = 1
BLOCKS = 1
STIMULI = ("con",)  # , "isf")  # , "strobe")
TASKS = ("left", "right")
# OBS: With representation of both congruent and incongruent tasks for
# each stimulus/attenention pair, the number of repetitions is always a
# factor two higher than this int
REPETITIONS = 1
TASK_CONGRUENCE = (1, 0)

# Setup data manager
data_path = Path(__file__).parent / "data"
experiment_manager = VisualAttentionExperimentManager(sub=SUB, ses=SES, run=RUN)
experiment_manager.make_and_save_experiment_data(
    root=data_path,
    blocks=BLOCKS,
    stimuli=STIMULI,
    tasks=TASKS,
    repetitions=REPETITIONS,
    target_congruence=TASK_CONGRUENCE,
    overwrite=True,
)
experiment_manager.load_experiment_data(root=data_path)

# Experiment constants
# No need to touch
WINDOW = visual.Window([1024, 768], fullscr=False, units="pix")
FIXATION_GRATING = visual.GratingStim(
    WINDOW, tex="sin", mask="gauss", units="pix", contrast=1, sf=0.05, size=100
)
DETECTION_GRATING = visual.GratingStim(
    WINDOW, tex="sin", mask="gauss", units="pix", contrast=0.25, sf=0.05, size=100
)
GRATING_POS_LEFT = (-400, -300)
GRATING_POS_RIGHT = (400, -300)
# GRATING_ORIENTATION_NEGATIVE_PHASE = -45
# GRATING_ORIENTATION_POSITIVE_PHASE = 45
GRATION_ORIENTATIONS = (45, -45)
GRATING_POSITION_MAP = {"left": GRATING_POS_LEFT, "right": GRATING_POS_RIGHT}
GRATING_ORIENTATION_MAP = {
    "left": GRATION_ORIENTATIONS[0],
    "right": GRATION_ORIENTATIONS[1],
}


# fixation = visual.Circle(WINDOW, size = 5, lineColor = 'white', fillColor = 'lightGrey')
# msg = visual.TextStim(win, text="PRESS SPACE")
KEYBOARD = keyboard.Keyboard()
SIDES = ("left", "right")
RESPONSE_KEYS = ("down", "up")  # first is incongruent, second is congruent

# hit_strs = ("MISS!", "HIT!")


def execute_experiment_one_trial(
    grating_side: str, grating_congruence: bool, stimulus: str
):
    # pos_side = np.random.choice(SIDES)
    # phase_side= np.random.choice(SIDES)
    msg = visual.TextStim(WINDOW, text=f"Attend to the {grating_side} light")
    msg.draw()
    WINDOW.flip()
    core.wait(1)

    # Fixation point
    FIXATION_GRATING.ori = GRATING_ORIENTATION_MAP[grating_side]
    FIXATION_GRATING.draw()
    WINDOW.flip()
    core.wait(1)

    # ledc_left.set_stimuli(1)
    # ledc_right.set_stimuli(2)
    core.wait(np.random.uniform(6, 8))
    # text = hit_strs[hit] + f" - Reaction time: {rt:0.2f} seconds" if rt is not None else "Timed out"

    # text_msg = visual.TextStim(win, text=text)
    # text_msg.draw()
    # win.flip()
    FIXATION_GRATING.draw()
    DETECTION_GRATING.pos = GRATING_POSITION_MAP[grating_side]
    if grating_congruence:
        detection_grating_orientation = FIXATION_GRATING.ori
    else:
        detection_grating_orientation = FIXATION_GRATING.ori * -1

    DETECTION_GRATING.ori = detection_grating_orientation
    DETECTION_GRATING.draw()
    WINDOW.flip()

    correct_key = RESPONSE_KEYS[grating_congruence]

    KEYBOARD.getKeys()
    return _get_response_and_reaction_time(KEYBOARD, correct_key, timeout=1.75)


def _get_response_and_reaction_time(
    kb: keyboard.Keyboard, target_key: str, timeout: int = 5
) -> float | None:
    t_start = time.time()
    while 1:
        rt = time.time() - t_start
        if rt > timeout:
            return 0, timeout

        keys = kb.getKeys()
        if len(keys) > 0:
            for key_ in keys:
                k = key_
                if k == target_key:
                    return 1, rt
                elif k == "q":
                    WINDOW.close()
                    exit()
                else:
                    return 0, rt


# run some trials
while True:
    try:
        current_trial = experiment_manager.get_current_trial_data()
        attention_side = current_trial.task
        stimulus = current_trial.stimulus_condition
        task_congruence = current_trial.task_congruence
        response, reaction_time = execute_experiment_one_trial(
            grating_side=attention_side,
            grating_congruence=task_congruence,
            stimulus=stimulus,
        )

        experiment_manager.set_current_trial_response(response, reaction_time)
        end_of_experiment_flag = experiment_manager.increment_trial_progress()
        experiment_manager.save_experiment_data()

        if end_of_experiment_flag:
            break

    except KeyboardInterrupt:
        break
WINDOW.close()

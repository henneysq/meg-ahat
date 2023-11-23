from psychopy.visual import Window, grating
from psychopy.hardware import keyboard
from psychopy import visual

text_stim = visual.TextStim

BLOCKS = 1
STIMULI = ("con", "isf", "strobe")
TASKS = ("left", "right")
# OBS: With representation of both congruent and incongruent tasks for
# each stimulus/attenention pair, the number of repetitions is always a
# factor two higher than this int
REPETITIONS = 1
TASK_CONGRUENCE = (1, 0)

WINDOW = Window(fullscr=True, units="pix")
KEYBOARD = keyboard.Keyboard()
INSTRUCTION_DURATION = 1
FIXATION_DURATION_RANGE = (6, 8)
FIXATION_GRATING = grating.GratingStim(
    WINDOW, tex="sin", mask="gauss", units="pix", contrast=1, sf=0.05, size=100
)
DETECTION_GRATING = grating.GratingStim(
    WINDOW, tex="sin", mask="gauss", units="pix", contrast=0.25, sf=0.05, size=100
)
GRATING_POS_LEFT = (-400, -300)
GRATING_POS_RIGHT = (400, -300)
GRATION_ORIENTATIONS = (45, -45)
GRATING_POSITION_MAP = {"left": GRATING_POS_LEFT, "right": GRATING_POS_RIGHT}
GRATING_ORIENTATION_MAP = {
    "left": GRATION_ORIENTATIONS[0],
    "right": GRATION_ORIENTATIONS[1],
}
SIDES = ("left", "right")
RESPONSE_KEYS = ("down", "up")  # first is incongruent, second is congruent
RESPONSE_TIMEOUT = 1

expected_max_single_trial_duration = (
    INSTRUCTION_DURATION
    + (FIXATION_DURATION_RANGE[0] + FIXATION_DURATION_RANGE[1]) / 2
    + RESPONSE_TIMEOUT
)
total_experiment_trials = (
    BLOCKS
    * len(STIMULI)
    * len(TASKS)
    * len(TASK_CONGRUENCE)
    * REPETITIONS
)
total_experiment_duration = total_experiment_trials * expected_max_single_trial_duration

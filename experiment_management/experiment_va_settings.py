BLOCKS = 5
STIMULI = ("con", "isf", "strobe")
TASKS = ("left", "right")
# OBS: With representation of both congruent and incongruent tasks for
# each stimulus/attenention pair, the number of repetitions is always a
# factor two higher than this int
REPETITIONS = 4
TASK_CONGRUENCE = (1, 0)

INSTRUCTION_DURATION = 3.7 # Currently rest period (3 s) + fixation cross (.2 s) + lateral cue (.5 s)
FIXATION_DURATION_RANGE = (1, 2.5)
GRATING_POS_LEFT = (-400, -300)
GRATING_POS_RIGHT = (400, -300)
GRATION_ORIENTATIONS = (45, -45)
GRATING_POSITION_MAP = {"left": GRATING_POS_LEFT, "right": GRATING_POS_RIGHT}
GRATING_ORIENTATION_MAP = {
    "left": GRATION_ORIENTATIONS[0],
    "right": GRATION_ORIENTATIONS[1],
}

RESPONSE_KEYS = ("down", "up")  # first is incongruent, second is congruent
RESPONSE_TIMEOUT = .75

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

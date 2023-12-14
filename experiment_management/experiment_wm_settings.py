# Factors of statistical design
# Presented light stimuli levels
STIMULI = ("con", "isf", "strobe")
# Two levels of WM task difficulty
TASK_DIFFICULTY = ("low", "high")
# Booleans indicating whether the presented sum will be
# wrong or correct.
PRESENTED_SUM_CORRECTNESS = (0, 1)
# OBS: With representation of both a correct and incorrect task for
# each stimulus/difficulty pair, the number of repetitions is always a
# factor two higher than this:
REPETITIONS = 1
# Number of blocks. All of the above is repeated once
# in each block (though randomised for each block)
BLOCKS = 10

## Trial design parameters
# Duration of fixation prior to task
REST_DURATION = 3
PRE_FIXATION_DURATION = .5 # seconds
# Duration for which the WM task is presented
WM_TASK_DURATION = 5 # seconds
# Duration range between task and response
FIXATION_DURATION_RANGE = (2, 2)  # seconds

# Target response keys
# NOTE: Map these to button box
RESPONSE_KEYS = ("down", "up")  # first is wrong, second is right
# Time window in which a response can be given
RESPONSE_TIMEOUT = .75 # seconds

expected_max_single_trial_duration = (
    PRE_FIXATION_DURATION
    + WM_TASK_DURATION
    + (FIXATION_DURATION_RANGE[0] + FIXATION_DURATION_RANGE[1]) / 2
    + RESPONSE_TIMEOUT
)
total_experiment_trials = (
    BLOCKS
    * len(STIMULI)
    * len(TASK_DIFFICULTY)
    * len(PRESENTED_SUM_CORRECTNESS)
    * REPETITIONS
)
total_experiment_duration = total_experiment_trials * expected_max_single_trial_duration

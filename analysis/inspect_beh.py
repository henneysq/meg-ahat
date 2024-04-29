"""
Module for exploratory analysis of behavioural data.

Outputs figures to ./img/ for use in ./NOTES.md.

"""

from collections import defaultdict
from copy import deepcopy
from pathlib import Path

from numpy import ndarray
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt

from experiment_management import experiment_va_settings as VA_SETTINGS
from experiment_management import experiment_wm_settings as WM_SETTINGS

IMG_DIR = Path(__file__).parent.parent / "img"  # Output local image dir
DATA_DIR = Path("/Volumes/3031004.01/data/raw2")

# First 15: 1 2 3 4 5 6 7 10 12 14 15 16 19 20]
SUBJECTS = (8, 11, 13, 17, 18, 21, 22, 23, 25, 27, 29)
RUNS = (1, 2)

# Define a map for translating
# button box values into congruence booleans
# with default to handle missing presses or
# other accidental presses.
CORRECT_RESPONSE_MAP = defaultdict(lambda: -1)
CORRECT_RESPONSE_MAP[97] = 1
CORRECT_RESPONSE_MAP[98] = 0

# Map for converting run number to task
TASK_MAP = {1: "visualattention", 2: "workingmemory"}

# Map for converting run number to task specific factors
TASK_SPEC_MAP = {1: "task_congruence", 2: "presented_sum_correctness"}

# Map for converting run number to task factor level
TASK_LEVEL_MAP = {1: "task", 2: "task_difficulty"}

# Map looking up experiment specific settings
SETTINGS_MAP = {
    1: VA_SETTINGS,
    2: WM_SETTINGS,
}

# Maps for translating run number into experiment
# specific factors and levels for verbose labaling
# when plotting
TASK_SPEC_MAP_VERBOSE = {
    1: ("Task Congruence", ["Incongruent", "Congruent"]),
    2: ("Sum Correctness", ["Incorrect", "Correct"]),
}
TASK_LEVEL_MAP_VERBOSE = {
    1: ("Visual Attention", {"left": "Left", "right": "Right"}),
    2: ("Arithmetic Difficulty", {"high": "High", "low": "Low"}),
}
STIM_MAP = {
    "con": "0 Hz",
    "strobe": "40 Hz LF",
    "isf": "40 Hz ISF",
}

def make_beh_plots(df_: pd.DataFrame, axes_: ndarray[ndarray[plt.Axes]], run: int):
    """ Fill figures with behavuoral data plots

    Args:
        df_ (pd.DataFrame): Behavioural ata for a single subject
            or concatenated accross subjects.
        axes_ (ndarray[ndarray[plt.Axes]]): Matplotlib axes array
            for plot onto.
        run (int): Integer denoting the run number, referenced according
            to `TASK_MAP`.

    Returns:
        _type_: _description_
    """

    # Bar plot of correct responses by stimulus for run
    ax = sns.barplot(
        data=df_,
        x="stimulus_condition",
        y="correct_response",
        hue="stimulus_condition",
        ax=axes_[1, 0],
        legend=False,
    )
    ax.set(xlabel="Stimulus", ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(STIM_MAP[xtl._text])
    ax.axes.set_xticklabels(xtick_lab)

    # Histogram of reaction time grouped by stimulus for run
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue="stimulus_condition",
        kde=True,
        ax=axes_[0, 0],
        stat="percent",
    )
    ax.set_xlim(left=0, right=SETTINGS_MAP[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    for t in leg.texts:
        leg.set_title("Stimulus")
        t.set_text(STIM_MAP[t._text])
    sns.move_legend(ax, "upper left")

    # Bar plot of correct responses by stimulus for run
    ax = sns.barplot(
        data=df_,
        x=TASK_SPEC_MAP[run],
        y="correct_response",
        hue=TASK_SPEC_MAP[run],
        ax=axes_[1, 1],
        legend=False,
    )
    ax.set(xlabel=TASK_SPEC_MAP_VERBOSE[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(TASK_SPEC_MAP_VERBOSE[run][1][int(xtl._text)])
    ax.axes.set_xticklabels(xtick_lab)

    # Histogram of reaction time grouped by stimulus for run
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue=TASK_SPEC_MAP[run],
        kde=True,
        ax=axes_[0, 1],
        stat="percent",
    )
    ax.set_xlim(left=0, right=SETTINGS_MAP[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    leg.set_title(TASK_SPEC_MAP_VERBOSE[run][0])
    for t in leg.texts:
        t.set_text(TASK_SPEC_MAP_VERBOSE[run][1][int(t._text)])
    sns.move_legend(ax, "upper left")

    # Bar plot of correct responses by stimulus for run
    ax = sns.barplot(
        data=df_,
        x=TASK_LEVEL_MAP[run],
        y="correct_response",
        hue=TASK_LEVEL_MAP[run],
        ax=axes_[1, 2],
        legend=False,
    )
    ax.set(xlabel=TASK_LEVEL_MAP_VERBOSE[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(TASK_LEVEL_MAP_VERBOSE[run][1][xtl._text])
    ax.axes.set_xticklabels(xtick_lab)

    # Histogram of reaction time grouped by stimulus for run
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue=TASK_LEVEL_MAP[run],
        kde=True,
        ax=axes_[0, 2],
        stat="percent",
    )
    ax.set_xlim(left=0, right=SETTINGS_MAP[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    leg.set_title(TASK_LEVEL_MAP_VERBOSE[run][0])
    for t in leg.texts:
        t.set_text(TASK_LEVEL_MAP_VERBOSE[run][1][t._text])
    sns.move_legend(ax, "upper left")

    return axes_


# Set seaborn theme
sns.set_theme()
sns.set_theme(rc={"figure.figsize": (11.7, 8.27)})

# Prepare empty lists for appending single subject dfs.
# These are concatenated after plotting on an individual level
run1_df_list = []
run2_df_list = []
# A map for acessing the right list
runs_df_map = {1: run1_df_list, 2: run2_df_list}

# Iterate over subjects and prepare and plot behavioural data
# on a single subject level
#
# NOTE: Figures are not updated w.r.t. label
# names and additional experiment factors
for sub in SUBJECTS:
    sub_dir = DATA_DIR / f"sub-{sub:03d}"
    ses_dir = sub_dir / "ses-001"
    beh_dir = ses_dir / "beh"

    # Prepare some figures for plotting
    fig_va, axes_va = plt.subplots(2, 3)
    fig_va.suptitle(f"Subject {sub} - visual attention")
    fig_wm, axes_wm = plt.subplots(2, 3)
    fig_wm.suptitle(f"Subject {sub} - working memory")
    axes_tup = (axes_va, axes_wm)

    for run in RUNS:
        filename = f"sub-{sub:03d}_ses-001_run-00{run}_task-{TASK_MAP[run]}_events.tsv"
        filepath = beh_dir / filename

        # Load data
        df = pd.read_table(filepath)

        # Add subject number
        df["sub"] = sub

        # Check which responses are correct and add as boolean
        df["correct_response"] = (
            df.response.apply(lambda x: CORRECT_RESPONSE_MAP[x])
            == df[TASK_SPEC_MAP[run]]
        )

        # Access the axes for the run
        axes_ = axes_tup[run - 1]

        axes_ = make_beh_plots(df, axes_, run)

        # Append the subject data to the list; make sure
        # to avoid passing the variable by reference
        runs_df_map[run].append(deepcopy(df))

    fig_va.savefig(
        IMG_DIR / f"sub-{sub:03d}_run-001_task-visualattention.png", bbox_inches="tight"
    )
    fig_wm.savefig(IMG_DIR / f"sub-{sub:03d}_run-002_task-workingmemory.png", bbox_inches="tight")

# Merge dataframes across subejcts within each run
merged_run1_df = pd.concat(runs_df_map[1])
merged_run2_df = pd.concat(runs_df_map[2])

# Put them in a map for later access
merged_runs_df_map = {
    1: merged_run1_df,
    2: merged_run2_df,
}


# Prepare figures for plotting accross subjects
fig_va, axes_va = plt.subplots(2, 3)
fig_va.suptitle(f"All subjects - visual attention")
fig_wm, axes_wm = plt.subplots(2, 3)
fig_wm.suptitle(f"All subjects - working memory")
axes_tup = (axes_va, axes_wm)
print(axes_wm, type(axes_wm), axes_wm[0][0], type(axes_wm[0][0]))

# Iterate over runs and plot
for run in RUNS:
    # Access the dataframe for the run
    df_ = merged_runs_df_map[run]

    # Access the axes for the run
    axes_ = axes_tup[run - 1]

    axes_ = make_beh_plots(df_, axes_, run)


fig_va.savefig(
    IMG_DIR / f"sub-all_run-001_task-visualattention.png", bbox_inches="tight"
)
fig_wm.savefig(IMG_DIR / f"sub-all_run-002_task-workingmemory.png", bbox_inches="tight")

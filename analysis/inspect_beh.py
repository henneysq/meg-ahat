"""
Module for exploratory analysis of behavioural data.

Outputs figures to ./img/ for use in ./NOTES.md.

"""

from collections import defaultdict
from copy import deepcopy
from typing import Final
from pathlib import Path

import numpy as np
from numpy import ndarray
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt

from experiment_management import experiment_va_settings as VA_SETTINGS
from experiment_management import experiment_wm_settings as WM_SETTINGS

IMG_DIR = Path(__file__).parent.parent / "img"  # Output local image dir
DATA_DIR = Path("/Volumes/3031004.01/data/raw2")

FIRST_FIFTEEN: Final[tuple] = {1, 2, 3, 4, 5, 6, 7, 10, 12, 14, 15, 16, 19, 20}
SUBJECTS = {8, 9, 11, 13, 17, 18, 21, 22, 23, 24, 25, 27, 28, 29, 30}
assert len(SUBJECTS.intersection(FIRST_FIFTEEN)) == 0
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
    "con": "0 Hz CON",
    "isf": "40 Hz ISF",
    "strobe": "40 Hz LF",
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

def make_beh_plots_w_bps(df_: pd.DataFrame, axes_: ndarray[ndarray[plt.Axes]], run: int):
    
    # response_frac_by_stim = {}
    
    # response_frac_by_stim["sub"] = []
    # response_frac_by_stim["stimulus_condition"] = []
    # response_frac_by_stim["task_level"] = []
    # response_frac_by_stim["task_spec"] = []
    # response_frac_by_stim["frac_correct"] = []

    # for sub in df_["sub"].unique():
    #     for task in df_[TASK_LEVEL_MAP[run]].unique():
    #         for task_spec in df_[TASK_SPEC_MAP[run]].unique():
    #             for stim_condition in df_["stimulus_condition"].unique():
    #                 mask = (df_["sub"]==sub).values & \
    #                     (df_[TASK_LEVEL_MAP[run]]==task).values & \
    #                     (df_[TASK_SPEC_MAP[run]]==task_spec).values & \
    #                     (df_["stimulus_condition"]==stim_condition).values
                    
    #                 frac = df_[mask]["correct_response"].mean()

    #                 response_frac_by_stim["sub"].append(sub)
    #                 response_frac_by_stim["task_level"].append(task)
    #                 response_frac_by_stim["task_spec"].append(task_spec)
    #                 response_frac_by_stim["stimulus_condition"].append(stim_condition)
    #                 response_frac_by_stim["frac_correct"].append(frac)
    
    # response_frac_df = pd.DataFrame.from_dict(response_frac_by_stim)
    
    response_frac_by_stim = {}
    response_frac_by_stim["sub"] = []
    response_frac_by_stim["stimulus_condition"] = []#df_["stimulus_condition"].unique()
    response_frac_by_stim["frac_correct"] = []
    for sub in df_["sub"].unique():
        for stim_condition in df_["stimulus_condition"].unique():
            mask = (df_["sub"]==sub).values & \
                    (df_["stimulus_condition"]==stim_condition).values
            
            frac = df_[mask]["correct_response"].mean()
            response_frac_by_stim["sub"].append(sub)
            response_frac_by_stim["stimulus_condition"].append(stim_condition)
            response_frac_by_stim["frac_correct"].append(frac)

    response_frac_df = pd.DataFrame.from_dict(response_frac_by_stim)

    # Bar plot of correct responses by stimulus for run
    ax = sns.boxplot(
        data=response_frac_df,
        x="stimulus_condition",
        y="frac_correct",
        hue="stimulus_condition",
        ax=axes_[1, 0],
        # kde=True,
        # stat="percent",
        legend=False,
        orient="v",
        # whis=(0, 100),
        boxprops={'alpha': 0.4},
        showfliers=False,
    )
    # sns.stripplot(data=response_frac_df, x="stimulus_condition", y="frac_correct",
    #           hue="stimulus_condition", hue_order=['con', 'isf', "strobe"], dodge=False, ax=ax,
    #           marker="D", alpha=.6, jitter=.25)
    # ax.axhline(0, color='black', ls='--')
    ax.set(xlabel="Stimulus", ylabel="Response Accuracy",ylim=(0,1))
    
    jitter = 0.1#05
    df_x_jitter = response_frac_df.copy()
    df_x_jitter["stimulus_condition"] = df_x_jitter["stimulus_condition"].map({"con": 0, "isf": 1, "strobe": 2})
    df_x_jitter["stimulus_condition"] += np.random.normal(loc=0, scale=jitter, size=len(response_frac_df))
    for col in response_frac_df["stimulus_condition"].unique():
        mask = response_frac_df["stimulus_condition"]==col
        ax.plot(df_x_jitter[mask]["stimulus_condition"], response_frac_df[mask]["frac_correct"], 'D', alpha=.40, zorder=1, mew=.5)
    ax.set_xticks(range(3))
    ax.set_xticklabels(response_frac_df["stimulus_condition"].unique())
    ax.set_xlim(-0.5, 3-0.5)
    for sub in response_frac_df["sub"].unique():
        mask = response_frac_df["sub"] == sub
        ax.plot((df_x_jitter[mask].iloc[0]["stimulus_condition"], df_x_jitter[mask].iloc[1]["stimulus_condition"], df_x_jitter[mask].iloc[2]["stimulus_condition"]),
                (response_frac_df[mask].iloc[0]["frac_correct"], response_frac_df[mask].iloc[1]["frac_correct"], response_frac_df[mask].iloc[2]["frac_correct"]), 
                color = 'grey',  linewidth = 0.7, linestyle = '--', zorder=1, alpha=0.5)    

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
    ax.set(xlabel="Response Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    for t in leg.texts:
        leg.set_title("Stimulus")
        t.set_text(STIM_MAP[t._text])
    sns.move_legend(ax, "upper left")
    
    
    response_frac_by_stim = {}
    response_frac_by_stim["sub"] = []
    response_frac_by_stim["task_spec"] = []#df_["stimulus_condition"].unique()
    response_frac_by_stim["frac_correct"] = []
    for sub in df_["sub"].unique():
        for task_spec in df_[TASK_SPEC_MAP[run]].unique():
            mask = (df_["sub"]==sub).values & \
                    (df_[TASK_SPEC_MAP[run]]==task_spec).values
            
            frac = df_[mask]["correct_response"].mean()
            response_frac_by_stim["sub"].append(sub)
            response_frac_by_stim["task_spec"].append(task_spec)
            response_frac_by_stim["frac_correct"].append(frac)

    response_frac_df = pd.DataFrame.from_dict(response_frac_by_stim)

    # Bar plot of correct responses by stimulus for run
    ax = sns.boxplot(
        data=response_frac_df,
        x="task_spec",
        y="frac_correct",
        hue="task_spec",
        ax=axes_[1, 1],
        # kde=True,
        # stat="percent",
        legend=False,
        orient="v",
        # whis=(0, 100),
        boxprops={'alpha': 0.4},
        showfliers=False,
    )
    # sns.stripplot(data=response_frac_df, x="task_spec", y="frac_correct",
    #           hue="task_spec", dodge=False, ax=ax, legend=False,
    #           marker="D", alpha=.6, jitter=.25)
    ax.set(xlabel=TASK_SPEC_MAP_VERBOSE[run][0], ylabel="",ylim=(0,1))
    jitter = 0.1#05
    df_x_jitter = response_frac_df.copy()
    # df_x_jitter["task_spec"] = df_x_jitter["task_spec"].map({"con": 0, "isf": 1, "strobe": 2})
    df_x_jitter["task_spec"] += np.random.normal(loc=0, scale=jitter, size=len(response_frac_df))
    for col in response_frac_df["task_spec"].unique():
        mask = response_frac_df["task_spec"]==col
        ax.plot(df_x_jitter[mask]["task_spec"], response_frac_df[mask]["frac_correct"], 'D', alpha=.40, zorder=1, mew=.5)
    ax.set_xticks(range(2))
    ax.set_xticklabels(response_frac_df["task_spec"].unique())
    ax.set_xlim(-0.5, 2-0.5)
    for sub in response_frac_df["sub"].unique():
        mask = response_frac_df["sub"] == sub
        ax.plot((df_x_jitter[mask].iloc[0]["task_spec"], df_x_jitter[mask].iloc[1]["task_spec"]),
                (response_frac_df[mask].iloc[0]["frac_correct"], response_frac_df[mask].iloc[1]["frac_correct"]), 
                color = 'grey', linewidth = 0.7, linestyle = '--', zorder=1, alpha=0.5)  
    # ax = sns.histplot(
    #     data=df_,
    #     #x=TASK_SPEC_MAP[run],
    #     x="correct_response",
    #     hue=TASK_SPEC_MAP[run],
    #     ax=axes_[1, 1],
    #     legend=False,
    #     kde=True,
    #     stat="percent",
    # )
    # ax.set(xlabel=TASK_SPEC_MAP_VERBOSE[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        # import pdb; pdb.set_trace()
        # break
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
    ax.set(xlabel="Response Time", ylabel="")
    leg = ax.axes.get_legend()
    leg.set_title(TASK_SPEC_MAP_VERBOSE[run][0])
    for t in leg.texts:
        t.set_text(TASK_SPEC_MAP_VERBOSE[run][1][int(t._text)])
    sns.move_legend(ax, "upper left")

    
    response_frac_by_stim = {}
    response_frac_by_stim["sub"] = []
    response_frac_by_stim["task"] = []#df_["stimulus_condition"].unique()
    response_frac_by_stim["frac_correct"] = []
    for sub in df_["sub"].unique():
        for task in df_[TASK_LEVEL_MAP[run]].unique():
            mask = (df_["sub"]==sub).values & \
                    (df_[TASK_LEVEL_MAP[run]]==task).values
            
            frac = df_[mask]["correct_response"].mean()
            response_frac_by_stim["sub"].append(sub)
            response_frac_by_stim["task"].append(task)
            response_frac_by_stim["frac_correct"].append(frac)

    response_frac_df = pd.DataFrame.from_dict(response_frac_by_stim)

    # Bar plot of correct responses by stimulus for run
    ax = sns.boxplot(
        data=response_frac_df,
        x="task",
        y="frac_correct",
        hue="task",
        ax=axes_[1, 2],
        # kde=True,
        # stat="percent",
        legend=False,
        orient="v",
        # whis=(0, 100),
        boxprops={'alpha': 0.4},
        showfliers=False,
    )
    # sns.stripplot(data=response_frac_df, x="task", y="frac_correct",
    #           hue="task", dodge=False, ax=ax, legend=False,
    #           marker="D", alpha=.6, jitter=.25)
    ax.set(xlabel=TASK_LEVEL_MAP_VERBOSE[run][0], ylabel="",ylim=(0,1))
    jitter = 0.1#05
    df_x_jitter = response_frac_df.copy()
    df_x_jitter["task"] = df_x_jitter["task"].map({"left": 0, "right": 1, "low": 0, "high": 1})
    df_x_jitter["task"] += np.random.normal(loc=0, scale=jitter, size=len(response_frac_df))
    for col in response_frac_df["task"].unique():
        mask = response_frac_df["task"]==col
        ax.plot(df_x_jitter[mask]["task"], response_frac_df[mask]["frac_correct"], 'D', alpha=.40, zorder=1, mew=.5)
    ax.set_xticks(range(2))
    ax.set_xticklabels(response_frac_df["task"].unique())
    ax.set_xlim(-0.5, 2-0.5)
    for sub in response_frac_df["sub"].unique():
        mask = response_frac_df["sub"] == sub
        ax.plot((df_x_jitter[mask].iloc[0]["task"], df_x_jitter[mask].iloc[1]["task"]),
                (response_frac_df[mask].iloc[0]["frac_correct"], response_frac_df[mask].iloc[1]["frac_correct"]), 
                color = 'grey',  linewidth = 0.7, linestyle = '--', zorder=1, alpha=0.5)  
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:

        xtl.set_text(TASK_LEVEL_MAP_VERBOSE[run][1][xtl._text])
    ax.axes.set_xticklabels(xtick_lab)
    # ax = sns.histplot(
    #     data=df_,
    #     # x=TASK_LEVEL_MAP[run],
    #     x="correct_response",
    #     hue=TASK_LEVEL_MAP[run],
    #     ax=axes_[1, 2],
    #     legend=False,
    #     kde=True,
    #     stat="percent",
    # )
    # ax.set(xlabel=TASK_LEVEL_MAP_VERBOSE[run][0], ylabel="Fraction Correct Reponses")
    # xtick_lab = ax.axes.get_xticklabels()
    # for xtl in xtick_lab:
    #     xtl.set_text(TASK_LEVEL_MAP_VERBOSE[run][1][xtl._text])
    # ax.axes.set_xticklabels(xtick_lab)

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
    ax.set(xlabel="Response Time", ylabel="")
    leg = ax.axes.get_legend()
    leg.set_title(TASK_LEVEL_MAP_VERBOSE[run][0])
    for t in leg.texts:
        t.set_text(TASK_LEVEL_MAP_VERBOSE[run][1][t._text])
    sns.move_legend(ax, "upper left")

    return axes_

# Set seaborn theme
sns.set_theme()
sns.set_theme(rc={"figure.figsize": (11.7, 8.27)})

# Make sure dirs exists
IMG_DIR.mkdir(exist_ok=True)

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
    #fig_va.suptitle(f"Subject {sub} - visual attention")
    fig_wm, axes_wm = plt.subplots(2, 3)
    #fig_wm.suptitle(f"Subject {sub} - working memory")
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

        # axes_ = make_beh_plots(df, axes_, run)

        # Append the subject data to the list; make sure
        # to avoid passing the variable by reference
        runs_df_map[run].append(deepcopy(df))

    # fig_va.savefig(
    #     IMG_DIR / f"sub-{sub:03d}_run-001_task-visualattention.png", bbox_inches="tight"
    # )
    # fig_wm.savefig(IMG_DIR / f"sub-{sub:03d}_run-002_task-workingmemory.png", bbox_inches="tight")

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
#fig_va.suptitle(f"All subjects - visual attention")
fig_wm, axes_wm = plt.subplots(2, 3)
#fig_wm.suptitle(f"All subjects - working memory")
axes_tup = (axes_va, axes_wm)
print(axes_wm, type(axes_wm), axes_wm[0][0], type(axes_wm[0][0]))

# Iterate over runs and plot
for run in RUNS:
    # Access the dataframe for the run
    df_ = merged_runs_df_map[run]

    # Access the axes for the run
    axes_ = axes_tup[run - 1]

    axes_ = make_beh_plots_w_bps(df_, axes_, run)


fig_va.savefig(
    IMG_DIR / f"sub-all_run-001_task-visualattention.png", bbox_inches="tight"
)
fig_wm.savefig(IMG_DIR / f"sub-all_run-002_task-workingmemory.png", bbox_inches="tight")

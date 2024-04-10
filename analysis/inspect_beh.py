"""
Module for exploratory analysis of behavioural data.

Outputs figures to ./img/ for use in ./NOTES.md.

"""

from collections import defaultdict
from copy import deepcopy
from pathlib import Path

import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt

from experiment_management import experiment_va_settings as VA_SETTINGS
from experiment_management import experiment_wm_settings as WM_SETTINGS

sns.set_theme()
sns.set_theme(rc={"figure.figsize": (11.7, 8.27)})


img_dir = Path(__file__).parent.parent / "img"  # Output local image dir
data_dir = Path("/Volumes/3031004.01/data/raw2")

subs = list(range(1, 8)) + [10, 12, 14, 15, 16, 17, 19, 20]
runs = (1, 2)

# Define a map for translating
# button box values into congruence booleans
# with default to handle missing presses or
# other accidental presses.
correct_response_map = defaultdict(lambda: -1)
correct_response_map[97] = 1
correct_response_map[98] = 0

# Map for converting run number to task
task_map = {1: "visualattention", 2: "workingmemory"}

# Map for converting run number to task specific factors
task_spec_map = {1: "task_congruence", 2: "presented_sum_correctness"}

# Map for converting run number to task factor level
task_level_map = {1: "task", 2: "task_difficulty"}

# Map looking up experiment specific settings
settings_map = {
    1: VA_SETTINGS,
    2: WM_SETTINGS,
}

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
for sub in subs:
    sub_dir = data_dir / f"sub-{sub:03d}"
    ses_dir = sub_dir / "ses-001"
    beh_dir = ses_dir / "beh"

    fig, axes = plt.subplots(2, 2)
    fig.suptitle(f"subject {sub}")
    for run in runs:
        filename = f"sub-{sub:03d}_ses-001_run-00{run}_task-{task_map[run]}_events.tsv"
        filepath = beh_dir / filename

        # Load data
        df = pd.read_table(filepath)
        # Add subject number
        df["sub"] = sub
        # Check which responses are correct and add as boolean
        df["correct_response"] = (
            df.response.apply(lambda x: correct_response_map[x])
            == df[task_spec_map[run]]
        )

        # Append the subject data to the list; make sure
        # to avoid passing the variable by reference
        runs_df_map[run].append(deepcopy(df))

        # Bar plot of fraction of correct responses
        # grouped by light stimulus
        ax = sns.barplot(
            data=df,
            x="stimulus_condition",
            y="correct_response",
            hue="stimulus_condition",
            ax=axes[run - 1, 0],
        )
        ax.set(xlabel="Stimulus", ylabel="Fraction Correct Reponses")

        # Histograms of the reaction times
        # grouped by light stimulus
        ax = sns.histplot(
            data=df[df.reaction_time > 0],
            x="reaction_time",
            hue="stimulus_condition",
            kde=True,
            ax=axes[run - 1, 1],
            stat="percent",
        )
        ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
        ax.set(xlabel="Reaction Time", ylabel="Percent")

        # Save figure
        fig.savefig(img_dir / f"sub-{sub:03d}_beh.png", bbox_inches="tight")


# Merge dataframes across subejcts within each run
merged_run1_df = pd.concat(runs_df_map[1])
merged_run2_df = pd.concat(runs_df_map[2])

# Put them in a map for later access
merged_runs_df_map = {
    1: merged_run1_df,
    2: merged_run2_df,
}

# Maps for translating run number into experiment
# specific factors and levels for verbose labaling
# when plotting
task_spec_map_verbose = {
    1: ("Task Congruence", ["Incongruent", "Congruent"]),
    2: ("Sum Correctness", ["Incorrect", "Correct"]),
}
task_level_map_verbose = {
    1: ("Visual Attention", {"left": "Left", "right": "Right"}),
    2: ("Arithmetic Difficulty", {"high": "High", "low": "Low"}),
}
stim_map = {
    "con": "0 Hz",
    "strobe": "40 Hz LF",
    "isf": "40 Hz ISF",
}

# Prepare some figures for plotting
fig_va, axes_va = plt.subplots(2, 3)
fig_va.suptitle(f"All subjects - visual attention - behaviour by stimulus")
fig_wm, axes_wm = plt.subplots(2, 3)
fig_wm.suptitle(f"All subjects - working memory - behaviour by stimulus")
axes_tup = (axes_va, axes_wm)

fig1, axes1 = plt.subplots(2, 2)
fig1.suptitle(f"All subjects - behaviour by stimulus")
fig2, axes2 = plt.subplots(2, 2)
fig2.suptitle(f"All subjects - behaviour by task congruence / correctness")
fig3, axes3 = plt.subplots(2, 2)
fig3.suptitle(f"All subjects - behaviour by task level")

# Iterate over runs and plot
for run in runs:
    # Access the dataframe for the run
    df_ = merged_runs_df_map[run]

    # Access the axes for the run
    axes_ = axes_tup[run - 1]

    # Bar plot of correct responses by stimulus
    ax = sns.barplot(
        data=df_,
        x="stimulus_condition",
        y="correct_response",
        hue="stimulus_condition",
        ax=axes1[run - 1, 0],
        legend=False,
    )
    ax.set(xlabel="Stimulus", ylabel="Fraction Correct Reponses")

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
        xtl.set_text(stim_map[xtl._text])
    ax.axes.set_xticklabels(xtick_lab)

    # Histogram of reaction time grouped by stimulus
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue="stimulus_condition",
        kde=True,
        ax=axes1[run - 1, 1],
        stat="percent",
    )
    ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    for t in leg.texts:
        leg.set_title("Stimulus")
        t.set_text(stim_map[t._text])
    sns.move_legend(ax, "upper left")

    # Histogram of reaction time grouped by stimulus for run
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue="stimulus_condition",
        kde=True,
        ax=axes_[0, 0],
        stat="percent",
    )
    ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    for t in leg.texts:
        leg.set_title("Stimulus")
        t.set_text(stim_map[t._text])
    sns.move_legend(ax, "upper left")

    # Bar plot of correct responses by stimulus
    ax = sns.barplot(
        data=df_,
        x=task_spec_map[run],
        y="correct_response",
        hue=task_spec_map[run],
        ax=axes2[run - 1, 0],
        legend=False,
    )
    ax.set(xlabel=task_spec_map_verbose[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(task_spec_map_verbose[run][1][int(xtl._text)])
    ax.axes.set_xticklabels(xtick_lab)

    # Bar plot of correct responses by stimulus for run
    ax = sns.barplot(
        data=df_,
        x=task_spec_map[run],
        y="correct_response",
        hue=task_spec_map[run],
        ax=axes_[1, 1],
        legend=False,
    )
    ax.set(xlabel=task_spec_map_verbose[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(task_spec_map_verbose[run][1][int(xtl._text)])
    ax.axes.set_xticklabels(xtick_lab)

    # Histogram of reaction time grouped by stimulus
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue=task_spec_map[run],
        kde=True,
        ax=axes2[run - 1, 1],
        stat="percent",
    )
    ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    leg.set_title(task_spec_map_verbose[run][0])
    for t in leg.texts:
        t.set_text(task_spec_map_verbose[run][1][int(t._text)])
    sns.move_legend(ax, "upper left")

    # Histogram of reaction time grouped by stimulus for run
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue=task_spec_map[run],
        kde=True,
        ax=axes_[0, 1],
        stat="percent",
    )
    ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    leg.set_title(task_spec_map_verbose[run][0])
    for t in leg.texts:
        t.set_text(task_spec_map_verbose[run][1][int(t._text)])
    sns.move_legend(ax, "upper left")

    # Bar plot of correct responses by stimulus
    ax = sns.barplot(
        data=df_,
        x=task_level_map[run],
        y="correct_response",
        hue=task_level_map[run],
        ax=axes3[run - 1, 0],
        legend=False,
    )
    ax.set(xlabel=task_level_map_verbose[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(task_level_map_verbose[run][1][xtl._text])
    ax.axes.set_xticklabels(xtick_lab)

    # Bar plot of correct responses by stimulus for run
    ax = sns.barplot(
        data=df_,
        x=task_level_map[run],
        y="correct_response",
        hue=task_level_map[run],
        ax=axes_[1, 2],
        legend=False,
    )
    ax.set(xlabel=task_level_map_verbose[run][0], ylabel="Fraction Correct Reponses")
    xtick_lab = ax.axes.get_xticklabels()
    for xtl in xtick_lab:
        xtl.set_text(task_level_map_verbose[run][1][xtl._text])
    ax.axes.set_xticklabels(xtick_lab)

    # Histogram of reaction time grouped by stimulus
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue=task_level_map[run],
        kde=True,
        ax=axes3[run - 1, 1],
        stat="percent",
    )
    ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    leg.set_title(task_level_map_verbose[run][0])
    for t in leg.texts:
        t.set_text(task_level_map_verbose[run][1][t._text])
    sns.move_legend(ax, "upper left")

    # Histogram of reaction time grouped by stimulus for run
    ax = sns.histplot(
        data=df_[df_.reaction_time > 0],
        x="reaction_time",
        hue=task_level_map[run],
        kde=True,
        ax=axes_[0, 2],
        stat="percent",
    )
    ax.set_xlim(left=0, right=settings_map[run].RESPONSE_TIMEOUT)
    ax.set(xlabel="Reaction Time", ylabel="Percent")
    leg = ax.axes.get_legend()
    leg.set_title(task_level_map_verbose[run][0])
    for t in leg.texts:
        t.set_text(task_level_map_verbose[run][1][t._text])
    sns.move_legend(ax, "upper left")

fig1.savefig(img_dir / f"sub-all_strat-stim.png", bbox_inches="tight")
fig2.savefig(img_dir / f"sub-all_strat-congr.png", bbox_inches="tight")
fig3.savefig(img_dir / f"sub-all_strat-level.png", bbox_inches="tight")
fig_va.savefig(
    img_dir / f"sub-all_run-001_task-visualattention.png", bbox_inches="tight"
)
fig_wm.savefig(img_dir / f"sub-all_run-002_task-workingmemory.png", bbox_inches="tight")

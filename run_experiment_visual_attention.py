from pathlib import Path

from experiment_manager_va import VisualAttentionExperimentManager

# Experiment variables
SUB = 42
SES = 42
RUN = 42

ROOT = Path(__file__).parent / "data"

experiment_manager = VisualAttentionExperimentManager(
    sub=SUB, ses=SES, run=RUN, root=ROOT
)

experiment_manager.make_and_save_experiment_data(
    overwrite=True,
)
experiment_manager.load_experiment_data()

experiment_manager.execute_current_trial("left", True, "isf")

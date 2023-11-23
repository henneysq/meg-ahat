from pathlib import Path

from experiment_management.experiment_manager_wm import WorkingMemoryExperimentManager

# Experiment variables
SUB = 42
SES = 42
RUN = 2

ROOT = Path(__file__).parent / "data"

experiment_manager = WorkingMemoryExperimentManager(
    sub=SUB, ses=SES, run=RUN, root=ROOT
)

experiment_manager.make_and_save_experiment_data(
    overwrite=True,
)
experiment_manager.load_experiment_data()

experiment_manager.run_experiment()

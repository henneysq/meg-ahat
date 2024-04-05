import logging
from pathlib import Path

from tests.test_util import set_git_executable_path

set_git_executable_path()

import git

test_log_dir = filename=Path(__file__).parent / "test_logs"
test_log_dir.mkdir(exist_ok=True)
test_data_dir = filename=Path(__file__).parent / "test_data"
test_data_dir.mkdir(exist_ok=True)

repo = git.Repo(search_parent_directories=True)
sha = repo.head.object.hexsha[:8]
logging.basicConfig(filename=test_log_dir/ f"log_{sha}.log", level=logging.INFO, filemode="w")

import logging
from pathlib import Path

import git

test_log_dir = filename=Path(__file__).parent / "test_logs"
test_log_dir.mkdir(exist_ok=True)

repo = git.Repo(search_parent_directories=True)
sha = repo.head.object.hexsha[:8]
logging.basicConfig(filename=test_log_dir/ f"log_{sha}.log", level=logging.INFO, filemode="w")

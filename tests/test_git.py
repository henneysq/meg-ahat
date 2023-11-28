import logging
from pathlib import Path
import platform
import unittest

from util import (
    set_git_executable_path,
    git_status,
    git_commit,
    git_add,
    git_push_changes,
    git_pull_changes,
)

test_log_dir = filename = Path(__file__).parent / "test_logs"
test_log_dir.mkdir(exist_ok=True)
logging.basicConfig(
    filename=test_log_dir / f"custom_git.log", level=logging.INFO, filemode="w"
)


class TestGitUtils(unittest.TestCase):
    def test1_set_exec_path(self):
        new_path_set = set_git_executable_path()
        logging.info(
            f"Tested function {set_git_executable_path} on "
            + f"platform {platform.platform()} and got `new_path_set` "
            + f"return code of {new_path_set}."
        )

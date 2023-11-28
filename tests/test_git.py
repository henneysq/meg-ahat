import logging
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

class TestGitUtils(unittest.TestCase):
    def test1_set_exec_path(self):
        new_path_set = set_git_executable_path()
        logging.info(
            f"\nTested function {set_git_executable_path} on "
            + f"platform {platform.platform()} and got `new_path_set` "
            + f"return code of {new_path_set}."
        )

    def test2_git_status(self):
        status = git_status(return_status=True)
        logging.info("\nOutput of custom git status:")
        logging.info(status)
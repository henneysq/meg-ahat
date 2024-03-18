from tests.test_util import set_git_executable_path
set_git_executable_path()

import git

def get_git_sha():
    repo = git.Repo(search_parent_directories=True)
    sha = repo.head.object.hexsha[:8]
    return sha
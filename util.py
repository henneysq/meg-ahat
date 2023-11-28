from __future__ import annotations
from pathlib import Path

def set_git_executable_path(path = None) -> bool:
    import os
    import platform

    new_path_set = False

    MEG_LAB_PC_NAME = "LAB-PRE120"
    GIT_THUMBDRIVE_EXECUTABLE_PATH = "F:\dependencies\portable-git\cmd\git.exe"
    if not "Windows" in platform.platform():
        return new_path_set
    
    if not path is None:
        os.environ["GIT_PYTHON_GIT_EXECUTABLE"] = path    
    elif platform.node() == MEG_LAB_PC_NAME:
        os.environ["GIT_PYTHON_GIT_EXECUTABLE"] = GIT_THUMBDRIVE_EXECUTABLE_PATH
    else:
        return new_path_set
    
    new_path_set = True
    return new_path_set
    
        
set_git_executable_path()
from git import Repo

def git_status(repo_path: str | Path | None = None, return_status: bool = False):    
    if repo_path is None:
       repo_path = Path(__file__).parent
       
    if not (repo_path / ".git").exists():
        raise FileNotFoundError
    
    repo = Repo(repo_path)
    status = repo.git.status()
    
    if return_status:
        return status
    
    print(status)

def git_pull_changes(repo_path: str | Path | None = None):
    
    if repo_path is None:
       repo_path = Path(__file__).parent
       
    if not (repo_path / ".git").exists():
        raise FileNotFoundError
    
    repo = Repo(repo_path)
    pull = repo.git.pull()
    
    print(pull)
    
def git_push_changes(repo_path: str | Path | None = None):
    
    if repo_path is None:
       repo_path = Path(__file__).parent
       
    if not (repo_path / ".git").exists():
        raise FileNotFoundError
    
    repo = Repo(repo_path)
    push = repo.git.push()
    
    print(push)
    
def git_add(file: str | Path, repo_path: str | Path | None = None):
    
    if repo_path is None:
       repo_path = Path(__file__).parent
       
    if not (repo_path / ".git").exists():
        raise FileNotFoundError
    
    repo = Repo(repo_path)
    
    repo.git.add(file)
    
def git_commit(msg: str, repo_path: str | Path | None = None):
    
    if repo_path is None:
       repo_path = Path(__file__).parent
       
    if not (repo_path / ".git").exists():
        raise FileNotFoundError
    
    repo = Repo(repo_path)
    
    repo.index.commit(msg)
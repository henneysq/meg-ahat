from __future__ import annotations
from pathlib import Path

from util import set_git_executable_path        
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
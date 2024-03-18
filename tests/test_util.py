from __future__ import annotations
import logging
from pathlib import Path
from unittest.mock import MagicMock

from serial import SerialException

def check_is_trigger_connected(experiment_manager: ExperimentManagerBase):
    from experiment_management.experiment_manager_base import ExperimentManagerBase

    try:
        experiment_manager.trigger.prepare_trigger()
    except SerialException as e:
        logging.info("Caught exception while connecting serial port:\n" + str(e))
        logging.info("Continuing with mock trigger")
        experiment_manager.trigger.ser = MagicMock()
        experiment_manager.trigger.ser.write = MagicMock()
        experiment_manager.trigger.ser.read = MagicMock(return_value=bytearray([0]))
        experiment_manager.trigger.trigger_ready = True
        
    return experiment_manager

def check_is_lc_connected(experiment_manager: ExperimentManagerBase):
    from experiment_management.experiment_manager_base import ExperimentManagerBase
    try:
        experiment_manager.prepare_led_controllers()
        print("Succesfully connected LED controllers")
    except ConnectionError as e:
        logging.info("Caught exception while connecting LED controllers:\n" + str(e))
        logging.info("Continuing with mock LED controllers")
        experiment_manager.lc_left = MagicMock()
        experiment_manager.lc_right = MagicMock()
        experiment_manager.led_controllers_ready = True    
    
    return experiment_manager

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
    repo = _check_default_repo_loc(repo_path)
    status = repo.git.status()
    
    if return_status:
        return status
    
    print(status)

def git_pull_changes(repo_path: str | Path | None = None):
    repo = _check_default_repo_loc(repo_path)
    pull = repo.git.pull()
    
    print(pull)
    
def git_push_changes(repo_path: str | Path | None = None):
    repo = _check_default_repo_loc(repo_path)
    push = repo.git.push()
    
    print(push)
    
def git_add(file: str | Path, repo_path: str | Path | None = None):
    repo = _check_default_repo_loc(repo_path)
    
    repo.git.add(file)
    
def git_commit(msg: str, repo_path: str | Path | None = None):
    repo = _check_default_repo_loc(repo_path)
    
    repo.index.commit(msg)

def _check_default_repo_loc(repo_path):
    if repo_path is None:
        print(repo_path)
        repo_path = Path(__file__).parent.parent
        print(repo_path)
       
    if not (repo_path / ".git").exists():
        raise FileNotFoundError
    
    return Repo(repo_path)
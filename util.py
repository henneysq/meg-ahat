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
    

import os
import platform

MEG_LAB_PC_NAME = "LAB-PRE120"
GIT_THUMBDRIVE_EXECUTABLE_PATH = "F:\dependencies\portable-git\cmd\git.exe"

def set_git_executable_path(path = None) -> None:
    if not "Windows" in platform.platform():
        return
    
    if not path is None:
        os.environ["GIT_PYTHON_GIT_EXECUTABLE"] = path
        
    elif platform.node() == MEG_LAB_PC_NAME:
        os.environ["GIT_PYTHON_GIT_EXECUTABLE"] = GIT_THUMBDRIVE_EXECUTABLE_PATH
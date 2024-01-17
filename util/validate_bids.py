from pathlib import Path

from bids_validator import BIDSValidator

PILOT_RAW1_PATH = Path("/project/3031004.01/pilot-data/raw1")

bv = BIDSValidator()

print(f"Validting files in {PILOT_RAW1_PATH}")
invalid_files = []
valid_files = []

# for item in PILOT_RAW1_PATH.walk():
#     if not bv.is_bids(item.as_posix()):
#         invalid_files.append(item.as_posix())

def check_if_dir_is_bids(dir):
    for item in dir.iterdir():
        if item.is_dir():
            check_if_dir_is_bids(item)
            continue
        
        relative_path_string_list = item.as_posix().split('/')[5:]
        relative_path_string = "/".join(relative_path_string_list)
        
        if not bv.is_bids(relative_path_string):
            invalid_files.append(item.as_posix())
        else:
            valid_files.append(item.as_posix())

check_if_dir_is_bids(PILOT_RAW1_PATH)

with open("/project/3031004.01/pilot-data/bids_validation.log", 'w') as f:
    f.write("\nValid files:")
    [f.write(f"{valid_file}\n") for valid_file in valid_files]

    f.write("\nInvalid files:")
    [f.write(f"{invalid_file}\n") for invalid_file in invalid_files]
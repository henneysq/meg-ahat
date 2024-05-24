from pathlib import Path
from typing import Final

SERVER_DATA_DIR = Path("/Volumes/3031004.01/data/")
FIRST_FIFTEEN: Final[tuple] = {1, 2, 3, 4, 5, 6, 7, 10, 12, 14, 15, 16, 17, 19, 20}
LAST_FIFTEEN = {8, 9, 11, 13, 18, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}

raw2_participants_fname = SERVER_DATA_DIR / "raw2" / "participants.tsv"
subjects = set()
with open(raw2_participants_fname) as file:
  for n, line in enumerate(file):
    if n > 0:
        l = line.split('\t')[0]
        sub = l.split("\n")[0]
        sub_num = int(sub.split("-")[1])
        subjects.add(sub_num)

assert len(FIRST_FIFTEEN) == 15
assert len(LAST_FIFTEEN) == 15
assert len(LAST_FIFTEEN.intersection(FIRST_FIFTEEN)) == 0
assert len(LAST_FIFTEEN.intersection(subjects)) == 15
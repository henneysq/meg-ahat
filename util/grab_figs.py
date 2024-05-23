from itertools import product
from pathlib import Path
import shutil

from _subj_def import subjects

SERVER_DERIV_DIR = Path("/Volumes/3031004.01/data/derivatives")
LOCAL_IMG_DIR = Path(__file__).parent.parent / "img"
STIMS = ("con", "strobe")
BANDS = ("40", "alpha", "beta")
CONTRASTS = ("lateral", "arithmetic-difficulty")

combs_ = (STIMS, BANDS, CONTRASTS)
combs = product(*combs_)
# print(list(combs))

maintained_figs = []

for comb in combs:
    maintained_figs.append(
        f"sub-all_stim-{comb[0]}_band-{comb[1]}_{comb[2]}-dif.png"
    )

# maintained_figs = [
#     "sub-all_stim-con_band-40_lateral-dif.png",
#     "sub-all_stim-con_band-alpha_lateral-dif.png",
#     "sub-all_stim-con_band-beta_lateral-dif.png",
#     "sub-all_stim-strobe_band-40_lateral-dif.png",
#     "sub-all_stim-strobe_band-alpha_lateral-dif.png",
#     "sub-all_stim-strobe_band-beta_lateral-dif.png",
#     "sub-all_stim-strobe_band-40_arithmetic-difficulty-dif.png",
#     "sub-all_stim-strobe_band-alpha_arithmetic-difficulty-dif.png",
#     "sub-all_stim-strobe_band-beta_arithmetic-difficulty-dif.png",
#     "sub-all_stim-con_band-40_arithmetic-difficulty-dif.png",
#     "sub-all_stim-con_band-alpha_arithmetic-difficulty-dif.png",
#     "sub-all_stim-con_band-beta_arithmetic-difficulty-dif.png",
# ]

# for subject in subjects:
#     maintained_figs.append(
#         f"sub-{subject:03d}/ses-001/img/sub-{subject:03d}_40Hz-source_stim-strobe_lateral-contrast.png"
#     )

def grab_fig(serverside_relative_path: Path, local_abs_path: Path):
    src = SERVER_DERIV_DIR / serverside_relative_path
    shutil.copy(src, local_abs_path)

if __name__ == "__main__":
    for fig in maintained_figs:
        fig = Path(fig)
        grab_fig(fig, LOCAL_IMG_DIR / fig.name)
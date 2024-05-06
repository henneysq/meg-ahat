from pathlib import Path
import shutil

SERVER_DERIV_DIR = Path("/Volumes/3031004.01/data/derivatives")
LOCAL_IMG_DIR = Path(__file__).parent / "img"
MAINTAINED_FIGS = (
    "sub-all_stim-con_band-40_lateral-dif.png",
    "sub-all_stim-con_band-alpha_lateral-dif.png",
    "sub-all_stim-con_band-beta_lateral-dif.png",
    "sub-all_stim-strobe_band-40_lateral-dif.png",
    "sub-all_stim-strobe_band-alpha_lateral-dif.png",
    "sub-all_stim-strobe_band-beta_lateral-dif.png",
)


def grab_fig(serverside_relative_path: Path, local_abs_path: Path):
    src = SERVER_DERIV_DIR / serverside_relative_path
    shutil.copy(src, local_abs_path)

if __name__ == "__main__":
    for fig in MAINTAINED_FIGS:
        grab_fig(fig, LOCAL_IMG_DIR / fig)
#%%
from pathlib import Path

from colour import plotting, SpectralDistribution
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from PIL import Image, ImageDraw
from scipy.ndimage.filters import gaussian_filter1d
import seaborn as sns

from resutil.plotlib import set_oc_style, set_oc_font
set_oc_style()
#%%

spectrum_dir = Path("/Users/markhenney/Library/CloudStorage/GoogleDrive-mah@optoceutics.com/Shared drives/OC Product/The Light/Photometry/raw spectra")
img_dir = Path("/Users/markhenney/Library/CloudStorage/GoogleDrive-mah@optoceutics.com/Shared drives/OC Clinical/4. Investigator-Initiated Trials/MEG-AHAT/Manuscript/img")
# img_dir = Path(__file__).parent / "img"
# %%
spectrum = pd.read_csv(spectrum_dir / "spectra_organised_ISF.csv", index_col=0)
spectrum.head()
#%%
#
bl = SpectralDistribution(data=spectrum.drop(columns=["cyan_red", "ISF"]).to_dict()["blue_lime"], name="Phase 1")
cr = SpectralDistribution(data=spectrum.drop(columns=["blue_lime", "ISF"]).to_dict()["cyan_red"], name="Phase 2")
isf = SpectralDistribution(data=spectrum.drop(columns=["blue_lime", "cyan_red"])["ISF"].to_dict(), name="ISF")
strobe = SpectralDistribution(data=spectrum.drop(columns=["blue_lime", "cyan_red"]).to_dict()["ISF"], name="STROBE")
fig, ax = plt.subplots(1,1,figsize=(6,8))
fig, ax = plotting.plot_sds_in_chromaticity_diagram_CIE1931(sds=(isf, cr, bl), axes=ax, title="",
                                                  annotate_kwargs={"annotate": False, "size": 8}, render_kwards={})
plt.tight_layout()
plt.show()
fig.savefig(img_dir / "CIE_ISF.pdf")
#%%

fig, ax =plotting.plot_single_sd(bl)
fig, ax =plotting.plot_single_sd(cr)
fig, ax =plotting.plot_single_sd(isf)
#%%
plotting.plot_multi_sds((cr, bl))
#%%
smoothing = 2
norm_factor = np.max(spectrum.iloc[:,1:3].values)
spectrum["smoothed_bl"] = gaussian_filter1d(spectrum.blue_lime, sigma=smoothing) / norm_factor
spectrum["smoothed_cr"] = gaussian_filter1d(spectrum.cyan_red, sigma=smoothing) / norm_factor
spectrum["smoothed_ISF"] = gaussian_filter1d(spectrum.ISF, sigma=smoothing) / norm_factor


set_oc_style()
fig_size = (8,6)
fig, ax = plt.subplots(1,1,figsize=fig_size)
sns.lineplot(data=spectrum, x="wavelength", y="smoothed_bl", label="LED Set 1")
sns.lineplot(data=spectrum, x="wavelength", y="smoothed_cr", label="LED Set 2")
sns.lineplot(data=spectrum, x="wavelength", y="smoothed_ISF", label="ISF")
plt.legend(loc='upper left', title="Light Spectra")
plt.xlim((380, 700))
plt.ylim((-10**-2,  1.1))
plt.ylabel("Relative intensity")
plt.xlabel(r"Wavelength $\lambda$ [nm]")
plt.tight_layout()
# plt.tick_params(axis="x", labelcolor=["turquoise", "orange", "turquoise", "turquoise", "turquoise", "turquoise", "turquoise"])
colors = [(131, 0, 181), (0, 70, 255), (0, 255, 146), (163, 255, 0), (255, 190, 0), (250, 0, 0), (0, 0, 0)]
colors = [np.array(c)/255 for c in colors]
c = 0
for x, xtick in enumerate(ax.get_xticklabels()):
    wavelength = xtick.get_position()[0]
    if not wavelength >= 400:
        continue

    xtick.set_color(colors[c])
    xtick.set_weight="bold"
    xtick.set_size(25)

    c += 1
    if c == 7:
        break

for l in ax.lines:
    x1 = l.get_xydata()[:, 0]
    y1 = l.get_xydata()[:, 1]
    ax.fill_between(x1, y1, color="grey", alpha=0.1)
    ax.margins(x=0, y=0)
plt.savefig(img_dir / "light_spectra.png")
#%%
fig, axes = plt.subplots(3,1,figsize=fig_size)
# for i, spec in enumerate((bl, cr, isf)):
#     ax = axes[i]
plotting.plot_single_sd(cr, axes=axes[0])
plotting.plot_single_sd(bl, axes=axes[1])
# fig, ax =plotting.plot_single_sd(cr)
# fig, ax =plotting.plot_single_sd(isf)

#%%
from colour import MSDS_CMFS
cmfs = MSDS_CMFS["CIE 1931 2 Degree Standard Observer"]
XYZ = plotting.colorimetry.wavelength_to_XYZ(480, cmfs)
print(XYZ)
import colour
print(colour.XYZ_to_sRGB(XYZ))


#%%

n = 30
dt = 3 # ms
time = np.arange(0,int(100/2.5))*2.5
indexer = (time/12.5).astype(int) % 2
isf_1 = np.ones(time.shape)
isf_1 -= indexer
isf_2 = 1 - isf_1

colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
fig, axes = plt.subplots(nrows=3, ncols=1, figsize=fig_size)
sns.lineplot(x=time, y=isf_1, ax=axes[0], color=colors[0])
sns.lineplot(x=time, y=isf_2, ax=axes[0], color=colors[1])
sns.lineplot(x=time, y=isf_1, ax=axes[1], color=colors[2])
sns.lineplot(x=time, y=isf_2+isf_1, ax=axes[2], color=colors[2])
for ax in axes:
    ax.set_ylim((-0.1, 1.4))
    ax.set_xlim((0,50))
    ax.locator_params(axis="y", nbins=3)


    for l in ax.lines:
        x1 = l.get_xydata()[:, 0]
        y1 = l.get_xydata()[:, 1]
        ax.fill_between(x1, y1, color="grey", alpha=0.1)
        ax.margins(x=0, y=0)

axes[0].annotate(text="LED Set 1",xy=(1, 1.1))
axes[0].annotate(text="LED Set 2",xy=(13, 1.1))
axes[0].set_xticklabels([])
axes[1].annotate(text="LED Sets 1 + 2",xy=(1, 1.1))
axes[1].set_xticklabels([])
axes[2].annotate(text="LED Sets 1 + 2",xy=(1, 1.1))

ax = axes[2]

plt.xlabel("Time [ms]")
# plt.legend(loc='center left', title="Light Spectrum")
axes[1].set_ylabel("Relative intensiy")
plt.tight_layout()
plt.savefig(img_dir / "light_phases_timeseries.png")

#%%
n = 30
offset = 7
t = np.linspace(0, .05, n) * 1000 # ms
bl = np.ones((n,1)) * 1
bl[int(n*.125):int(n*.25)+7] = 0
bl[int(n*.75)+7:] = 0
cr = np.ones((n,1)) * 1
cr[:int(n*.25)-7] = 0
cr[int(n*.5):int(n*.75)] = 0
isf = np.ones((n,1)) * 1.01

plt.figure()
plt.plot(t, bl, '--', label="Phase 1")
plt.plot(t, cr, '--', label="Phase 2")
# plt.plot(t, isf, label="ISF")
plt.xlabel("Time [ms]")
plt.legend(loc='center left', title="Light Spectrum")
plt.ylim((-0.01, 1.1))
# plt.tight_layout()
plt.savefig(img_dir / "light_phases_timeseries.png")


#%% Combined images
mpl.rcParams.update(mpl.rcParamsDefault)

img = Image.open(img_dir / "light_spectra.png") 
img1 = Image.open(img_dir / "light_phases_timeseries.png") 


# make a blank image for the text, initialized to transparent text color
txt = Image.new("RGBA", img.size, (255, 255, 255, 0))
d = ImageDraw.Draw(img)
d.text((0, 0), "A", fill=(0, 0, 0, 255), font_size=120, stroke_width=3)
img = Image.alpha_composite(img, txt)

d = ImageDraw.Draw(img1)
d.text((0, 0), "B", fill=(0, 0, 0, 255), font_size=120, stroke_width=3)
img1 = Image.alpha_composite(img1, txt)

# creating a new image and pasting  
# the images 
img2 = Image.new("RGB", (2*img.size[0], img.size[1]), "white") 
  
# pasting the first image (image_name, 
img2.paste(img, (0, 0)) 
  
# # pasting the second image (image_name, 
img2.paste(img1, (img.size[0], 0)) 
  
img2.save(img_dir / "combined_spectrum_plot.png")

# %%
from pathlib import Path

import pandas as pd
import numpy as np

data_dir = Path(
    "/Users/m-hen/Library/CloudStorage/GoogleDrive-mah@optoceutics.com/.shortcut-targets-by-id/1aaC03HwrvY271gWp9k-za9N99zijPsmm/PhD Project - Mark Henney/Projects/DONDERS_MEG-AHAT/power estimation data"
)

df = pd.read_csv(data_dir / "SNR_Intensities.txt", index_col=False)

# %%
df_reduced = df[df["Stimulus"] == "ISF"]
df_reduced = df_reduced[df_reduced["Intensity"] == 3]

# Prepare some list to store variables as we go
within_sub_sigmas = []
sub_means = []

# Iterate over each subject
for sub in df.Subject.unique():
    # For a given subject ...
    df_subject_reduced = df_reduced[df_reduced.Subject == sub]
    # Computed the within subject standard deviation
    within_sub_sigmas.append(df_subject_reduced.SNR_dB.std())
    # Compute the subject mean
    sub_means.append(df_subject_reduced.SNR_dB.mean())

# Average over sample within subject standard deviations
# to obtain the estimated within subject standard deviation
within_sub_sigma = np.mean(within_sub_sigmas)

# Calculate the standard deviation accross subject means
# to estimate the between subject standard deviations
between_sub_sigma = np.std(sub_means)

# Get the number of repetitions
k = df_subject_reduced.__len__()

# Calculate grand-average ISF power
isf_power_average = df_reduced.SNR_dB.mean()

# Do some reporting
print(f"Within subject std.: {within_sub_sigma}")
print(f"Between subject std.: {between_sub_sigma}")
print(f"Number of repetitions: {k}")
print(f"Grand-average: {isf_power_average}")

# Calculate the sample standard deviation
isf_sample_sigma = np.sqrt(between_sub_sigma**2 + within_sub_sigma**2 / k)
# ... and report
print(f"Sample std.: {isf_sample_sigma}")

## Introducing the lateral attention effect
#
# From https://doi.org/10.1111/psyp.14452, we get
# a cohen's d of 0.95 for the lateral difference.
#
# Multiplying this by the sample variance, we get the
# expected mean difference:
cohens_d = 0.95
expected_attention_difference = cohens_d * isf_sample_sigma
print(f"Expected difference: {expected_attention_difference} dB")

# %%
# Estimate effect of working memory
chi_sq = 12.97
dof = 15
# Make conversion from chi square to correlation coefficient r
# https://www.campbellcollaboration.org/escalc/html/EffectSizeCalculator-R5.php
r = 0.9299

# Conversion of correlation coefficient
# to cohen's d
# (DOI: 10.1037/1082-989X.13.1.19; Table 1, equal sized groups)
d = 2 * r / (np.sqrt(1 - r**2))
expected_workmem_difference = d * isf_sample_sigma
print(f"Expected working memory difference: {expected_workmem_difference} dB")


# %%
####################
#                  #
##                 #
##                ##
## Now for Strobe ## NORMALISED TO POWER OF DOI: 10.3389/fnagi.2022.1010765
##                ##
#                  #
#                  #
df_reduced = df[df["Stimulus"] == "STROBE"]
df_reduced = df_reduced[df_reduced["Intensity"] == 3]

# Calculate grand-average ISF power
strobe_grand_average = df_reduced.SNR_dB.mean()

# Normalise to Kachatryan et. al. 2022
kachatryan_strobe_power = 3.1
df_reduced["SNR_dB"] *= kachatryan_strobe_power / strobe_grand_average

# Prepare some list to store variables as we go
within_sub_sigmas = []
sub_means = []

# Iterate over each subject
for sub in df.Subject.unique():
    # For a given subject ...
    df_subject_reduced = df_reduced[df_reduced.Subject == sub]
    # Computed the within subject standard deviation
    within_sub_sigmas.append(df_subject_reduced.SNR_dB.std())
    # Compute the subject mean
    sub_means.append(df_subject_reduced.SNR_dB.mean())

# Average over sample within subject standard deviations
# to obtain the estimated within subject standard deviation
within_sub_sigma = np.mean(within_sub_sigmas)

# Calculate the standard deviation accross subject means
# to estimate the between subject standard deviations
between_sub_sigma = np.std(sub_means)

# Get the number of repetitions
k = df_subject_reduced.__len__()

# Do some reporting
print(f"Within subject std.: {within_sub_sigma}")
print(f"Between subject std.: {between_sub_sigma}")
print(f"Number of repetitions: {k}")
print(f"Grand-average: {df_reduced.SNR_dB.mean()}")

# Calculate the sample standard deviation
strobe_sample_sigma = np.sqrt(between_sub_sigma**2 + within_sub_sigma**2 / k)
# ... and report
print(f"Sample std.: {strobe_sample_sigma}")

expected_workmem_difference = abs(3.1 - 3.96)
cohens_d_workmem = expected_workmem_difference * strobe_sample_sigma
expected_workmem_difference = cohens_d_workmem * isf_sample_sigma
print(f"Expected working memory difference: {expected_workmem_difference} dB")
# %%

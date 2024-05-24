# Table of Contents
1. [Inspection of raw1 Data](#inspection-of-raw1-data)
2. [Data Preprocessing](#data-preprocessing)
3. [Exploratory Analysis of Behaviour](#exploratory-analysis-of-behaviour)


# Inspection of raw1 Data

This section was written based on the outputs of the [`inspect_raw1.m`](https://github.com/henneysq/meg-ahat/blob/main/analysis/inspect_raw1.m). It serves as a fast basic quality assurance step during data collection. The anatomical MRI, MEG events, and MEG time series are inspected. The general tendencies are highlighted, and any deviances from these are described.

Subjects inspected so far:

[1 2 3 4 5 6 7 10 12 14 15 16 19 20]

## Anatomical MRI

All subjects have good coverage on the FOV of the MRI.

## MEG Events

The triggers in general follow the expected patter with runs and blocks clearly visible.

The VA experiment is fully satisfactory with regards to events. It has an initial trigger (1) and a final trigger (8) that outline the beginning and end of the experiment. Also, the quick trial (9) and catch trial (10) triggers are evident.

For subjects [1:7 10 12 14 16 19 20], the WM experiment is found to be missing trigger 7 (response) in the events. It should have been [right after getting the response](https://github.com/henneysq/meg-ahat/blob/8bc5dec6476df06477e73449c7667a5e34a15671/experiment_management/experiment_manager_wm.py#L236) as is the case for the [code for the VA experiment](https://github.com/henneysq/meg-ahat/blob/8bc5dec6476df06477e73449c7667a5e34a15671/experiment_management/experiment_manager_va.py#L263). 
This issue is fixed in commit [b7a8843](https://github.com/henneysq/meg-ahat/commit/b7a88433b2477bfbe1cf73027890c64d80d4938d) but affects the data in the following ways:

1. Reaction times can not be calculated as the duration between trigger 6 (result) and 7 (response). However, the reaction time can be queried directly from the behavioural log, in which it was calculated and noted live. Thus, it is not of major consequence.
2. Trial definition can not rely on the response trigger. This should, however, not be necessary, as the main research question relates to the period of calculating and remembering the result.

Additionally, the trigger 8 (final-trigger) is never sent in the WM experiment. This means that it can not be used as a backstop to outline the experiment. However, no triggers are supposed to be present after this point anyway.


| ![meg_events.png](./img/meg_events.png) | 
|:--:| 
| **MEG event trigger values as a function of time (early representative recording):** The experiment structure is clearly visible. The first experiment has an initial trigger (1) and final trigger (8) outlining it. The second experiment is missing the final trigger. Also, the second experiment is missing the response triggers (7).|

| ![alt text](./img/sub-017_meg_events.png) | 
|:--:| 
| **MEG event trigger values as a function of time (late representative recording):** The experiment structure is clearly visible. The first experiment has an initial trigger (1) and final trigger (8) outlining it. The previously missing trigger are now evident after rectifying the mistake.|

### sub-019

In the subject 19 recording, the MEG events for the VA and WM experiment are reversed, such that the WM experiment triggers are before the VA experiment triggers. This is because I forgot to press the CTF start button and only realised after the VA experiment.
"Luckily", the subject did not tolerate the WM experiment very well, which is why only 6 of the intended 10 blocks are recorded and ends with a trigger 11 (early exit). The subject was very keen on redoing the VA experiment, and there was time leftover for this.

| ![alt text](./img/sub-019_meg_events.png) | 
|:--:| 
| **Subject 19 MEG Events:** The experiment structure is clearly visible, but the order of runs (and thus events) are reversed for subject 19. |

## MEG Time Series

The MEG sensor time series were broken down into arbitrary 1-second segments to look for any suspicious temporal changes. Below is the typical output of 1-second segmenting (including only meg sensor channels) for one subject.

| ![alt text](./img/1sec_segments.png) | 
|:--:| 
| **MEG time series segmented into arbitrary 1-second segments:** Top left shows the segment variance colour coded as a function of channel number and segment (trial number). The top right shows the variance as a function of channel number. The bottom left shows the variance as a function of segment (trial number).|

As far as I can tell, this looks like it's behaving as expected: There is a clear temporal structure following the changing light conditions. The variance over "trials" (1 sec segments) has two clear plateaus (which I attribute to the changing current in the LEDs) as well as some randomness. It will be interesting to investigate how much of the random variance is in the narrow 40 Hz band. The channels are affected to a varying degree (but consistently over time), which must be expected from the geometrical differences.

There appears to consistently be one (or some) outlier(s) at the very end of the recording, but this is probably to be expected as the subjects are told that the experiment is over, but the recording has not yet been terminated.

| ![img/1sec_seg_outlier.png](./img/1sec_seg_outlier.png) | 
|:--:| 
| **MEG time series segmented into arbitrary 1-second segments:** The recordings typically have a (or some) *very* high variance segment(s) towards the very end (notice the single observation at ~(2900, 1.38e-21)). This is suspected to arise during the interim period between the experiment ending and the recording ending. |

### sub-004

Subject 4 has a behaviour slightly outside the remaining subjects. There are several high variance "outliers" - they seem to follow a temporal structure sucht that they are clustered closely together (perhaps within a trial). However, in contrast to other subjects, they are not "plateaued" as is expected if the variance is due to field picked up directly from the changing currents - they vary in magnitude. HOWEVER! There is another lower plateau below it. This would indicate that one of the 40 Hz stimuli leads to a signal variance dominated by the artefact picked up directly from the LEDs, while the other is dominated by (or at least has eqiuvalent contribution from) another signal with varying amplitude (which could be cortical response). This warrants further investigation. Subject 4 was the oldest (> 50 yrs?) participant.

Below the segment variance is plotted with iteratively more high variance segments removed to investigate the pattern.

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

| ![alt text](./img/1sec_seg_sub-004_00.png) | 
|:--:| 
| **Subject 4 MEG time series segmented:** A few very high variance segments dominate the dynamic range of the colour coding - they are removed next. |

| ![alt text](./img/1sec_seg_sub-004_01.png) | 
|:--:| 
| **Subject 4 MEG time series segmented - few rejections:** There is a high variability in the variance, and it seems to cluster together in short durations. |

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

| ![alt text](./img/1sec_seg_sub-004_02.png) | 
|:--:| 
| **Subject 4 MEG time series segmented - more rejections:** There is a high variability in the variance, though now atleast one platuau is visible. |


### sub-012

Subject 12 appears to have a distinctive temporal structure in the very high variance segments. It declines roughly with the progress of experiment 1 (<~1000th "trial"). There is a slight increase again at the point where the second experiment begins (or the interim period where they could be moving more). There is a final "bump" close to the end - i.e. around the beginning of the last block of the second experiment. This could indicate a higher degree of engagement with the experiment.


| ![alt text](./img/1sec_seg_sub-012_00.png) | 
|:--:| 
| **Subject 12 MEG time series segmented:** There is a temporal dependency of the variability in segment variance. |

The two channel with the highest variance are removed one at a time to uncover more details.

| ![alt text](./img/1sec_seg_sub-012_01.png) | 
|:--:| 
| **Subject 12 MEG time series segmented - removed 1 channel:** There is a temporal dependency of the variability in segment variance. |


| ![alt text](./img/1sec_seg_sub-012_02.png) | 
|:--:| 
| **Subject 12 MEG time series segmented - removed 2 channels:** There is a temporal dependency of the variability in segment variance, though it is less pronounced with the higher dynamic range. |

Then, finally a lot of segments are removed to uncover that the two plateaus are also present.


| ![alt text](./img/1sec_seg_sub-012_03.png) | 
|:--:| 
| **Subject 12 MEG time series segmented - removed channels and segments:** When removing the highest variance channels and segments, the plateauing behaviour returns. |

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

# Data Preprocessing

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>


| ![alt text](/Volumes/3031004.01/data/derivatives/sub-001/ses-001/img/10_trial_artefact.png) | 
|:--:| 
| **MEG Timeseries of 10 Trials with Artefact:** Legend...|


# Exploratory Analysis of Behaviour

This section was written based on the outputs of the module [`inspect_beh.py`](https://github.com/henneysq/meg-ahat/blob/main/analysis/inspect_beh.py). It serves to highlight the tendencies of the behavioural data on a group level.

## Visual attention experiment

In the visual attention experiment, summarised graphically below, the behavioural results appear to be minute. However, the difficulty of the task seems appropriate as there is not a saturation in the fraction of correct responses, and nor is it close to random responses (50%).

The distributions of reaction times grouped by light stimulus are nearly indistinguishable, as is the case for the fraction of correct responses.

For task (grating) congruence, the reaction times appear to be slightly faster for the congruent case than the incongruent case, but the fraction of correct responses are similar.

When grouped by the visual attention side, the left side reaction times may be ever so slightly faster, but more notably, the fraction of correct responses is higher for the left side than the right side. **Could the latter observation be a matter of eye dominance?**

| ![alt text](./img/sub-all_run-001_task-visualattention.png) | 
|:--:| 
| **Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|


## Working memory experiment

In the working memory experiment behavioural results presented graphically below, there are some more notable differences. Again, the difficulty of the task seems appropriate as there is not a saturation in the fraction of correct responses, and nor is it close to random responses (50%).

When grouping by light stimulus, the reaction times are very similar, but the fraction of correct responses appears to be slightly higher for the continuous light (0 Hz) condition.

The effect of the sum correctness appears to have an effect on the reaction time and the correct responses. Responses to trials with correct sums are both more rapid and more correct than when the sums are incorrect.

Arithmetic difficulty appears to have a small effect on the reaction time, in which the lower difficulty leads to faster responses. There is a big (and expected) difference in the fraction of correct responses.


| ![alt text](./img/sub-all_run-002_task-workingmemory.png) | 
|:--:| 
| **Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |


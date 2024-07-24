
<style>
  red { color: Red }
ora { color: Orange }
gre { color: Green }
blu { color: blue }
pur { color: purple }

.vaTwoWayConStrobe {
  text-align: center;
}
.vaTwoWayConStrobe th {
  background: white;
    word-wrap: break-word;
}
.vaTwoWayConStrobe tr:nth-child(1) { background: white; }
.vaTwoWayConStrobe tr:nth-child(2) { background: gray; }
.vaTwoWayConStrobe tr:nth-child(3) { background: white; }

.vaCon {
  text-align: center;
}
.vaCon th {
  background: white;
    word-wrap: break-word;
}
.vaCon tr:nth-child(1) { background: white; }
.vaCon tr:nth-child(2) { background: gray; }
.vaCon tr:nth-child(3) { background: gray; }

.vaStrobe {
  text-align: center;
}
.vaStrobe th {
  background: white;
    word-wrap: break-word;
}
.vaStrobe tr:nth-child(1) { background: gray; }
.vaStrobe tr:nth-child(2) { background: gray; }
.vaStrobe tr:nth-child(3) { background: white; }

</style>

# Data Analysis <!-- omit in toc -->

This document describes the figures that show the results of the study.

## Table of Contets <!-- omit in toc -->

- [1. Visual Attention Experiment](#1-visual-attention-experiment)
  - [1.1. Data description](#11-data-description)
  - [1.2. Behaviour](#12-behaviour)
  - [1.3. Sensor Level](#13-sensor-level)
  - [1.4. Source Level](#14-source-level)
    - [1.4.1. Interaction effect between lateralised attention and visual stimulation](#141-interaction-effect-between-lateralised-attention-and-visual-stimulation)
    - [1.4.2. Flicker versus non-flickering stimulus contrast](#142-flicker-versus-non-flickering-stimulus-contrast)
    - [1.4.3. Left versus right attention stratified by visual stimulus](#143-left-versus-right-attention-stratified-by-visual-stimulus)
      - [1.4.3.1. No flicker (con)](#1431-no-flicker-con)
      - [1.4.3.2. Flicker (strobe)](#1432-flicker-strobe)
- [2. Arithmetic experiment](#2-arithmetic-experiment)
  - [2.1. Data description](#21-data-description)
  - [2.2. Behaviour](#22-behaviour)
  - [2.3. Sensor Level](#23-sensor-level)
  - [2.4. Source Level](#24-source-level)
    - [Interaction effect between arithmetic difficulty and visual stimulation](#interaction-effect-between-arithmetic-difficulty-and-visual-stimulation)
- [3. Appendix](#3-appendix)
  - [3.1. Behaviour By Subject](#31-behaviour-by-subject)
    - [3.1.1. Visual attention experiment](#311-visual-attention-experiment)
    - [3.1.2. Arithmetic experiment](#312-arithmetic-experiment)
  - [3.2. Sensor Level Analysis by Subject](#32-sensor-level-analysis-by-subject)

# 1. Visual Attention Experiment

## 1.1. Data description

The factorial table below describes the levels in the $2 \times 3$ design with the two factors *lateral attention* (two levels: $left$ & $right$) and *visual stimulus* (three levels: $con$, $isf$ & $strobe$). The data matrix $\mathbf{A}$ refers to a given functional measure (i.e. sensor or source level 40 Hz power), and the subscripted indices refer to subsets of the data pertaining to given factor level combinations.

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{left,con}$    | $\mathbf{A}_{right,con}$    |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\mathbf{A}_{left,strobe}$ | $\mathbf{A}_{right,strobe}$ |
|


## 1.2. Behaviour

In the visual attention experiment, summarised graphically below, the behavioural results appear to be minute. However, the difficulty of the task seems appropriate as there is not a saturation in the fraction of correct responses, nor is it close to random responses (50%).

The distributions of reaction times grouped by light stimulus are nearly indistinguishable, as is the case for the fraction of correct responses. Perhaps, there is a tendency for higher correct response rate during 40 Hz LF.

For task (grating) congruence, the reaction times appear very similar. The fraction of correct responses is slightly higher for the incongruent case, though this may be driven mostly by subjecet 23 who appears to have responded randomly congruent cases.

When grouped by the visual attention side, the distributions for reaction time and correct responses are both very similiar. However, again subject 23 appears to have answered randomly only in the case of left attention. **Could the latter observation be a matter of eye dominance?**

| ![alt text](./img/sub-all_run-001_task-visualattention.png) | 
|:--:| 
| **Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-023_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 23 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|


## 1.3. Sensor Level

The following plots show the contrast between the static light (`con`) and visual (luminance) flicker (`strobe`) as a grand average across trials and subjects. The plots are based on the power in three bands: Narrow gamma [40;40] Hz, alpha [7; 15] Hz, and beta [13; 30] Hz.

| ![alt text](./img/sub-all_stim-con_band-40_lateral-dif.png) | ![alt text](./img/sub-all_stim-strobe_band-40_lateral-dif.png) | 
|:--:| :--:| 

**Visual Attention Lateral Contrast 40 Hz:** Contrast between left and right visual attention conditions in the narrow gamma [39; 41] Hz range.


| ![alt text](./img/sub-all_stim-con_band-alpha_lateral-dif.png) | ![alt text](./img/sub-all_stim-strobe_band-alpha_lateral-dif.png) | 
|:--:| :--:| 

**Visual Attention Lateral Contrast alpha band:** Contrast between left and right visual attention conditions in the alpha [7; 15] Hz range.


| ![alt text](./img/sub-all_stim-con_band-beta_lateral-dif.png) | ![alt text](./img/sub-all_stim-strobe_band-beta_lateral-dif.png) | 
|:--:| :--:| 

**Visual Attention Lateral Contrast beta band:** Contrast between left and right visual attention conditions in the beta [13; 30] Hz range.


## 1.4. Source Level

### 1.4.1. Interaction effect between lateralised attention and visual stimulation

<div class="vaTwoWayConStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\blue{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |
|

</div>


The following two-way contrast of left versus right lateral attention and flicker (strobe) versus no flicker (con) shows the interaction effect between lateralised attention and visual stimulation on the 40 Hz source power. It is decribed mathematically as:


$(\red{\mathbf{A}_{right,strobe}} - \purple{\mathbf{A}_{left,strobe}}) - (\blue{\mathbf{A}_{right,con}} - \orange{\mathbf{A}_{left,con}})$



Here, we expect to find an 

| ![alt text](./img/task-va_contrast-tasklevel-left-right_permutation-stimcondition-con-strobe_npermut-1500.png) | 
|:--:| 
| **Visual Attention two-way contrast permutation:** Source estimate contrast between VA task levels (right minus left attention), permutation tested between continuous and strobe stimulus conditions. The plotted values indicate the two-way contrast averaged across subjects; no significant clusters are found, thus the entire statistics volumes is shown without masking. Colourbar indicates t-values estimated from the paired observations across subjects (?). |

### 1.4.2. Flicker versus non-flickering stimulus contrast

<div class="vaTwoWayConStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\orange{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\red{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |
|

</div>

The following contrast of flicker (strobe) versus no flicker (con) shows the difference in 40 Hz steady-state visually evoked field (SSVEF) source power between the stimulus conditions, described from the factorial table as:

$\red{\mathbf{A}_{strobe}} - \orange{\mathbf{A}_{con}},$

where the data is collapsed across the lateral attention factor levels (i.e. $\red{\mathbf{A}_{strobe}}$ is the union of $\red{\mathbf{A}_{left,strobe}}$ and $\red{\mathbf{A}_{right,strobe}}$).

We expect that..

| ![alt text](./img/task-va_permutation-stimcondition-con-strobe_npermut-1500.png) | 
|:--:| 
| **Visual Attention permutation of continuous and stroboscopic flicker:** Source estimate of the VA task permuted between continuous and stroboscopic flicker. The sources were estimated across trials from both levels of the VA task levels. The plotted values indicate the contrast averaged across subjects; no significant clusters are found. Colourbar indicates t-values estimated from the paired observations across subjects (?). |


### 1.4.3. Left versus right attention stratified by visual stimulus

#### 1.4.3.1. No flicker (con)

<div class="vaCon">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\blue{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\mathbf{A}_{left,strobe}$ | $\mathbf{A}_{right,strobe}$ |
|

</div>

The following contrast of right versus left lateral attention shows the differencein 40 Hz source power during non-flickering (con) stimulation. It is decribed mathematically as:

$\blue{\mathbf{A}_{right,con}} - \orange{\mathbf{A}_{left,con}}.$

We expect that..

| ![alt text](./img/task-va_stimcondition-con_permutation-tasklevel-left-right_npermut-1500.png) | 
|:--:| 
| **Visual Attention permutation of task levels within continuous stim condition:** Source estimate of the VA task during continuous light stimulation, permuted between task levels. The plotted values indicate the contrast averaged across subjects; no significant clusters are found. Colourbar indicates t-values estimated from the paired observations across subjects (?). |

#### 1.4.3.2. Flicker (strobe)

<div class="vaStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{left,con}$ | $\mathbf{A}_{right,con}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |
|

</div>

The following contrast of right versus left lateral attention shows the differencein 40 Hz source power during flickering (strobe) stimulation. It is decribed mathematically as:


$\red{\mathbf{A}_{right,strobe}} - \purple{\mathbf{A}_{left,strobe}}.$

We expect that..

| ![alt text](./img/task-va_stimcondition-strobe_permutation-tasklevel-left-right_npermut-1500.png) | 
|:--:| 
| **Visual Attention permutation of task levels within stroboscopic stim condition:** Source estimate of the VA task during stroboscopic light stimulation, permuted between task levels. The plotted values indicate the contrast averaged across subjects; no significant clusters are found. Colourbar indicates t-values estimated from the paired observations across subjects (?). |

<div style="page-break-after: always;"></div>


# 2. Arithmetic experiment

## 2.1. Data description

The factorial table below describes the levels in the $2 \times 3$ design with the two factors *arithmetic difficulty* (two levels: $low$ & $high$) and *visual stimulus* (three levels: $con$, $isf$ & $strobe$). The data matrix $\mathbf{A}$ refers to a given functional measure (i.e. sensor or source level 40 Hz power), and the subscripted indices refer to subsets of the data pertaining to given factor level combinations.

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{low,con}$    | $\mathbf{A}_{high,con}$    |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\mathbf{A}_{low,strobe}$ | $\mathbf{A}_{high,strobe}$ |
|

## 2.2. Behaviour

In the arithmetic experiment behavioural results presented graphically below, there are some more notable differences. Again, the difficulty of the task seems appropriate as there is not a saturation in the fraction of correct responses, and nor is it close to random responses (50%).

When grouping by light stimulus, the reaction times are very similar, but the fraction of correct responses appears to be slightly higher for the continuous light (0 Hz) condition.

The effect of the sum correctness appears to have an effect on the reaction time and the correct responses. Responses to trials with correct sums are both more rapid and more correct than when the sums are incorrect.

Arithmetic difficulty appears to have a small effect on the reaction time, in which the lower difficulty leads to faster responses. There is a big (and expected) difference in the fraction of correct responses.


| ![alt text](./img/sub-all_run-002_task-workingmemory.png) | 
|:--:| 
| **Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

## 2.3. Sensor Level

TODO

## 2.4. Source Level

### Interaction effect between arithmetic difficulty and visual stimulation

<div class="vaTwoWayConStrobe">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{low,con}}$    | $\blue{\mathbf{A}_{high,con}}$    |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{low,strobe}}$ | $\red{\mathbf{A}_{high,strobe}}$ |
|

</div>

The following two-way contrast of high versus low arithmetic difficulty and flicker (strobe) versus no flicker (con) shows the interaction effect between arithmetic difficulty and visual stimulation on the 40 Hz source power. It is decribed mathematically as:


$(\red{\mathbf{A}_{high,strobe}} - \purple{\mathbf{A}_{low,strobe}}) - (\blue{\mathbf{A}_{high,con}} - \orange{\mathbf{A}_{low,con}})$

We expect that..

| ![alt text](./img/task-wm_contrast-tasklevel-low-high_permutation-stimcondition-con-strobe_npermut-1500.png) | 
|:--:| 
| **Arithmetic two-way contrast permutation:** Source estimate contrast between WM task levels (high minus low arithmetic difficulty), permutation tested between continuous and strobe stimulus conditions. The plotted values indicate the contrast averaged across subjects, and the opaque area is the significant cluster. Colourbar indicates t-values estimated from the paired observations across subjects (?). |


| ![alt text](./img/task-wm_permutation-stimcondition-con-strobe_npermut-1500.png) | 
|:--:| 
| **Arithmetic permutation of continuous and stroboscopic flicker:** Source estimate of the WM task permuted between continuous and stroboscopic flicker. The sources were estimated across trials from both levels of the WM task levels. The plotted values indicate the contrast averaged across subjects; no significant clusters are found. Colourbar indicates t-values estimated from the paired observations across subjects (?). |


| ![alt text](./img/task-wm_stimcondition-con_permutation-tasklevel-low-high_npermut-1500.png) | 
|:--:| 
| **Arithmetic permutation of task levels within continuous stim condition:** Source estimate of the WM task during continuous light stimulation, permuted between task levels. The sources were estimated across trials from both levels of the WM task levels. The plotted values indicate the contrast averaged across subjects, and the opaque area is the significant cluster. Colourbar indicates t-values estimated from the paired observations across subjects (?). |


| ![alt text](./img/task-wm_stimcondition-strobe_permutation-tasklevel-low-high_npermut-1500.png) | 
|:--:| 
| **Arithmetic permutation of task levels within stroboscopic stim condition:** Source estimate of the WM task during stroboscopic light stimulation, permuted between task levels. The sources were estimated across trials from both levels of the WM task levels. The plotted values indicate the contrast averaged across subjects, and the opaque area is the significant cluster. Colourbar indicates t-values estimated from the paired observations across subjects (?). |

<div style="page-break-after: always;"></div>

# 3. Appendix

## 3.1. Behaviour By Subject

### 3.1.1. Visual attention experiment


| ![alt text](./img/sub-008_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 8 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-009_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 9 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-011_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 11 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-013_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 13 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-017_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 17 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-018_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 18 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-021_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 21 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-022_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 22 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-025_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 25 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-027_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 27 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-028_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 28 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

| ![alt text](./img/sub-029_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 29 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.

### 3.1.2. Arithmetic experiment

| ![alt text](./img/sub-008_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 8 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-011_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 11 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-013_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 13 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-017_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 17 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-018_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 18 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-021_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 218 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-022_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 22 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-023_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 23 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-025_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 25 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-027_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 27 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-028_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 28 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

| ![alt text](./img/sub-029_run-002_task-workingmemory.png) | 
|:--:| 
| **Subject 29 Working Memory Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty. |

## 3.2. Sensor Level Analysis by Subject
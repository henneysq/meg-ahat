
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

This document describes the results of the MEG-AHAT study.

## Abbreviations \& Nomenclature  <!-- omit in toc -->

The following terms and abbreviations are used interchangably:

* Continuous stimulation, CON, con, static light, 0 Hz
* Invisible Spectral Flicker, ISF, isf
* Strobocopic flicker, STROBE, strobe, luminance flicker, LF
* Power spectrum, PSD

## 0.1. Notes

* Check potential NAN values of source plots
  * Potentially use inward shift
  * Unit for plots (dB for sensor level, T values for source)
  * In source plots (about masking), "masked for significance of the hypothesis test ...  clusters based on cluster-permutation test
  * Unexpected lateral differences can be caused by confounding effects of stimulation side related purely to devices.
  * recommendations: If simmetric stimulation is used in the future, the lateraliseation of devices should be balanced between devices.
  * Computed PSD as 10*log10(x1/x2)
  * Conculsion: The visual attention experiment failed
  * Con/strobe conditions could have been implemented with known presentation equipment rather than stimulation devices to control the positive/negative control conditions.
  * Check that subtractions are in the same direction
  * Read up on lateralisation of math processing

## Table of Contets <!-- omit in toc -->

- [1. Visual Attention Experiment](#1-visual-attention-experiment)
  - [1.1. Data description](#11-data-description)
  - [1.2. Behaviour](#12-behaviour)
  - [1.3. Static (continuous) stimulus](#13-static-continuous-stimulus)
  - [1.4. Strobocopic (flicker) stimulus](#14-strobocopic-flicker-stimulus)
  - [1.5. Flicker versus non-flickering stimulus contrast](#15-flicker-versus-non-flickering-stimulus-contrast)
  - [1.6. Left versus right attention stratified by visual stimulus](#16-left-versus-right-attention-stratified-by-visual-stimulus)
    - [1.6.1. No flicker (con)](#161-no-flicker-con)
    - [1.6.2. Flicker (strobe)](#162-flicker-strobe)
  - [1.7. Interaction effect between lateralised attention and visual stimulation](#17-interaction-effect-between-lateralised-attention-and-visual-stimulation)
- [2. Arithmetic experiment](#2-arithmetic-experiment)
  - [2.1. Data description](#21-data-description)
  - [2.2. Behaviour](#22-behaviour)
  - [2.3. Static (continuous) stimulus](#23-static-continuous-stimulus)
  - [2.4. Strobocopic (flicker) stimulus](#24-strobocopic-flicker-stimulus)
  - [2.5. Flicker versus non-flickering stimulus contrast](#25-flicker-versus-non-flickering-stimulus-contrast)
  - [2.6. High versus low arithmetic difficulty stratified by visual stimulus](#26-high-versus-low-arithmetic-difficulty-stratified-by-visual-stimulus)
    - [2.6.1. No flicker (con)](#261-no-flicker-con)
    - [2.6.2. Flicker (strobe)](#262-flicker-strobe)
  - [2.7. Interaction effect between arithmetic difficulty and visual stimulation](#27-interaction-effect-between-arithmetic-difficulty-and-visual-stimulation)
- [3. Appendix](#3-appendix)
  - [3.1. Behaviour By Subject](#31-behaviour-by-subject)
    - [3.1.1. Visual attention experiment](#311-visual-attention-experiment)
    - [3.1.2. Arithmetic experiment](#312-arithmetic-experiment)
  - [3.2. Sensor Level Analysis by Subject](#32-sensor-level-analysis-by-subject)
- [4. ARCHIVE](#4-archive)
  - [4.1. Sensor Level](#41-sensor-level)

<div style="page-break-after: always;"></div>

# 1. Visual Attention Experiment

## 1.1. Data description

The factorial table below describes the levels in the $2 \times 3$ design with the two factors *lateral attention* (two levels: $left$ & $right$) and *visual stimulus* (three levels: $con$, $isf$ & $strobe$). The data matrix $\mathbf{A}$ refers to a given functional measure (i.e. sensor or source level 40 Hz power), and the subscripted indices refer to subsets of the data pertaining to given factor level combinations.

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{left,con}$    | $\mathbf{A}_{right,con}$    |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\mathbf{A}_{left,strobe}$ | $\mathbf{A}_{right,strobe}$ |


## 1.2. Behaviour

In the visual attention experiment, summarised graphically below, the behavioural results appear to be minute. However, the difficulty of the task seems appropriate as there is not a saturation in the fraction of correct responses, nor is it close to random responses (50%).

The distributions of reaction times grouped by light stimulus are nearly indistinguishable, as is the case for the fraction of correct responses. Perhaps, there is a tendency for higher correct response rate during 40 Hz LF.

For task (grating) congruence, the reaction times appear very similar. The fraction of correct responses is slightly higher for the incongruent case, though this may be driven mostly by subjecet 23 who appears to have responded randomly congruent cases.

When grouped by the visual attention side, the distributions for reaction time and correct responses are both very similiar. However, again subject 23 appears to have answered randomly only in the case of left attention. **Could the latter observation be a matter of eye dominance?**

![alt text](./img/sub-all_run-001_task-visualattention.png) 
**Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.


<div style="page-break-after: always;"></div>

## 1.3. Static (continuous) stimulus

<div class="vaCon">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\orange{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\mathbf{A}_{left,strobe}$ | $\mathbf{A}_{right,strobe}$ |

</div>

The following shows the average power spectrum and 40 Hz sensor and source power during non-flickering (con) stimulation. It is decribed mathematically as:

$\orange{\mathbf{A}_{con}} = \orange{\mathbf{A}_{left,con}} \cup \orange{\mathbf{A}_{right,con}}$

We expect that the power spectrum follows a $\frac{1}{f^a}$ shape with only the line noise peak at 50 Hz deviating. Stratifying by left and right attention is not expected to impact the shape of the PSD notably in the $[30; 50]$ Hz range.

The PSDs behave as expected. There is a ~9 dB difference in broadband power between the highest and the lowest channels. From the topographic plot of 40 Hz power, it is evident that the highest power is observed in the temporal channels with decent lateral symmetry. The difference in 40 Hz power in the topography plot reflects broadband differences rather than specifically at 40 Hz.

![alt text](./img/task-va_stim-con_psd.png)
**Visual Attention continuous stim condition:** $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{con}}))$, where $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

| ![alt text](./img/task-va_tasklevel-left_stim-con_psd.png) | ![alt text](./img/task-va_tasklevel-right_stim-con_psd.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{left,con}}))$ | $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{right,con}}))$|

![alt text](./img/task-va_stim-con_topo.png)
**Visual Attention continuous stim condition:** $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{con}},40\ \mathrm{Hz}))$, where $P(\orange{\mathbf{A}_{con}},40\ \mathrm{Hz})$ is the average 40 Hz power of the $\orange{\mathbf{A}_{con}}$ data subset.

| ![alt text](./img/task-va_tasklevel-left_stim-con_topo.png) | ![alt text](./img/task-va_tasklevel-right_stim-con_topo.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{left,con}}, 40\ \mathrm{Hz}))$ | $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{right,con}}, 40\ \mathrm{Hz}))$|


<div style="page-break-after: always;"></div>

## 1.4. Strobocopic (flicker) stimulus

<div class="vaStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{left,con}$ | $\mathbf{A}_{right,con}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\red{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |

</div>

The following contrast of right versus left lateral attention shows the difference in 40 Hz source power during flickering (strobe) stimulation. It is decribed mathematically as:

$\red{\mathbf{A}_{strobe}} = \red{\mathbf{A}_{left,strobe}} \cup \red{\mathbf{A}_{right,strobe}}$

We expect that..

![alt text](./img/task-va_stim-strobe_psd.png)
**Visual Attention stroboscopic stim condition:** $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{strobe}}))$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset.

| ![alt text](./img/task-va_tasklevel-left_stim-strobe_psd.png) | ![alt text](./img/task-va_tasklevel-right_stim-strobe_psd.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{left,strobe}}))$ | $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{right,strobe}}))$|


![alt text](./img/task-va_stim-strobe_topo.png)
**Visual Attention stroboscopic stim condition:** $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{strobe}}, 40\ \mathrm{Hz}))$, where $P(\red{\mathbf{A}_{strobe}}, 40\ \mathrm{Hz})$ is the average 40 Hz power of the $\red{\mathbf{A}_{strobe}}$ data subset.

| ![alt text](./img/task-va_tasklevel-left_stim-strobe_topo.png) | ![alt text](./img/task-va_tasklevel-right_stim-strobe_topo.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{left,strobe}}, 40\ \mathrm{Hz}))$ | $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{right,strobe}}, 40\ \mathrm{Hz}))$|


<div style="page-break-after: always;"></div>

## 1.5. Flicker versus non-flickering stimulus contrast

<div class="vaTwoWayConStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\orange{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\red{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |

</div>

The following contrast of flicker (strobe) versus no flicker (con) shows the difference in 40 Hz steady-state visually evoked field (SSVEF) source power between the stimulus conditions, described from the factorial table as:

$\red{\mathbf{A}_{strobe}} - \orange{\mathbf{A}_{con}},$

where the data is collapsed across the lateral attention factor levels (i.e. $\red{\mathbf{A}_{strobe}} = \red{\mathbf{A}_{left,strobe}} \cup \red{\mathbf{A}_{right,strobe}}$, and $\orange{\mathbf{A}_{con}} = \orange{\mathbf{A}_{left,con}} \cup \orange{\mathbf{A}_{right,con}}$).

We expect that..

![alt text](./img/task-va_contrast-con-strobe_psd.png)
**Visual Attention flicker versus no-flicker PSD:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{strobe}})}{P(\orange{\mathbf{A}_{con}})})$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset, and $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

![alt text](./img/task-va_contrast-con-strobe_topo.png)
**Visual Attention flicker versus no-flicker 40 Hz sensor power:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{strobe}})}{P(\orange{\mathbf{A}_{con}})})$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset, and $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

![alt text](./img/task-va_permutation-stimcondition-con-strobe_npermut-1500.png)
**Visual Attention flicker versus no-flicker 40 Hz source power:** Contrast of the flicker versus no flicker 40 Hz Source estimates during visual attention task (averaged over task levels). Colourbar indicates the $t$-values for the estimated parameter contrast $\hat{\beta} = \red{\mathbf{A}_{strobe}} - \orange{\mathbf{A}_{con}}$. Testing for the null hypothesis that the two stimulation conditions were interchangeble using non-parametric cluster-based permutation tests revealed no significant differences.


<div style="page-break-after: always;"></div>

## 1.6. Left versus right attention stratified by visual stimulus

### 1.6.1. No flicker (con)

<div class="vaCon">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\blue{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\mathbf{A}_{left,strobe}$ | $\mathbf{A}_{right,strobe}$ |

</div>

The following contrast of right versus left lateral attention shows the difference in 40 Hz source power during non-flickering (con) stimulation. It is decribed mathematically as:

$\blue{\mathbf{A}_{right,con}} - \orange{\mathbf{A}_{left,con}}.$

We expect that..

![alt text](./img/task-va_contrast-left-right_stim-con_psd.png)
**Visual Attention left versus right contrast PSD; con stimulation:**  $10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{right,con}})}{P(\orange{\mathbf{A}_{left,con}})})$, where $P(\blue{\mathbf{A}_{right,con}})$ is the average power spectral density of the $\blue{\mathbf{A}_{right,con}}$ data subset, and $P(\orange{\mathbf{A}_{left,con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{left,con}}$ data subset.

![alt text](./img/task-va_contrast-left-right_stim-con_topo.png)
**Visual Attention left versus right contrast 40 Hz sensor power; con stimulation:**  $10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{right,con}})}{P(\orange{\mathbf{A}_{left,con}})})$, where $P(\blue{\mathbf{A}_{right,con}})$ is the average power spectral density of the $\blue{\mathbf{A}_{right,con}}$ data subset, and $P(\orange{\mathbf{A}_{left,con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{left,con}}$ data subset.

![alt text](./img/task-va_stimcondition-con_permutation-tasklevel-left-right_npermut-1500.png)
**Visual Attention left versus right 40 Hz source power; continuous stimulation:** Contrast of the left versus right 40 Hz source estimates during visual attention task and stimulation with continuoius light. Colourbar indicates the $t$-values for the estimated parameter contrast $\hat{\beta} = \blue{\mathbf{A}_{right,con}} - \orange{\mathbf{A}_{left,con}}$. Testing for the null hypothesis that the two lateral attentions conditions were interchangeble using non-parametric cluster-based permutation tests revealed no significant differences.

<div style="page-break-after: always;"></div>


### 1.6.2. Flicker (strobe)

<div class="vaStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{left,con}$ | $\mathbf{A}_{right,con}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |

</div>

The following contrast of right versus left lateral attention shows the difference in 40 Hz source power during flickering (strobe) stimulation. It is decribed mathematically as:


$\red{\mathbf{A}_{right,strobe}} - \purple{\mathbf{A}_{left,strobe}}.$

We expect that..

![alt text](./img/task-va_contrast-left-right_stim-strobe_psd.png)
**Visual Attention left versus right contrast PSD; strobe stimulation:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{right,strobe}})}{P(\purple{\mathbf{A}_{left,strobe}})})$, where $P(\red{\mathbf{A}_{right,strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{right,strobe}}$ data subset, and $P(\purple{\mathbf{A}_{left,strobe}})$ is the average power spectral density of the $\purple{\mathbf{A}_{left,strobe}}$ data subset.

![alt text](./img/task-va_contrast-left-right_stim-strobe_topo.png)
**Visual Attention left versus right contrast 40 Hz sensor power; con stimulation:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{right,strobe}})}{P(\purple{\mathbf{A}_{left,strobe}})})$, where $P(\red{\mathbf{A}_{right,strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{right,strobe}}$ data subset, and $P(\purple{\mathbf{A}_{left,strobe}})$ is the average power spectral density of the $\purple{\mathbf{A}_{left,strobe}}$ data subset.

![alt text](./img/task-va_stimcondition-strobe_permutation-tasklevel-left-right_npermut-1500.png)
**Visual Attention left versus right 40 Hz source power; stroboscopic stimulation:** Contrast of the left versus right 40 Hz source estimates during visual attention task and stimulation with stroboscopic light. Colourbar indicates the $t$-values for the estimated parameter contrast $\hat{\beta} = \red{\mathbf{A}_{right,strobe}} - \purple{\mathbf{A}_{left,strobe}}$. Testing for the null hypothesis that the two lateral attentions conditions were interchangeble using non-parametric cluster-based permutation tests revealed no significant differences.

<div style="page-break-after: always;"></div>

## 1.7. Interaction effect between lateralised attention and visual stimulation

<div class="vaTwoWayConStrobe">

|            | Left Attention             | Right Attention             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{left,con}}$ | $\blue{\mathbf{A}_{right,con}}$ |
| **ISF**    | $\mathbf{A}_{left,isf}$    | $\mathbf{A}_{right,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{left,strobe}}$ | $\red{\mathbf{A}_{right,strobe}}$ |


</div>


The following two-way contrast of left versus right lateral attention and flicker (strobe) versus no flicker (con) shows the interaction effect between lateralised attention and visual stimulation on the 40 Hz source power. It is decribed mathematically as:


$(\red{\mathbf{A}_{right,strobe}} - \purple{\mathbf{A}_{left,strobe}}) - (\blue{\mathbf{A}_{right,con}} - \orange{\mathbf{A}_{left,con}})$


Here, we expect to find an 


![alt text](./img/task-va_interaction-task-stim_tasklevel-left-right_stim_condition-con-strobe_psd.png)
**Visual Attention interaction between task and stimulus PSD:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{right,strobe}}) / P(\purple{\mathbf{A}_{left,strobe}})}{P(\blue{\mathbf{A}_{right,con}}) / P(\orange{\mathbf{A}_{left,con}})}) = 10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{right,strobe}})}{P(\purple{\mathbf{A}_{left,strobe}})}) - 10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{right,con}})}{P(\orange{\mathbf{A}_{left,con}})})$.

![alt text](./img/task-va_interaction-task-stim_tasklevel-left-right_stim_condition-con-strobe_topo.png)
**Visual Attention interaction between task and stimulus 40 Hz sensor power:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{right,strobe}}) / P(\purple{\mathbf{A}_{left,strobe}})}{P(\blue{\mathbf{A}_{right,con}}) / P(\orange{\mathbf{A}_{left,con}})}) = 10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{right,strobe}})}{P(\purple{\mathbf{A}_{left,strobe}})}) - 10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{right,con}})}{P(\orange{\mathbf{A}_{left,con}})})$.

![alt text](./img/task-va_contrast-tasklevel-left-right_permutation-stimcondition-con-strobe_npermut-1500.png)
**Visual Attention two-way contrast permutation 40 Hz source power:** Interaction effect of the lateralisation and stimulation factors on 40 Hz source estimates, corresponding to . Colourbar indicates the $t$-values for the estimated parameter contrast $\hat{\beta} = (\red{\mathbf{A}_{right,strobe}} - \purple{\mathbf{A}_{left,strobe}}) - (\blue{\mathbf{A}_{right,con}} - \orange{\mathbf{A}_{left,con}})$. Testing for the null hypothesis that the two stimulation conditions were interchangeble using non-parametric cluster-based permutation tests revealed no significant differences.


<div style="page-break-after: always;"></div>




# 2. Arithmetic experiment

## 2.1. Data description

The factorial table below describes the levels in the $2 \times 3$ design with the two factors *arithmetic difficulty* (two levels: $low$ & $high$) and *visual stimulus* (three levels: $con$, $isf$ & $strobe$). The data matrix $\mathbf{A}$ refers to a given functional measure (i.e. sensor or source level 40 Hz power), and the subscripted indices refer to subsets of the data pertaining to given factor level combinations.

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{low,con}$    | $\mathbf{A}_{high,con}$    |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\mathbf{A}_{low,strobe}$ | $\mathbf{A}_{high,strobe}$ |

## 2.2. Behaviour

In the arithmetic experiment behavioural results presented graphically below, there are some more notable differences. Again, the difficulty of the task seems appropriate as there is not a saturation in the fraction of correct responses, and nor is it close to random responses (50%).

When grouping by light stimulus, the reaction times are very similar, but the fraction of correct responses appears to be slightly higher for the continuous light (0 Hz) condition.

The effect of the sum correctness appears to have an effect on the reaction time and the correct responses. Responses to trials with correct sums are both more rapid and more correct than when the sums are incorrect.

Arithmetic difficulty appears to have a small effect on the reaction time, in which the lower difficulty leads to faster responses. There is a big (and expected) difference in the fraction of correct responses.


![alt text](./img/sub-all_run-002_task-workingmemory.png)
**Arithmetic Experiment Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by correctness of the presented sum, and the right column groups by arithmetic difficulty.

<div style="page-break-after: always;"></div>

## 2.3. Static (continuous) stimulus

<div class="vaCon">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{low,con}}$ | $\orange{\mathbf{A}_{high,con}}$ |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\mathbf{A}_{low,strobe}$ | $\mathbf{A}_{righighht,strobe}$ |

</div>

The following ... 40 Hz source power during non-flickering (con) stimulation. It is decribed mathematically as:

$\orange{\mathbf{A}_{con}} = \orange{\mathbf{A}_{low,con}} \cup \orange{\mathbf{A}_{high,con}}$

We expect that..

![alt text](./img/task-wm_stim-con_psd.png)
**Arithmetic Experiment continuous stim condition:** $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{con}}))$, where $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

| ![alt text](./img/task-wm_tasklevel-low_stim-con_psd.png) | ![alt text](./img/task-wm_tasklevel-high_stim-con_psd.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{low,con}}))$ | $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{high,con}}))$|

![alt text](./img/task-wm_stim-con_topo.png)
**Arithmetic Experiment continuous stim condition:** $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{con}}))$, where $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

| ![alt text](./img/task-wm_tasklevel-low_stim-con_topo.png) | ![alt text](./img/task-wm_tasklevel-high_stim-con_topo.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{low,con}}, 40\ \mathrm{Hz}))$ | $10 \operatorname{log}_{10}(P(\orange{\mathbf{A}_{high,con}}, 40\ \mathrm{Hz}))$|


<div style="page-break-after: always;"></div>

## 2.4. Strobocopic (flicker) stimulus

<div class="vaStrobe">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{low,con}$ | $\mathbf{A}_{high,con}$ |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\red{\mathbf{A}_{low,strobe}}$ | $\red{\mathbf{A}_{high,strobe}}$ |

</div>

The following ... 40 Hz source power during flickering (strobe) stimulation. It is decribed mathematically as:

$\red{\mathbf{A}_{strobe}} = \red{\mathbf{A}_{low,strobe}} \cup \red{\mathbf{A}_{high,strobe}}$

We expect that..

![alt text](./img/task-wm_stim-strobe_psd.png)
**Arithmetic Experiment stroboscopic stim condition:** $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{strobe}}))$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset.

| ![alt text](./img/task-wm_tasklevel-low_stim-strobe_psd.png) | ![alt text](./img/task-wm_tasklevel-high_stim-strobe_psd.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{low,strobe}}))$ | $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{high,strobe}}))$|

![alt text](./img/task-wm_stim-strobe_topo.png)
**Arithmetic Experiment stroboscopic stim condition:** $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{strobe}}))$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset.

| ![alt text](./img/task-wm_tasklevel-low_stim-strobe_topo.png) | ![alt text](./img/task-wm_tasklevel-high_stim-strobe_topo.png) | 
|:--:| :--:|
|$10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{low,strobe}}, 40\ \mathrm{Hz}))$ | $10 \operatorname{log}_{10}(P(\red{\mathbf{A}_{high,strobe}}, 40\ \mathrm{Hz}))$|



<div style="page-break-after: always;"></div>


## 2.5. Flicker versus non-flickering stimulus contrast

<div class="vaTwoWayConStrobe">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{low,con}}$    | $\orange{\mathbf{A}_{high,con}}$    |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\red{\mathbf{A}_{low,strobe}}$ | $\red{\mathbf{A}_{high,strobe}}$ |

</div>

The following contrast of flicker (strobe) versus no flicker (con) shows the difference in 40 Hz steady-state visually evoked field (SSVEF) source power between the stimulus conditions, described from the factorial table as:

$\red{\mathbf{A}_{strobe}} - \orange{\mathbf{A}_{con}},$

where the data is collapsed across the arithmetic difficulty factor levels (i.e. $\red{\mathbf{A}_{strobe}}$ is the union of $\red{\mathbf{A}_{low,strobe}}$ and $\red{\mathbf{A}_{high,strobe}}$, and $\orange{\mathbf{A}_{con}}$ is the union of $\orange{\mathbf{A}_{low,con}}$ and $\orange{\mathbf{A}_{high,con}}$).

We expect that..

![alt text](./img/task-wm_contrast-con-strobe_psd.png)
**Arithmetic Experiment flicker versus no-flicker stim condition:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{strobe}})}{P(\orange{\mathbf{A}_{con}})})$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset, and $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

![alt text](./img/task-wm_contrast-con-strobe_topo.png)
**Arithmetic Experiment flicker versus no-flicker stim condition:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{strobe}})}{P(\orange{\mathbf{A}_{con}})})$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset, and $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

![alt text](./img/task-wm_permutation-stimcondition-con-strobe_npermut-1500.png)
**Arithmetic Experiment permutation of continuous and stroboscopic flicker:** Source estimate of the WM task permuted between continuous and stroboscopic flicker. The sources were estimated across trials from both levels of the WM task levels. The plotted values indicate the contrast averaged across subjects; no significant clusters are found. Colourbar indicates t-values estimated from the paired observations across subjects (?).


## 2.6. High versus low arithmetic difficulty stratified by visual stimulus

### 2.6.1. No flicker (con)

<div class="vaCon">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{low,con}}$ | $\blue{\mathbf{A}_{high,con}}$ |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\mathbf{A}_{low,strobe}$ | $\mathbf{A}_{high,strobe}$ |

</div>

The following contrast of high versus low arithmetic difficulty shows the difference in 40 Hz source power during non-flickering (con) stimulation. It is decribed mathematically as:

$\blue{\mathbf{A}_{high,con}} - \orange{\mathbf{A}_{low,con}}.$

We expect that..

![alt text](./img/task-wm_contrast-low-high_stim-con_psd.png)
**Arithmetic Experiment high versus low contrast; continuous stim condition:**  $10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{high,con}})}{P(\orange{\mathbf{A}_{low,con}})})$, where $P(\blue{\mathbf{A}_{high,con}})$ is the average power spectral density of the $\blue{\mathbf{A}_{high,con}}$ data subset, and $P(\orange{\mathbf{A}_{low,con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{low,con}}$ data subset.

![alt text](./img/task-wm_contrast-low-high_stim-con_topo.png)
**Arithmetic Experiment high versus low contrast; continuous stim condition:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{strobe}})}{P(\orange{\mathbf{A}_{con}})})$, where $P(\red{\mathbf{A}_{strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{strobe}}$ data subset, and $P(\orange{\mathbf{A}_{con}})$ is the average power spectral density of the $\orange{\mathbf{A}_{con}}$ data subset.

![alt text](./img/task-wm_stimcondition-con_permutation-tasklevel-low-high_npermut-1500.png)
**Arithmetic permutation of task levels within continuous stim condition:** Source estimate of the WM task during continuous light stimulation, permuted between task levels. The sources were estimated across trials from both levels of the WM task levels. The plotted values indicate the contrast averaged across subjects, and the opaque area is the significant cluster. Colourbar indicates t-values estimated from the paired observations across subjects (?).


### 2.6.2. Flicker (strobe)

<div class="vaStrobe">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\mathbf{A}_{low,con}$ | $\mathbf{A}_{high,con}$ |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{low,strobe}}$ | $\red{\mathbf{A}_{high,strobe}}$ |

</div>

The following contrast of right versus left lateral attention shows the difference in 40 Hz source power during flickering (strobe) stimulation. It is decribed mathematically as:


$\red{\mathbf{A}_{high,strobe}} - \purple{\mathbf{A}_{low,strobe}}.$

We expect that..

![alt text](./img/task-wm_contrast-low-high_stim-strobe_psd.png)
**Arithmetic experiment high versus low contrast; strobe stim condition:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{high,strobe}})}{P(\purple{\mathbf{A}_{low,strobe}})})$, where $P(\red{\mathbf{A}_{high,strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{high,strobe}}$ data subset, and $P(\purple{\mathbf{A}_{low,strobe}})$ is the average power spectral density of the $\purple{\mathbf{A}_{low,strobe}}$ data subset.

![alt text](./img/task-wm_contrast-low-high_stim-strobe_topo.png)
**Arithmetic Experiment high versus low contrast; strobe stim condition:** $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{high,strobe}})}{P(\purple{\mathbf{A}_{low,strobe}})})$, where $P(\red{\mathbf{A}_{high,strobe}})$ is the average power spectral density of the $\red{\mathbf{A}_{high,strobe}}$ data subset, and $P(\purple{\mathbf{A}_{low,strobe}})$ is the average power spectral density of the $\purple{\mathbf{A}_{low,strobe}}$ data subset.

![alt text](./img/task-wm_stimcondition-strobe_permutation-tasklevel-low-high_npermut-1500.png)
**Arithmetic permutation of task levels within stroboscopic stim condition:** Source estimate of the WM task during stroboscopic light stimulation, permuted between task levels. The sources were estimated across trials from both levels of the WM task levels. The plotted values indicate the contrast averaged across subjects, and the opaque area is the significant cluster. Colourbar indicates t-values estimated from the paired observations across subjects (?).

## 2.7. Interaction effect between arithmetic difficulty and visual stimulation

<div class="vaTwoWayConStrobe">

|            | Low Difficulty             | High Difficulty             |
| ---------: | :---------------------:    | :----------------------:    |
| **con**    | $\orange{\mathbf{A}_{low,con}}$    | $\blue{\mathbf{A}_{high,con}}$    |
| **ISF**    | $\mathbf{A}_{low,isf}$    | $\mathbf{A}_{high,isf}$    |
| **strobe** | $\purple{\mathbf{A}_{low,strobe}}$ | $\red{\mathbf{A}_{high,strobe}}$ |


</div>

The following two-way contrast of high versus low arithmetic difficulty and flicker (strobe) versus no flicker (con) shows the interaction effect between arithmetic difficulty and visual stimulation on the 40 Hz source power. It is decribed mathematically as:


$(\red{\mathbf{A}_{high,strobe}} - \purple{\mathbf{A}_{low,strobe}}) - (\blue{\mathbf{A}_{high,con}} - \orange{\mathbf{A}_{low,con}})$

We expect that..

![alt text](./img/task-wm_interaction-task-stim_tasklevel-low-high_stim_condition-con-strobe_psd.png)
**Visual Attention interaction between task and stimulus:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{high,strobe}}) / P(\purple{\mathbf{A}_{low,strobe}})}{P(\blue{\mathbf{A}_{high,con}}) / P(\orange{\mathbf{A}_{low,con}})}) = 10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{high,strobe}})}{P(\purple{\mathbf{A}_{low,strobe}})}) - 10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{high,con}})}{P(\orange{\mathbf{A}_{low,con}})})$.

![alt text](./img/task-wm_interaction-task-stim_tasklevel-low-high_stim_condition-con-strobe_topo.png)
**Visual Attention interaction between task and stimulus:**  $10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{high,strobe}}) / P(\purple{\mathbf{A}_{low,strobe}})}{P(\blue{\mathbf{A}_{high,con}}) / P(\orange{\mathbf{A}_{low,con}})}) = 10 \operatorname{log}_{10}(\frac{P(\red{\mathbf{A}_{high,strobe}})}{P(\purple{\mathbf{A}_{low,strobe}})}) - 10 \operatorname{log}_{10}(\frac{P(\blue{\mathbf{A}_{high,con}})}{P(\orange{\mathbf{A}_{low,con}})})$.

| ![alt text](./img/task-wm_contrast-tasklevel-low-high_permutation-stimcondition-con-strobe_npermut-1500.png) | 
|:--:| 
| **Arithmetic two-way contrast permutation:** Source estimate contrast between WM task levels (high minus low arithmetic difficulty), permutation tested between continuous and strobe stimulus conditions. The plotted values indicate the contrast averaged across subjects, and the opaque area is the significant cluster. Colourbar indicates t-values estimated from the paired observations across subjects (?). |


<div style="page-break-after: always;"></div>

# 3. Appendix

## 3.1. Behaviour By Subject

### 3.1.1. Visual attention experiment


| ![alt text](./img/sub-008_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 8 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-009_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 9 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-011_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 11 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-013_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 13 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-017_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 17 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-018_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 18 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-021_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 21 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-022_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 22 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-023_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 23 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-025_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 25 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-027_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 27 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-028_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 28 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

| ![alt text](./img/sub-029_run-001_task-visualattention.png) | 
|:--:| 
| **Subject 29 Visual Attention Behaviour:** On the top row, the distribution of reaction times is presented in groupings, while the bottom row shows the similarly grouped fraction of correct responses. The left column groups by light stimulus; 0 Hz: Continuous non-modulated light, 40 Hz LF: Luminance flicker with 100% modulation depth modulated at 40 Hz, 40 Hz ISF: Invisible spectral flicker modulated at 40 Hz. The middle column groups by congruence of the gratings, and the right column groups by attentive side.|

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


# 4. ARCHIVE

## 4.1. Sensor Level

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


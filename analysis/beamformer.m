%% Add util dir to path
clear;

addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');

% Start logging
diaryfile = fullfile(data_dir, 'beamformer.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

% Load data details
data_details_cfg = get_data_details();

% Define subjects - should eventually be centralised
subjects = [24]; %[8 9 11 13 17 18 21:23 25 27:30];
tasks = ["va"];
conditions = ["strobe"]

stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);

%%
for sub = subjects
    sub_str = sprintf('sub-%03d', sub)

    deriv_anat_dir = fullfile(derivatives_dir, sub_str, '/ses-001/anat/');
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    img_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/img/');
    raw2_meg_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    raw2_anat_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/anat/');
    
    % Load headmodel
    mri_headmodel_file = fullfile(deriv_anat_dir, 'mri_headmodel.mat');
    load (mri_headmodel_file)
    % just to be sure
    mri_headmodel = ft_convert_units(mri_headmodel, 'mm');
    
    % Load grad
    grad = ft_read_sens( ...
        fullfile(raw2_meg_dir, ...
            sprintf('sub-%03d_ses-001_task-flicker_meg.ds', sub)), ...
        'senstype', 'meg');

    % Source model
    cfg = [];
    cfg.headmodel = mri_headmodel;
    cfg.symmetry = 'y';
    cfg.xgrid = -150:8:150; % in mm
    cfg.ygrid =    4:8:150; % in mm, one hemisphere, offset to the midline
    cfg.zgrid = -150:8:150; % in mm
    sourcemodel = ft_prepare_sourcemodel(cfg);
    save (fullfile(deriv_meg_dir, 'sourcemodel.mat'), 'sourcemodel', '-v7.3')        
    
    cfg = [];
    cfg.grad = grad;
    cfg.channel = {'MEGGRAD'};
    cfg.headmodel = mri_headmodel;
    cfg.sourcemodel = sourcemodel;
    leadfield = ft_prepare_leadfield(cfg);

    for task = tasks
        fname = sprintf('data_pca_%s.mat', task);
        ar_source = fullfile(deriv_meg_dir, fname);
        load (ar_source, sprintf('data_pca_%s', task));

        switch task
            case "va"


                % if not(exist('sourcemodel', 'var'))
                %     cfg                  = [];
                %     cfg.grad             = data_pca_va.grad;
                %     cfg.headmodel        = mri_headmodel;
                %     cfg.reducerank       = 2;
                %     cfg.channel          = 'MEG';
                %     cfg.resolution       = 1;   
                %     cfg.sourcemodel.unit = 'mm';
                %     sourcemodel = ft_prepare_leadfield(cfg);
                % end

                task_map = dictionary(["left", "right"], [1, 2]);
                % Redefine trials to 2-second segments
                cfg = [];
                cfg.toilim    = [0.5 2.5-1/1200];
                data        = ft_redefinetrial(cfg,data_pca_va);
            
                % Iterate over the no-flicker and luminance-flicker
                % conditions for now
                for condition = conditions
                    condition
            
                    % Find and select trials that are from run 1
                    % and belong to the condition
                    trials_va_cond = data.trialinfo(:,3) == stim_map(condition) & ...
                        bitor(data.trialinfo(:,4) == task_map("left"), ...
                            data.trialinfo(:,4) == task_map("right"));
                    cfg = [];
                    cfg.trials = trials_va_cond;
                    data_va_cond = ft_selectdata(cfg, data);
            
                    % Find and select left and right attention trials independently
                    trials_left = data_va_cond.trialinfo(:,4) == task_map("left");
                    trials_right = data_va_cond.trialinfo(:,4) == task_map("right");
            
                    cfg = [];
                    cfg.trials = trials_left;
                    data_left = ft_selectdata(cfg, data_va_cond);
                    
                    cfg = [];
                    cfg.trials = trials_right;
                    data_right = ft_selectdata(cfg, data_va_cond);
                         
                    % Calculate FFT
                    cfg              = [];
                    channels = 'MEG';
                    cfg.output       = 'powandcsd';
                    cfg.channel      = channels;
                    cfg.method       = 'mtmfft';
                    cfg.taper        = 'boxcar';
                    cfg.foilim       = [39 41]; %foilims(:, foilim)';
                    ERboxcar_ar_left        = ft_freqanalysis(cfg, data_left);
                    ERboxcar_ar_right        = ft_freqanalysis(cfg, data_right);
                    ERboxcar_Ar        = ft_freqanalysis(cfg, data_va_cond);

                    
                    
                    % Source Analysis: without contrasting condition
                    cfg                   = []; 
                    cfg.method            = 'dics';
                    cfg.frequency         = 40;  
                    cfg.channel           = data_pca_va.label(:);
                    %cfg.elec              = elec_aligned;
                    %cfg.grid              = sourcemodel;
                    cfg.sourcemodel       = sourcemodel;
                    cfg.headmodel         = mri_headmodel;
                    cfg.dics.keepfilter   = 'yes';
                    cfg.dics.fixedori     = 'no';
                    cfg.dics.projectnoise = 'yes';
                    cfg.dics.lambda       = '5%';
                    cfg.dics.realfilter   = 'yes';
                    cfg.dics.keepcsd      = 'yes';
                    cfg.refchan           = {'refchan'};
                    % cfg              = [];
                    % cfg.method       = 'dics';
                    % cfg.frequency    = 40;
                    % cfg.sourcemodel  = sourcemodel;
                    % cfg.headmodel    = mri_headmodel;
                    % cfg.dics.projectnoise = 'yes';
                    % cfg.dics.lambda       = 0; % should this be increased?
                    % cfg.channel          = sourcemodel.label(:);
                    %cfg.dics.keepfilter   = 'yes';  % We want to reuse the calculated filter later on
                    source_va = ft_sourceanalysis(cfg, ERboxcar_Ar);

                    cfg.sourcemodel.filter = source_va.avg.filter;
                    cfg.dics.keepfilter   = 'no';
                    source_va_left = ft_sourceanalysis(cfg, ERboxcar_ar_left);
                    source_va_right = ft_sourceanalysis(cfg, ERboxcar_ar_right);

                    for k = 1:size(source_va_left.pos,1)
                      if ~isempty(source_va_left.avg.csdlabel{k})
                        source_va_left.avg.csdlabel{k}(4:6) = {'supdip'};
                        source_va_right.avg.csdlabel{k}(4:6) = {'supdip'};
                      end
                    end
                    source_va_left = ft_sourcedescriptives([], source_va_left);
                    source_va_right = ft_sourcedescriptives([], source_va_right);

                    % SAVE OUTPUT TO DERIVATIVES FOR LATER
                    source_va_left_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_left_cond-%s.mat', task, condition));
                    save (source_va_left_file, 'source_va_left', '-v7.3')
                    source_va_right_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_right_cond-%s.mat', task, condition));
                    save (source_va_right_file, 'source_va_right', '-v7.3')

                    % Plot the source on subject MRI
                    % cfg            = [];
                    % cfg.downsample = 2;
                    % cfg.parameter  = 'pow';
                    % source_va_left_intrp  = ft_sourceinterpolate(cfg, source_va_left, mri_realigned);
                    % source_va_right_intrp  = ft_sourceinterpolate(cfg, source_va_right, mri_realigned);

                    % Display
                    % cfg              = [];
                    % cfg.method       = 'slice';
                    % cfg.funparameter = 'pow';
                    % ft_sourceplot(cfg, source_va_left_intrp);
                    % ft_sourceplot(cfg, source_va_right_intrp);
                end
            case "wm"
                
                task_map = dictionary(["high", "low"], [1, 2]);
                % Redefine trials to 2-second segments
                cfg = [];
                cfg.toilim    = [0.5 6.5-1/1200];
                data        = ft_redefinetrial(cfg,data_pca_wm);
            
                % Iterate over the no-flicker and luminance-flicker
                % conditions for now
                for condition = ["con", "strobe"]
                    condition
            
                    % Find and select trials that are from run 1
                    % and belong to the condition
                    trials_wm_cond = data.trialinfo(:,3) == stim_map(condition) & ...
                        bitor(data.trialinfo(:,4) == task_map("high"), ...
                            data.trialinfo(:,4) == task_map("low"));
                    cfg = [];
                    cfg.trials = trials_wm_cond;
                    data_wm_cond = ft_selectdata(cfg, data);
            
                    % Find and select left and right attention trials independently
                    trials_high = data_wm_cond.trialinfo(:,4) == task_map("high");
                    trials_low = data_wm_cond.trialinfo(:,4) == task_map("low");
            
                    cfg = [];
                    cfg.trials = trials_high;
                    data_high = ft_selectdata(cfg, data_wm_cond);
                    
                    cfg = [];
                    cfg.trials = trials_low;
                    data_low = ft_selectdata(cfg, data_wm_cond);
                         
                    % Calculate FFT
                    cfg              = [];
                    channels = 'MEG';
                    cfg.output       = 'powandcsd';
                    cfg.channel      = channels;
                    cfg.method       = 'mtmfft';
                    cfg.taper        = 'boxcar';
                    cfg.foilim       = [39 41]; %foilims(:, foilim)';
                    ERboxcar_ar_high        = ft_freqanalysis(cfg, data_high);
                    ERboxcar_ar_low        = ft_freqanalysis(cfg, data_low);
                    ERboxcar_Ar        = ft_freqanalysis(cfg, data_wm_cond);
                    
                    % Source Analysis: without contrasting condition
                    cfg              = [];
                    cfg.method       = 'dics';
                    cfg.frequency    = 40;
                    cfg.sourcemodel  = sourcemodel;
                    cfg.headmodel    = mri_headmodel;
                    cfg.dics.projectnoise = 'yes';
                    cfg.dics.lambda       = 0; % should this be increased?
                    cfg.channel          = sourcemodel.label(:);
                    cfg.dics.keepfilter   = 'yes';  % We want to reuse the calculated filter later on
                    
                    source_wm = ft_sourceanalysis(cfg, ERboxcar_Ar);

                    cfg.sourcemodel.filter = source_wm.avg.filter;
                    cfg.dics.keepfilter   = 'no';
                    source_va_high = ft_sourceanalysis(cfg, ERboxcar_ar_high);
                    source_va_low = ft_sourceanalysis(cfg, ERboxcar_ar_low);

                    % SAVE OUTPUT TO DERIVATIVES FOR LATER
                    source_wm_high_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_high_cond-%s.mat', task, condition));
                    save (source_wm_high_file, 'source_va_left', '-v7.3')
                    source_wm_low_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_low_cond-%s.mat', task, condition));
                    save (source_wm_low_file, 'source_va_right', '-v7.3')

                    % Plot the source on subject MRI
                    % cfg            = [];
                    % cfg.downsample = 2;
                    % cfg.parameter  = 'pow';
                    % source_wm_high_intrp  = ft_sourceinterpolate(cfg, source_wm_high_file, mri_realigned);
                    % source_wm_low_intrp  = ft_sourceinterpolate(cfg, source_wm_low_file, mri_realigned);
                end
                
        end

    end

end
%%
close all


for sub = subjects

    sub_str = sprintf('sub-%03d', sub)

    deriv_anat_dir = fullfile(derivatives_dir, sub_str, '/ses-001/anat/');
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    img_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/img/');
    raw2_meg_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    raw2_anat_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/anat/');

    % Load the MRI for later plotting
    mri_realigned_file = fullfile(deriv_anat_dir, 'mri_realigned.mat');
    load (mri_realigned_file)

    % just to be sure
    mri_realigned = ft_convert_units(mri_realigned, 'mm');
    mri_normalised = ft_volumenormalise(cfg, mri_realigned);

    % load sourcemodel
    load (fullfile(deriv_meg_dir, 'sourcemodel.mat'))  

    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    img_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/img/');
    conds = [];
    for condition = conditions
        conds.(condition) = [];
        source_va_left_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_left_cond-%s.mat', task, condition));
        source_va_right_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_right_cond-%s.mat', task, condition));
        load (source_va_left_file)
        load (source_va_right_file)
        conds.(condition).left = source_va_left;
        conds.(condition).right = source_va_right;
    
    end

    source_lateral_dif = conds.strobe.left;
    source_lateral_dif.avg.pow = (conds.strobe.left.avg.pow - conds.strobe.right.avg.pow) ...
        ./ (conds.strobe.left.avg.pow + conds.strobe.right.avg.pow);

    % tmp = source_lateral_dif.avg.pow;
    % source_lateral_dif.avg.pow = nan(size(sourcemodel.pos,1), size(tmp, 2), size(tmp, 3));
    % source_lateral_dif.avg.pow(sourcemodel.inside,:,:) = tmp(sourcemodel.inside,:,:);
    
    % source_stim_dif_left = conds.strobe.left;
    % source_stim_dif_left.avg.pow = (conds.strobe.left.avg.pow - conds.con.left.avg.pow) ...
    %     ./ (conds.strobe.left.avg.pow + conds.con.left.avg.pow);

    % sourceDiff = conds.strobe;
    % sourceDiff.avg.pow = (conds.strobe.avg.pow - conds.con.avg.pow) ./ conds.strobe.avg.pow;
    cfg            = [];
    cfg.downsample = 2;
    cfg.parameter  = 'pow';
    source_lateral_dif_interp  = ft_sourceinterpolate(cfg, source_lateral_dif , mri_normalised);
        
    % interpolate onto MRI
    % load(fullfile(path_data,'templates','mri152.mat'));
    % mri.coordsys = 'mni';
    % 
    % cfg = [];
    % cfg.parameter = 'stat';
    % stat_interp = ft_sourceinterpolate(cfg, stat, mri);
    
    % thresholded opacity map, anything <65% of maximum is fully transparent,
    % anything >80% of maximum is fully opaque
    % stat_interp.nicemask = make_mask(stat_interp.stat, [0.65 0.8]);
    % 
    % cfg = [];
    % cfg.atlas = fullfile(ftpath, 'template', 'atlas', 'aal', 'ROI_MNI_V4.nii');
    % cfg.funparameter = 'stat';
    % cfg.maskparameter = 'nicemask';
    % cfg.method = 'ortho';
    % cfg.funcolorlim = [-4 4];
    % cfg.colorbar = 'yes';
    % 
    % % first maximum is in R Hippocampus
    % cfg.location = [42.9 -30.5 -9.3];
    % ft_sourceplot(cfg, stat_interp);
    
    %
    maxval = max(source_lateral_dif_interp.pow,[],'all');
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'pow';
    cfg.maskparameter = cfg.funparameter;
    %cfg.funcolorlim   = [0.0 maxval];
    % cfg.opacitylim    = [0.65*maxval maxval];
    cfg.funcolorlim   = 'maxabs';
    cfg.opacitymap    = 'rampup';

    figure;
    ft_sourceplot(cfg, source_lateral_dif_interp);
    title(sprintf('Left minus right attention; %s', condition));
    saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_40Hz-source_stim-%s_lateral-contrast.png', sub, condition)))
    
end

%%
cfg = [];
cfg.parameter = source_lateral_dif.avg;
ft_volumenormalise(cfg, mri_realigned)

%%
% cfg = [];
% normalised_mri = ft_volumenormalise(cfg, mri_realigned);
% %%
% cfg = [];
% normalised_dif = ft_volumenormalise(cfg, source_lateral_dif);
% 
% %%
% cfg            = [];
% cfg.downsample = 1;
% cfg.parameter  = 'pow';
% source_lateral_dif_interp  = ft_sourceinterpolate(cfg, source_lateral_dif , normalised_mri);
% 
% %%
% maxval = max(source_lateral_dif_interp.pow,[],'all');
% cfg = [];
% cfg.method        = 'slice';
% cfg.funparameter  = 'pow';
% cfg.maskparameter = cfg.funparameter;
% cfg.funcolorlim   = 'maxabs';
% cfg.opacitymap    = 'rampup';
% cfg.funcolorlim   = [0.0 maxval];
% cfg.opacitylim    = [0.65*maxval maxval];
% 
% figure;
% ft_sourceplot(cfg, source_lateral_dif_interp);
% title(sprintf('Left minus right attention; %s', condition));
%saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_40Hz-source_stim-%s_lateral-contrast.png', sub, condition)))
%%
[~,ftpath] = ft_version();
load(fullfile(ftpath, 'template', 'sourcemodel', 'standard_sourcemodel3d8mm.mat'), 'sourcemodel');
template_grid = sourcemodel;
clear sourcemodel;
cfg = [];
cfg.parameter='pow';

%
% create the subject specific grid, using the template grid that has just been created
cfg           = [];
cfg.warpmni   = 'yes';
cfg.template  = template_grid;
cfg.nonlinear = 'yes';
cfg.mri       = mri_realigned;
cfg.unit      ='mm';
grid          = ft_prepare_sourcemodel(cfg);

% make a figure of the single subject headmodel, and grid positions
figure; hold on;
ft_plot_headmodel(mri_headmodel, 'edgecolor', 'none', 'facealpha', 0.4);
ft_plot_mesh(grid.pos(grid.inside,:));

%%

source_lateral_dif_templ = ft_sourceinterpolate(cfg, source_lateral_dif, template_grid);
%
maxval = max(source_lateral_dif_templ.pow,[],'all');
cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = 'maxabs';
cfg.opacitymap    = 'rampup';
% cfg.funcolorlim   = [0.0 maxval];
% cfg.opacitylim    = [0.65*maxval maxval];
figure;
ft_sourceplot(cfg, source_lateral_dif_templ);
title(sprintf('Left minus right attention; %s', condition));

%cont_sources{pat,1,2}=ft_sourceinterpolate(cfg, sourceON_con, atlas);
%%
source_lateral_dif.inside = template_grid.inside;
source_lateral_dif.pos = template_grid.pos;
source_lateral_dif.dim = template_grid.dim;

% the source job has discarded all the voxels outside the brain, but FT
% expects them present, so restore them here
tmp = source_lateral_dif.avg.pow;
source_lateral_dif.avg.pow = nan(size(template_grid.pos,1), size(tmp, 2), size(tmp, 3));
source_lateral_dif.avg.pow(template_grid.inside,:,:) = tmp;


%%
diary off

% ARCHIVE
%% Add util dir to path
addpath('/project/3031004.01/meg-ahat/util')

%% Set pilot data directory
data_dir = '/project/3031004.01/pilot-data';
diaryfile = strcat(data_dir, '/beamformer.log');

if (exist(diaryfile, 'file'))
  delete(diaryfile);
end

diary (diaryfile)

raw2_dir = '/project/3031004.01/pilot-data/raw2';
derivatives_dir = '/project/3031004.01/pilot-data/derivatives';

%% Se tup Fieldtrip
configure_ft

%% Metedata
% Sebject (defined as cell array for future compatibility)
subj = {
  '099'
  };
ses = 1;

%% Load preprocessed MEG data
meg_dir = sprintf('%s/sub-%s/ses-00%d/meg/', derivatives_dir, subj{1}, ses);
fname = sprintf('sub-%s_ses-00%d_task-flicker_proc-preproc_meg.mat', subj{1}, ses);
load (sprintf('%s%s', meg_dir, fname));

%% Select just the first five trials while testing to reduce computation time
cfg = [];
cfg.trials = [1, 2, 3, 4, 5]; % the first 5 trials sub1 ses1 run1 are with 40 Hz
data_stim_five = ft_selectdata(cfg, data_meg);

%% 
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 1;
cfg.foilim    = [40 40];
freq_stim = ft_freqanalysis(cfg, data_stim_five);

%% load headmodel
deriv_anat_dir = sprintf('%s/sub-%s/ses-00%d/anat/', derivatives_dir, subj{1}, ses);
fname = sprintf('sub-%s_ses-00%d_proc-segmented_T1w.mat', subj{1}, ses);
load (sprintf('%s%s', deriv_anat_dir, fname));
headmodel = vol;
%clear vol

%% plot headmodel and sensors
figure
ft_plot_sens(freq_stim.grad);
hold on
ft_plot_headmodel(ft_convert_units(headmodel,'cm'));

%% Source model
cfg                  = [];
cfg.grad             = freq_stim.grad;
cfg.headmodel        = headmodel;
cfg.reducerank       = 2;
cfg.channel          = sourcemodel.label(:);
% use a 3-D grid with a 1 cm resolution
cfg.resolution       = 1;   
cfg.sourcemodel.unit = 'cm';
sourcemodel = ft_prepare_leadfield(cfg);

%% Source Analysis: without contrasting condition
cfg              = [];
cfg.method       = 'dics';
cfg.frequency    = 40;
cfg.sourcemodel  = sourcemodel;
cfg.headmodel    = headmodel;
cfg.dics.projectnoise = 'yes';
cfg.dics.lambda       = 0;
cfg.channel          = sourcemodel.label(:);

source_stim_nocon = ft_sourceanalysis(cfg, freq_stim);

%% SAVE OUTPUT TO DERIVATIVES FOR LATER

outdir = sprintf('%s/sub-%s/ses-00%d/meg/', derivatives_dir, subj{1}, ses);
fname = sprintf('sub-%s_ses-00%d_task-flicker_proc-beamformer_meg.mat', subj{1}, ses);

%%
save (sprintf('%s%s', outdir, fname), 'source_stim_nocon', '-v7.3');

%% Load from derivatives
load (sprintf('%s%s', outdir, fname))

%% Interpolate results
anat_dir = sprintf('%s/sub-%s/ses-00%d/anat/', raw2_dir, subj{1}, ses);
fname = sprintf('sub-%s_ses-00%d_T1w.nii', subj{1}, ses);
mri = ft_read_mri(strcat(anat_dir, fname));

cfg = [];
mri = ft_volumereslice(cfg, mri);

cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
source_stim_intrp_nocon  = ft_sourceinterpolate(cfg, source_stim_nocon, mri);

%% Display
cfg              = [];
cfg.method       = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, source_stim_intrp_nocon);


diary off

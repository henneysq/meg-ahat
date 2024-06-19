% Module for removing 40 Hz electronics
% artefact from the continuous data
%
%% Add util dir to path
clear;

addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');

% Start logging
diaryfile = fullfile(data_dir, 'artefact_rejection.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

% Load data details
data_details_cfg = get_data_details();
subjects = data_details_cfg.new_trigger_subs;

tasks = ["va", "wm"];

for sub = subjects
    close all;
    ses = 1;
    
    % Speciffy subject specific dirs
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), 'ses-001', 'meg');
    img_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), 'ses-001', 'img');
    
    if not(exist(deriv_meg_dir, 'dir'))
      mkdir(deriv_meg_dir);
    end
    
    if not(exist(img_dir, 'dir'))
      mkdir(img_dir);
    end
    
    % Denoise on continuous data %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dataset_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), 'ses-001', 'meg', ...
        sprintf('sub-%03d_ses-001_task-flicker_meg.ds', sub));
    
    for run = [1 2] 
        task = tasks(run)

        cfg = [];
        cfg.dataset = dataset_dir;
        hdr   = ft_read_header(cfg.dataset);
        cfg.run = run;
        cfg.ses = ses;
        cfg.sub = sub;
        cfg.continuous = 'yes'; % Redundant after definetrial?
        cfg.trialfun = strcat('definetrial_', task);
        cfg.trialdef.pre  = 0.5;
        cfg.trialdef.post = 0; %2 + 1/hdr.Fs;
        cfg = ft_definetrial(cfg);
        
        %
        cfg.hpfilter = 'yes';
        cfg.hpfilttype = 'firws';
        cfg.hpfreq  = 0.5;
        cfg.channel = 'MEGREF';
        refdata = ft_preprocessing(cfg);

        %
        cfg.channel = 'MEG';
        cfg.hpfilter = 'no';
        cfg.demean  = 'yes';
        data    = ft_preprocessing(cfg);
        
        % 3d order gradient balancing, uses fixed weights for references
        cfg = [];
        cfg.gradient = 'G3BR';
        data_G3BR = ft_denoise_synthetic(cfg, ft_appenddata([], data, refdata));
        data_G3BR.sampleinfo = data.sampleinfo;
        data_G3BR.trialinfo = data.trialinfo;
        
        % Reject trials/channels
        cfg=[];
        cfg.method = 'summary';
        cfg.channel = 'MEG';
        data_G3BR_clean = ft_rejectvisual(cfg, data_G3BR);
        
        
        %
        % % estimate weights for references, based on data
        cfg = [];
        cfg.trials = data_G3BR_clean.cfg.trials;
        refdata_clean = ft_selectdata(cfg, refdata);
        cfg = [];
        cfg.truncate = 2; % truncates the singular values
        data_pca = ft_denoise_pca(cfg, data_G3BR_clean, refdata_clean);

        if task == 'va'
            data_pca_va = ft_denoise_pca(cfg, data_G3BR_clean, refdata_clean);
        elseif task == 'wm'
            data_pca_wm = ft_denoise_pca(cfg, data_G3BR_clean, refdata_clean);
        end
        
        fname = sprintf('data_pca_%s.mat', task);
        ar_out_dest = fullfile(deriv_meg_dir, fname);
        save (ar_out_dest, sprintf('data_pca_%s', task), '-v7.3');
        
    end
end    
%     %%
diary off

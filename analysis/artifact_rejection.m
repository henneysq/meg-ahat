%% Add util dir to path
clear;

addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');

% Start logging
diaryfile = fullfile(data_dir, 'artefact_rejection.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

for sub = [8 21] %[1:7 10 12 14:17 19:20]
    close all;
    ses = 1;
    
    % Speciffy subject specific dirs
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    img_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/img/');
    
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
    
    cfg = [];
    cfg.dataset = dataset_dir;
    cfg.continuous = 'yes';
    cfg.channel = 'BG1';
    cfg.hpfilter = 'yes';
    cfg.hpfreq = 0.1;
    cfg.hpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
    bg1 = ft_preprocessing(cfg);
    
    
    cfg.run = 1;
    cfg.ses = ses;
    cfg.sub = sub;
    cfg.trialfun = 'definetrial_va';
    cfg.trialdef.pre  = 2;
    cfg.trialdef.post = 0;
    cfg = ft_definetrial(cfg);
    
    %
    cfg.hpfreq  = 0.5;
    cfg.channel = 'MEGREF';
    refdata = ft_preprocessing(cfg);
    fname = 'refdata.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'refdata', '-v7.3');
    
    
    
    %
    cfg.channel = 'MEG';
    cfg.hpfilter = 'no';
    cfg.demean  = 'yes';
    %cfg     = rmfield(cfg, 'padding');
    data    = ft_preprocessing(cfg);
    
    %
    % trl = 5;
    % figure;plot(data.time{trl}, data.trial{trl});
    % figure;plot(refdata.time{trl}, refdata.trial{trl})
    
    % Plot the first 10 trial timeseries
    figure;
    for k = 1:10
    plot(data.time{k}, data.trial{k}(end-3,:)+k*1.5e-12);
    hold on;
    end
    plot([0 0], [0 1], 'k');
    ylim([0 11*1.5e-12]);
    set(gca, 'ytick', (1:10).*1.5e-12);
    set(gca, 'yticklabel', 1:10);
    ylabel('trial number');
    xlabel('time (s)');
    saveas(gcf,fullfile(img_dir, '10_trial_artefact.png'))
    
    
    % 3d order gradient balancing, uses fixed weights for references
    cfg = [];
    cfg.gradient = 'G3BR';
    data_G3BR = ft_denoise_synthetic(cfg, ft_appenddata([], data, refdata));
    data_G3BR.sampleinfo = data.sampleinfo;
    data_G3BR.trialinfo = data.trialinfo;
    
    %
    % figure;plot(data_G3BR.time{4}, data_G3BR.trial{4}(1:273,:));
    % figure;plot(data_G3BR.time{5}, data_G3BR.trial{5}(1:273,:));
    %
    % cfg=[];
    % cfg.viewmode = 'butterfly';
    % cfg.channel = 'MEG';
    % cfg.layout = 'CTF275_helmet.mat';
    % ft_databrowser(cfg, data_G3BR)
    
    % Reject trials/channels
    cfg=[];
    cfg.method = 'summary';
    cfg.channel = 'MEG';
    data_G3BR_clean = ft_rejectvisual(cfg, data_G3BR);
    
    fname = sprintf('data_G3BR_clean.mat');
    clean_data_dest = fullfile(deriv_meg_dir, fname);
    save (clean_data_dest, 'data_G3BR_clean', '-v7.3');
    
    % Add reject flag to events file
    % 
    % events = readtable(fullfile(sprintf('%s/sub-%s/ses-00%d/meg/', raw2_dir, subj{1}, ses), sprintf('sub-%s_ses-00%d_task-flicker_events.tsv', subj{1}, ses)) , "FileType","text",'Delimiter', '\t');
    % events.reject = ones(height(events), 1);
    % 
    % for i = 1:numel(events.trial_number)
    %     ev = events.trial_number{i};
    %     if strcmp(ev, 'n/a')
    %         continue
    %     end
    % 
    %     matlab_trial = str2double(ev) + 1; % OI! Rember Python vs. Matlab indexing
    %     assert(not(isnan(matlab_trial)))
    % 
    %     if any(data_G3BR_clean.cfg.trials == matlab_trial)
    %         events.reject(i) = 0;
    %     end
    % end
    % 
    % % Save for specific run
    % writetable(events, ...
    %     fullfile( ...
    %         derivatives_dir, ...
    %         sprintf('sub-%s', subj{1}), ...
    %         sprintf('ses-00%d', ses), ...
    %         'meg', ...
    %         sprintf('sub-%s_ses-00%d_task-visualattention_events.tsv', subj{1}, ses) ...
    %     ), ...
    %     'filetype', 'text', 'delimiter', '\t')
    
    
    %
    % fname = sprintf('data_G3BR_clean.mat');
    % clean_data_dest = fullfile(deriv_meg_dir, 'data_G3BR_clean.mat');
    load (fullfile(deriv_meg_dir, 'data_G3BR_clean.mat'));
    load (fullfile(deriv_meg_dir, 'refdata.mat'));
    
    cfg = [];   
    cfg.method = 'pca';
    %cfg.trials = data_G3BR_clean.cfg.trials;
    refdata_pca = ft_componentanalysis(cfg, refdata);
    
    %
    % looks like 2 components explain most of the variance,
    % but let's also plot the first 8 in sets of 2
    % figure;plot(refdata.time{1},refdata_pca.trial{1})
    % figure;plot(refdata.time{5},refdata_pca.trial{5})
    
    
    
    %
    % % estimate weights for references, based on data
    cfg = [];
    cfg.trials = data_G3BR_clean.cfg.trials;
    refdata_clean = ft_selectdata(cfg, refdata);
    cfg = [];
    cfg.truncate = 2; % truncates the singular values
    data_pca = ft_denoise_pca(cfg, data_G3BR_clean, refdata_clean);
    
    fname = 'data_pca.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'data_pca', '-v7.3');
    
    %
    % figure;plot(data_G3BR_clean.time{3}, data_G3BR_clean.trial{3});
    % figure;plot(data_pca.time{3}, data_pca.trial{3});
    % figure;plot(data_G3BR_clean.time{5}, data_G3BR_clean.trial{5});
    % figure;plot(data_pca.time{5}, data_pca.trial{5});
    
    %
    % figure;plot(data_clean.time{5}, data_clean.trial{5});
    % figure;plot(data_pca.time{5}, data_pca.trial{5}([1,234],:));
    
    %
    % cfg=[];
    % cfg.viewmode = 'butterfly';
    % cfg.channel = 'MEG';
    % cfg.layout = 'CTF275_helmet.mat';
    % ft_multiplotER(cfg, data)
    
    % Plot the first 10 trial timeseries
    figure;
    for k = 1:10
    plot(data_pca.time{k}, data_pca.trial{k}(end-3,:)+k*1.5e-12);
    hold on;
    end
    plot([0 0], [0 1], 'k');
    ylim([0 11*1.5e-12]);
    set(gca, 'ytick', (1:10).*1.5e-12);
    set(gca, 'yticklabel', 1:10);
    ylabel('trial number');
    xlabel('time (s)');
    saveas(gcf,fullfile(img_dir, '10_trial_artefact_removed.png'))
    
    
    %%%%%%%%%%%%%%%%%%%%%%
    % LOAD PCA AR DATA %%
    
    %fname = sprintf('sub-%s_ses-00%d_task-flicker_proc-artefactremoval_meg.mat', subj{1}, ses);
    %ar_out_dest = fullfile(deriv_meg_dir, 'data_pca.mat');
    load (fullfile(deriv_meg_dir, 'data_pca.mat'))
    %events = readtable(fullfile(deriv_meg_dir, sprintf('sub-%s_ses-00%d_task-visualattention_events.tsv', subj{1}, ses)) , "FileType","text",'Delimiter', '\t');
        %'sprintf(']%s/sub-%s/ses-00%d/meg/', raw2_dir, subj{1}, ses), sprintf('sub-%s_ses-00%d_task-flicker_events.tsv', subj{1}, ses)) , "FileType","text",'Delimiter', '\t');
    
    %
    %events_not_rejected = events(not(events.reject),:);
    %trial_idxs = 1:numel(events_not_rejected.trial_number);
    %%
    
    stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);
    task_map = dictionary(["left", "right"], [1, 2]);
    
    for condition = ["con", "isf", "strobe"]
        trials = data_pca.trialinfo(:,3) == stim_map(condition);
        %trials = str2double(trials);
        %trials = trials + 1; % take into account that python is 0-indexed
        
        % OBS MAKE SURE THAT TRIALS/CHANNELS ARE REJECTED
        % DO REJECTION -> SAVE TO FILE -> LOAD FROM FILE
        cfg = [];
        cfg.trials = trials;
        
        data_stim_no_ar = ft_selectdata(cfg, data_G3BR_clean);
        data_stim_ar = ft_selectdata(cfg, data_pca); % OBS check offset in .sampleinfo
        
        % time-frequency analysis
        
        channels = 'M*O**';
        
        cfg              = [];
        cfg.output       = 'pow';
        cfg.channel      = channels;
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'boxcar';
        cfg.foi          = 2:1:105;                         % analysis 2 to 30 Hz in steps of 2 Hz
        cfg.t_ftimwin    = ones(length(cfg.foi),1).*1;   % length of time window = 1 sec
        cfg.toi          = -3.5:0.05:2.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
        TFRboxcar_no_ar        = ft_freqanalysis(cfg, data_stim_no_ar);
        TFRboxcar_ar        = ft_freqanalysis(cfg, data_stim_ar);
        
        % plot TFR
        cfg = [];
        %cfg.zlim = [-1e-27 3e-27];
        %cfg.baseline     = [-3 -2];
        cfg.channel      = channels;
        figure; ft_singleplotTFR(cfg, TFRboxcar_no_ar);
        saveas(gcf,fullfile(img_dir, sprintf('avg_spectrogram_%s.png', condition)))
        
        figure; ft_singleplotTFR(cfg, TFRboxcar_ar);
        saveas(gcf,fullfile(img_dir, sprintf('avg_spectrogram_%s_AR.png', condition)))
    end
    % fig 3,4 : strobe ; 5,6 : isf
    
    % for k = 1:2
    %     cfg              = [];
    %     cfg.trials       = trials(k);
    %     cfg.output       = 'pow';
    %     cfg.channel      = 'M*O0*';
    %     cfg.method       = 'mtmconvol';
    %     cfg.taper        = 'boxcar';
    %     cfg.foi          = 2:1:60;                         % analysis 2 to 30 Hz in steps of 2 Hz
    %     cfg.t_ftimwin    = ones(length(cfg.foi),1).*1;   % length of time window = 1 sec
    %     cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
    %     TFRboxcar        = ft_freqanalysis(cfg, data_stim);
    % 
    %     % plot TFR
    %     cfg = [];
    %     cfg.zlim = [-1e-27 3e-27];
    %     cfg.channel = 'MZO01';
    %     figure; ft_singleplotTFR(cfg, TFRboxcar);
    % end
end    
    %%
diary off

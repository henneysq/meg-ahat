%% Add util dir to path
clear;

addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')

% Define directories
data_dir = '/project/3031004.01/data/';
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');
derivatives_img_dir = fullfile(derivatives_dir, 'img');
derivatives_img_dir_sensor = fullfile(derivatives_img_dir, 'sensor-level');

% Start logging
diaryfile = fullfile(data_dir, 'sensor_level_analysis.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

% Load data details
data_details_cfg = get_data_details();

% Define subjects - should eventually be centralised
subjects = data_details_cfg.new_trigger_subs;

stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);

% Create a character vector describing the avering procedure
operation_str_avg = '(';
for s = 1:numel(subjects)
    operation_str_avg = [operation_str_avg 'x' num2str(s) '+'];
end
operation_str_avg = [operation_str_avg(1:end-1) ')/' num2str(numel(subjects))];

%
%% VISUAL ATTENTION EXPERIMENT
%
%
task_map = dictionary(["left", "right"], [1, 2]);
tfr_data = [];
tfr_data.con = [];
tfr_data.strobe = [];

for sub = subjects
    sub_str = sprintf('sub-%03d', sub)
    close all

    % Define subject specific directories
    img_dir = fullfile(derivatives_dir, sub_str, '/ses-001/img/');
    deriv_meg_dir = fullfile(derivatives_dir, sub_str, '/ses-001/meg/');

    % Load artefact-suppressed data
    load (fullfile(deriv_meg_dir, 'data_pca_va.mat'))
    
    % Redefine trials to 2-second segments
    cfg = [];
    cfg.toilim    = [0.5 2.5-1/1200];
    data        = ft_redefinetrial(cfg,data_pca_va);
    
    % Prepare some variables
    foilims = [[38 42]', [7 15]', [13 30]'];
    foilim_bands = ["40-Hz", "7-15-Hz", "13-30-Hz"];
    lateral_contrast_gamma = [];
    lateral_contrast_alpha = [];
    lateral_contrast_beta = [];

    % Iterate over the no-flicker and luminance-flicker
    % conditions for now
    for condition = ["con", "strobe"]
        sprintf('Condition: %s', condition)

        % Find and select trials that are from run 1
        % and belong to the condition
        trials_va_cond = data.trialinfo(:,3) == stim_map(condition) & ...
            bitor(data.trialinfo(:,4) == task_map("left"), ...
                data.trialinfo(:,4) == task_map("right"));
        cfg = [];
        cfg.trials = trials_va_cond;
        data_va_cond = ft_selectdata(cfg, data);

        % plot TFR for sanity check (clear 40 Hz artefact only in strobe)
        channels         = 'M*O**';
        cfg              = [];
        cfg.output       = 'pow';
        cfg.channel      = channels;
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'boxcar';
        cfg.foi          = 30:1:50;                         
        cfg.t_ftimwin    = 10./cfg.foi;%ones(length(cfg.foi),1).*1;   
        cfg.toi          = -0.5:0.05:2.5;
        TFRboxcar_ar_eft = ft_freqanalysis(cfg, data_va_cond);

        tfr_data.(condition).(sprintf('sub%d',sub)) = TFRboxcar_ar_eft;

        cfg = [];
        figure; ft_singleplotTFR(cfg, TFRboxcar_ar_eft);
        title('Left attention');
        saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_power_stim-%s_left-attention_psd.png', sub, condition)))

        % Find and select left and right attention trials independently
        trials_left = data_va_cond.trialinfo(:,4) == task_map("left");
        trials_right = data_va_cond.trialinfo(:,4) == task_map("right");
       
        cfg = [];
        cfg.trials = trials_left;
        data_left = ft_selectdata(cfg, data_va_cond);
        
        cfg = [];
        cfg.trials = trials_right;
        data_right = ft_selectdata(cfg, data_va_cond);
        
        % Iterate over three bands defined by `foilims`
        proc = "splg"; % Indicates synthetic planar gradients
        for foilim = 1%[1 2 3]
            
            % Prepare neighbours for planar gradients (but re-use)
            if not(exist('neighbours', 'var') == 1)
                cfg                 = [];
                cfg.feedback        = 'yes';
                cfg.method          = 'template';
                neighbours      = ft_prepare_neighbours(cfg, data_pca_va);
            end

            % Calculate planar gradients
            cfg                 = [];
            cfg.feedback        = 'yes';
            cfg.planarmethod    = 'sincos';
            cfg.neighbours      = neighbours;
            data_left_planar = ft_megplanar(cfg, data_left);
            data_right_planar = ft_megplanar(cfg, data_right);

            % Calculate FFT
            cfg              = [];
            channels = 'MEG';
            cfg.output       = 'pow';
            cfg.channel      = channels;
            cfg.method       = 'mtmfft';
            cfg.taper        = 'boxcar';
            cfg.foilim       = foilims(:, foilim)';
            ERboxcar_ar_left_planar        = ft_freqanalysis(cfg, data_left_planar);
            ERboxcar_ar_right_planar        = ft_freqanalysis(cfg, data_right_planar);
            
            % Combine
            cfg = [];
            ERboxcar_ar_left = ft_combineplanar(cfg, ERboxcar_ar_left_planar);
            ERboxcar_ar_right= ft_combineplanar(cfg, ERboxcar_ar_right_planar);
    
            % Calculate lateral contrast of the power in the foilim
            cfg.parameter = 'powspctrm';
            cfg.operation = 'log10(x1./x2)'; %'(x1-x2)/(x1+x2)';
            ERboxcar_ar_lateral_dif = ft_math(cfg, ERboxcar_ar_left, ERboxcar_ar_right);
            
            % Plot topography for each level and for contrast
            cfg = [];
            cfg.xlim         = foilims(:, foilim)';
            cfg.marker       = 'on';
            cfg.colorbar     = 'yes';
            cfg.layout       = 'CTF151_helmet.mat';
            cfg.colormap     = '*RdBu';
            cfg.zlim         = 'maxabs';
            
            figure;
            ft_topoplotER(cfg, ERboxcar_ar_left);
            title('Left attention');
            saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_%s-power_stim-%s_proc-%s_left-attention_topo.png', sub, foilim_bands(foilim), condition, proc)))
            
            figure;
            ft_topoplotER(cfg, ERboxcar_ar_right);
            title('Right attention');
            saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_%s-power_stim-%s_proc-%s_right-attention.png', sub, foilim_bands(foilim), condition, proc)))
            
            figure;
            ft_topoplotER(cfg, ERboxcar_ar_lateral_dif);
            title('Left minus right attention (dB)');
            saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_%s-power_stim-%s_proc-%s_lateral-dif.png', sub, foilim_bands(foilim), condition, proc)))
            
            % Save the contrast for later averaging
            switch foilim
                case 1
                    lateral_contrast_gamma.(sprintf('%s', condition)) = ERboxcar_ar_lateral_dif;
                case 2
                    lateral_contrast_alpha.(sprintf('%s', condition)) = ERboxcar_ar_lateral_dif;
                case 3
                    lateral_contrast_beta.(sprintf('%s', condition)) = ERboxcar_ar_lateral_dif;
            end
        end
        
    end

    % Save contrasts to disk
    fname = 'lateral_contrast_gamma.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'lateral_contrast_gamma', '-v7.3');
    fname = 'lateral_contrast_alpha.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'lateral_contrast_alpha', '-v7.3');
    fname = 'lateral_contrast_beta.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'lateral_contrast_beta', '-v7.3');
end

tfr_data.strobe = struct2cell(tfr_data.strobe);
tfr_data.con = struct2cell(tfr_data.con);
%% Plot average spectrograms

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = operation_str_avg;

tfr_data.strobe_avg = ft_math(cfg, tfr_data.strobe{:});
tfr_data.con_avg = ft_math(cfg, tfr_data.con{:});

cfg = [];
figure; ft_singleplotTFR(cfg, tfr_data.strobe_avg);
title('strobe')
saveas(gcf, fullfile(derivatives_img_dir_sensor, 'spectrogram_stim-strobe_task-va.png'))

figure; ft_singleplotTFR(cfg, tfr_data.con_avg);
title('con')
saveas(gcf, fullfile(derivatives_img_dir_sensor, 'spectrogram_stim-con_task-va.png'))

%% Calculate contrast pr. band averaged over subjects

close all
sub_struct_gamma = [];
sub_struct_alpha = [];
sub_struct_beta = [];

% Load contrasts from disk
for sub = subjects
    sub_str = sprintf('sub-%03d', sub)
    deriv_meg_dir = fullfile(derivatives_dir, sub_str, '/ses-001/meg/');
    load (fullfile(deriv_meg_dir, 'lateral_contrast_gamma.mat'))
    sub_struct_gamma.(sprintf('sub%03d', sub)) = lateral_contrast_gamma;
    load (fullfile(deriv_meg_dir, 'lateral_contrast_alpha.mat'))
    sub_struct_alpha.(sprintf('sub%03d', sub)) = lateral_contrast_alpha;
    load (fullfile(deriv_meg_dir, 'lateral_contrast_beta.mat'))
    sub_struct_beta.(sprintf('sub%03d', sub)) = lateral_contrast_beta;
end

%% Iterate over bands and conditions
condition = ["con", "strobe"];
for band = ["40", "alpha", "beta"]
    switch band
        case "40"
            data = sub_struct_gamma;
        case "alpha"
            data = sub_struct_alpha;
        case "beta"
            data = sub_struct_beta;
    end

    for cond = condition
        % Average spectra over subjects        
        data_args = {};
       
        operation_str = '(';
        for s = 1:numel(subjects)
            data_args = [data_args data.(sprintf('sub%03d', subjects(s))).(cond)];
            operation_str = [operation_str 'x' num2str(s) '+'];
        end

        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = [operation_str(1:end-1) ')/' num2str(numel(subjects))];

        avg_ERboxcar_ar_lateral_dif = ft_math(cfg, data_args{:});
    
        % Plot the average topography
        cfg = [];
        cfg.marker       = 'on';
        cfg.colorbar     = 'yes';
        cfg.layout       = 'CTF151_helmet.mat';
        cfg.colormap     = '*RdBu';
        figure;
        ft_topoplotER(cfg, avg_ERboxcar_ar_lateral_dif);
        title(sprintf('Average left - right attention (dB) ; %s', cond));
        saveas(gcf,fullfile(derivatives_dir, sprintf('sub-all_stim-%s_band-%s_lateral-dif.png', cond, band)))
    end
end


%% WORKING MEMORY EXPERIMENT

for sub = subjects
    sub_str = sprintf('sub-%03d', sub)
    close all

    img_dir = fullfile(derivatives_dir, sub_str, '/ses-001/img/');
    deriv_meg_dir = fullfile(derivatives_dir, sub_str, '/ses-001/meg/');
    load (fullfile(deriv_meg_dir, 'data_pca_wm.mat'))

    if not(exist('neighbours', 'var') == 1)
        cfg                 = [];
        cfg.feedback        = 'yes';
        cfg.method          = 'template';
        cfg.planarmethod    = 'sincos';
        neighbours      = ft_prepare_neighbours(cfg, data_pca_wm);
    end
    
    cfg = [];
    cfg.toilim    = [0.5 6.5-1/1200];
    data        = ft_redefinetrial(cfg,data_pca_wm);
    
    stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);
    foilims = [[39 41]', [7 15]', [13 30]'];
    foilim_bands = ["40-Hz", "7-15-Hz", "13-30-Hz"];
    difficulty_contrast_gamma = [];
    difficulty_contrast_alpha = [];
    difficulty_contrast_beta = [];
    for condition = ["con", "strobe"]
        condition

        task_map = dictionary(["high", "low"], [1, 2]);
        
        trials_va_cond = data.trialinfo(:,3) == stim_map(condition) & ...
            bitor(data.trialinfo(:,4) == task_map("high"), ...
                data.trialinfo(:,4) == task_map("low"));
       
        cfg = [];
        cfg.trials = trials_va_cond;
        data_wm_cond = ft_selectdata(cfg, data);

        % plot TFR
        channels = 'M*O**';
        cfg              = [];
        cfg.output       = 'pow';
        cfg.channel      = channels;
        cfg.method       = 'mtmconvol';
        cfg.taper        = 'boxcar';
        cfg.foi          = 10:1:50;                         % analysis 2 to 30 Hz in steps of 2 Hz
        cfg.t_ftimwin    = ones(length(cfg.foi),1).*1;   % length of time window = 1 sec
        cfg.toi          = 0:0.05:2;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
        TFRboxcar_ar        = ft_freqanalysis(cfg, data_wm_cond);
        
        cfg = [];
        figure; ft_singleplotTFR(cfg, TFRboxcar_ar);
        title('Left attention');
        saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_power_stim-%s_wm_psd.png', sub, condition)))


        trials_high = data_wm_cond.trialinfo(:,4) == task_map("high");
        trials_low = data_wm_cond.trialinfo(:,4) == task_map("low");
       
        cfg = [];
        cfg.trials = trials_high;
        data_high = ft_selectdata(cfg, data_wm_cond);
        
        cfg = [];
        cfg.trials = trials_low;
        data_low = ft_selectdata(cfg, data_wm_cond);
        

        proc = "splg"
        for foilim = [1 2 3]
        %
        %
             cfg                 = [];
            cfg.feedback        = 'yes';
            cfg.method          = 'template';
            cfg.planarmethod    = 'sincos';
            cfg.neighbours      = neighbours;
            data_high_planar = ft_megplanar(cfg, data_high);
            data_low_planar = ft_megplanar(cfg, data_low);

            cfg              = [];
            channels = 'MEG';
            cfg.output       = 'pow';
            cfg.channel      = channels;
            cfg.method       = 'mtmfft';
            cfg.taper        = 'boxcar';
            cfg.foilim       = foilims(:, foilim)';
            ERboxcar_ar_high_planar        = ft_freqanalysis(cfg, data_high_planar);
            ERboxcar_ar_low_planar        = ft_freqanalysis(cfg, data_low_planar);
            
            cfg = [];
            ERboxcar_ar_high = ft_combineplanar(cfg, ERboxcar_ar_high_planar);
            ERboxcar_ar_low= ft_combineplanar(cfg, ERboxcar_ar_low_planar);
        
            
            cfg.parameter = 'powspctrm';
            cfg.operation = 'log10(x1./x2)'; %'(x1-x2)/(x1+x2)';
            ERboxcar_ar_difficulty_dif = ft_math(cfg, ERboxcar_ar_high, ERboxcar_ar_low);
            
            
            %
            cfg = [];
            cfg.xlim         = foilims(:, foilim)';
            cfg.marker       = 'on';
            cfg.colorbar     = 'yes';
            cfg.layout       = 'CTF151_helmet.mat';
            cfg.colormap = '*RdBu';
            cfg.zlim = 'maxabs';
            
            figure;
            ft_topoplotER(cfg, ERboxcar_ar_high);
            title(sprintf('High arithmetic difficulty, %s', condition));
            saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_%s-power_stim-%s_proc-%s_high-difficulty_topo.png', sub, foilim_bands(foilim), condition, proc)))

            
            figure;
            ft_topoplotER(cfg, ERboxcar_ar_low);
            title(sprintf('Low arithmetic difficulty; %s', condition));
            saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_%s-power_stim-%s_proc-%s_low-difficulty.png', sub, foilim_bands(foilim), condition, proc)))
            
            figure;
            ft_topoplotER(cfg, ERboxcar_ar_difficulty_dif);
            title(sprintf('High minus low arithmetic difficulty (dB); %s', condition));
            saveas(gcf,fullfile(img_dir, sprintf('sub-%03d_%s-power_stim-%s_proc-%s_difficulty-contrast.png', sub, foilim_bands(foilim), condition, proc)))
            
            switch foilim
                case 1
                    difficulty_contrast_gamma.(sprintf('%s', condition)) = ERboxcar_ar_difficulty_dif;
                case 2
                    difficulty_contrast_alpha.(sprintf('%s', condition)) = ERboxcar_ar_difficulty_dif;
                case 3
                    difficulty_contrast_beta.(sprintf('%s', condition)) = ERboxcar_ar_difficulty_dif;
            end
        end
    end
    fname = 'difficulty_contrast_gamma.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'difficulty_contrast_gamma', '-v7.3');
    fname = 'difficulty_contrast_alpha.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'difficulty_contrast_alpha', '-v7.3');
    fname = 'difficulty_contrast_beta.mat';
    ar_out_dest = fullfile(deriv_meg_dir, fname);
    save (ar_out_dest, 'difficulty_contrast_beta', '-v7.3');
end

%
close all
sub_struct_gamma = [];
sub_struct_alpha = [];
sub_struct_beta = [];

for sub = subjects    
    deriv_meg_dir = fullfile(derivatives_dir, sub_str, '/ses-001/meg/');
    load (fullfile(deriv_meg_dir, 'difficulty_contrast_gamma.mat'))
    sub_struct_gamma.(sprintf('sub%03d', sub)) = difficulty_contrast_gamma;
    load (fullfile(deriv_meg_dir, 'difficulty_contrast_alpha.mat'))
    sub_struct_alpha.(sprintf('sub%03d', sub)) = difficulty_contrast_alpha;
    load (fullfile(deriv_meg_dir, 'difficulty_contrast_beta.mat'))
    sub_struct_beta.(sprintf('sub%03d', sub)) = difficulty_contrast_beta;
end

%
close all
condition = ["con", "strobe"];
avg_cond = [];
for band = ["40", "alpha", "beta"]
    switch band
        case "40"
            data = sub_struct_gamma;
        case "alpha"
            data = sub_struct_alpha;
        case "beta"
            data = sub_struct_beta;
    end
    for cond = condition
        % Average spectra over subjects        
        data_args = {};
       
        operation_str = '(';
        for s = 1:numel(subjects)
            data_args = [data_args data.(sprintf('sub%03d', subjects(n))).(cond)];
            operation_str = [operation_str 'x' num2str(s) '+'];
        end
        operation_str = [operation_str(1:end-1) ')/' num2str(numel(subjects))];

        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str;

        avg_ERboxcar_ar_lateral_dif = ft_math(cfg, data_args{:});
    
        cfg = [];
        cfg.marker       = 'on';
        cfg.colorbar     = 'yes';
        cfg.layout       = 'CTF151_helmet.mat';
        cfg.colormap = '*RdBu';
        cfg.zlim = 'maxabs';
        figure;
        ft_topoplotER(cfg, avg_ERboxcar_ar_lateral_dif);
        title(sprintf('Average high - low arithmetic difficulty (dB) ; %s', cond));
        saveas(gcf,fullfile(derivatives_dir, sprintf('sub-all_stim-%s_band-%s_arithmetic-difficulty-dif.png', cond, band)))
    end
end

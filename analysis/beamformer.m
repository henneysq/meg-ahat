%% SETUP
clear;

% Flag to indicate whether we update source and leadfield models
update_models = false;

% Add util and template dirs to path
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/templates')

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

% Define subjects, tasks, and conditions
subjects = data_details_cfg.new_trigger_subs; % Subjects correctly stimulated
tasks = ["va"];
conditions = ["con" "strobe"];

% Define mapping for easier indexing
stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);


%% BEAMFORMING
% Iterate over subjects to perform beamforming of the 40 Hz signal
% and contrast condtions given task(s) and condition(s).
% Each contrast is saved to disk for a given subject.
for sub = subjects
    sub_str = sprintf('sub-%03d', sub)
    
    % Define subject-level directories
    deriv_anat_dir = fullfile(derivatives_dir, sub_str, '/ses-001/anat/');
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    raw2_meg_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    
    % Load headmodel
    mri_headmodel_file = fullfile(deriv_anat_dir, 'mri_headmodel.mat');
    load (mri_headmodel_file)
    % As we are defining a grid in mm, assure the unit of head model is mm
    mri_headmodel = ft_convert_units(mri_headmodel, 'mm');    

    % Symmentrical source model:
    % Define a source model with a grid symmetric around the midline
    % for conducting symmetric dipole beamforming.
    % As the grid is defined in 'CTF' coordinates, positive y-values
    % indicate the left side hemisphere:
    % https://www.fieldtriptoolbox.org/faq/coordsys/#details-of-the-ctf-coordinate-system
    if not(isfile(fullfile(deriv_meg_dir, 'sourcemodel.mat'))) || update_models
        cfg = [];
        cfg.headmodel = mri_headmodel;
        cfg.symmetry = 'y';
        cfg.xgrid = -148:8:148; % in mm
        cfg.ygrid =    4:8:148; % in mm, left hemisphere, offset to the midline
        cfg.zgrid = -148:8:148; % in mm
        sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'sourcemodel.mat'), 'sourcemodel', '-v7.3')
    else
        load (fullfile(deriv_meg_dir, 'sourcemodel.mat'))
    end

    % Non-symmetrical source model:
    % Create a headmodel without the symmetry constraint.
    % This is needed to interpret the results of the symmetric dipole
    % beamforming results after untangling the hemispheres.
    if not(isfile(fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'))) || update_models
        cfg = [];
        cfg.headmodel = mri_headmodel;
        cfg.xgrid = -148:8:148; % in mm
        cfg.ygrid = -148:8:148; % in mm, one hemisphere, offset to the midline
        cfg.zgrid = -148:8:148; % in mm
        nonsym_sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'), 'nonsym_sourcemodel', '-v7.3')
    else
        load (fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'))
    end

    % Leadfield:
    % Estimate the leadfield using the symmetric sourcemodel
    if not(isfile(fullfile(deriv_meg_dir, 'leadfield.mat'))) || update_models
        % Load grad from raw2 version of meg data
        grad = ft_read_sens( ...
            fullfile(raw2_meg_dir, ...
                sprintf('sub-%03d_ses-001_task-flicker_meg.ds', sub)), ...
            'senstype', 'meg');

        cfg = [];
        cfg.grad = grad;
        cfg.channel = {'MEGGRAD'};
        cfg.headmodel = mri_headmodel;
        cfg.sourcemodel = sourcemodel;
        leadfield = ft_prepare_leadfield(cfg);
        save (fullfile(deriv_meg_dir, 'leadfield.mat'), 'leadfield', '-v7.3')  
    else
        load (fullfile(deriv_meg_dir, 'leadfield.mat'))
    end

    % Iterate over tasks (i.e. runs 1 and 2: visual attention ('va') and 
    % working memory('wm') )
    for task = tasks
        % Load artefact-removed data containing MEG data from both runs
        var_name = sprintf('data_pca_%s', task);
        fname = strcat(var_name, '.mat');
        ar_source = fullfile(deriv_meg_dir, fname);
        data_all = load (ar_source, var_name);
        data_all = data_all.(var_name);
        
        switch task
            case "va"
                task_map = dictionary(["left", "right"], [1, 2]);
                % Redefine trials to 2-second segments
                cfg = [];
                cfg.toilim    = [0.5 2.5-1/1200];
                data        = ft_redefinetrial(cfg,data_all);
            
                % Iterate over the no-flicker and luminance-flicker
                % conditions for now (con & strobe)
                for condition = conditions
                    sprintf('Stimulation condtition: %s', condition)
            
                    % Find and select trials that are from run 1
                    % and belong to the condition
                    trials_va_cond = data.trialinfo(:,3) == stim_map(condition) & ...
                        bitor(data.trialinfo(:,4) == task_map("left"), ...
                            data.trialinfo(:,4) == task_map("right"));
                    cfg = [];
                    cfg.trials = trials_va_cond;
                    data = ft_selectdata(cfg, data);
            
                    % Find and select left and right attention trials independently
                    trials_left = data.trialinfo(:,4) == task_map("left");
                    trials_right = data.trialinfo(:,4) == task_map("right");
                    cfg = [];
                    cfg.trials = trials_left;
                    data_left = ft_selectdata(cfg, data);
                    cfg.trials = trials_right;
                    data_right = ft_selectdata(cfg, data);
                         
                    % Calculate periodogram
                    cfg              = [];
                    cfg.output       = 'powandcsd';
                    cfg.method       = 'mtmfft';
                    cfg.taper        = 'boxcar';
                    cfg.foilim       = [40 40];
                    ERboxcar_ar_left        = ft_freqanalysis(cfg, data_left);
                    ERboxcar_ar_right        = ft_freqanalysis(cfg, data_right);
                    % We also need the combined data for calculating the
                    % common spatial filter
                    ERboxcar_Ar        = ft_freqanalysis(cfg, data);
                    
                    % Source Analysis of lateral contrast
                    cfg                   = []; 
                    cfg.method            = 'dics';
                    cfg.frequency         = 40;  
                    cfg.channel           = data.label(:);
                    cfg.grid              = leadfield;
                    cfg.headmodel         = mri_headmodel;
                    cfg.dics.keepfilter   = 'yes';
                    cfg.dics.fixedori     = 'no';
                    cfg.dics.projectnoise = 'yes';
                    cfg.dics.lambda       = '5%';
                    cfg.dics.realfilter   = 'yes';
                    cfg.dics.keepcsd      = 'yes';
                    source_va = ft_sourceanalysis(cfg, ERboxcar_Ar);
                    
                    % Extract the common spatial filter and use in the
                    % individual source estimates
                    cfg.sourcemodel.filter = source_va.avg.filter;
                    % We need to use the 'pcc' method with keepdcsd = 'yes'
                    % and then manually calculate the power on each
                    % hemisphere, decoupling the symmetric dipoles
                    cfg.method   = 'pcc';
                    cfg.keepcsd = 'yes';
                    cfg          = rmfield(cfg, 'dics');
                    source_va_left = ft_sourceanalysis(cfg, ERboxcar_ar_left);
                    source_va_right = ft_sourceanalysis(cfg, ERboxcar_ar_right);

                    % From the symmetric dipole constraint, we get a
                    % 6x6 CSD matrix, defined by the 6-dimensional position
                    % vector 'pos' , of which the first three elements are
                    % the xyz coordinates of the left hemisphere diploe
                    % (positive y), and the last three elements are the xyz
                    % coordinates of the right hemisphere diploe (negative
                    % y). As such, the CSD values reflect the coordinate
                    % pairs defined by pos^T x pos.
                    % Thus, the upper left 3x3 block represents the left
                    % hemisphere dipole CSD, and the lower right 3x3 block
                    % represents the right hemisphere dipole
                    hemispheres = ["left", "right"];
                    sources_va_left_hsplit = [];
                    sources_va_right_hsplit = [];
                    for hn = 1:2
                        for k = 1:size(source_va_left.pos,1)
                            if ~isempty(source_va_left.avg.csdlabel{k})
                                % Define 3x3 block indices for the CSD of
                                % interest
                                indices = (1:3) + 3 * (hn - 1);
                                % Set the CSD label to 'scandip' to
                                % indicate the it is a scanner dipole
                                source_va_left.avg.csdlabel{k}(indices) = {'scandip'};
                                source_va_right.avg.csdlabel{k}(indices) = {'scandip'};
                                % Define 3x3 block indices for the CSD of
                                % no-interest
                                indices = (4:6) - 3 * (hn - 1);
                                % Set the CSD label to 'scandip' to
                                % indicate the it is a suppression dipole
                                source_va_left.avg.csdlabel{k}(indices) = {'supdip'};
                                source_va_right.avg.csdlabel{k}(indices) = {'supdip'};
                                
                            end
                        end
                        % Estimate the power from the CSD using the first
                        % singular value
                        cfg = [];
                        cfg.keepcsd = 'no';
                        cfg.powmethod = 'lambda1';
                        % ft_sourcedescriptives indexes the 6x6 CSD matric
                        % based on the CSD labels and implements the power
                        % estimate based on Gross et.al. eq (8) https://doi.org/10.1073/pnas.98.2.694
                        sources_va_left_hsplit.(hemispheres(hn)) = ft_sourcedescriptives(cfg, source_va_left);
                        sources_va_right_hsplit.(hemispheres(hn)) = ft_sourcedescriptives(cfg, source_va_right);
                    end
                    
                    % As we are left with two objects representing
                    % simulataneously both hemispheres and one hemisphere,
                    % we need to massage the estimates back into a
                    % structure that fieldtrip understands downstream.
                    % Reshape the 1-dimensional power estimates to the
                    % 3-dimensional sourcemodel dims
                    hem_left = reshape(sources_va_left_hsplit.left.avg.pow, sourcemodel.dim);
                    hem_right = reshape(sources_va_left_hsplit.right.avg.pow, sourcemodel.dim);

                    % As the symmetric source model grid was define on the
                    % left hemisphere (positive y in CTF coordinates), we
                    % need to flip the right hemispheres around the y-axis
                    % before concatenating them
                    hem_right = flip(hem_right,2);
                    both_hemispheres = [hem_right hem_left];

                    % Make sure this risky step happened as intended
                    assert (all((size(both_hemispheres) == size(hem_left)) == [1 0 1]))

                    % Grab the metadata from the non-symmetrical
                    % sourcemodel and add value(s)
                    s_va_left= nonsym_sourcemodel;
                    s_va_left.freq = 40;
                    % Reshape the 3-dimensional power estimates for the
                    % entire brain back into the 1-dimensional array
                    % expected by fieldtrip
                    s_va_left.avg.pow = reshape(both_hemispheres,[],1);

                    % Repeat for other lateral condition
                    hem_left = reshape(sources_va_right_hsplit.left.avg.pow, sourcemodel.dim);
                    hem_right = reshape(sources_va_right_hsplit.right.avg.pow, sourcemodel.dim);
                    hem_right = flip(hem_right,2);
                    both_hemispheres = [hem_right hem_left];
                    assert (all((size(both_hemispheres) == size(hem_left)) == [1 0 1]))
                    s_va_right= nonsym_sourcemodel;
                    s_va_right.freq = 40;
                    s_va_right.avg.pow = reshape(both_hemispheres,[],1);

                    % Contrast the lateral conditions, normalising to their
                    % combined power
                    cfg           = [];
                    cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
                    cfg.parameter = 'avg.pow';
                    source_lateral_dif   = ft_math(cfg,s_va_left,s_va_right);                    

                    % Save output to derivatives
                    source_va_dif_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_dif-lateral_cond-%s.mat', task, condition));
                    save (source_va_dif_file, 'source_lateral_dif', '-v7.3')

                end
            case "wm"
                % TODO
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

%% Average over lateral contrasts

lateral_dif_sources = cell(1,numel(subjects));
task = "va";
conditions = ["con" "strobe"];
for condition = conditions
    for s = 1:numel(subjects)
        sub = subjects(s)
        
        deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    
        source_va_dif_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_dif-lateral_cond-%s.mat', task, condition));
        load (source_va_dif_file) % source_lateral_dif
    
        lateral_dif_sources{s} = source_lateral_dif;
    
    end
    
    % grand average over subjects
    cfg           = [];
    cfg.parameter = 'pow';
    gaall         = ft_sourcegrandaverage(cfg, lateral_dif_sources{1});
    
    % interpolate onto MRI
    % load ('mri152.mat');
    deriv_anat_dir = fullfile(derivatives_dir, 'sub-030', '/ses-001/anat/'); % Use sub 30 mri for now
    mri_realigned_file = fullfile(deriv_anat_dir, 'mri_realigned.mat');
    load (mri_realigned_file)
    
    cfg           = [];
    cfg.parameter = 'pow';
    source_lateral_dif_interp  = ft_sourceinterpolate(cfg, gaall, mri_realigned);
    
    % Plot the estimated sources
    
    % thresholded opacity map, anything <65% of maximum is fully transparent,
    % anything >80% of maximum is fully opaque
    
    cfg = [];
    cfg.method        = 'ortho';
    cfg.funparameter  = 'pow';
    cfg.funcolormap   = 'jet';
    
    figure;
    ft_sourceplot(cfg, source_lateral_dif_interp);
    
    
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'pow';
    cfg.funcolormap   = 'jet';
    
    figure;
    ft_sourceplot(cfg, source_lateral_dif_interp);
    % 
    % 
    % source_lateral_dif_interp.nicemask = make_mask(source_lateral_dif_interp.pow, [0.5 0.8]);
    % cfg = [];
    % cfg.method        = 'ortho';
    % cfg.funparameter  = 'pow';
    % cfg.maskparameter = 'nicemask';
    % cfg.funcolormap   = 'jet';
    % 
    % figure;
    % ft_sourceplot(cfg, source_lateral_dif_interp);
    % 
    % 
    % cfg = [];
    % cfg.method        = 'slice';
    % cfg.funparameter  = 'pow';
    % cfg.maskparameter = 'nicemask';
    % cfg.funcolormap   = 'jet';
    % 
    % figure;
    % ft_sourceplot(cfg, source_lateral_dif_interp);
end
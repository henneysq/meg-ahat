%% Add util dir to path
clear;

addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');

% Start logging
diaryfile = fullfile(data_dir, 'make_head_model.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

% Load data details
data_details_cfg = get_data_details();

% Define subjects - should eventually be centralised
% subjects = data_details_cfg.new_trigger_subs; %[8 9 11 13 17 18 21:23 25 27:30];
subjects = [24 26]

for sub = subjects
    close all
    sub_str = sprintf('sub-%03d', sub)

    deriv_anat_dir = fullfile(derivatives_dir, sub_str, '/ses-001/anat/');
    raw2_meg_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    
    if not(exist(deriv_anat_dir, 'dir'))
      mkdir(deriv_anat_dir);
    end

    % Check if fiducials/realignment has already been done
    mri_file = fullfile(deriv_anat_dir, 'mri_realigned.mat');
    if isfile(mri_file)
        load (mri_file)
    else
        
        % Load anatomical MRI data
        anat_dir = fullfile(raw2_dir, sub_str, 'ses-001', 'anat');
        fname = sprintf('%s_ses-001_T1w.nii', sub_str);
        mri = ft_read_mri(fullfile(anat_dir, fname));
        mri = ft_determine_coordsys(mri);
    
        % Re-align MRI to MEG
        cfg = [];
        cfg.method = 'interactive';
        cfg.coordsys = 'ctf';
        cfg.viewresult = 'no';
        mri_realigned = ft_volumerealign(cfg, mri); 
        save (mri_file, 'mri_realigned', '-v7.3')
    end
    
    % Segment MRI
    cfg           = [];
    cfg.output    = 'brain';
    cfg.spmmethod = 'old';
    cfg.spmversion = 'spm12';
    segmentedmri  = ft_volumesegment(cfg, mri_realigned);

    % Build head model
    cfg = [];
    cfg.method='singleshell';
    mri_headmodel = ft_prepare_headmodel(cfg, segmentedmri);

    % Visualise
    mri_headmodel = ft_convert_units(mri_headmodel, 'mm');
    sens = ft_read_sens(fullfile(raw2_meg_dir, ...
       sprintf('%s_ses-001_task-flicker_meg.ds', sub_str)), 'senstype', 'meg');
    
    figure
    title(sub_str)
    ft_plot_sens(sens, 'style', '*b');
    
    hold on
    ft_plot_headmodel(mri_headmodel);

    % Save headmodel to disk
    mri_headmodel_file = fullfile(deriv_anat_dir, 'mri_headmodel.mat');
    save (mri_headmodel_file, 'mri_headmodel', '-v7.3')

end

diary off

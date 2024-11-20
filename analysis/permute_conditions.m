function [stat, output_file] = permute_conditions(permute_cfg)

    % Define directories
    data_dir = '/project/3031004.01/data/';
    derivatives_dir = fullfile(data_dir, 'derivatives');
    derivatives_group_dir = fullfile(derivatives_dir, 'group');

    % Add util dirs to path
    addpath('/project/3031004.01/meg-ahat/util')

    % Set up Fieldtrip
    configure_ft


    if isfield(permute_cfg, 'numrandomization')
        numrandomization = permute_cfg.numrandomization;
    else
        numrandomization = 1500;
    end

    if permute_cfg.permute.factor == "stim_condition"
        if isfield(permute_cfg, 'contrast')
            input_snip1 = sprintf('task-%s_stimcondition-%s_contrast-tasklevel-%s-%s', ...
                permute_cfg.task, permute_cfg.permute.levels(1), permute_cfg.contrast(1), permute_cfg.contrast(2));
            input_snip2 = sprintf('task-%s_stimcondition-%s_contrast-tasklevel-%s-%s', ...
                permute_cfg.task, permute_cfg.permute.levels(2), permute_cfg.contrast(1), permute_cfg.contrast(2));
            output_file = sprintf('task-%s_contrast-tasklevel-%s-%s_permutation-stimcondition-%s-%s_npermut-%d.mat', ...
                permute_cfg.task, permute_cfg.contrast(1), permute_cfg.contrast(2),permute_cfg.permute.levels(1), ...
                permute_cfg.permute.levels(2), numrandomization);
        else
            input_snip1 = sprintf('task-%s_stimcondition-%s', ...
                permute_cfg.task, permute_cfg.permute.levels(1));
            input_snip2 = sprintf('task-%s_stimcondition-%s', ...
                permute_cfg.task, permute_cfg.permute.levels(2));
            output_file = sprintf('task-%s_permutation-stimcondition-%s-%s_npermut-%d.mat', ...
                permute_cfg.task, permute_cfg.permute.levels(1), permute_cfg.permute.levels(2), ...
                numrandomization);
        end
    elseif permute_cfg.permute.factor == "tasklevel"
        assert (isfield(permute_cfg, 'stim_condition'))
        input_snip1 = sprintf('task-%s_stimcondition-%s_tasklevel-%s', ...
            permute_cfg.task, permute_cfg.stim_condition, permute_cfg.permute.levels(1));
        input_snip2 = sprintf('task-%s_stimcondition-%s_tasklevel-%s', ...
            permute_cfg.task, permute_cfg.stim_condition, permute_cfg.permute.levels(2));
        output_file = sprintf('task-%s_stimcondition-%s_permutation-tasklevel-%s-%s_npermut-%d.mat', ...
            permute_cfg.task, permute_cfg.stim_condition, permute_cfg.permute.levels(1), ...
            permute_cfg.permute.levels(2), numrandomization);
    else
        error("Unrecognised permutation factor")
    end

    overwrite = false;
    if isfield(permute_cfg, 'overwrite')
        overwrite = permute_cfg.overwrite;
    end

    if isfile(fullfile(derivatives_group_dir,output_file)) && ~overwrite
        stat = load (fullfile(derivatives_group_dir,output_file));
        stat = stat.stat;
        return
    end

    n_subs = numel(permute_cfg.subs);
    sources1 = cell(n_subs, 1);
    sources2 = cell(n_subs, 1);
    for s = 1:n_subs

        sub = permute_cfg.subs(s);

        file1_intvolnorm = fullfile(derivatives_dir, ...
            sprintf('sub-%03d', sub), 'ses-001', 'meg', ...
            sprintf('sub-%03d_%s_intvolnorm.mat', sub, input_snip1));
        file2_intvolnorm = fullfile(derivatives_dir, ...
            sprintf('sub-%03d', sub), 'ses-001', 'meg', ...
            sprintf('sub-%03d_%s_intvolnorm.mat', sub, input_snip2));

        if isfile(file1_intvolnorm) && isfile(file2_intvolnorm) && ~overwrite
            source1 = load(file1_intvolnorm);
            fn = fieldnames(source1);
            sources1{s} = ft_struct2single(source1.(fn{1}));
            source2 = load(file2_intvolnorm);
            fn = fieldnames(source2);
            sources2{s} = ft_struct2single(source2.(fn{1}));
        else

            file1 = fullfile(derivatives_dir, ...
                sprintf('sub-%03d', sub), 'ses-001', 'meg', ...
                sprintf('sub-%03d_%s.mat', sub, input_snip1));
            source1 = load(file1);
            fn = fieldnames(source1);
            source1 = ft_struct2single(source1.(fn{1}));

            file2 = fullfile(derivatives_dir, ...
                sprintf('sub-%03d', sub), 'ses-001', 'meg', ...
                sprintf('sub-%03d_%s.mat', sub, input_snip2));
            source2 = load(file2);
            fn = fieldnames(source2);
            source2 = ft_struct2single(source2.(fn{1}));
    
            % Interpolate and volume normalise
            deriv_anat_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), 'ses-001', 'anat');
            mri_realigned = load (fullfile(deriv_anat_dir, 'mri_realigned.mat'));
            mri_realigned = mri_realigned.mri_realigned;
    

            cfg           = [];
            cfg.parameter = 'pow';
            source1 = ft_sourceinterpolate(cfg, source1, mri_realigned);
            source2 = ft_sourceinterpolate(cfg, source2, mri_realigned);

            cfg = [];
            cfg.nonlinear     = 'no';
            source1 = ft_volumenormalise(cfg, source1);
            source2 = ft_volumenormalise(cfg, source2);

            
            save(file1_intvolnorm, 'source1')
            save(file2_intvolnorm, 'source2')

            sources1{s} = source1;
            sources2{s} = source2;
        end
        

    end

    cfg=[]; 
    cfg.numrandomization = 5;
    cfg.correctm = 'cluster';
    cfg.dim         = sources1{1}.dim;
    cfg.method      = 'montecarlo';
    cfg.statistic   = 'ft_statfun_depsamplesT';
    cfg.parameter   = 'pow';
    % cfg.tfce_H           = 2;       % default setting
    % cfg.tfce_E           = 0.5;     % default setting
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.alpha       = 0.05; % note that this only implies single-sided testing
    cfg.tail        = 0;
    
    nsubj=numel(sources1);
    cfg.design(1,:) = [1:nsubj 1:nsubj];
    cfg.design(2,:) = [ones(1,nsubj)*1 ones(1,nsubj)*2];
    cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
    cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)


    stat = ft_sourcestatistics(cfg, sources1{:}, sources2{:});

    save(fullfile(derivatives_group_dir, output_file), 'stat', '-v7.3')

end
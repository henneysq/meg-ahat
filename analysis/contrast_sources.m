function source_contrast = contrast_sources(source1_cfg, source2_cfg, cfg)
    % Contrast the task conditions, normalising to their
    % combined power

    % Add util dirs to path
    addpath('/project/3031004.01/meg-ahat/util')

    % Set up Fieldtrip
    configure_ft

    if ~exist('cfg','var')
        cfg           = [];
        cfg.operation = '(x2-x1)/(x2+x1)';
        cfg.parameter = 'pow';
    end

    assert (source1_cfg.sub == source2_cfg.sub)
    sub = source1_cfg.sub;
    
    assert (source1_cfg.task == source2_cfg.task)
    task = source1_cfg.task;

    if source1_cfg.stim_condition == source2_cfg.stim_condition
        input_file1 = sprintf('sub-%03d_task-%s_stimcondition-%s_tasklevel-%s.mat', sub, ...
            task, source1_cfg.stim_condition, source1_cfg.task_level);
        input_file2 = sprintf('sub-%03d_task-%s_stimcondition-%s_tasklevel-%s.mat', sub, ...
            task, source2_cfg.stim_condition, source2_cfg.task_level);
        output_file = sprintf('sub-%03d_task-%s_stimcondition-%s_contrast-tasklevel-%s-%s.mat', sub, ...
                task, source1_cfg.stim_condition, source1_cfg.task_level, source2_cfg.task_level);
    elseif not(isfield(source1_cfg, 'tasklevel'))
        input_file1 = sprintf('sub-%03d_task-%s_stimcondition-%s.mat', sub, ...
            task, source1_cfg.stim_condition);
        input_file2 = sprintf('sub-%03d_task-%s_stimcondition-%s.mat', sub, ...
            task, source2_cfg.stim_condition);
        output_file = sprintf('sub-%03d_task-%s_contrast-stimcondition-%s-%s.mat', sub, ...
                task, source1_cfg.stim_condition, source2_cfg.stim_condition);
    end
    
    % Define directories
    data_dir = '/project/3031004.01/data/';
    derivatives_dir = fullfile(data_dir, 'derivatives');
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');

    source1 = load(fullfile(deriv_meg_dir, input_file1));
    fn = fieldnames(source1);
    source1 = source1.(fn{1});
    source2 = load(fullfile(deriv_meg_dir, input_file2));
    fn = fieldnames(source2);
    source2 = source2.(fn{1});

    source_contrast = ft_math(cfg, source1, source2);

    save(fullfile(deriv_meg_dir, output_file), 'source_contrast', '-v7.3')

end
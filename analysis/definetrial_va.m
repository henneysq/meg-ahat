function [trl, event] = pilot_definetrial_va(cfg);
    
    % read the header information and the events from the data
    hdr   = ft_read_header(cfg.dataset);

    run = cfg.run;
    ses = cfg.ses;
    sub = cfg.sub;
    task = 'visualattention';

    beh_dir = fullfile(cfg.dataset, '..', '..', 'beh');
    event = readtable(fullfile(beh_dir, ...
        sprintf('sub-%03d_ses-00%d_run-00%d_task-%s_events.tsv', ...
        sub, ses, run, task)), ...
        "FileType","text",'Delimiter', '\t');

    % OBS: Remove entries that have -1 to indicate quick/catch trials
    event = event(event.sample ~= -1, :);
    
    % determine the number of samples before and after the trigger
    pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
    posttrig =  round(cfg.trialdef.post * hdr.Fs);

    % Make map from string-represented condition to integer
    stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);
    task_map = dictionary(["left", "right"], [1, 2]);
    
    % look for the combination of a trigger "5" followed by a trigger "6"
    % for each trigger except the last one
    trl = [];
    for j = 1:height(event)

        trlbegin = event.sample(j) + pretrig;
          
        trlend = event.sample(j) + round(hdr.Fs * event.duration(j)) + posttrig;
        
        
        offset   = pretrig;
        python_trial_number = event.trial_number(j);
        block_number = event.block_number(j);
        condition = stim_map(event.stimulus_condition(j));
        task = task_map(event.task(j));
        task_congruence = event.task_congruence(j);
        response  = event.response(j);
        rt  = event.reaction_time(j);
        rt_meg  = event.rt_meg(j);
        newtrl   = [trlbegin trlend, offset, python_trial_number, ...
                block_number, condition, task, task_congruence, ...
                response, rt, rt_meg];
        
        trl      = [trl; newtrl];
    end

    trl = [trl (1:size(trl, 1))'];
    
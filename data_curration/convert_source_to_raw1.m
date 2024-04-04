function convert_source_to_raw1(sub, general_cfg, source_dir, overwrite_cfg)

    sub_str = sprintf('sub-%03d', sub);
    ses_str = 'ses-001';
    sub_source_dir = fullfile(source_dir, sub_str);
    source_ses1_dir = fullfile(sub_source_dir, ses_str);

    % Evaluate the missing data file
    eval data_details
    if isfield(data_details_cfg, sprintf('sub%03d', sub))
        sub_data_details_cfg = data_details_cfg.(sprintf('sub%03d', sub));
    else
        sub_data_details_cfg = [];
    end
    
    % Specify the missing sunject specific details
    general_cfg.sub = sprintf('%03d', sub);

    
    % #################################
    % ############## MRI ##############
    
    % First check for existing raw1 file and whether to overwrite
    raw1_output_nifti_file = fullfile(general_cfg.bidsroot, sub_str,  ses_str, ...
        'anat', sprintf('%s_%s_T1w.nii', sub_str, ses_str));
        
    % FieldTrip does not provide the logic for overwriting
    % in all scenarios, so we deal with it here
    write_files_flag = check_n_prep_overwrite(raw1_output_nifti_file, ...
        overwrite_cfg.anat);

    if write_files_flag
        % Specify souce path
        sub_source_mri_data = fullfile(sub_source_dir, 'ses-mri01', ...
            '006-t1_mprage_sag_ipat2_1p0iso_20ch-head-neck');
    
        % The Skyra MRI scanner produces a single DICOM, while
        % the Prisma produces one pr. slice; handle this
        tmp = dir(fullfile(sub_source_mri_data, '*.IMA'));
        if numel(tmp) > 1
            % Just use the first DICOM file
            mri_file = fullfile(sub_source_mri_data, tmp(1).name);
        else
            mri_file = fullfile(sub_source_mri_data, tmp.name);
        end        
    
        % Get the general information for the config
        cfg = general_cfg;
        cfg.ses = '001';
    
        % Specify the MRI specific details
        cfg.dataset = mri_file;
        cfg.suffix = 'T1w';
        cfg.dataset_description.BIDSVersion = 'v1.5.0';
    
        data2bids(cfg);
    end

    
    % #######################################
    % ############## Polhemous ##############
    
    % Specify destination file path
    meg_dir_raw1_ses1 = fullfile(general_cfg.bidsroot, sub_str, ...
        ses_str, 'meg');
    head_shape_file_raw1 = fullfile(meg_dir_raw1_ses1, ...
        sprintf('%s_%s_headshape.pos', sub_str, ses_str));

    write_files_flag = check_n_prep_overwrite(head_shape_file_raw1, ...
        overwrite_cfg.polhemous);
    if write_files_flag
        % Specify souce path
        head_shape_file_source = fullfile(source_ses1_dir, 'meg', ...
            sprintf('%s.pos', sub_str));
    
        if not(isfolder(meg_dir_raw1_ses1))
            mkdir(meg_dir_raw1_ses1)
        end
    
        copyfile(head_shape_file_source, head_shape_file_raw1)
    end


    % #################################
    % ############## MEG ##############

    meg_file = fullfile(meg_dir_raw1_ses1, ...
        sprintf('%s_%s_task-flicker_meg.ds', sub_str, ses_str));

    write_files_flag = check_n_prep_overwrite(meg_file, overwrite_cfg.meg);

    if write_files_flag
        % Specify source path
        sub_source_meg_dir = fullfile(sub_source_dir, 'ses-meg01', 'meg');
        sub_source_meg_data_dir = dir(fullfile(sub_source_meg_dir, ...
            sprintf('sub%03dses01*.ds', sub)));
        sub_source_meg_data = fullfile(sub_source_meg_dir, ...
            sub_source_meg_data_dir.name);
    
        % Get the general information for the config
        cfg = general_cfg;
    
        % Specify the MEG configuration
        cfg.ses = '001';
        cfg.dataset = sub_source_meg_data;
        cfg.suffix = 'meg';
        cfg.method = 'copy'; % the original data is in a BIDS-compliant 
                             % format and can simply be copied
        cfg.dataset_description.BIDSVersion = 'v1.5.0';
        cfg.TaskDescription = ['The experiment consisted of visual flicker ' ...
            'stimulation combined with a visual attention discrimination ' ...
            'task and an arithmetic task.'];
        cfg.task = 'flicker';
        cfg.PowerLineFrequency  = 50;
        cfg.DewarPosition       = 'upright';
        cfg.SoftwareFilters     = 'n/a';
        cfg.DigitizedLandmarks  = true;
        cfg.DigitizedHeadPoints = false;

        data2bids(cfg);
    end



    % ##########################################
    % ############## EYE TRACKING ##############
    
    % First check if the eyetrack data is missing
    if isfield(sub_data_details_cfg, 'eyetrack_missing')
        assert(sub_data_details_cfg.eyetrack_missing)
    else % otherwise, proceed with conversion

        % It's ambiguous where to send eyetracking data, as the BEP020
        % has naming conflicts for the events files in the /meg dir.
        % For now, we keep it in beh
        datatypedir = 'beh';
        
        eyetrack_file = fullfile(general_cfg.bidsroot, sub_str,  ses_str, ...
            datatypedir, sprintf('%s_%s_task-flicker_eyetrack.tsv', sub_str, ses_str));
        
        write_files_flag = check_n_prep_overwrite(eyetrack_file, ...
            overwrite_cfg.eyetrack);
        
        if write_files_flag
            % Specify source data path
            sub_source_eyetrack_file = fullfile(source_ses1_dir, 'meg', ...
                sprintf('%s.asc', sub_str));
            
            % Specify configuration
            cfg = general_cfg;
            cfg.datatypedir  = datatypedir;
            cfg.ses = '001';
            cfg.dataset_description.BIDSVersion = 'v1.10.0-dev';
            cfg.method    = 'convert'; % the eyelink-specific format is not 
                                       % supported, convert it to plain TSV
            cfg.dataset = sub_source_eyetrack_file;
            cfg.suffix = 'eyetrack';
            cfg.Manufacturer          = 'SR Research';
            cfg.ManufacturerModelName = 'Eyelink 1000';
            cfg.TaskDescription = ['The experiment consisted of visual flicker ' ...
                'stimulation combined with a visual attention discrimination ' ...
                'task and an arithmetic task.'];
            cfg.task = 'flicker';
            cfg.EnvironmentCoordinates = 'top-left'; % verify
            %cfg.SamplingFrequency = 1000;
            cfg.SampleCoordinateUnit = 'pixel'; % verify
            cfg.SampleCoordinateSystem = 'gaze-on-screen';
            cfg.Columns = {"timestamp","eye1_x_coordinate", "eye1_y_coordinate", ...
                "eye1_pupil_size", "event_trigger"};
            cfg.AdditionalColumns = struct('event_trigger', ...
                'Event trigger codes from BITSI');
        
            data2bids(cfg);
        end
    end


    % ##############################################
    % ############## BEHAVIOURAL LOGS ##############
    
    % Ensure that the beh dir exists
    beh_dir = fullfile(general_cfg.bidsroot, sub_str, ses_str, 'beh');

    if not(isfolder(beh_dir))
      mkdir(beh_dir)
    end
    
    % There is one log pr. experiment; considered run-001 and run-002
    % Tasks in the two runs
    tasks = {
      'visualattention';
      'workingmemory'
    };
    
    % Iterate over runs
    for runindx=1:2
        
        out_filename = sprintf('%s_%s_run-%03d_task-%s_events', ...
            sub_str, ses_str, runindx, tasks{runindx});
        out_file_path = fullfile(beh_dir, strcat(out_filename, '.tsv'));
        
        write_files_flag = check_n_prep_overwrite(out_file_path, ...
            overwrite_cfg.beh);

        if write_files_flag
            % Specify source path
            beh_filename = sprintf('%s_%s_run-%03d_experimentdata_managerdump-*.csv', sub_str, ses_str, runindx);
            beh_file_path = fullfile(source_ses1_dir, 'beh', beh_filename);

            % If there are multiple dumps, check the data_datails_cfg
            specific_filename = dir(beh_file_path);
            if numel(specific_filename) == 1
                beh_file_path = fullfile(source_ses1_dir, 'beh', specific_filename.name);
            else
                specific_filename = sub_data_details_cfg.(sprintf('beh_run%d_log_filename', runindx));
                beh_file_path = fullfile(source_ses1_dir, 'beh', specific_filename);
            end

            % Load the behavioural data as a table
            beh_log = readtable(beh_file_path);
        
            % Add BIDS required columns
            log_len = size(beh_log, 1);
            beh_log.onset = repmat("n/a", log_len, 1);
            beh_log.duration = repmat("n/a", log_len, 1);

            % Re-order to satisfy BIDS standard
            beh_log = beh_log(:, [end-1:end 1:end-3]);
            
            % Write the behavioural data to destination
            writetable(beh_log, out_file_path, 'filetype', 'text', ...
                'delimiter','\t')
            
            % Make a sidecar .json file
            info = [];
            % Specify task information
            info.TaskName = tasks{runindx};
            trial = [];
            trial.Levels = [];

            % Add more details based on the run
            if runindx == 1
                trial.LongName = 'Lateralised visual attention';
                trial.Description = 'Lateralised visual attention combined with a detection tasks that is congruent or incongruent';
                trial.Levels.congruent = 'Fixation- and detection grating orientations match.';
                trial.Levels.incongruent = 'Fixation- and detection grating orientations do not match.';
            else
                trial.LongName = 'Working memory arithmetic task';
                trial.Description = 'Mental arithmetic constisting of addition of two integers with simultaneous visual stimulation';
                trial.Levels.high = 'Integers are in the range [100;500].';
                trial.Levels.low = 'Integers are in the range [1;9].';
            end
            info.trial = trial;

            % Encode the information as json
            json_txt = jsonencode(info, "PrettyPrint", true);
        
            % Specify the destination
            out_json_file = strcat(out_filename, '.json');
            out_json_path = fullfile(beh_dir, out_json_file);

            % Write the file
            fid = fopen(out_json_path, 'w');
            fprintf(fid, '%s', json_txt);
            fclose(fid);
        end
    
    end
end

function write_files_flag = check_n_prep_overwrite(path, overwrite)
    % FieldTrip does not provide the logic for overwriting
    % in this scenario, so we deal with it here

    % First check for existing raw1 file and whether to overwrite
    if isfile(path) || isfolder(path)
        if overwrite
            if isfolder(path)
                rmdir(path, 's')
            elseif isfile(path)
                delete(path)
            else
                error('This code defies intended logic and should not be reached')
            end
            write_files_flag = true;
        else
            ft_warning(sprintf('Not overwriting file: %s', ...
                path));
            write_files_flag = false;
        end
    else
        write_files_flag = true;
    end
end
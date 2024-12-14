%%
clear; close all;

reestimate = false;

% Load data details
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')
data_details_cfg = get_data_details();
configure_ft


% Define subjects, tasks, and conditions
subjects = data_details_cfg.new_trigger_subs; % Subjects correctly stimulated


data_dir = '/project/3031004.01/data/';
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');
derivatives_img_dir = fullfile(derivatives_dir, 'img');
derivatives_img_dir_sensor = fullfile(derivatives_img_dir, 'sensor-level');

tasks = ["va" "wm"];
stim_conditions = ["con", "isf", "strobe"];

%% Estimate PSDs and planar gradient-trasnformed PSDs
if reestimate
    for task = tasks
        for sub = subjects
            for stim_condition = stim_conditions
                estimate_sensors(sub, task, stim_condition)
            end
        end 
    end
end

%% POWER SPECTRA

% Create a character vector describing the avering procedure
operation_str_avg = '(';
for s = 1:numel(subjects)
    operation_str_avg = [operation_str_avg 'x' num2str(s) '+'];
end
operation_str_avg = [operation_str_avg(1:end-1) ')/' num2str(numel(subjects))];

%%
psds = [];
psds_task1 = [];
psds_task2 = [];

for task = tasks
    psds.(task) = [];
    psds_task1.(task) = [];
    psds_task2.(task) = [];
    psds_dif.(task) = [];

    switch task
        case "va"
            task_levels = ["left", "right"];
        case "wm"
            task_levels = ["low", "high"];
    end
    

    for stim_condition = stim_conditions
        psds_task1.(task).(stim_condition) = [];
        psds_task2.(task).(stim_condition) = [];
        psds.(task).(stim_condition) = [];

        for sub = subjects
            deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
            bids_str = sprintf('sub-%03d_task-%s_stimcondition-%s', sub, task, stim_condition);
        
            psd_file1 = fullfile( ...
                deriv_meg_dir, ...
                sprintf('%s_tasklevel-%s_psd.mat', bids_str, task_levels(1)));
            psds_task1.(task).(stim_condition).(sprintf('sub%d',sub)) = load_and_extract(psd_file1);
        
            psd_file2 = fullfile( ...
                deriv_meg_dir, ...
                sprintf('%s_tasklevel-%s_psd.mat', bids_str, task_levels(2)));
            psds_task2.(task).(stim_condition).(sprintf('sub%d',sub)) = load_and_extract(psd_file2);
            
            psd_file = fullfile(deriv_meg_dir, sprintf('%s_psd.mat', bids_str));
            psds.(task).(stim_condition).(sprintf('sub%d',sub)) = load_and_extract(psd_file);

            cfg = [];
            cfg.parameter = 'powspctrm';
            cfg.operation = '10*log10(x2/x1)';
            psd_dif = ft_math(cfg, ...
                psds_task1.(task).(stim_condition).(sprintf('sub%d',sub)), ...
                psds_task2.(task).(stim_condition).(sprintf('sub%d',sub)));
            psds_dif.(task).(stim_condition).(sprintf('sub%d',sub)) = psd_dif;
        end
    end
end

%%
psd_condif_avg_db_pool = [];
psd_40dif_avg_db_pool = [];
for task = tasks
    psd_task_avg = []; % OBS: before log-transform
    psd_dif_avg_db = [];
    for stim_condition = stim_conditions
        psd_cell = struct2cell(psds.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_avg = ft_math(cfg, psd_cell{:});
        psd_task_avg.(stim_condition) = psd_avg;
        cfg.operation = '10*log10(x1)';
        psd_avg_db = ft_math(cfg, psd_avg);
        
        figure
        plot(psd_avg_db.freq, psd_avg_db.powspctrm)
        % title(sprintf('task-%s stimcondition-%s', task, stim_condition))
        xlabel('Frequency [Hz]')
        ylabel('dB')
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_stim-%s_psd.png', task, stim_condition)))

        switch task
            case "va"
                task_levels = ["left", "right"];
            case "wm"
                task_levels = ["low", "high"];
        end
        
        psd_cell = struct2cell(psds_task1.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_task1_avg = ft_math(cfg, psd_cell{:});
        cfg.operation = '10*log10(x1)';
        psd_task1_avg_db = ft_math(cfg, psd_task1_avg);
        
        figure
        plot(psd_task1_avg_db.freq, psd_task1_avg_db.powspctrm)
        % title(sprintf('task-%s tasklevel-%s stimcondition-%s', task, task_levels(1), stim_condition))
        xlabel('Frequency [Hz]')
        ylabel('dB')
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_tasklevel-%s_stim-%s_psd.png', task, task_levels(1), stim_condition)))

        
        psd_cell = struct2cell(psds_task2.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_task2_avg = ft_math(cfg, psd_cell{:});
        cfg.operation = '10*log10(x1)';
        psd_task2_avg_db = ft_math(cfg, psd_task2_avg);
        
        figure
        plot(psd_task2_avg_db.freq, psd_task2_avg_db.powspctrm)
        % title(sprintf('task-%s tasklevel-%s stimcondition-%s', task, task_levels(2), stim_condition))
        xlabel('Frequency [Hz]')
        ylabel('dB')
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_tasklevel-%s_stim-%s_psd.png', task, task_levels(2), stim_condition)))

        
        psd_cell = struct2cell(psds_dif.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_dif_avg_db.(stim_condition) = ft_math(cfg, psd_cell{:});
        % cfg.operation = '10*log10(x1)';
        % psd_dif_avg_db = ft_math(cfg, psd_dif_avg.(stim_condition));

        figure
        plot(psd_dif_avg_db.(stim_condition).freq, psd_dif_avg_db.(stim_condition).powspctrm)
        % title(sprintf('task-%s contrast-%s-%s stimcondition-%s', task, task_levels(1), task_levels(2), stim_condition))
        xlabel('Frequency [Hz]')
        ylabel('dB')
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_contrast-%s-%s_stim-%s_psd.png', task, task_levels(1), task_levels(2), stim_condition)))

        if not(stim_condition == "con")
            psd_40dif_avg_db_pool = [psd_40dif_avg_db_pool; psd_dif_avg_db.(stim_condition).powspctrm];
        else
            psd_condif_avg_db_pool = [psd_condif_avg_db_pool; psd_dif_avg_db.(stim_condition).powspctrm];
        end
    end

    % Stim contrast
    % Strobe - con
    cfg.operation = '10*log10(x2/x1)';
    psd_task_avg_db = ft_math(cfg, psd_task_avg.con, psd_task_avg.strobe);

    figure
    plot(psd_task_avg_db.freq, psd_task_avg_db.powspctrm)
    % title(sprintf('task-%s contrast-%s-%s stimcondition-%s', task, task_levels(1), task_levels(2), stim_condition))
    xlabel('Frequency [Hz]')
    ylabel('dB')
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_contrast-%s-%s_psd.png', task, ...
        'con', 'strobe')))

    % ISF - con
    cfg.operation = '10*log10(x2/x1)';
    psd_task_avg_db = ft_math(cfg, psd_task_avg.con, psd_task_avg.isf);

    figure
    plot(psd_task_avg_db.freq, psd_task_avg_db.powspctrm)
    % title(sprintf('task-%s contrast-%s-%s stimcondition-%s', task, task_levels(1), task_levels(2), stim_condition))
    xlabel('Frequency [Hz]')
    ylabel('dB')
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_contrast-%s-%s_psd.png', task, ...
        'con', 'isf')))

    % stim-task interaction
    % Strobe/con
    cfg.operation = 'x2-x1';
    psd_interaction_avg_db = ft_math(cfg, psd_dif_avg_db.con, psd_task_avg.strobe);

    figure
    plot(psd_interaction_avg_db.freq, psd_interaction_avg_db.powspctrm)
    % title(sprintf('task-%s contrast-%s-%s stimcondition-%s', task, task_levels(1), task_levels(2), stim_condition))
    xlabel('Frequency [Hz]')
    ylabel('dB')
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_interaction-task-stim_tasklevel-%s-%s_stim_condition-%s-%s_psd.png', task, ...
        task_levels(1), task_levels(2), 'con', 'strobe')))


    % ISF/con
    cfg.operation = 'x2-x1';
    psd_interaction_avg_db = ft_math(cfg, psd_dif_avg_db.con, psd_task_avg.isf);

    figure
    plot(psd_interaction_avg_db.freq, psd_interaction_avg_db.powspctrm)
    % title(sprintf('task-%s contrast-%s-%s stimcondition-%s', task, task_levels(1), task_levels(2), stim_condition))
    xlabel('Frequency [Hz]')
    ylabel('dB')
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_interaction-task-stim_tasklevel-%s-%s_stim_condition-%s-%s_psd.png', task, ...
        task_levels(1), task_levels(2), 'con', 'isf')))
end

%% Plot variance over channels in spectrum
x = psd_interaction_avg_db.freq;
x2 = [x, fliplr(x)];

close all
psd_mean40 = mean(psd_40dif_avg_db_pool);
psd_var40 = var(psd_40dif_avg_db_pool);
psd_std40 = std(psd_40dif_avg_db_pool);
psd_meanCon = mean(psd_condif_avg_db_pool);
psd_varCon = var(psd_condif_avg_db_pool);
psd_stdCon = std(psd_condif_avg_db_pool);

figure
plot(psd_dif_avg_db.(stim_condition).freq,psd_40dif_avg_db_pool)
%hold on

f=figure;
f.Position(3) = f.Position(3)*2;
hold on
plot(psd_dif_avg_db.(stim_condition).freq,psd_40dif_avg_db_pool)
inBetween = [psd_mean40 - 5*psd_var40, fliplr(psd_mean40 + 5*psd_var40)];
fill(x2, inBetween, [.5 .5 .5], 'FaceAlpha', 0.3, 'LineStyle', ':');
plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40, 'Color', 'k', 'LineStyle', '-')
% plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40 + psd_var40*1.001, 'Color', 'k', 'LineStyle', ':')
% plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40 - psd_var40*1.001, 'Color', 'k', 'LineStyle', ':')
title("40 Hz ISF \cup 40 Hz LF")
xlabel("Frequency [Hz]")
ylabel("dB")
exportgraphics(gcf,fullfile(derivatives_img_dir_sensor, '40hz_psd_var.png'),'BackgroundColor','none')
% saveas(gcf,fullfile(derivatives_img_dir_sensor, '40hz_psd_var.png'))
hold off

figure
hold on
% plot(psd_dif_avg_db.(stim_condition).freq,psd_40dif_avg_db_pool)
inBetween = [psd_mean40 - psd_40dif_avg_db_pool, fliplr(psd_mean40 + psd_40dif_avg_db_pool)];
inBetween = [psd_mean40 - 0.00001*psd_40dif_avg_db_pool, fliplr(0.0001*psd_mean40 + psd_40dif_avg_db_pool)];
fill(x2, inBetween, [0.3 0.3 0.3], 'FaceAlpha', 0.05, 'LineStyle', ':');
plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40, 'Color', 'k', 'LineStyle', '-')
% plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40 + psd_var40*1.001, 'Color', 'k', 'LineStyle', ':')
% plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40 - psd_var40*1.001, 'Color', 'k', 'LineStyle', ':')
hold off

figure
plot(psd_dif_avg_db.(stim_condition).freq,psd_meanCon)
%hold on


f=figure;
f.Position(3) = f.Position(3)*2;
hold on
plot(psd_dif_avg_db.(stim_condition).freq,psd_condif_avg_db_pool)
inBetween = [psd_meanCon - 5*psd_varCon, fliplr(psd_meanCon + 5*psd_varCon)];
fill(x2, inBetween, [.5 .5 .5], 'FaceAlpha', 0.3, 'LineStyle', ':');
plot(psd_dif_avg_db.(stim_condition).freq,psd_meanCon, 'Color', 'k', 'LineStyle', '-')
% plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40 + psd_var40*1.001, 'Color', 'k', 'LineStyle', ':')
% plot(psd_dif_avg_db.(stim_condition).freq,psd_mean40 - psd_var40*1.001, 'Color', 'k', 'LineStyle', ':')
title("0 Hz Con")
xlabel("Frequency [Hz]")
ylabel("dB")
exportgraphics(gcf,fullfile(derivatives_img_dir_sensor, 'con_psd_var.png'),'BackgroundColor','none')
% saveas(gcf,)
hold off

% 
% figure
% plot(psd_dif_avg_db.(stim_condition).freq,psd_var)
% 
% figure
% plot(psd_dif_avg_db.(stim_condition).freq,psd_condif_avg_db_pool)
% %hold on
% 
% figure
% plot(psd_dif_avg_db.(stim_condition).freq,psd_varCon)

%%
close all; figure
nbins = 10;
counts = zeros(nbins,3);
for c = 1:3
    [counts(:,c),~] = imhist(psd_40dif_avg_db_pool(c,:),nbins);
end
% plot them using bar3()
xoffset = [0 10 20];
alpha = 0.5;
hb = bar3(counts);
for k = 1:numel(hb)
    hb(k).XData(:) = xoffset(k);
    hb(k).FaceAlpha = alpha;
    hb(k).LineStyle = 'none';
end
xticks(xoffset)
colormap(hsv(numel(hb))) % or pick whatever map you want
% adjust dataaspect to force spacing on x
xscalefactor = 2; % adjust me
yl = ylim; % store for later
hax = gca;
hax.DataAspectRatio(1) = hax.DataAspectRatio(1)/xscalefactor;

%% TOPOGRAPHY

psds_planar = [];
psds_planar_task1 = [];
psds_planar_task2 = [];

for task = tasks
    psds_planar.(task) = [];
    psds_planar_task1.(task) = [];
    psds_planar_task2.(task) = [];
    psds_planar_dif.(task) = [];

    switch task
        case "va"
            task_levels = ["left", "right"];
        case "wm"
            task_levels = ["low", "high"];
    end
    

    for stim_condition = stim_conditions
        psds_planar_task1.(task).(stim_condition) = [];
        psds_planar_task2.(task).(stim_condition) = [];
        psds_planar.(task).(stim_condition) = [];

        for sub = subjects
            deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
            bids_str = sprintf("sub-%03d_task-%s_stimcondition-%s", sub, task, stim_condition);
            
            % Task level 1
            psd_planar_file1 = fullfile( ...
                deriv_meg_dir, ...
                sprintf("%s_tasklevel-%s_psd-planar.mat", bids_str, task_levels(1)));
            % load (psd_planar_file1)
            psds_planar_task1.(task).(stim_condition).(sprintf('sub%d',sub)) = load_and_extract(psd_planar_file1);
        
            % Task level 2
            psd_planar_file2 = fullfile( ...
                deriv_meg_dir, ...
                sprintf("%s_tasklevel-%s_psd-planar.mat", bids_str, task_levels(2)));
            % load (psd_planar_file2)
            psds_planar_task2.(task).(stim_condition).(sprintf('sub%d',sub)) = load_and_extract(psd_planar_file2);
            
            % Both tasks
            psd_planar_file = fullfile(deriv_meg_dir, sprintf('%s_psd-planar.mat', bids_str));
            % load (psd_planar_file)
            psds_planar.(task).(stim_condition).(sprintf('sub%d',sub)) = load_and_extract(psd_planar_file);

            cfg = [];
            cfg.parameter = 'powspctrm';
            cfg.operation = '10*log10(x2/x1)';
            psd_dif = ft_math(cfg, ...
                psds_planar_task1.(task).(stim_condition).(sprintf('sub%d',sub)), ...
                psds_planar_task2.(task).(stim_condition).(sprintf('sub%d',sub)));
            psds_planar_dif.(task).(stim_condition).(sprintf('sub%d',sub)) = psd_dif;
        end
    end
end

%%
close all
% Plot topography for each level and for contrast
topo_cfg = [];
topo_cfg.xlim         = [40 40];
topo_cfg.marker       = 'on';
topo_cfg.colorbar     = 'yes';
topo_cfg.layout       = 'CTF151_helmet.mat';
topo_cfg.colormap     = '*RdBu';
% topo_cfg.zlim         = 'maxabs';


for task = tasks
    psd_planar_task_avg = []; % OBS: before log-transform
    psd_planar_dif_avg_dB = [];
    for stim_condition = stim_conditions
        psd_cell = struct2cell(psds_planar.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_planar_avg = ft_math(cfg, psd_cell{:});
        psd_planar_task_avg.(stim_condition) = psd_planar_avg;
        cfg.operation = '10*log10(x1)';
        psd_planar_avg_db = ft_math(cfg, psd_planar_avg);
        
        figure;
        cfg = topo_cfg;
        ft_topoplotER(cfg, psd_planar_avg_db);
        % title(sprintf('task-%s stimcondition-%s', task, stim_condition))
        hc=colorbar;
        title(hc,'dB');
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_stim-%s_topo.png', task, stim_condition)))

        switch task
            case "va"
                task_levels = ["left", "right"];
            case "wm"
                task_levels = ["low", "high"];
        end
        
        psd_cell = struct2cell(psds_planar_task1.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_planar_task1_avg = ft_math(cfg, psd_cell{:});
        cfg.operation = '10*log10(x1)';
        psd_planar_task1_avg_db = ft_math(cfg, psd_planar_task1_avg);
        
        figure;
        cfg = topo_cfg;
        ft_topoplotER(cfg, psd_planar_task1_avg_db);
        % title(sprintf('task-%s tasklevel-%s stimcondition-%s', task, task_levels(1), stim_condition))
        % xlabel('Frequency [Hz]')
        hc=colorbar;
        title(hc,'dB');
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_tasklevel-%s_stim-%s_topo.png', task, task_levels(1), stim_condition)))

        
        psd_cell = struct2cell(psds_planar_task2.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_planar_task2_avg = ft_math(cfg, psd_cell{:});
        cfg.operation = '10*log10(x1)';
        psd_planar_task2_avg_db = ft_math(cfg, psd_planar_task2_avg);
        
        figure
        cfg = topo_cfg;
        ft_topoplotER(cfg, psd_planar_task2_avg_db);
        % title(sprintf('task-%s tasklevel-%s stimcondition-%s', task, task_levels(2), stim_condition))
        hc=colorbar;
        title(hc,'dB');
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_tasklevel-%s_stim-%s_topo.png', task, task_levels(2), stim_condition)))

        
        psd_cell = struct2cell(psds_planar_dif.(task).(stim_condition));
        cfg = [];
        cfg.parameter = 'powspctrm';
        cfg.operation = operation_str_avg;
        psd_planar_dif_avg_dB.(stim_condition) = ft_math(cfg, psd_cell{:});
        % cfg.operation = '10*log10(x1)';
        % psd_planar_dif_avg_db = ft_math(cfg, psd_planar_dif_avg.(stim_condition));

        figure
        cfg = topo_cfg;
        cfg.zlim = 'maxabs';
        ft_topoplotER(cfg, psd_planar_dif_avg_dB.(stim_condition))
        hc=colorbar;
        title(hc,'dB');
        saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
            sprintf('task-%s_contrast-%s-%s_stim-%s_topo.png', task, task_levels(1), task_levels(2), stim_condition)))
    end

    % Stim contrast
    % Strobe - con
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = '10*log10(x2/x1)';
    psd_planar_task_avg_db = ft_math(cfg, psd_planar_task_avg.con, psd_planar_task_avg.strobe);

    figure
    cfg = topo_cfg;
    cfg.zlim = 'maxabs';
    ft_topoplotER(cfg, psd_planar_task_avg_db)
    hc=colorbar;
    title(hc,'dB');
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_contrast-%s-%s_topo.png', task, ...
        'con', 'strobe')))

    % ISF - con
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = '10*log10(x2/x1)';
    psd_planar_task_avg_db = ft_math(cfg, psd_planar_task_avg.con, psd_planar_task_avg.isf);

    figure
    cfg = topo_cfg;
    cfg.zlim = 'maxabs';
    ft_topoplotER(cfg, psd_planar_task_avg_db)
    hc=colorbar;
    title(hc,'dB');
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_contrast-%s-%s_topo.png', task, ...
        'con', 'isf')))

    % stim-task interaction
    % Strobe - con
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = 'x2-x1';
    psd_planar_interaction_avg_db = ft_math(cfg, psd_planar_dif_avg_dB.con, psd_planar_task_avg.strobe);

    figure
    cfg = topo_cfg;
    cfg.zlim = 'maxabs';
    ft_topoplotER(cfg, psd_planar_interaction_avg_db)
    hc=colorbar;
    title(hc,'dB');
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_interaction-task-stim_tasklevel-%s-%s_stim_condition-%s-%s_topo.png', task, ...
        task_levels(1), task_levels(2), 'con', 'strobe')))

    % ISF - con
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = 'x2-x1';
    psd_planar_interaction_avg_db = ft_math(cfg, psd_planar_dif_avg_dB.con, psd_planar_task_avg.isf);

    figure
    cfg = topo_cfg;
    cfg.zlim = 'maxabs';
    ft_topoplotER(cfg, psd_planar_interaction_avg_db)
    hc=colorbar;
    title(hc,'dB');
    saveas(gcf,fullfile(derivatives_img_dir_sensor, ...
        sprintf('task-%s_interaction-task-stim_tasklevel-%s-%s_stim_condition-%s-%s_topo.png', task, ...
        task_levels(1), task_levels(2), 'con', 'isf')))
end

%%
function psd = load_and_extract(filepath)
    psd_ = load (filepath);
    var_name_cell = fields(psd_);
    assert (numel(var_name_cell) == 1)
    psd = psd_.(var_name_cell{1});
end
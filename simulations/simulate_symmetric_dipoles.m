%% SETUP
clear;close all;
% Set up Fieldtrip
addpath('/project/3031004.01/meg-ahat/util')
configure_ft

poses = {[-4 -4 4], [4 -4 4]};%, [-4 -4 4; 4 -4 4]};
moms = {[1 0 .5]', [-1 0 .5]'};%, [[1 0 1]', [-1 0 1]']};
sources_pcc = {};
sources_lcmv = {};
sources_dics = {};
sources = {"left", "right"};

for p = 1:numel(poses)
    
    
    % create an array with some magnetometers at 12cm distance from the origin
    [X, Y, Z] = sphere(10);
    pos = unique([X(:) Y(:) Z(:)], 'rows');
    pos = pos(pos(:,3)>=0,:);
    grad = [];
    grad.coilpos = 12*pos;
    grad.coilori = pos; % in the outward direction
    % grad.tra = eye(length(pos)); % each coils contributes exactly to one channel
    for i=1:length(pos)
      grad.label{i} = sprintf('chan%03d', i);
    end
    
    % create a spherical volume conductor with 10cm radius
    vol.r = 10;
    vol.o = [0 0 0];
    
    % Dipole simulation
    cfg = [];
    cfg.headmodel = vol;
    cfg.grad = grad;
    cfg.sourcemodel.pos = poses{p};
    cfg.sourcemodel.mom =   moms{p};% the dipole 
    cfg.sourcemodel.frequency = 40;
    cfg.relnoise = 2;
    cfg.ntrials = 10;
    data = ft_dipolesimulation(cfg);
    
    % compute the data covariance matrix, which will capture the activity of
    % the simulated dipole - used by the lcmv
    cfg = [];
    cfg.covariance = 'yes';
    timelock = ft_timelockanalysis(cfg, data);

    % Calculate periodogram - used by pcc and dics
    cfg              = [];
    cfg.output       = 'powandcsd';
    cfg.method       = 'mtmfft';
    cfg.taper        = 'boxcar';
    cfg.foilim       = [40 40];
    periodogram        = ft_freqanalysis(cfg, data);
    

    % Do source estimation with pcc, dics, and lcmv
    cfg                   = []; 
    cfg.frequency         = 40;  
    cfg.pcc.fixedori     = 'no';
    cfg.pcc.projectnoise = 'yes';
    cfg.pcc.lambda       = '5%';
    cfg.pcc.realfilter   = 'yes';
    cfg.pcc.keepcsd      = 'yes';
    cfg.headmodel = vol;
    cfg.grad = grad;
    cfg.resolution = 1;
    cfg.method = 'pcc';
    source_pcc = ft_sourceanalysis(cfg, periodogram);


    cfg                   = []; 
    cfg.method            = 'dics';
    cfg.frequency         = 40;  
    cfg.dics.fixedori     = 'no';
    cfg.dics.projectnoise = 'yes';
    cfg.dics.lambda       = '5%';
    cfg.dics.realfilter   = 'yes';
    cfg.dics.keepcsd      = 'yes';
    cfg.headmodel = vol;
    cfg.grad = grad;
    cfg.resolution = 1;
    source_dics = ft_sourceanalysis(cfg, periodogram);

    cfg = [];
    cfg.headmodel = vol;
    cfg.grad = grad;
    cfg.resolution = 1;
    cfg.method = 'lcmv';
    cfg.lcmv.projectnoise = 'yes'; % needed for neural activity index
    source_lcmv = ft_sourceanalysis(cfg, timelock);

    
    cfg = [];
    cfg.keepcsd = 'no';
    cfg.powmethod = 'lambda1';
    sources_pcc{p} = ft_sourcedescriptives(cfg, source_pcc);

    cfg = [];
    cfg.keepcsd = 'no';
    cfg.powmethod = 'lambda1';
    sources_dics{p} = ft_sourcedescriptives(cfg, source_dics);


    cfg = [];
    cfg.powmethod = 'none'; % keep the power as estimated from the data covariance, i.e. the induced power
    sources_lcmv{p} = ft_sourcedescriptives(cfg, source_lcmv);
    
    %
    cfg = [];
    cfg.method = 'slice';
    cfg.funparameter = 'pow';
    figure;
    ft_sourceplot(cfg, sources_pcc{p});
    title(sprintf('PCC estimate of %s source', sources{p}))

    figure;
    ft_sourceplot(cfg, sources_dics{p});
    title(sprintf('DICS estimate of %s source', sources{p}))

    cfg.funparameter = 'nai';
    cfg.funcolorlim = [1.4 1.5];
    figure;
    ft_sourceplot(cfg, sources_lcmv{p});
    title(sprintf('LCMV estimate of %s source', sources{p}))
    

end

%%

cfg           = [];
cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
cfg.parameter = 'pow';

source_contrast_pcc   = ft_math(cfg,sources_pcc{1},sources_pcc{2});
source_contrast_dics   = ft_math(cfg,sources_dics{1},sources_dics{2});
source_contrast_lcmv   = ft_math(cfg,sources_lcmv{1},sources_lcmv{2});


%

%
cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
% cfg.funcolorlim = [1.4 1.5];  % the voxel in the center of the volume conductor messes up the autoscaling
figure;
ft_sourceplot(cfg, source_contrast_pcc);
title(sprintf('PCC estimate, lateral source contrast', sources{p}))
figure;
ft_sourceplot(cfg, source_contrast_dics);
title(sprintf('DICS estimate, lateral source contrast', sources{p}))
figure;
ft_sourceplot(cfg, source_contrast_lcmv);
title(sprintf('LCMV estimate, lateral source contrast', sources{p}))
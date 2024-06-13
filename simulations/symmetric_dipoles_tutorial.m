%% SETUP
% Update to match your fieldtrip configuration
clear;%close all;
% Set up Fieldtrip
addpath('/project/3031004.01/meg-ahat/util')
configure_ft

% Set an output path for figures
img_dir = fullfile('/home/megmethods/markhen', 'symmetry_example');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation of correlated and un-correlated symmetric dipole pairs %%

% Define two dipole positions and two directions of moment
dippos = [-4 -4 4; 4 -4 4];
dipmom = [1 0 .5; -1 0 .5]';

% Create an array with some magnetometers at 12cm distance from the origin
[X, Y, Z] = sphere(10);
pos = unique([X(:) Y(:) Z(:)], 'rows');
pos = pos(pos(:,3)>=0,:);
grad = [];
grad.coilpos = 12*pos;
grad.coilori = pos; % in the outward direction
for i=1:length(pos)
grad.label{i} = sprintf('chan%03d', i);
end

% Create a spherical volume conductor with 10cm radius
vol.r = 10;
vol.o = [0 0 0];

% Define a non-symmetric 'normal' source model
cfg = [];
cfg.headmodel = vol; % use the spherical volume conducter as head model
cfg.grad = grad;
% Source models are defined with x-axis normal to the midline.
cfg.xgrid = -9.5:9.5; % ensure that the midline is not included
cfg.ygrid = -10:10;
cfg.zgrid = 0:10;
sourcemodel_normal = ft_prepare_leadfield(cfg);

% Plot the grid of the source model
figure
ft_plot_mesh(sourcemodel_normal.pos(sourcemodel_normal.inside,:))
ft_plot_sens(grad)

saveas(gcf,fullfile(img_dir, 'sourcemodel_normal.png'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Un-correlated symmetric sources with non-symmetric source model %%

% Dipole simulation
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.fsample = 1000;
cfg.relnoise = 2;
cfg.sourcemodel.pos = dippos(:,:);
cfg.sourcemodel.mom = dipmom(:,:);
% create some left-right amplitude imbalance, emulating lateral attention modulation
cfg.sourcemodel.signal = repmat({[1.1*sin(40*2*pi*(0:999)/1000); 0.9*cos(40*2*pi*(0:999)/1000)]}, 1, 10);
dataLR_attL = ft_dipolesimulation(cfg);
cfg.sourcemodel.signal = repmat({[0.9*sin(40*2*pi*(0:999)/1000); 1.1*cos(40*2*pi*(0:999)/1000)]}, 1, 10);
dataLR_attR = ft_dipolesimulation(cfg);

% Compute the data covariance matrix, which will capture the activity 
% of each simulated dipole and is needed for the beamformer source estimation
cfg = [];
cfg.covariance = 'yes';
timelockLR_attL  = ft_timelockanalysis(cfg, dataLR_attL);
timelockLR_attR  = ft_timelockanalysis(cfg, dataLR_attR);

% Apply the beamformer based on the non-symmetric 'normal' source model
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.sourcemodel = sourcemodel_normal;
cfg.method = 'lcmv';
singleLR_attL = ft_sourceanalysis(cfg, timelockLR_attL);
singleLR_attR = ft_sourceanalysis(cfg, timelockLR_attR);

% calculate the lateral contrast
cfg           = [];
cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
cfg.parameter = 'pow';
contrastLR_attL_attR = ft_math(cfg, singleLR_attL, singleLR_attR);

% plot the result
cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
figure; ft_sourceplot(cfg, contrastLR_attL_attR);

saveas(gcf,fullfile(img_dir, 'contrastLR_attL_attR_nonsym_uncor.png'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correlated symmetric sources with non-symmetric source model %%

% Dipole simulation
% Make the oscillations of the two symmetric dipoles correlated by 
% changing the right dipole signals from cosines to sines
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.fsample = 1000;
cfg.relnoise = 2;
cfg.sourcemodel.pos = dippos(:,:);
cfg.sourcemodel.mom = dipmom(:,:);
% create some left-right amplitude imbalance, emulating lateral attention modulation.
% OBS: Notice the right dipole signal is now also defined by a sine
cfg.sourcemodel.signal = repmat({[1.1*sin(40*2*pi*(0:999)/1000); 0.9*sin(40*2*pi*(0:999)/1000)]}, 1, 10);
dataLR_attL = ft_dipolesimulation(cfg);
cfg.sourcemodel.signal = repmat({[0.9*sin(40*2*pi*(0:999)/1000); 1.1*sin(40*2*pi*(0:999)/1000)]}, 1, 10);
dataLR_attR = ft_dipolesimulation(cfg);

% Compute the covariance and apply the beamformer still with the non-symetric source model
cfg = [];
cfg.covariance = 'yes';
timelockLR_attL  = ft_timelockanalysis(cfg, dataLR_attL);
timelockLR_attR  = ft_timelockanalysis(cfg, dataLR_attR);

cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.sourcemodel = sourcemodel_normal;
cfg.method = 'lcmv';
singleLR_attL = ft_sourceanalysis(cfg, timelockLR_attL);
singleLR_attR = ft_sourceanalysis(cfg, timelockLR_attR);

% Compute contrast and plot
cfg           = [];
cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
cfg.parameter = 'pow';
contrastLR_attL_attR = ft_math(cfg, singleLR_attL, singleLR_attR);

cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
figure; ft_sourceplot(cfg, contrastLR_attL_attR);

saveas(gcf,fullfile(img_dir, 'contrastLR_attL_attR_nonsym_cor.png'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correlated symmetric sources with symmetric source model %%

% To deal with the correlation between the symmetric dipoles, 
% the source model is re-defined with a symmetry constraint 
% across the midline (in this case the x-axis)
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.xgrid = -9.5:0; % Only define one hemisphere
cfg.ygrid = -10:10;
cfg.zgrid = 0:10;
cfg.symmetry = 'x'; % Axis of symmetry - OBS: This is dependent on scanner coordinate system
sourcemodel_double = ft_prepare_leadfield(cfg);

% In the symmetric sourcemodel, the `.pos` field is a `N/2x6` matrix 
% (where `N` is the number of vertices in the grid), rather than the 
% usual `Nx3`, where the xyz-coordinates of the vertices are given 
% in pairs of triplets.
head(sourcemodel_double.pos)

%% Plot the symmetrically defined grid, colour coding each hemisphere
figure
ft_plot_mesh(sourcemodel_double.pos(sourcemodel_double.inside,1:3), 'vertexcolor', 'r')
ft_plot_mesh(sourcemodel_double.pos(sourcemodel_double.inside,4:6), 'vertexcolor', 'b')
ft_plot_sens(grad)
saveas(gcf,fullfile(img_dir, 'sourcemodel_double.png'))

% Re-do the beamformer estimation with the symmetric source model,
% and compute the contrast between the conditions again
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.sourcemodel = sourcemodel_double;
cfg.method = 'lcmv';
cfg.lcmv.keepcov = 'yes';
doubleLR_attL = ft_sourceanalysis(cfg, timelockLR_attL);
doubleLR_attR = ft_sourceanalysis(cfg, timelockLR_attR);

% construct the single-dipole model from the (symmetric) double-dipole model

n = size(sourcemodel_double.pos,1);
lh2full = nan(n,1);
rh2full = nan(n,1);

% determine the mapping between the left and right hemisphere to the full model
for i=1:n
  pos_lh = sourcemodel_double.pos(i,1:3);
  pos_rh = sourcemodel_double.pos(i,4:6);
  lh2full(i) = find(sourcemodel_normal.pos(:,1)==pos_lh(1) & sourcemodel_normal.pos(:,2)==pos_lh(2) & sourcemodel_normal.pos(:,3)==pos_lh(3));
  rh2full(i) = find(sourcemodel_normal.pos(:,1)==pos_rh(1) & sourcemodel_normal.pos(:,2)==pos_rh(2) & sourcemodel_normal.pos(:,3)==pos_rh(3));
end

% this mainly serves as a sanity check
sourcemodel_single = [];
sourcemodel_single.pos(lh2full, 1) = sourcemodel_double.pos(:,1);
sourcemodel_single.pos(lh2full, 2) = sourcemodel_double.pos(:,2);
sourcemodel_single.pos(lh2full, 3) = sourcemodel_double.pos(:,3);
sourcemodel_single.pos(rh2full, 1) = sourcemodel_double.pos(:,4);
sourcemodel_single.pos(rh2full, 2) = sourcemodel_double.pos(:,5);
sourcemodel_single.pos(rh2full, 3) = sourcemodel_double.pos(:,6);

% these should now be equal
assert(isequal(sourcemodel_single.pos, sourcemodel_normal.pos));

sourcemodel_single.dim = sourcemodel_normal.dim;
sourcemodel_single.unit = sourcemodel_normal.unit;
sourcemodel_single.inside = sourcemodel_normal.inside;

% convert the (symmetric) double-dipole estimates into a single-dipole representation
singleLR_attL = sourcemodel_single;
singleLR_attL.pow = nan(prod(sourcemodel_normal.dim),1);
singleLR_attR = sourcemodel_single;
singleLR_attR.pow = nan(prod(sourcemodel_normal.dim),1);

% Extract the covariance from each hemisphere and calculate
% the power using the first singular value (aka lambda1)
for i=find(doubleLR_attL.inside(:)')
  covL = doubleLR_attL.avg.cov{i}(1:3,1:3); % Left hemisphere covariance
  covR = doubleLR_attL.avg.cov{i}(4:6,4:6); % Right hemisphere covariance
  powL = svd(covL); powL = powL(1); % Estimate power by 1st singular value
  powR = svd(covR); powR = powR(1);
  singleLR_attL.pow(lh2full(i)) = powL;
  singleLR_attL.pow(rh2full(i)) = powR;

  covL = doubleLR_attR.avg.cov{i}(1:3,1:3);
  covR = doubleLR_attR.avg.cov{i}(4:6,4:6);
  powL = svd(covL); powL = powL(1);
  powR = svd(covR); powR = powR(1);
  singleLR_attR.pow(lh2full(i)) = powL;
  singleLR_attR.pow(rh2full(i)) = powR;
end

% Compute the contrast between the conditions as before and plot the results
cfg           = [];
cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
cfg.parameter = 'pow';
contrastLR_attL_attR = ft_math(cfg, singleLR_attL, singleLR_attR);

cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
figure; ft_sourceplot(cfg, contrastLR_attL_attR);
saveas(gcf,fullfile(img_dir, 'contrastLR_attL_attR_sym_cor.png'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Un-correlated symmetric sources with symmetric source model %%

% Dipole simulation
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.fsample = 1000;
cfg.relnoise = 2;
cfg.sourcemodel.pos = dippos(:,:);
cfg.sourcemodel.mom = dipmom(:,:);
% create some left-right amplitude imbalance, emulating lateral attention modulation.
% OBS: Notice the right dipole signal is now also defined by a sine
cfg.sourcemodel.signal = repmat({[1.1*sin(40*2*pi*(0:999)/1000); 0.9*cos(40*2*pi*(0:999)/1000)]}, 1, 10);
dataLR_attL = ft_dipolesimulation(cfg);
cfg.sourcemodel.signal = repmat({[0.9*sin(40*2*pi*(0:999)/1000); 1.1*cos(40*2*pi*(0:999)/1000)]}, 1, 10);
dataLR_attR = ft_dipolesimulation(cfg);

% Compute covariance
cfg = [];
cfg.covariance = 'yes';
timelockLR_attL  = ft_timelockanalysis(cfg, dataLR_attL);
timelockLR_attR  = ft_timelockanalysis(cfg, dataLR_attR);

% Do symmetric source estimation
cfg = [];
cfg.headmodel = vol;
cfg.grad = grad;
cfg.sourcemodel = sourcemodel_double;
cfg.method = 'lcmv';
singleLR_attL = ft_sourceanalysis(cfg, timelockLR_attL);
singleLR_attR = ft_sourceanalysis(cfg, timelockLR_attR);

% convert the (symmetric) double-dipole estimates into a single-dipole representation
singleLR_attL = sourcemodel_single;
singleLR_attL.pow = nan(prod(sourcemodel_normal.dim),1);
singleLR_attR = sourcemodel_single;
singleLR_attR.pow = nan(prod(sourcemodel_normal.dim),1);

% Extract the covariance from each hemisphere and calculate the power using the first singular value:
for i=find(doubleLR_attL.inside(:)')
    covL = doubleLR_attL.avg.cov{i}(1:3,1:3); % Left hemisphere covariance
    covR = doubleLR_attL.avg.cov{i}(4:6,4:6); % Right hemisphere covariance
    powL = svd(covL); powL = powL(1); % Estimate power by 1st singular value
    powR = svd(covR); powR = powR(1);
    singleLR_attL.pow(lh2full(i)) = powL;
    singleLR_attL.pow(rh2full(i)) = powR;

    covL = doubleLR_attR.avg.cov{i}(1:3,1:3);
    covR = doubleLR_attR.avg.cov{i}(4:6,4:6);
    powL = svd(covL); powL = powL(1);
    powR = svd(covR); powR = powR(1);
    singleLR_attR.pow(lh2full(i)) = powL;
    singleLR_attR.pow(rh2full(i)) = powR;
end

% Compute the contrast between the conditions as before and plot the results
cfg           = [];
cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
cfg.parameter = 'pow';
contrastLR_attL_attR = ft_math(cfg, singleLR_attL, singleLR_attR);

cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
figure; ft_sourceplot(cfg, contrastLR_attL_attR);
saveas(gcf,fullfile(img_dir, 'contrastLR_attL_attR_sym_uncor.png'))

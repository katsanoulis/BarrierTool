%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%              ____________________   ___           %%%%%%%%%%%%%
%%%%%%%%%%%             /  ________   ___   /__/  /           %%%%%%%%%%%%%
%%%%%%%%%%%            /  _____/  /  /  /  ___   /            %%%%%%%%%%%%%
%%%%%%%%%%%           /_______/  /__/  /__/  /__/             %%%%%%%%%%%%%
%%%%%%%%%%%    Swiss Federal Institute of Technology Zurich   %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Author: Stergios Katsanoulis  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Email:  katsanos@ethz.ch      %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Date:   07/10/2019            %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add path
%rootdir = fileparts(pwd)
p{1} = fullfile('Advection');
p{2} = fullfile('Data');
p{3} = fullfile(genpath('Extraction Algorithm'));
p{4} = fullfile('qField Computation');

for i = 1:4
    addpath(rootdir,p{i});
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Advection of particles
%% Parameters for advection of particles
diffusion = 'true';          % This must be false ONLY for black-hole vortices.
NCores = 1;                  % Parallel advection is not implemented in this version. Check GUI version for that.
tstep = 0.2;                 % Time step of the DNS data for linear interpolation in time.
methodInterp = 'spline';     % Interpolation method in space for every time snapshot.
tspan = [0:49 49.8];         % Integration time.
numX = 100;                 % Number of grid points in the x-direction.
numY = 100;                 % Number of grid points in the y-direction.

%% Grid definition
xspan = linspace(0,2*pi,numX);
yspan = linspace(0,2*pi,numY);

rhox = (xspan(2) - xspan(1))*0.1;
rhoy = rhox;

[xgrid,ygrid] = ndgrid(xspan,yspan);

%% Advection
xt = zeros(numX,numY,5);
yt = zeros(numX,numY,5);
for k=1:4
    xt(:,:,k) = xgrid + rhox*cos( (k-1)*pi/2 );
    yt(:,:,k) = ygrid + rhoy*sin( (k-1)*pi/2 );
end

xt(:,:,5) = xgrid;
yt(:,:,5) = ygrid;

options = odeset('RelTol',1e-6,'AbsTol',1e-6);

tic
[xt,yt] = Integrator(xt(:,:,:),yt(:,:,:),tspan,NCores,options,diffusion,tstep,methodInterp);

disp('Integration is over.')
toc

xt = reshape(xt, length(tspan), numX, numY, 5);
yt = reshape(yt, length(tspan), numX, numY, 5);

%% Save advected particles
filename = fullfile('Advection','advectedParticles.mat');
save(filename,'xt','yt','-v7.3')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Computation of q field
[qx,qy] = qField(xt,yt,xspan,yspan,tspan,tstep,methodInterp,rhox,rhoy,numX,numY);
disp('Computation of q-field is over.')

x1_g = xspan;
x2_g = yspan;

%% Save qField
filename = fullfile('qField Computation','qField.mat');
save(filename,'x1_g','x2_g','qx','qy','rhox','rhoy')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Extraction of diffusive vortex boundaries
%% Parameters
l_v = 1.0;                   % Smaller \Tau_0 value
g_v = 6.0;                   % Larger  \Tau_0 value
tau = 12;                    % Number of \Tau_0 values to check
lamV = linspace(l_v,g_v,tau);
dist = 0.005;                 % Upper bound for distance between initial and final point of the extracted curve
err = 0.2;                   % Error tolerance for fixed step-size solver - Invariance
sVec = 0:0.01:12;            % Arclength parameterization of r(s)
NCores = 6;                  % Number of CPU cores used for solving the reduced flow
%% Computation of derivatives of q field and DBS field
[phiPrGr,qx,qy,DBS] = qFieldDerivativesAndDBS(x1_g,x2_g,qx,qy,rhox,rhoy);

%% Extraction of diffusive vortex boundaries
[x0lam,y0lam,phi0lam]=r0_lam(lamV,qx,qy,x1_g,x2_g);

[x1Psol,x2Psol] = FindClosedNullGeod(phiPrGr,x0lam,y0lam,phi0lam,x1_g,x2_g,lamV,sVec,NCores,dist,err);

%% Save diffusive vortex boundaries
filename = fullfile('Extraction Algorithm','Output','Structures.mat');
save(filename,'x1Psol','x2Psol','x1_g','x2_g','lamV','DBS','sVec')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Plots
%% Plot families of diffusive vortex boundaries
PlotAllClosedNullGeodesics(x1Psol,x2Psol,x1_g,x2_g,lamV,DBS)

%% Find and plot diffusive vortex boundaries
[x1LcOutM,x2LcOutM,LamLcOutM] = FindOutermost(x1Psol,x2Psol,lamV,sVec);

PlotOutmost(x1LcOutM,x2LcOutM,LamLcOutM,lamV,x1_g,x2_g,DBS)

%% Advect diffusive vortex boundaries along with passive tracers color-coded with their DBS values
%% Parameters
tspan = 0:49;                % Integration time.
m = 10;                      % Number of passive tracers in the x-direction.
n = 10;                      % Number of passive tracers in the y-direction.

AdvectParticlesAndLCSs(x1LcOutM,x2LcOutM,DBS,x1_g,x2_g,methodInterp,tstep,tspan,m,n);

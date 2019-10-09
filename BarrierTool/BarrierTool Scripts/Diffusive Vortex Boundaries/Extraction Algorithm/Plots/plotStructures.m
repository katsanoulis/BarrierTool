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
%% Read extracted diffusive vortex boundaries
filename = '../Output/Structures.mat';
load(filename)
%% Plot families of diffusive vortex boundaries
PlotAllClosedNullGeodesics(x1Psol,x2Psol,x1_g,x2_g,lamV,DBS)

%% Find and plot diffusive vortex boundaries
[x1LcOutM,x2LcOutM,LamLcOutM] = FindOutermost(x1Psol,x2Psol,lamV,sVec);

PlotOutmost(x1LcOutM,x2LcOutM,LamLcOutM,lamV,x1_g,x2_g,DBS)

%% Advect diffusive vortex boundaries along with passive tracers color-coded with their DBS values
% Parameters
methodInterp = 'spline';     % Interpolation method in space for every time snapshot.
tstep = 0.2;                 % Time step of the DNS data for linear interpolation in time.
tspan = 0:49;                % Integration time.
m = 10;                      % Number of passive tracers in the x-direction.
n = 10;                      % Number of passive tracers in the y-direction.

AdvectParticlesAndLCSs(x1LcOutM,x2LcOutM,DBS,x1_g,x2_g,methodInterp,tstep,tspan,m,n);
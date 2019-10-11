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
%% Parameters
l_v = 2.0;                   % Smaller \Tau_0 value
g_v = 6.0;                   % Larger  \Tau_0 value
tau = 18;                    % Number of \Tau_0 values to check
lamV = linspace(l_v,g_v,tau);
dist = 0.01;                 % Upper bound for distance between initial and final point of the extracted curve
err = 0.1;                   % Error tolerance for fixed step-size solver - Invariance
sVec = 0:0.01:12;            % Arclength parameterization of r(s)
NCores = 6;                  % Number of CPU cores used for solving the reduced flow

%% Load q field
filename = '../qField Computation/qField.mat';
load(filename)

%% Computation of derivatives of q field and DBS field
[phiPrGr,qx,qy,DBS] = qFieldDerivativesAndDBS(x1_g,x2_g,qx,qy,rhox,rhoy);

%% Extraction of diffusive vortex boundaries
[x0lam,y0lam,phi0lam]=r0_lam(lamV,qx,qy,x1_g,x2_g);

[x1Psol,x2Psol] = FindClosedNullGeod(phiPrGr,x0lam,y0lam,phi0lam,x1_g,x2_g,lamV,sVec,NCores,dist,err);

filename = fullfile('Output','Structures.mat');
save(filename,'x1Psol','x2Psol','x1_g','x2_g','lamV','DBS','sVec')
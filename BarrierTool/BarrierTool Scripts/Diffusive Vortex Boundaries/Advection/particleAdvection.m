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
diffusion = 'true';          % This must be false ONLY for black-hole vortices.
NCores = 1;                  % Parallel advection is not implemented in this version. Check GUI version for that.
tstep = 0.2;                 % Time step of the DNS data for linear interpolation in time.
methodInterp = 'spline';     % Interpolation method in space for every time snapshot.
tspan = [0:49 49.8];         % Integration time.
numX = 1000;                 % Number of grid points in the x-direction.
numY = 1000;                 % Number of grid points in the y-direction.

%% Grid definition
xspan = linspace(0,2*pi,numX);
yspan = linspace(0,2*pi,numY);

rhox = (xspan(2) - xspan(1))*0.1;
rhoy = rhox;

[xgrid,ygrid] = ndgrid(xspan,yspan);
[m,n] = size(xgrid);

%% Advection of particles
xt = zeros(m,n,5);
yt = zeros(m,n,5);
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

xt = reshape(xt, length(tspan), m, n, 5);
yt = reshape(yt, length(tspan), m, n, 5);

filename = 'advectedParticles.mat';
save(filename,'xt','yt','-v7.3')
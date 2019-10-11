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
tstep = 0.2;                 % Time step of the DNS data for linear interpolation in time.
methodInterp = 'spline';     % Interpolation method in space for every time snapshot.
tspan = [0:49 49.8];         % Integration time.
numX = 1000;                  % Number of grid points in the x-direction.
numY = 1000;                  % Number of grid points in the y-direction.

%% Load advected particles
filename = '../Advection/advectedParticles.mat';
load(filename,'xt','yt')

%% Grid definition
xspan = linspace(0,2*pi,numX);
yspan = linspace(0,2*pi,numY);

rhox = (xspan(2) - xspan(1))*0.1;
rhoy = rhox;

xPlusEpsilon_grid  = xspan + rhox;
xMinusEpsilon_grid = xspan - rhox;
yPlusEpsilon_grid  = yspan + rhoy;
yMinusEpsilon_grid = yspan - rhoy;
[xPe,y0] = ndgrid(xPlusEpsilon_grid,yspan);
[xMe,~]  = ndgrid(xMinusEpsilon_grid,yspan);
[x0,yPe] = ndgrid(xspan,yPlusEpsilon_grid);
[~,yMe]  = ndgrid(xspan,yMinusEpsilon_grid);
[m,n] = size(x0);

%% Computation of q-field
deltat = tspan(end) - tspan(1);
dt = (deltat)/(length(tspan) - 1);

qx = zeros(m,n);
qy = zeros(m,n);

F11 = ones(m,n)/2;
F12 = zeros(m,n);
F21 = zeros(m,n);
F22 = ones(m,n)/2;

str1 = '../Data/turb_w_';
str2 = pad(int2str(0),4,'left','0');
str = strcat(str1,str2);
load(str);

w = [w w(:,1)];
w = [w; w(1,:)]';

% Vorticity gradient
omega_interp = griddedInterpolant({linspace(0,2*pi,1025),linspace(0,2*pi,1025)},w,methodInterp,'none');
gox = ((omega_interp(wrapTo2Pi(xPe),wrapTo2Pi(y0))-omega_interp(wrapTo2Pi(xMe),wrapTo2Pi(y0)))/(2*rhox));
goy = ((omega_interp(wrapTo2Pi(x0),wrapTo2Pi(yPe))-omega_interp(wrapTo2Pi(x0),wrapTo2Pi(yMe)))/(2*rhoy));

qx = qx + (F11.*gox+F12.*goy)*dt/deltat;
qy = qy + (F21.*gox+F22.*goy)*dt/deltat;

for num = 2:length(tspan)-1
    F11 = (squeeze(xt(num,:,:,1))-squeeze(xt(num,:,:,3)))/(2*rhox);
    F12 = (squeeze(xt(num,:,:,2))-squeeze(xt(num,:,:,4)))/(2*rhox);
    F21 = (squeeze(yt(num,:,:,1))-squeeze(yt(num,:,:,3)))/(2*rhoy);
    F22 = (squeeze(yt(num,:,:,2))-squeeze(yt(num,:,:,4)))/(2*rhoy);

    detDF = F11.*F22-F12.*F21;
    
    F11_old = F11;
    F11 = F22./detDF;
    F12 = -F12./detDF;
    F21 = -F21./detDF;
    F22 = F11_old./detDF;

    str1 = '../Data/turb_w_';
    u_int = int8(tspan(num)/tstep)+1;
    str2 = pad(int2str(u_int),4,'left','0');
    str = strcat(str1,str2);
    load(str);
    
    w = [w w(:,1)];
    w = [w; w(1,:)]';
    
    % Vorticity gradient
    omega_interp = griddedInterpolant({linspace(0,2*pi,1025),linspace(0,2*pi,1025)},w,methodInterp,'none');
    
    x0 = squeeze(xt(num,:,:,5));
    y0 = squeeze(yt(num,:,:,5));
    xPe = squeeze(xt(num,:,:,5)) + rhox;
    xMe = squeeze(xt(num,:,:,5)) - rhox;
    yPe = squeeze(yt(num,:,:,5)) + rhoy;
    yMe = squeeze(yt(num,:,:,5)) - rhoy;

    gox = ((omega_interp(wrapTo2Pi(xPe),wrapTo2Pi(y0))-omega_interp(wrapTo2Pi(xMe),wrapTo2Pi(y0)))/(2*rhox));
    goy = ((omega_interp(wrapTo2Pi(x0),wrapTo2Pi(yPe))-omega_interp(wrapTo2Pi(x0),wrapTo2Pi(yMe)))/(2*rhoy));
    
    qx = qx + (F11.*gox+F12.*goy)*dt/deltat;
    qy = qy + (F21.*gox+F22.*goy)*dt/deltat;
    
end

F11 = (squeeze(xt(end,:,:,1))-squeeze(xt(end,:,:,3)))/(2*rhox);
F12 = (squeeze(xt(end,:,:,2))-squeeze(xt(end,:,:,4)))/(2*rhox);
F21 = (squeeze(yt(end,:,:,1))-squeeze(yt(end,:,:,3)))/(2*rhoy);
F22 = (squeeze(yt(end,:,:,2))-squeeze(yt(end,:,:,4)))/(2*rhoy);

detDF = F11.*F22-F12.*F21;

F11_old = F11;
F11 = F22./detDF;
F12 = -F12./detDF;
F21 = -F21./detDF;
F22 = F11_old./detDF;

str1 = '../Data/turb_w_';
u_int = int8(tspan(end)/tstep)+1;
str2 = pad(int2str(u_int),4,'left','0');
str = strcat(str1,str2);
load(str);

w = [w w(:,1)];
w = [w; w(1,:)]';

% Vorticity gradient
omega_interp = griddedInterpolant({linspace(0,2*pi,1025),linspace(0,2*pi,1025)},w,methodInterp,'none');

x0 = squeeze(xt(num,:,:,5));
y0 = squeeze(yt(num,:,:,5));
xPe = squeeze(xt(num,:,:,5)) + rhox;
xMe = squeeze(xt(num,:,:,5)) - rhox;
yPe = squeeze(yt(num,:,:,5)) + rhoy;
yMe = squeeze(yt(num,:,:,5)) - rhoy;

gox = ((omega_interp(wrapTo2Pi(xPe),wrapTo2Pi(y0))-omega_interp(wrapTo2Pi(xMe),wrapTo2Pi(y0)))/(2*rhox));
goy = ((omega_interp(wrapTo2Pi(x0),wrapTo2Pi(yPe))-omega_interp(wrapTo2Pi(x0),wrapTo2Pi(yMe)))/(2*rhoy));

qx = qx + (F11.*gox+F12.*goy)*dt/deltat/2;
qy = qy + (F21.*gox+F22.*goy)*dt/deltat/2;

x1_g = xspan;
x2_g = yspan;

save('qField.mat','x1_g','x2_g','qx','qy','rhox','rhoy')

disp('Computation of q-field is over.')
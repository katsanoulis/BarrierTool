function [handles] = computeTensorFieldData(handles)

x_span = linspace(handles.xmin,handles.xmax,handles.pointsInX);
y_span = linspace(handles.ymin,handles.ymax,handles.pointsInY);

[x0_in,y0_in] = ndgrid(x_span,y_span);

u_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.vx,'spline','none');
v_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.vy,'spline','none');

rho.x = (x_span(2)-x_span(1))*0.1;
rho.y = (y_span(2)-y_span(1))*0.1;

t0 = handles.itime;
tf = handles.ftime;

%number of sub-intervals to split the time domain
if handles.b_h{1,1} || handles.eulerian
    num = 1;
elseif numel(handles.D11) == 1
    num = handles.intermediatePointsForAveraging;
else
    num = handles.intermediatePointsForAveraging;
    D11_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.D11,'spline','none');
    D12_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.D12,'spline','none');
    D22_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.D22,'spline','none');
end
dt = (tf-t0)/num;
ti = t0;

C11 = zeros(handles.pointsInX,handles.pointsInY);
C12 = zeros(handles.pointsInX,handles.pointsInY);
C22 = zeros(handles.pointsInX,handles.pointsInY);

dtstar = t0 + 0.9 * (handles.time(2) - handles.time(1)); % df: not validated yet

for i=1:num
    
    ti = ti+dt;
    tspan = [t0 dtstar ti];
    %tspan = [t0,ti];

    if ~handles.eulerian
        options = odeset('RelTol',1e-6,'AbsTol',1e-6); % ODE solver options
        NCores = handles.NCores;
    if handles.b_h{1,1}
        disp(' ')
        disp('Computing the Cauchy-Green strain tensor and its derivatives ...')        
        tic
        [lam2,C11i,C12i,C22i,trC] = cgTensor(x0_in,y0_in,tspan,rho,NCores,options,u_interp,v_interp);
    elseif numel(handles.D11) == 1
        disp(' ')
        disp(['time interval: ',num2str(i),' of ', num2str(num)])
        disp('Computing the transport tensor and its derivatives ...')
        tic
        [lam2,C11i,C12i,C22i,trC] = cgTensor(x0_in,y0_in,tspan,rho,NCores,options,u_interp,v_interp);
    else
        disp(' ')
        disp(['time interval: ',num2str(i),' of ', num2str(num)])
        disp('Computing the transport tensor and its derivatives ...')
        tic
        [lam2,C11i,C12i,C22i,trC] = cgTensorDiffusivity(x0_in,y0_in,tspan,rho,NCores,options,u_interp,v_interp,D11_interp,D12_interp,D22_interp);
    end
    else
        disp(' ')
        disp('Computing the Rate-of-Strain tensor and its derivatives ...')
        tic
        [lam2,C11i,C12i,C22i,trC] = RateOfStrainTensor(x_span,y_span,rho,u_interp,v_interp,handles.itime,handles.b_h{1,1});
    end
    
    C11 = C11 + dt/(tf-t0)*C11i;
    C12 = C12 + dt/(tf-t0)*C12i;
    C22 = C22 + dt/(tf-t0)*C22i;
end

%gradient of transport tensor
C11_interp = griddedInterpolant({x_span,y_span},C11,'spline','none');
C12_interp = griddedInterpolant({x_span,y_span},C12,'spline','none');
C22_interp = griddedInterpolant({x_span,y_span},C22,'spline','none');

xPlusEpsilon  = x_span + rho.x;
xMinusEpsilon = x_span - rho.x;
yPlusEpsilon  = y_span + rho.y;
yMinusEpsilon = y_span - rho.y;
[xPe,y0] = ndgrid(xPlusEpsilon,y_span);
[xMe,~]  = ndgrid(xMinusEpsilon,y_span);
[x0,yPe] = ndgrid(x_span,yPlusEpsilon);
[~,yMe]  = ndgrid(x_span,yMinusEpsilon);
C11x1 = ((C11_interp(xPe,y0)-C11_interp(xMe,y0))/(2*rho.x));
C11x2 = ((C11_interp(x0,yPe)-C11_interp(x0,yMe))/(2*rho.y));
C12x1 = ((C12_interp(xPe,y0)-C12_interp(xMe,y0))/(2*rho.x));
C12x2 = ((C12_interp(x0,yPe)-C12_interp(x0,yMe))/(2*rho.y));
C22x1 = ((C22_interp(xPe,y0)-C22_interp(xMe,y0))/(2*rho.x));
C22x2 = ((C22_interp(x0,yPe)-C22_interp(x0,yMe))/(2*rho.y));
toc

if ~handles.eulerian
    if handles.b_h{1,1}
        disp(' ')
        disp('Computation of Cauchy-Green strain tensor and its derivatives is now completed.')
    else
        disp(' ')
        disp('Computation of Averaged Diffusive Cauchy-Green strain tensor and its derivatives is now completed.')
    end
else
    if handles.b_h{1,1}
        disp(' ')
        disp('Computation of Rate of strain tensor and its derivatives is now completed.')
    else
        disp(' ')
        disp('Computation of Diffusive Flux-Rate tensor and its derivatives is now completed.')
    end
end
%{
if handles.b_h{1,1}
    b = msgbox('Computation of Cauchy-Green strain tensor and its derivatives is now completed.',' Completion ');
    pos = getpixelposition(handles.figure1,true);
    set(b, 'position', [pos(1)+200 pos(2)+200 400 70]);
    ab = get( b, 'CurrentAxes' );
    ac = get( ab, 'Children' );
    set(ac, 'FontSize', 12);
else
    b = msgbox('Computation of transport tensor and its derivatives is now completed.',' Completion ');
    pos = getpixelposition(handles.figure1,true);
    set(b, 'position', [pos(1)+200 pos(2)+200 400 70]);
    ab = get( b, 'CurrentAxes' );
    ac = get( ab, 'Children' );
    set(ac, 'FontSize', 12);
end
%}
%%
handles.x1_g = x_span;
handles.x2_g = y_span;
handles.C11 = C11';
handles.C12 = C12';
handles.C22 = C22';
handles.C11x1 = C11x1';
handles.C11x2 = C11x2';
handles.C12x1 = C12x1';
handles.C12x2 = C12x2';
handles.C22x1 = C22x1';
handles.C22x2 = C22x2';
handles.lam2 = lam2';
handles.trC = trC';
end


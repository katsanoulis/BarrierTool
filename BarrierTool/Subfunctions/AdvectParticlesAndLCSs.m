function AdvectParticlesAndLCSs(handles)

tic
if handles.b_h{1,1}
    disp(' ');
    disp(['Advecting particles and Outermost Lagrangian Coherent Structures ...']);
    disp(' ');
else
    disp(' ');
    disp(['Advecting particles and Outermost Material Diffusion Barriers ...']);
    disp(' ');    
end
nLCSs = size(handles.x1LcOutM,2);
options = odeset('RelTol',1e-6,'AbsTol',1e-6);
t0 = handles.itimeAd;
t1 = handles.ftimeAd;
tspan = t0:t1;

m = handles.pointsInXAd;
n = handles.pointsInYAd;
x_span = linspace(handles.xminAd,handles.xmaxAd,m);
y_span = linspace(handles.yminAd,handles.ymaxAd,n);

[x0,y0] = meshgrid(x_span,y_span);
u_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.vx,'linear','none');
v_interp = griddedInterpolant({handles.time,handles.xc,handles.yc},handles.vy,'linear','none');

if handles.b_h{1,1} && ~handles.eulerian
    lam2_interp = griddedInterpolant({handles.x2_g,handles.x1_g},handles.lam2,'linear','none');
    lam2 = lam2_interp(y0,x0);
else
    trC_interp = griddedInterpolant({handles.x2_g,handles.x1_g},handles.trC,'linear','none');
    trC = trC_interp(y0,x0);
end

l = zeros(1,nLCSs+1);
[~,Fgrid] = ode45(@ODEfun,tspan,[x0(:);y0(:)],options,u_interp,v_interp);
l(1) = length(x0(:));

Fgrid1 = Fgrid(:,1:l(1));
Fgrid2 = Fgrid(:,l(1)+1:end);
max1 = max(Fgrid1(:));
min1 = min(Fgrid1(:));
max2 = max(Fgrid2(:));
min2 = min(Fgrid2(:));

F = cell(1,nLCSs);

for n = 1:nLCSs
    [timeInt,F{1,n}] = ode45(@ODEfun,tspan,[handles.x1LcOutM{1,n}(:);handles.x2LcOutM{1,n}(:)],options,u_interp,v_interp);
    l(n+1) = length(handles.x1LcOutM{1,n}(:));
end
toc

if ~handles.eulerian
if handles.b_h{1,1}
    h = figure('Name','Material Advection of Lagrangian Vortex Boundaries','NumberTitle','off');
else
    h = figure('Name','Material Advection of Outermost Closed Diffusion Barriers','NumberTitle','off');
end
else
if handles.b_h{1,1}
    h = figure('Name','Material Advection of Outermost Objective Eulerian Barriers','NumberTitle','off');
else
    h = figure('Name','Material Advection of Outermost Diffusive Instantaneous Barriers','NumberTitle','off');
end
end
axis tight manual % this ensures that getframe() returns a consistent size
if ismac
    filename = fullfile(fileparts(mfilename('fullpath')), '..', '/Output/NullGeodesics.gif');
elseif ispc
    filename = fullfile(fileparts(mfilename('fullpath')), '..', '\Output\NullGeodesics.gif');
end

tic
disp(' ');
disp(['Creating GIF ...']);
disp(' ');
for i=1:length(Fgrid(:,1))
    
    % Colormap encoding different \lambda values 
    
    % Plot properties 
    AxthicksFnt = 15;
    fontsizeaxlab = 15;
    
    sz = 8;
    if ~handles.eulerian
    if handles.b_h{1,1}
        scatter(Fgrid(i,1:l(1)),Fgrid(i,l(1)+1:end),sz,log(lam2(:))/handles.b_h{1,2}/2,'filled')
    else
        scatter(Fgrid(i,1:l(1)),Fgrid(i,l(1)+1:end),sz,log(trC(:)),'filled')
    end
    else   
    scatter(Fgrid(i,1:l(1)),Fgrid(i,l(1)+1:end),sz,trC(:),'filled')
    end
    hold on
    for n=1:nLCSs
        plot(F{1,n}(i,1:l(n+1)),F{1,n}(i,l(n+1)+1:end),'color','r','LineWidth',3)
    end
    axis([min1 max1 min2 max2])
    set(gca,'FontSize',AxthicksFnt,'fontWeight','normal')
    hhF=colorbar(gca);
    box on
    set(gca,'YDir','normal')
    set(gcf,'color','w');
    set(gcf, 'Position', [0, 0, 1000, 430])
    xlabel('$$x$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    ylabel('$$y$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    set(gca, 'Ticklength', [0 0])
    t = text(0.9,0.9,strcat(' T = ',{' '},num2str(timeInt(i)-t0),{' '}),'Units','normalized');
    t.FontSize = 16;
    t.FontWeight = 'bold';
    t.EdgeColor = 'black';
    t.LineWidth = 1.5;
    if ~handles.eulerian
    if handles.b_h{1,1}
        title('Material Advection of Lagrangian Vortex Boundaries (Red)')
        set(get(hhF,'xlabel'),'string','$$FTLE$$','Interpreter','latex','FontWeight','normal');
    else
        title('Material Advection of Outermost Closed Diffusion Barriers (Red)')
        set(get(hhF,'xlabel'),'string','$$\log \hphantom{[} DBS(x_{0})$$','Interpreter','latex','FontWeight','normal');
    end
    else
    if handles.b_h{1,1}
        title('Material Advection of Outermost Objective Eulerian Barriers (Red)')
        set(get(hhF,'xlabel'),'string','$$tr(S)$$','Interpreter','latex','FontWeight','normal');
    else
        title('Material Advection of Outermost Diffusive Instantaneous Barriers (Red)')
        set(get(hhF,'xlabel'),'string','$$tr \hphantom{[} [(\dot{T}_{t_0}^{t_0})^{-1}]$$','Interpreter','latex','FontWeight','normal');
    end
    end
    hold off
    drawnow
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if i == 1 
        imwrite(imind,cm,filename,'gif','DelayTime',0.1,'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','DelayTime',0.1,'WriteMode','append'); 
    end
end
toc


function dy = ODEfun(t,y,u_interp,v_interp)   
    Np = numel(y)/2;
    dy = zeros(2*Np,1);
    dy(1:Np,1)      = u_interp( t*ones(Np,1),y(1:Np,1),y(Np+1:2*Np,1) );
    dy(Np+1:2*Np,1) = v_interp( t*ones(Np,1),y(1:Np,1),y(Np+1:2*Np,1) );
end

end



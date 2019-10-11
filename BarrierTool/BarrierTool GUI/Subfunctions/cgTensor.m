function [lambda_2,C11,C12,C22,trC] = cgTensor(xi,yi,tspan,rho,NCores,options,u_interp,v_interp,diffusion)
%tspan =0:49;
%tspan =0:49;
%tspan = [tspan 49.8];
%tspan = 0:7:91;

[m,n] = size(xi);
xt=zeros(m,n,4);
yt=zeros(m,n,4);
for k=1:4
    xt(:,:,k) = xi + rho.x*cos( (k-1)*pi/2 );
    yt(:,:,k) = yi + rho.y*sin( (k-1)*pi/2 );
end
%!!!!!!!!!!
% if ~diffusion
%     xt=zeros(m,n,4);
%     yt=zeros(m,n,4);
%     for k=1:4
%         xt(:,:,k) = xi + rho.x*cos( (k-1)*pi/2 );
%         yt(:,:,k) = yi + rho.y*sin( (k-1)*pi/2 );
%     end
% else
%     xt=zeros(m,n,5);
%     yt=zeros(m,n,5);
%     for k=1:4
%         xt(:,:,k) = xi + rho.x*cos( (k-1)*pi/2 );
%         yt(:,:,k) = yi + rho.y*sin( (k-1)*pi/2 );
%     end
%     xt(:,:,5) = xi;
%     yt(:,:,5) = yi;
% end

%% Time integration

[xt,yt] = Integrator(xt(:,:,1:4),yt(:,:,1:4),tspan,NCores,options,u_interp,v_interp,diffusion);

if ~diffusion
    %a = reshape(a, m, n, 4);
    %b = reshape(b, m, n, 4);
    xt = reshape(xt, m, n, 4);
    yt = reshape(yt, m, n, 4);
    
    %xt(:,:,1:4) = a;
    %yt(:,:,1:4) = b;
    
    %clearvars a b
    
    disp('Advection of particles is over.')
    
    %% computation of eigen-values and eigen-vectors
    
    F11 = (xt(:,:,1)-xt(:,:,3))/(2*rho.x);
    F12 = (xt(:,:,2)-xt(:,:,4))/(2*rho.x);
    F21 = (yt(:,:,1)-yt(:,:,3))/(2*rho.y);
    F22 = (yt(:,:,2)-yt(:,:,4))/(2*rho.y);
    
    %g = fspecial('average', [3,3]);
    %F11 = conv2(F11,g,'same');
    %F12 = conv2(F12,g,'same');
    %F21 = conv2(F21,g,'same');
    %F22 = conv2(F22,g,'same');
    
    C11 = F11.^2 + F21.^2;
    C12 = F12.*F11 + F22.*F21;
    C22 = F12.^2 + F22.^2;
    
    disp('Computation of Cauchy-Green tensor is over.')
    
    trC  = C11+C22;
    detC = C11.*C22-C12.^2;
    
    lambda_2 = 0.5*trC+sqrt((0.5*trC).^2-detC);
else
    xt = reshape(xt, length(tspan), m, n, 4);
    yt = reshape(yt, length(tspan), m, n, 4);
    
%     if ismac
%         filename = fullfile(fileparts(mfilename('fullpath')), '..', '/Output/particles1100.mat');
%     elseif ispc
%          filename = fullfile(fileparts(mfilename('fullpath')), '..', '\Output\particles1100.mat');
%     end
%     save(filename,'xt','yt','-v7.3');

    C11 = ones(m,n)/2;
    C12 = zeros(m,n);
    C22 = ones(m,n)/2;
    
    deltat = tspan(end) - tspan(1);
    dt = (deltat)/(length(tspan) - 1);
    
    for num = 2:length(tspan)-1
        F11 = (squeeze(xt(num,:,:,1))-squeeze(xt(num,:,:,3)))/(2*rho.x);
        F12 = (squeeze(xt(num,:,:,2))-squeeze(xt(num,:,:,4)))/(2*rho.x);
        F21 = (squeeze(yt(num,:,:,1))-squeeze(yt(num,:,:,3)))/(2*rho.y);
        F22 = (squeeze(yt(num,:,:,2))-squeeze(yt(num,:,:,4)))/(2*rho.y);
        %{
        detDF = F11.*F22-F12.*F21;
        detDF(detDF<0) = 1;
        F11 = F11./sqrt(detDF);
        F12 = F12./sqrt(detDF);
        F21 = F21./sqrt(detDF);
        F22 = F22./sqrt(detDF);
        %}
        C11Inter = F11.^2 + F21.^2;
        C12Inter = F12.*F11 + F22.*F21;
        C22Inter = F12.^2 + F22.^2;
        %{
        detC = C11Inter.*C22Inter-C12Inter.*C12Inter;
        detC(detC<0) = 1;
        
        C11Inter = C11Inter./sqrt(detC);
        C12Inter = C12Inter./sqrt(detC);
        C22Inter = C22Inter./sqrt(detC);
        %}
        C11 = C11 + C11Inter;
        C12 = C12 + C12Inter;
        C22 = C22 + C22Inter;
    end
    
    F11 = (squeeze(xt(end,:,:,1))-squeeze(xt(end,:,:,3)))/(2*rho.x);
    F12 = (squeeze(xt(end,:,:,2))-squeeze(xt(end,:,:,4)))/(2*rho.x);
    F21 = (squeeze(yt(end,:,:,1))-squeeze(yt(end,:,:,3)))/(2*rho.y);
    F22 = (squeeze(yt(end,:,:,2))-squeeze(yt(end,:,:,4)))/(2*rho.y);
    
    %{
    detDF = F11.*F22-F12.*F21;
    detDF(detDF<0) = 1;
    F11 = F11./sqrt(detDF);
    F12 = F12./sqrt(detDF);
    F21 = F21./sqrt(detDF);
    F22 = F22./sqrt(detDF);
    %}
    
    C11Inter = F11.^2 + F21.^2;
    C12Inter = F12.*F11 + F22.*F21;
    C22Inter = F12.^2 + F22.^2;
    %{
    detC = C11Inter.*C22Inter-C12Inter.*C12Inter;
    detC(detC<0) = 1;
    
    C11Inter = C11Inter./sqrt(detC);
    C12Inter = C12Inter./sqrt(detC);
    C22Inter = C22Inter./sqrt(detC);
    %}
    C11 = C11 + C11Inter/2;
    C12 = C12 + C12Inter/2;
    C22 = C22 + C22Inter/2;
    
%     C11 = C11 + (F11.^2 + F21.^2)/2;
%     C12 = C12 + (F12.*F11 + F22.*F21)/2;
%     C22 = C22 + (F12.^2 + F22.^2)/2;
    
    C11 = C11*dt/deltat;
    C12 = C12*dt/deltat;
    C22 = C22*dt/deltat;
    
    trC  = C11+C22;
    detC = C11.*C22-C12.^2;
    
    lambda_2 = 0.5*trC+sqrt((0.5*trC).^2-detC);
    
    disp('Computation of transport tensor is over.')

end

end

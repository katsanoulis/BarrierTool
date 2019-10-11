function [lambda_2,C11,C12,C22,trC] = cgTensorDiffusivity(xi,yi,tspan,rho,NCores,options,u_interp,v_interp,D11_interp,D12_interp,D22_interp)

[m,n] = size(xi);
xt=zeros(m,n,5);
yt=zeros(m,n,5);
for k=1:4
    xt(:,:,k) = xi + rho.x*cos( (k-1)*pi/2 );
    yt(:,:,k) = yi + rho.y*sin( (k-1)*pi/2 );
end
xt(:,:,5) = xi;
yt(:,:,5) = yi;

%% Time integration

[a,b] = Integrator(xt(:,:,1:5),yt(:,:,1:5),tspan,NCores,options,u_interp,v_interp);

a = reshape(a, m, n, 5);
b = reshape(b, m, n, 5);

xt(:,:,1:5) = a;
yt(:,:,1:5) = b;
clearvars a b

disp('Advection of particles is over.')

%% computation of eigen-values and eigen-vectors

F11 = (xt(:,:,1)-xt(:,:,3))/(2*rho.x);
F12 = (xt(:,:,2)-xt(:,:,4))/(2*rho.x);
F21 = (yt(:,:,1)-yt(:,:,3))/(2*rho.y);
F22 = (yt(:,:,2)-yt(:,:,4))/(2*rho.y);

D11 = D11_interp(tspan(2)*ones(m,n),xt(:,:,5),yt(:,:,5));
D12 = D12_interp(tspan(2)*ones(m,n),xt(:,:,5),yt(:,:,5));
D22 = D22_interp(tspan(2)*ones(m,n),xt(:,:,5),yt(:,:,5));
clearvars xt yt D11_interp D12_interp D22_interp

detD = D11.*D22-D12.*D12;
% Transport tensor
C11 = detD.*(D11.*F11.^2 + 2*D12.*F11.*F21 + D22.*F21.^2);
C12 = detD.*(D11.*F12.*F11 + D12.*(F22.*F11 + F21.*F12) + D22.*F22.*F21);
C22 = detD.*(D11.*F12.^2 + 2*D12.*F22.*F12 + D22.*F22.^2);

disp('computation of C is over.')

trC  = C11+C22;
detC = C11.*C22-C12.^2;

lambda_2 = 0.5*trC+sqrt((0.5*trC).^2-detC);

end

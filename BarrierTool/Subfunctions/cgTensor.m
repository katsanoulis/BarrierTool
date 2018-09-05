function [lambda_2,C11,C12,C22,trC] = cgTensor(xi,yi,tspan,rho,NCores,options,u_interp,v_interp)

[m,n] = size(xi);
xt=zeros(m,n,4);
yt=zeros(m,n,4);
for k=1:4
    xt(:,:,k) = xi + rho.x*cos( (k-1)*pi/2 );
    yt(:,:,k) = yi + rho.y*sin( (k-1)*pi/2 );
end

%% Time integration

[a,b] = Integrator(xt(:,:,1:4),yt(:,:,1:4),tspan,NCores,options,u_interp,v_interp);

a = reshape(a, m, n, 4);
b = reshape(b, m, n, 4);

xt(:,:,1:4) = a;
yt(:,:,1:4) = b;

clearvars a b

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

disp('Computation of C is over.')

trC  = C11+C22;
detC = C11.*C22-C12.^2;

lambda_2 = 0.5*trC+sqrt((0.5*trC).^2-detC);

end

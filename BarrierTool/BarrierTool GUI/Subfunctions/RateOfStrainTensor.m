function [lambda_2,C11,C12,C22,trC] = RateOfStrainTensor(x_span,y_span,rho,u_interp,v_interp,time,noDiffusion)

xPlusEpsilon  = x_span + rho.x;
xMinusEpsilon = x_span - rho.x;
yPlusEpsilon  = y_span + rho.y;
yMinusEpsilon = y_span - rho.y;
[xPe,y0] = ndgrid(xPlusEpsilon,y_span);
[xMe,~]  = ndgrid(xMinusEpsilon,y_span);
[x0,yPe] = ndgrid(x_span,yPlusEpsilon);
[~,yMe]  = ndgrid(x_span,yMinusEpsilon);

[m,n] = size(x0);
time = time*ones(m,n);
Du11 = ((u_interp(time,xPe,y0)-u_interp(time,xMe,y0))/(2*rho.x));
Du12 = ((u_interp(time,x0,yPe)-u_interp(time,x0,yMe))/(2*rho.y));
Du21 = ((v_interp(time,xPe,y0)-v_interp(time,xMe,y0))/(2*rho.x));
Du22 = ((v_interp(time,x0,yPe)-v_interp(time,x0,yMe))/(2*rho.y));

if noDiffusion
    C11 = Du11;
    C12 = 0.5*(Du12 + Du21);
    C22 = Du22;
else
    C11 = 2*Du11;
    C12 = Du12 + Du21;
    C22 = 2*Du22;
end

disp('Computation of Rate-of-Strain tensor is over.')

trC  = C11+C22;
detC = C11.*C22-C12.^2;

lambda_2 = 0.5*trC+sqrt((0.5*trC).^2-detC);

end
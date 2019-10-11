%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  sumbitted, (2016).
%
function [x0lam,y0lam,phi0lam]=r0_lam(lamV,qx,qy,x_g,y_g)
%Define the initial \phi value: \phi_0 (cf. Fig. 2 of [1])
phi0 = 0;

% Initialize the output variables
x0lam = cell(1,length(lamV));
y0lam = x0lam;
phi0lam = x0lam;

% Compute the initial conditions r0_\lambda for different values of \lambda
for kkmu = 1:length(lamV)
    lam = (lamV(kkmu));
    ZeroSet = sqrt((- sin(phi0).*qx + cos(phi0).*qy).^2) - lam;
    
    %Discard the points where out of the domain of existence V (cf. eq. (37) of [1])
    DoE = qx.*cos(phi0) + qy.*sin(phi0);
    ZeroSet(abs(DoE)<1e-2) = nan;
    
    % Extract the x_0(\lambda,\phi_0) (cf. Fig. 2b or eq.(39) of [1])
    CC = contourc(x_g,y_g,ZeroSet,[0,0]);
    ss = getcontourlines(CC);
    if isempty(ss)
        x0lam{kkmu} = [];
        y0lam{kkmu} = [];
        phi0lam{kkmu} = [];
        continue
    else
        XXvTzero = [];
        YYvTzero = [];
        for kkk=1:size(ss,2)
            XXvTzero = [XXvTzero;(ss(kkk).x)'];
            YYvTzero = [YYvTzero;(ss(kkk).y)'];
        end
        
        ZZvTzero = phi0+0*XXvTzero;
        % Cell variables containing the x,y,\phi coordinates of \lambda-dependent zero level set
        x0lam{kkmu} = XXvTzero;
        y0lam{kkmu} = YYvTzero;
        phi0lam{kkmu} = ZZvTzero;
    end
    
end

end

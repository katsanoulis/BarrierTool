%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  sumbitted, (2016).
%%
% function [x0lam,y0lam,phi0lam]=r0_lam(lamV,C11,C12,C22,x_g,y_g)

% Input arguments:
    % lamV : Desired set of \lambda values
    % Cij  : ij entries of the C strain tensor 
    % x_g  : x component of the spatial grid 
    % y_g  : y component of the spatial grid 

% Output arguments:
%   x0lam: x-coordinates of r0_lam
%   y0lam: y-coordinates of r0_lam
%   phi0lam: phi-coordinates of r0_lam

%Note: This function returns the intial condition r0_lam for any value of
%phi0 \in [0,2\pi). Since this choice is arbitrary, in [1]
%we picked phi0=0, leading to the simplified formula (39) in [1].

%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------

function [x0lam,y0lam,phi0lam]=r0_lam(lamV,C11,C12,C22,x_g,y_g,b_h,eulerian) 

    %Define the initial \phi value: \phi_0 (cf. Fig. 2 of [1])
    phi0 = 0;

    % Initialize the output variables 
    x0lam = cell(1,length(lamV));
    y0lam = x0lam;
    phi0lam = x0lam;    

    % Compute the initial conditions r0_\lambda for different values of \lambda

    for kkmu = 1:length(lamV)
        lam = (lamV(kkmu));
        if b_h{1,1} && ~eulerian
            ZeroSet = (cos(phi0))^2*C11+sin(2*phi0)*C12+(sin(phi0))^2*C22-lam^2;
        else
            ZeroSet = (cos(phi0))^2*C11+sin(2*phi0)*C12+(sin(phi0))^2*C22-lam;
        end
        %Discard the points where out of the domain of existence V (cf. eq. (37) of [1])
        DoE = 2*C12.*cos(2*phi0)+sin(2*phi0).*(C22-C11);
        %DoE = C12.*cos(2*phi0)-sin(2*phi0).*C11;
        ZeroSet(abs(DoE)<1e-2) = nan;

        % Extract the x_0(\lambda,\phi_0) (cf. Fig. 2b or eq.(39) of [1])
        CC = contourc(x_g,y_g,ZeroSet,[0,0]);
        ss = getcontourlines(CC);
        if isempty(ss)
            x0lam = [];
            Spinner(gcf,'Done','Stop',[615,154,80,80]);
            break
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
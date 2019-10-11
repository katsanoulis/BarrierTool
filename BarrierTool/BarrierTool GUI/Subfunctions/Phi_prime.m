%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  submitted, (2016).
%%
% [phiPrGr,C22mC11Gr,C12Gr]=Phi_prime(C11,C11x1,C11x2,C12,C12x1,C12x2,C22,C22x1,C22x2,x1_g,x2_g)

% Input arguments:
    % Cij   : ij entries of the C strain tensor 
    % Cijx1 : x1-derivatice of the Cij entry 
    % Cijx2 : x2-derivatice of the Cij entry 
    % x1_g  : x1 component of the spatial grid 
    % x2_g  : x2 component of the spatial grid 

% Output argument:
%   C22mC11Gr: gridded interpolant object for C22(x,y)-C11(x,y)
%   C12Gr    : gridded interpolant object for C12(x,y)
%   phiPrGr  : gridded interpolant object for \phi'(x,\phi)


%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------

function [C22mC11Gr,C11Gr,C12Gr,C22Gr,phiPrGr]=Phi_prime(C11,C11x1,C11x2,C12,C12x1,C12x2,C22,C22x1,C22x2,x1_g,x2_g,interpolationIn2D)

if interpolationIn2D
    
    phiPrGr{1,1} = griddedInterpolant ({x1_g,x2_g},permute(C11x1,[2 1]),'linear');
    phiPrGr{1,2} = griddedInterpolant ({x1_g,x2_g},permute(C11x2,[2 1]),'linear');
    phiPrGr{1,3} = griddedInterpolant ({x1_g,x2_g},permute(C12x1,[2 1]),'linear');
    phiPrGr{1,4} = griddedInterpolant ({x1_g,x2_g},permute(C12x2,[2 1]),'linear');
    phiPrGr{1,5} = griddedInterpolant ({x1_g,x2_g},permute(C22x1,[2 1]),'linear');
    phiPrGr{1,6} = griddedInterpolant ({x1_g,x2_g},permute(C22x2,[2 1]),'linear');

else
    
    %Define the \phi component of the spatial grid 
    phi_g = linspace(0,2*pi,180);

    [~,~,Z3d]=meshgrid(x1_g,x2_g,phi_g);

    % phi' (cf. eq. (38) of [1])
    C_appropriate = repmat(C11x1,1,1,numel(phi_g));
    phiPr = - (C_appropriate.* cos(Z3d)).* cos(Z3d).^2;
    C_appropriate = repmat(C11x2,1,1,numel(phi_g));
    phiPr = phiPr - (C_appropriate.* sin(Z3d)).* cos(Z3d).^2;
    C_appropriate = repmat(C12x1,1,1,numel(phi_g));
    phiPr = phiPr - (C_appropriate.* cos(Z3d)).* sin(2*Z3d);
    C_appropriate = repmat(C12x2,1,1,numel(phi_g));
    phiPr = phiPr - (C_appropriate.* sin(Z3d)).* sin(2*Z3d);
    C_appropriate = repmat(C22x1,1,1,numel(phi_g));
    phiPr = phiPr - (C_appropriate.* cos(Z3d)).* sin(Z3d).^2;
    C_appropriate = repmat(C22x2,1,1,numel(phi_g));
    phiPr = phiPr - (C_appropriate.* sin(Z3d)).* sin(Z3d).^2;
    C_appropriate = repmat(C22,1,1,numel(phi_g));
    phiPrDen = C_appropriate.* sin(2*Z3d);
    C_appropriate = repmat(C11,1,1,numel(phi_g));
    phiPrDen = phiPrDen - C_appropriate.* sin(2*Z3d);
    C_appropriate = repmat(C12,1,1,numel(phi_g));
    phiPrDen = phiPrDen + 2 * C_appropriate.* cos(2*Z3d);

    phiPr = phiPr./ phiPrDen;

    clear C_appropriate phiPrDen Z3d

    phiPrGr = griddedInterpolant ({x1_g,x2_g,phi_g},permute(phiPr,[2 1 3]),'linear');
end

% Compute the (x)-dependent functions needed to define the domain of
% existence V (cf. eq. (37) of [1]) of the reduced 3D null-geodesic flow (cf. eq. (38) of [1]).
C22mC11Gr = griddedInterpolant ({x1_g,x2_g},permute(C22-C11,[2 1]),'linear');
%C22mC11Gr = griddedInterpolant ({x1_g,x2_g},permute(C11,[2 1]),'linear');
C11Gr = griddedInterpolant ({x1_g,x2_g},permute(C11,[2 1]),'linear');
C12Gr = griddedInterpolant ({x1_g,x2_g},permute(C12,[2 1]),'linear');
C22Gr = griddedInterpolant ({x1_g,x2_g},permute(C22,[2 1]),'linear');

end


%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  sumbitted, (2016).
%%
% function [~,xxx,yyy,zzz]=Advect_r(phiPrGr,C22mC11Gr,C12Gr,x_glim,y_glim,sVec,Z0,options)  

% Input arguments:
    % C22mC11Gr, C12Gr, phiPrGr : see step 2
    % x1_glim, x2_glim,         : domain limits to stop particles if they
    %                             reach the boundaries 
    % sVec, options             : see step 3
    % Z0                        : Initial conditions 

    % Output arguments:
    %   xxx    : x1-component of trajectories of the ODE (38) in [1]
    %   yyy    : x2-component of trajectories of the ODE (38) in [1]
    %   zzz    : \phi-component of trajectories of the ODE (38) in [1]

%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------
function     [xt,yt,zt] = Advect_r(phiPrGr,C22mC11Gr,C12Gr,x1_glim,x2_glim,sVec,xx,yy,zz,interpolationIn2D,C11Gr,C22Gr,lam) 
    % Shared variables 
    x1m = x1_glim(1);
    x1M = x1_glim(2);
    x2m = x2_glim(1);
    x2M = x2_glim(2);
     xt = zeros(length(sVec),length(xx));
     yt = zeros(length(sVec),length(yy));
     zt = zeros(length(sVec),length(zz));
     xt(1,:) = xx;
     yt(1,:) = yy;
     zt(1,:) = zz;
     
    for s=1:numel(sVec)-1
        
        ds = sVec(s+1) - sVec(s);
        
        [UK1,VK1,ZK1] = r_prime(xt(s,:),yt(s,:),zt(s,:),interpolationIn2D);
        xx = xt(s,:) + 0.5 * ds * UK1;
        yy = yt(s,:) + 0.5 * ds * VK1;
        zz = zt(s,:) + 0.5 * ds * ZK1;

        [UK2,VK2,ZK2] = r_prime(xx,yy,zz,interpolationIn2D);
        xx = xt(s,:) + 0.5 * ds * UK2;
        yy = yt(s,:) + 0.5 * ds * VK2;
        zz = zt(s,:) + 0.5 * ds * ZK2;
        
        [UK3,VK3,ZK3] = r_prime(xx,yy,zz,interpolationIn2D);
        xx = xt(s,:) + ds * UK3;
        yy = yt(s,:) + ds * VK3;
        zz = zt(s,:) + ds * ZK3;
        
        [UK4,VK4,ZK4] = r_prime(xx,yy,zz,interpolationIn2D);
        
        %increment in trajectories (displacement of grid)
        deltax = ds / 6 * (UK1 + 2 * UK2 + 2 * UK3 + UK4);
        deltay = ds / 6 * (VK1 + 2 * VK2 + 2 * VK3 + VK4);
        deltaz = ds / 6 * (ZK1 + 2 * ZK2 + 2 * ZK3 + ZK4);
        
        %update particle positions
        xt(s+1,:) = xt(s,:) + deltax;
        yt(s+1,:) = yt(s,:) + deltay;
        zt(s+1,:) = zt(s,:) + deltaz;
    end


function [k1,k2,k3] = r_prime(xx,yy,zz,interpolationIn2D) 
            
        % Freeze particles at the boundaries of the domain or when the ODE
        % (38) is not defined 
        Bll = 1+0*xx;
        Bll(xx>x1M) = 0; Bll(xx<x1m) = 0;
        Bll(yy>x2M) = 0; Bll(yy<x2m) = 0;
        
        % Freeze particles at the boundaries of the domain of definition V (cf eq. (37) of [1]) of
        % the ODE (38) of [1].
            % Domain of existence
            %DoE = -sin(2*zz).*C22mC11Gr(xx,yy)+cos(2*zz).*C12Gr(xx,yy);
            DoE = 2*C12Gr(xx,yy).*cos(2*zz)+sin(2*zz).*C22mC11Gr(xx,yy);
            Bll(abs(DoE)<1e-2) = 0;
             % Invariance condition
            %ZeroSet = (cos(zz)).^2.*C11Gr(xx,yy)+sin(2*zz).*C12Gr(xx,yy)+(sin(zz)).^2.*C22Gr(xx,yy);
            %ZeroSet = sqrt((- sin(zz).*qx_interp(xx,yy) + cos(zz).*qy_interp(xx,yy)).^2);
            %ZeroSet = sin(zz).*qx_interp(xx,yy) - cos(zz).*qy_interp(xx,yy);
            %Bll(ZeroSet<0.9*abs(lam))=0;
            %Bll(ZeroSet>1.1*abs(lam))=0;
            
        % Evaluate r'(s)
        utemp = cos(zz);
        vtemp = sin(zz);

        if interpolationIn2D
            wtemp = -((phiPrGr{1,1}(xx,yy).*cos(zz)+phiPrGr{1,2}(xx,yy).*sin(zz)).*cos(zz).^2+(phiPrGr{1,3}(xx,yy).*cos(zz)+phiPrGr{1,4}(xx,yy).*sin(zz)).*sin(2*zz)+(phiPrGr{1,5}(xx,yy).*cos(zz)+phiPrGr{1,6}(xx,yy).*sin(zz)).*sin(zz).^2)./(sin(2*zz).*C22mC11Gr(xx,yy)+2*cos(2*zz).*C12Gr(xx,yy));
            %wtemp = -((phiPrGr{1,1}(xx,yy).*cos(zz)+phiPrGr{1,2}(xx,yy).*sin(zz)).*cos(2*zz)+(phiPrGr{1,3}(xx,yy).*cos(zz)+phiPrGr{1,4}(xx,yy).*sin(zz)).*sin(2*zz))./(-sin(2*zz).*C22mC11Gr(xx,yy)+cos(2*zz).*C12Gr(xx,yy))./2;
        else
            wtemp = phiPrGr(xx,yy,zz);
        end

        Norma = sqrt(utemp.^2+vtemp.^2+wtemp.^2);
        k1 = utemp./Norma.*Bll;
        k2 = vtemp./Norma.*Bll;
        k3 = wtemp./Norma.*Bll;
end
    
end

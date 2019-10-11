%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  sumbitted, (2016).
%%
% function [x1Psol,x2Psol]=FindClosedNullGeod(C22mC11Gr,C12Gr,phiPrGr,x1_g,x2_g,lamV,sVec,options);   

% Input arguments:
    % C22mC11Gr, C12Gr, phiPrGr : see step 2
    % x1_g, x2_g, lamV          : see steps 0-1
    % sVec, options             : see step 3
    % NCores                    : Number of cores for Parallel computing 

% Output arguments:
    %   x1Psol    : x1-component of closed null-geodesics  
    %   x2Psol    : x2-component of closed null-geodesics  

%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------

function [x1Psol,x2Psol]=FindClosedNullGeod(C22mC11Gr,C11Gr,C12Gr,C22Gr,phiPrGr,x0lam,y0lam,phi0lam,x1_g,x2_g,lamV,sVec,NCores,b_h,interpolationIn2D)   

    % Initialize the variables containing the periodic solutions of the initial value problem
    xxx = cell(length(lamV),1);
    yyy = cell(length(lamV),1);
    x1Psol = cell(1,length(lamV));
    x2Psol = x1Psol;
    phiPsol = x1Psol;

    % Define the limits of the (x-y) domain to stop particles at the boundary 
    x1_glim = [min(x1_g),max(x1_g)];
    x2_glim = [min(x2_g),max(x2_g)];

tic
    % Compute closed orbits of the Initial Value Problem (cf. eqs. (38-39) of [1])
    for kklam = 1:1:length(lamV)
        
        if b_h{1,1}
            disp(' ');
            disp(['Searching Lagrangian Coherent Structures corresponding to lambda-parameter value of: ',num2str(lamV(kklam)) ,' ...']);
            disp(' ');
        else
            disp(' ');
            disp(['Searching Material Diffusion Barriers corresponding to T-parameter value of: ',num2str(lamV(kklam)) ,' ...']);
            disp(' ');    
        end

        % Extract the r0_lam for the current value of \lambda
        x0 = x0lam{kklam};
        y0 = y0lam{kklam};   
        phi0 = phi0lam{kklam};
        lam = lamV(kklam);
        
        tic        
        if NCores == 1
            [X_Vf,Y_Vf,Z_Vf] = Advect_r(phiPrGr,C22mC11Gr,C12Gr,x1_glim,x2_glim,sVec,x0(:),y0(:),phi0(:),interpolationIn2D);
        else
        %% Opening MATLAB Pool %%
        Np=size(x0,1);
        cpu_num = min(NCores,Np);
        id = ceil( linspace(0,Np,cpu_num+1) );

        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        l = 'local';
        if isempty(poolobj)                                          % if parpool is not open
            evalc('parpool(l,cpu_num)');
        elseif (~isempty(poolobj)) && (poolobj.NumWorkers~=cpu_num)  % if parpool is not consistent with cpu_num
            delete(gcp)
            evalc('parpool(l,cpu_num)');
        end
        %% Integrate the ODE (38) in [1]

        spmd
            Range = id(labindex)+1:id(labindex+1);
            [xxfTot,yyfTot,zzfTot] = Advect_r(phiPrGr,C22mC11Gr,C12Gr,x1_glim,x2_glim,sVec,x0(Range),y0(Range),phi0(Range),interpolationIn2D,C11Gr,C22Gr,lam);
        end

        % Put the trajectories of ODE (38) in matrix form
        X_Vf = cat(2,xxfTot{:});
        Y_Vf = cat(2,yyfTot{:});
        Z_Vf = cat(2,zzfTot{:});

        clear xxfTot yyfTot zzfTot

        %Warning in case of dimensionality mismatch        
        if size(X_Vf,2)~=length(x0)
            disp('spmd dim. mismatch')
        end
        end
        
        % Find periodic solutions 
        %[X1lco,X2lco] = PeriodicSolutions(X_Vf,Y_Vf,Z_Vf);
        [X1lco,X2lco,philco] = PeriodicSolutions(X_Vf,Y_Vf,Z_Vf);
        toc
        clear X_Vf Y_Vf Z_Vf
        
        %{
        for i = 1:size(X1lco,2)
            xx = X1lco(:,i);
            yy = X2lco(:,i);
            zz = philco(:,1);
            ZeroSet = (cos(zz)).^2.*C11Gr(xx,yy)+sin(2*zz).*C12Gr(xx,yy)+(sin(zz)).^2.*C22Gr(xx,yy);
            xx(ZeroSet<0.95*abs(lam) | ZeroSet>1.05*abs(lam))=[]; yy(ZeroSet<0.95*abs(lam) | ZeroSet>1.05*abs(lam))=[];
            %xx(ZeroSet>1.05*abs(lam))=[]; yy(ZeroSet>1.05*abs(lam))=[];
            xxx{kklam,1} = xx;
            yyy{kklam,1} = yy;
        end
        %}
    
        % Final curves in a cell 
        %x1Psol{kklam} = xx;
        %x2Psol{kklam} = yy;
        % Final curves in a cell 
        x1Psol{kklam} = X1lco;
        x2Psol{kklam} = X2lco;

        
    end
end


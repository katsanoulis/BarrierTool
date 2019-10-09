%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%              ____________________   ___           %%%%%%%%%%%%%
%%%%%%%%%%%             /  ________   ___   /__/  /           %%%%%%%%%%%%%
%%%%%%%%%%%            /  _____/  /  /  /  ___   /            %%%%%%%%%%%%%
%%%%%%%%%%%           /_______/  /__/  /__/  /__/             %%%%%%%%%%%%%
%%%%%%%%%%%    Swiss Federal Institute of Technology Zurich   %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Author: Stergios Katsanoulis  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Email:  katsanos@ethz.ch      %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  Date:   07/10/2019            %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
function [x1Psol,x2Psol]=FindClosedNullGeod(phiPrGr,x0lam,y0lam,phi0lam,x1_g,x2_g,lamV,sVec,NCores,dist,err)

    lv = length(lamV);
    x1Psol = cell(1,lv);
    x2Psol = x1Psol;
    phiPsol = x1Psol;

    x1_glim = [min(x1_g),max(x1_g)];
    x2_glim = [min(x2_g),max(x2_g)];

	tic
    %% Opening MATLAB Pool %%
    id = ceil( linspace(0,lv,NCores+1) );
    
    %batch_job = parcluster('EulerLSF8h');
    %batch_job.SubmitArguments = '-W 3:00 -R "rusage[mem=4000]"';
    %pool = parpool(batch_job, cpu_num);
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)                                          % if parpool is not open
        parpool('local',NCores)
        %pool = parpool(batch_job, NCores);
    elseif (~isempty(poolobj)) && (poolobj.NumWorkers~=NCores)  % if parpool is not consistent with cpu_num
        delete(gcp)
        parpool('local',NCores)
        %pool = parpool(batch_job, NCores);
    end
    
    spmd
        Range = id(labindex)+1:id(labindex+1);
        X1lco = cell(1,length(Range));
        X2lco = X1lco;
        for kklam = 1:length(Range)
            
            if ~isempty(x0lam{Range(kklam)})
                x0 = x0lam{Range(kklam)};
                y0 = y0lam{Range(kklam)};
                phi0 = phi0lam{Range(kklam)};
                lam = lamV(Range(kklam));

                [xxfTot,yyfTot,zzfTot] = Advect_r(phiPrGr,x1_glim,x2_glim,sVec,x0,y0,phi0,lam,err);
                
                [X1l,X2l] = PeriodicSolutions(xxfTot,yyfTot,zzfTot,dist);
                xxfTot = [];
                yyfTot = [];
                zzfTot = [];
                
                X1lco{1,kklam} = X1l;
                X2lco{1,kklam} = X2l;
            else
                X1lco{1,kklam} = [];
                X2lco{1,kklam} = [];
            end
        end
    end
    x1Psol = cat(2,X1lco{:});
    x2Psol = cat(2,X2lco{:});
    toc
end
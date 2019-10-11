%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  sumbitted, (2016).
%%
% function [X1lco,X2lco,philco]=PeriodicSolutions(X_Vf,Y_Vf,Z_Vf)

 % Input arguments:
    % X_Vf : x1-component of the trajectories of the ODE (38) in [1]
    % Y_Vf : x2-component of the trajectories of the ODE (38) in [1]
    % Z_Vf : \phi-component of the trajectories of the ODE (38) in [1]
    
 % Output arguments:
    %   X1lco    : x1-component of periodic solutions of ODE (38) in [1]
    %   X2lco    : x2-component of periodic solutions of ODE (38) in [1]
    %   philco   : \phi-component of periodic solutions of ODE (38) in [1]
%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------
function [X1lco,X2lco,philco] = PeriodicSolutions(X_Vf,Y_Vf,Z_Vf)


X1lco=[];X2lco=[];philco=[];


% Topological condition: discard the traject that have no Z values close to abs(2*pi)
MaxPerCol=max(abs(Z_Vf));
MinZVal=0.95*2*pi;
X_Vf=X_Vf(:,MaxPerCol>MinZVal);
Y_Vf=Y_Vf(:,MaxPerCol>MinZVal);
Z_Vf=Z_Vf(:,MaxPerCol>MinZVal);

% C^1 distance
distance2d02pi=sqrt((repmat(X_Vf(1,:),size(X_Vf,1),1)-X_Vf).^2+(repmat(Y_Vf(1,:),size(Y_Vf,1),1)-Y_Vf).^2+(abs(repmat(Z_Vf(1,:),size(Z_Vf,1),1)-Z_Vf)-2*pi).^2);

% Avoid to get the first points 
ReturnDist=2*1e-2;       % Avoid to scan all the set of initial conditions to find closed null-geodesics
distance2d02pi(abs(Z_Vf)<0.8*2*pi)=nan;
[valret,indrw]=min(distance2d02pi);
indrw(valret>ReturnDist)=[];
X_Vf(:,valret>ReturnDist)=[];
Y_Vf(:,valret>ReturnDist)=[];
%Z_Vf(:,valret>ReturnDist)=[];
valret(valret>ReturnDist)=[];

% Set to nan the points following the closest one
for kkss=1:length(indrw)
X_Vf(indrw(kkss)+1:end,kkss)=nan;
Y_Vf(indrw(kkss)+1:end,kkss)=nan;
%Z_Vf(indrw(kkss)+1:end,kkss)=nan;
end

[~,ind]=sort(valret,'ascend');
indrw=indrw(ind);
xIn=X_Vf(1,:);
yIn=Y_Vf(1,:);
MatrixFin=[];

% Filter the ones which do not have a change of spiraling
InDist=0.1;                 % Avoid to scan all the set of initial conditions to find the 2 closest initial conditions to the current initial point contained in the set

for kkh=1:length(ind)
    indFull=[];
    ind12=[];sign12=0;
    %analyze each trajectory 
    x00=X_Vf(1,ind(kkh));y00=Y_Vf(1,ind(kkh));
    %find the 2 closest initial conditions on the initial set 
    AlNorDir=mod(atan2((Y_Vf(2,ind(kkh))-y00),(X_Vf(2,ind(kkh))-x00))+pi/2,2*pi);
    distan=sqrt((xIn-x00).^2+(yIn-y00).^2);
    [vald,indd]=sort(distan,'ascend');
    indd(vald>InDist)=[];
    vald(vald>InDist)=[];
    indd(vald==0)=[];
    vald(vald==0)=[];
    if ~isempty(indd)
    xn=xIn(indd(1:end));yn=yIn(indd(1:end));
    AlneighDir=mod(atan2((yn-y00),(xn-x00)),2*pi);
    dotpr=[cos(AlNorDir) sin(AlNorDir)]*[cos(AlneighDir);sin(AlneighDir)];
    Boolsd=0*AlneighDir-1;
    Boolsd(AlneighDir>AlNorDir+pi/2)=1; 
    ind12=[ind12;indd(1)];
    sign12=(Boolsd(1));
    sign12Bool=sign12*Boolsd;
    [~,inddd]=find(sign12Bool<0);

        if ~isempty(inddd)
         ind12=[ind12;indd(inddd(1))]; 
        end
    
        if length(ind12)==2
            indFull=[ind12(1);ind(kkh);ind12(2)];
          % Check the change of spiraling
          Matr=[];
          spiral=[];
          dist=[];
           for kkcs=1:length(indFull)
               indcol=indFull(kkcs);
               InN1=length(X_Vf(~isnan(X_Vf(:,indcol)),indcol));

                AlNorDircon=mod(atan2((Y_Vf(2,indcol)-Y_Vf(1,indcol)),(X_Vf(2,indcol)-X_Vf(1,indcol)))+pi/2,2*pi);
                AlneighDircon=mod(atan2((Y_Vf(InN1,indcol)-Y_Vf(1,indcol)),(X_Vf(InN1,indcol)-X_Vf(1,indcol))),2*pi);
                AlneighAbsDist=sqrt((Y_Vf(InN1,indcol)-Y_Vf(1,indcol)).^2+(X_Vf(InN1,indcol)-X_Vf(1,indcol)).^2);
                spiral=[spiral;-sign([cos(AlNorDircon) sin(AlNorDircon)]*[cos(AlneighDircon);sin(AlneighDircon)])];      

                % Distance projected along the local normal 
                locDistVec=AlneighAbsDist*[cos(AlneighDircon),sin(AlneighDircon)];
                ProjVectDist=locDistVec*[cos(AlNorDircon);sin(AlNorDircon)];
                dist=[dist;abs(ProjVectDist)];
           end
           Matr=[indFull,spiral,dist];
          %  If there is a change of spiraling, take the selected point with
          %  min return distance 
           if Matr(1,2)*Matr(2,2)<0 | Matr(3,2)*Matr(2,2)<0
               MatrixFin=[MatrixFin;Matr(2,:)];
           end
        end
    end
end

    if ~isempty(MatrixFin)
        MatrixFinal=MatrixFin;
        [~,indddd]=sort(MatrixFinal(:,1),'ascend');
        MatrixFinal=MatrixFinal(indddd,:);

        Idxtodel=[];
        for kk=1:size(MatrixFinal,1)-1
            if abs(MatrixFinal(kk+1,1)-MatrixFinal(kk,1))==1  %if they are consecutive IC discard the one with max return distance (this avoids to have the same null-geodesic twice)
                [~,idistc]=max(MatrixFinal(kk:kk+1,end));
                if idistc==2
                Idxtodel=[Idxtodel;kk+1];
                else
                Idxtodel=[Idxtodel;kk];
                end
            end
        end
        MatrixFinal(Idxtodel,:)=[];
        indFFin=MatrixFinal(:,1);
        X1lco=X_Vf(:,indFFin);
        X2lco=Y_Vf(:,indFFin);
        philco=Z_Vf(:,indFFin);

        % Final closed null-geodesics
        for kk=1:size(X1lco,2)-1
            x1=X1lco(~isnan(X1lco(:,kk)),kk);
            x2=X2lco(~isnan(X2lco(:,kk)),kk);
            x1(end)=x1(1);x2(end)=x2(1);
            X1lco(~isnan(X1lco(:,kk)),kk)=x1;
            X2lco(~isnan(X2lco(:,kk)),kk)=x2;
        end

    end
end


%% References:
%[1] Mattia Serra and George Haller, "Efficient Computation of Null-Geodesic with 
%    Applications to Coherent Vortex Detection",  sumbitted, (2016).
%%
% function [xLcOutM,yLcOutM,LamLcOutM]=FindOutermost(xPsol,yPsol,lamV,sVec);   

% Input arguments:
    % x1Psol                  : x1-component of closed null-geodesics  
    % x2Psol                  : x2-component of closed null-geodesics  
    % lamV                      : see steps 0-1
    % sVec                      : see step 3

% Output arguments:
    %   xLcOutM    : x1-component of the outermost closed null-geodesics  
    %   yLcOutM    : x2-component of the outermost closed null-geodesics  
    % LamLcOutM    : \lambda values corresponding to the outermost closed null-geodesics  
%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------
function [xLcOutM,yLcOutM,LamLcOutM]=FindOutermost(xPsol,yPsol,lamV,sVec)

NMaxPts=length(sVec);

xlcEx=[];ylcEx=[];lamfin=[];xcPos=[];ycPos=[];AreaLc=[];

for kkmuv=1:1:length(lamV)
%save all the final curves in a cell 
xxapp=xPsol{kkmuv};
yyapp=yPsol{kkmuv};
if ~isempty(xxapp)
    for kkc=1:size(xxapp,2)
        xlc=xxapp(~isnan(xxapp(:,kkc)),kkc);
        ylc=yyapp(~isnan(yyapp(:,kkc)),kkc);
        %close the curve
        xlc(end)=xlc(1); ylc(end)=ylc(1); 
        %compute the area
        Alc = polyarea(xlc,ylc);
        xlcEx=[xlcEx,[xlc(:);nan(NMaxPts-length(xlc),1)]];
        ylcEx=[ylcEx,[ylc(:);nan(NMaxPts-length(xlc),1)]];
        xCentLc=mean(xlc);yCentLc=mean(ylc);
        xcPos=[xcPos,xCentLc];ycPos=[ycPos,yCentLc];
        AreaLc=[AreaLc,Alc];
        lamfin=[lamfin,lamV(kkmuv)];
    end
end
end

% Sort the Lc in decreasing Area
[~,ind]=sort(AreaLc,'descend');
AreaLc=AreaLc(ind);
xcPos=xcPos(ind);ycPos=ycPos(ind);
xlcEx=xlcEx(:,ind);ylcEx=ylcEx(:,ind);lamfin=lamfin(ind);

% Extract the outermost 

toDel=[];
MatCheck=nan(size(xlcEx,2),size(xlcEx,2));

for kkmuv=1:1:size(xlcEx,2)
xxapp=xlcEx(~isnan(xlcEx(:,kkmuv)),kkmuv);
yyapp=ylcEx(~isnan(ylcEx(:,kkmuv)),kkmuv);
in=inpolygon(xcPos,ycPos,xxapp,yyapp);
MatCheck(kkmuv,:)=in;
end
for kkmuv=1:1:size(MatCheck,2)
    vettIdx=kkmuv+1:length(AreaLc);
    VettMat=MatCheck(kkmuv,kkmuv+1:size(MatCheck,2));
    ToDelvett=vettIdx(VettMat==1); 
    toDel=[toDel,ToDelvett];
end

toDel=unique(toDel);
xlcEx(:,toDel)=[];
ylcEx(:,toDel)=[];
lamfin(toDel)=[];


% Store the outermost closed null-geodesic
xLcOutM=cell(1,size(xlcEx,2));
yLcOutM=cell(1,size(xlcEx,2));
LamLcOutM=nan(1,size(xlcEx,2));

for kkpl=1:size(xlcEx,2)
   LamLcOutM(kkpl)=lamfin(kkpl);
   xLcOutM{kkpl}=xlcEx(~isnan(xlcEx(:,kkpl)),kkpl);
   yLcOutM{kkpl}=ylcEx(~isnan(xlcEx(:,kkpl)),kkpl);
end


end
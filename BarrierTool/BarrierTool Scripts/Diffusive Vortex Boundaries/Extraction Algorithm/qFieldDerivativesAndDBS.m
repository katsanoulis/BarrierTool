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
function [phiPrGr,qx,qy,DBS] = qFieldDerivativesAndDBS(x1_g,x2_g,qx,qy,rhox,rhoy)
qx_interp = griddedInterpolant({x1_g,x2_g},qx,'spline','linear');
qy_interp = griddedInterpolant({x1_g,x2_g},qy,'spline','linear');

phiPrGr{1,1} = qx_interp;
phiPrGr{1,2} = qy_interp;

xPlusEpsilon  = x1_g + rhox;
xMinusEpsilon = x1_g - rhox;
yPlusEpsilon  = x2_g + rhoy;
yMinusEpsilon = x2_g - rhoy;
[xPe,y0G] = ndgrid(xPlusEpsilon,x2_g);
[xMe,~]   = ndgrid(xMinusEpsilon,x2_g);
[x0G,yPe] = ndgrid(x1_g,yPlusEpsilon);
[~,yMe]   = ndgrid(x1_g,yMinusEpsilon);

qxthx = ((qx_interp(xPe,y0G)-qx_interp(xMe,y0G))/(2*rhox));
qxthy = ((qx_interp(x0G,yPe)-qx_interp(x0G,yMe))/(2*rhoy));
qythx = ((qy_interp(xPe,y0G)-qy_interp(xMe,y0G))/(2*rhox));
qythy = ((qy_interp(x0G,yPe)-qy_interp(x0G,yMe))/(2*rhoy));

qxthx_interp = griddedInterpolant({x1_g,x2_g},qxthx,'linear','linear');
qxthy_interp = griddedInterpolant({x1_g,x2_g},qxthy,'linear','linear');
qythx_interp = griddedInterpolant({x1_g,x2_g},qythx,'linear','linear');
qythy_interp = griddedInterpolant({x1_g,x2_g},qythy,'linear','linear');

phiPrGr{1,3} = qxthx_interp;
phiPrGr{1,4} = qxthy_interp;
phiPrGr{1,5} = qythx_interp;
phiPrGr{1,6} = qythy_interp;

qx = qx';
qy = qy';

DBS = sqrt(qx.*qx+qy.*qy);
end

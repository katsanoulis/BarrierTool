%% References:
%%
% function [xt,yt] = Integrator(x0,y0,tspan,options)

% Input arguments:
%   x0,y0: x- and y-components of the initial positions
%   tspan: time span for advecting particles 
%   options: options structure for ordinary differential equation solvers

% Output arguments:
%   xt: x-component of Lagrangian trajectories - size: [#times,#particles]
%   yt: y-component of Lagrangian trajectories - size: [#times,#particles]
function [xt,yt] = Integrator(x0,y0,tspan,NCores,options,u_interp,v_interp,diffusion)
Np = numel(x0);               % number of particles
x0 = x0(:); y0 = y0(:);
%% Computing the final positions of the Lagrangian particles:
if NCores == 1

    [~,F] = ode45(@ODEfun,tspan,[x0;y0],options,u_interp,v_interp);
    if diffusion
        xt = F(:,1:end/2);
        yt = F(:,end/2+1:end);
    else
        xt = F(end,1:end/2);
        yt = F(end,end/2+1:end);
    end
    
else
    cpu_num = min(NCores,Np);
    id = ceil( linspace(0,Np,cpu_num+1) );
    %- Opening MATLAB Pool
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    l = 'local';
    if isempty(poolobj)                                          % if parpool is not open
        evalc('parpool(l,cpu_num)');
    elseif (~isempty(poolobj)) && (poolobj.NumWorkers~=cpu_num)  % if parpool is not consistent with cpu_num
        delete(gcp)
        evalc('parpool(l,cpu_num)');
    end
    spmd
        Range = id(labindex)+1:id(labindex+1);
        [~,F] = ode45(@ODEfun,tspan,[x0(Range);y0(Range)],options,u_interp,v_interp);
        
        if diffusion
            xt = F(:,1:end/2);
            yt = F(:,end/2+1:end);
        else
            xt = F(end,1:end/2);
            yt = F(end,end/2+1:end);
        end
        
    end
    
    xt = cat(2,xt{:});
    yt = cat(2,yt{:});
    
end  

end

function dy = ODEfun(t,y,u_interp,v_interp)   
    Np = numel(y)/2;
    dy = zeros(2*Np,1);
    dy(1:Np,1)      = u_interp( t*ones(Np,1),y(1:Np,1),y(Np+1:2*Np,1) );
    dy(Np+1:2*Np,1) = v_interp( t*ones(Np,1),y(1:Np,1),y(Np+1:2*Np,1) );
    %dy(1:Np,1)      = u_interp( t*ones(Np,1),wrapTo2Pi(y(1:Np,1)),wrapTo2Pi(y(Np+1:2*Np,1)) );
    %dy(Np+1:2*Np,1) = v_interp( t*ones(Np,1),wrapTo2Pi(y(1:Np,1)),wrapTo2Pi(y(Np+1:2*Np,1)) );
end
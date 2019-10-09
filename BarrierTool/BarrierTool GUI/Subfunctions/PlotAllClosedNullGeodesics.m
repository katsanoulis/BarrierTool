% function PlotAllClosedNullGeodesics(x1Psol,x2Psol,x1_g,x2_g,lamV,lam2)

% Input arguments:
    % lamV : Desired set of \lambda values
    % phi0 : initial \phi value (cf. Fig. 2 of [1])
    % CGij : ij entries of the CG strain tensor 
    % x1_g  : x1 component of the spatial grid 
    % x2_g  : x2 component of the spatial grid 

%--------------------------------------------------------------------------
% Author: Mattia Serra  serram@ethz.ch
% http://www.zfm.ethz.ch/~serra/
%--------------------------------------------------------------------------
function PlotAllClosedNullGeodesics(x1Psol,x2Psol,x1_g,x2_g,lamV,lam2,trC,b_h,eulerian)
    

    % Colormap encoding different \lambda values
    csize = 128;
    cmap = jet(csize);
    % Plot properties 
    AxthicksFnt = 15;
    fontsizeaxlab = 15;
    
    check = false;
    for k = 1:length(lamV)
        if ~isempty(x1Psol{1,k})
            check = true;
        end
    end
%check = true;
    if check % If there are closed null-geodesics 

    % Initialize the figure with the FTLE plot 
    
    %figure('units','normalized','outerposition',[0 0 .5 .5]);
    if ~eulerian
    if b_h{1,1}
        fig = figure('Name','FTLE field and Elliptic Lagrangian Coherent Structures','NumberTitle','off');
        imagesc(x1_g,x2_g,log(lam2)/b_h{1,2}/2);shading interp
    else
        fig = figure('Name','Diffusion Barrier Strength field and Closed Diffusion Barriers','NumberTitle','off');
        imagesc(x1_g,x2_g,log(trC));shading interp
    end
    else
    if b_h{1,1}
        fig = figure('Name','Trace of Rate-of-Strain tensor field and Eulerian Coherent Structures','NumberTitle','off');
    else
        fig = figure('Name','Trace of Flux-Rate tensor field and Diffusive Instantaneous Barriers','NumberTitle','off');
    end
    imagesc(x1_g,x2_g,trC);shading interp
    end
    set(gca,'FontSize',AxthicksFnt,'fontWeight','normal')
    hold on
    %axis([0 4 0 1])
    set(gca,'YDir','normal')
    set(gcf,'color','w');
    set(gcf, 'Position', [0, 0, 1000, 430])
    axis equal
    xlabel('$$x$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    ylabel('$$y$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    axis equal tight 
    colormap(gca,'gray')
    hhF=colorbar(gca);
    hhF.Location='westOutside';
    hhF.FontSize=fontsizeaxlab;
    if ~eulerian
    if b_h{1,1}
        title('FTLE field and Elliptic Lagrangian Coherent Structures')
        set(get(hhF,'xlabel'),'string','$$FTLE$$','Interpreter','latex','FontWeight','normal');
    else
        title('Diffusion Barrier Strength field and Closed Diffusion Barriers')
        set(get(hhF,'xlabel'),'string','$$\log \hphantom{[} DBS(x_{0})$$','Interpreter','latex','FontWeight','normal');
    end
    else
    if b_h{1,1}
        title('Trace of Rate-of-Strain tensor field and Eulerian Coherent Structures')
        set(get(hhF,'xlabel'),'string','$$tr(S)$$','Interpreter','latex','FontWeight','normal');
    else
        title('Trace of Flux-Rate tensor field and Diffusive Instantaneous Barriers')
        set(get(hhF,'xlabel'),'string','$$tr \hphantom{[} [(\dot{T}_{t_0}^{t_0})^{-1}]$$','Interpreter','latex','FontWeight','normal');
    end
    end
    

    for kkmuv=1:1:length(lamV)
    xxapp=x1Psol{kkmuv};
    yyapp=x2Psol{kkmuv};
    ind = interp1(linspace(lamV(1),lamV(end),csize),1:csize,lamV(kkmuv),'nearest');
    if ~isempty(xxapp)
        for kkc=1:size(xxapp,2)
            xlc=xxapp(~isnan(xxapp(:,kkc)),kkc);
            ylc=yyapp(~isnan(yyapp(:,kkc)),kkc);         
            hold on
            plot(xlc,ylc,'color',cmap(ind,:),'linewidth',2.5)
        end
    end
    end
    axis equal tight

    %add a second colorbar for the \lambda values
    
    ax1=gca;
    ax1_pos = ax1.Position;
    ax2 = axes('Position',ax1_pos,...
               'XAxisLocation','bottom',...
               'YAxisLocation','left',...
               'Color','none');
           
    hhF2 = colorbar(ax2,'eastOutside');
    hhF2.FontSize=AxthicksFnt;
    if b_h{1,1}
        set(get(hhF2,'xlabel'),'string','$$\lambda$$','Interpreter','latex','FontWeight','normal');
    else
        set(get(hhF2,'xlabel'),'string','$$\mathcal{T}_0$$','Interpreter','latex','FontWeight','normal');
    end
    colormap(ax2,'jet')
    hhF2.Ticks=linspace(0,1,3);
    v_1 = num2str(lamV(1),'%.2f');
    v_2 = num2str((lamV(1)+lamV(end))/2,'%.2f');
    v_3 = num2str(lamV(end),'%.2f');
    hhF2.XTickLabel={v_1;v_2;v_3};
    set(ax2,'xtick',[])
    set(ax2,'ytick',[])
    set(ax2, 'visible', 'off') ;
    
    if ismac
        filename = fullfile(fileparts(mfilename('fullpath')), '..', '/Output/NullGeodesics.fig');
    elseif ispc
        filename = fullfile(fileparts(mfilename('fullpath')), '..', '\Output\NullGeodesics.fig');
    end
    saveas(fig,filename);
    
    else
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg(['\fontsize{13}', 'No Null Geodesics were detected for the input you have provided. '], ' Computation Error', mode);
    end
    
    
end
    
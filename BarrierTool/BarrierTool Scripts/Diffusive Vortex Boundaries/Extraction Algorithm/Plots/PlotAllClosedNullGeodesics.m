function PlotAllClosedNullGeodesics(x1Psol,x2Psol,x1_g,x2_g,lamV,trC)
% Colormap encoding different \lambda values
csize = 128;
cmap = jet(csize);
% Plot properties
AxthicksFnt = 22;
fontsizeaxlab = 22;

if ~isempty(x1Psol) % If there are closed null-geodesics
    
    % Initialize the figure with the FTLE plot
    figure();
    imagesc(x1_g,x2_g,log(trC));shading interp
    set(gca,'FontSize',AxthicksFnt,'fontWeight','normal','FontSize',fontsizeaxlab)
    hold on
    %axis([0 4 0 1])
    set(gca,'YDir','normal')
    set(gcf,'color','w');
    set(gcf, 'Position', [0, 0, 1200, 900])
    axis equal
    xlabel('$$x$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    ylabel('$$y$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    axis equal tight
    colormap(gca,'bone');
    hhF=colorbar(gca);
    hhF.Location='westOutside';
    hhF.FontSize=fontsizeaxlab;
    set(get(hhF,'xlabel'),'string','$$\log \hphantom{[} DBS(x_0)$$','Interpreter','latex','FontWeight','normal','FontSize',fontsizeaxlab);
    title('Diffusion Barrier Strength field and family of diffusive vortex boundaries','Interpreter','latex','FontWeight','normal','FontSize',fontsizeaxlab)
    set(gca,'TickLabelInterpreter', 'latex');
    set(hhF,'TickLabelInterpreter', 'latex');
    
    for kkmuv=1:1:length(lamV)
        xxapp=x1Psol{kkmuv};
        yyapp=x2Psol{kkmuv};
        ind = interp1(linspace(lamV(1),lamV(end),csize),1:csize,lamV(kkmuv),'nearest');
        if ~isempty(xxapp)
            for kkc=1:size(xxapp,2)
                xlc=xxapp(~isnan(xxapp(:,kkc)),kkc);
                ylc=yyapp(~isnan(yyapp(:,kkc)),kkc);
                hold on
                plot(xlc,ylc,'color',cmap(ind,:),'linewidth',2);
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
    set(get(hhF2,'xlabel'),'string','$$\mathcal{T}_0$$','Interpreter','latex','FontWeight','normal','FontSize',fontsizeaxlab);
    colormap(ax2,'jet');
    hhF2.Ticks=linspace(0,1,3);
    v_1 = num2str(lamV(1),'%.2f');
    v_2 = num2str((lamV(1)+lamV(end))/2,'%.2f');
    v_3 = num2str(lamV(end),'%.2f');
    hhF2.XTickLabel={v_1;v_2;v_3};
    set(ax2,'xtick',[])
    set(ax2,'ytick',[])
    set(ax2, 'visible', 'off') ;
    set(hhF2,'TickLabelInterpreter', 'latex');
end

end


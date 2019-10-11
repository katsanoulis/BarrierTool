function PlotOutmost(xLcOutM,yLcOutM,LamLcOutM,lamV,x1_g,x2_g,trC)

if ~isempty(LamLcOutM) % If there are closed null-geodesics
    % Colormap encoding different \lambda values
    csize = 128;
    cmap = jet(csize);
    
    % Plot properties
    AxthicksFnt = 22;
    fontsizeaxlab = 22;
    
    figure();
    imagesc(x1_g,x2_g,log(trC));shading interp
    set(gca,'FontSize',AxthicksFnt,'fontWeight','normal')
    hold on
    set(gca,'YDir','normal')
    set(gcf,'color','w');
    set(gcf, 'Position', [0, 0, 1200, 900])
    axis equal
    xlabel('$$x$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    ylabel('$$y$$','Interpreter','latex','FontWeight','bold','FontSize',fontsizeaxlab);
    colormap(gca,'bone')
    hhF=colorbar(gca);
    hhF.Location='westOutside';
    hhF.FontSize=fontsizeaxlab;
    set(get(hhF,'xlabel'),'string','$$\log \hphantom{[} DBS(x_0)$$','Interpreter','latex','FontWeight','normal');
    title('Diffusion Barrier Strength field and diffusive vortex boundaries','Interpreter','latex','FontWeight','normal')
    set(gca,'TickLabelInterpreter', 'latex');
    set(hhF,'TickLabelInterpreter', 'latex');
    
    % Plot outermost Closed null-geodesics
    for kkmuv=1:1:length(LamLcOutM)
        Lamidx=find(lamV==LamLcOutM(kkmuv));
        ind = interp1(linspace(lamV(1),lamV(end),csize),1:csize,lamV(Lamidx),'nearest');
        xlc=xLcOutM{kkmuv};
        ylc=yLcOutM{kkmuv};
        hold on
        plot(xlc,ylc,'color',cmap(ind,:),'linewidth',2);
    end
    axis equal tight
    
    % Add a second colorbar encoding the different \lambda values    
    ax1 = gca;
    ax1_pos = ax1.Position; % position of first axes
    ax2 = axes('Position',ax1_pos,...
        'XAxisLocation','bottom',...
        'YAxisLocation','left',...
        'Color','none');
    hhF2 = colorbar(ax2,'eastOutside');
    hhF2.FontSize = AxthicksFnt;
    set(get(hhF2,'xlabel'),'string','$$\mathcal{T}_0$$','Interpreter','latex','FontWeight','normal');
    colormap(ax2,'jet')
    hhF2.Ticks=linspace(0,1,3);
    v_1 = num2str(lamV(1),'%.2f');
    v_2 = num2str((lamV(1)+lamV(end))/2,'%.2f');
    v_3 = num2str(lamV(end),'%.2f');
    hhF2.XTickLabel={v_1;v_2;v_3};
    set(ax2,'xtick',[])
    set(ax2,'ytick',[])
    set(ax2, 'visible', 'off');
    set(hhF2,'TickLabelInterpreter', 'latex');
end

end

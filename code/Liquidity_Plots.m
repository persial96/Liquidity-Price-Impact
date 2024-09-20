%% Funzione per la creazione dei plot delle superfici di liquidità.

function [Surface_Sigma] = Liquidity_Plots(l_size, tao, C_vol, names, isin, subtitle)

    % Definizione delle dimensioni dell'output.
    Surface_Sigma = figure('Name','Liquidity Surface', ...
        'position', ...
        [900  900   1500   2000]);
    
    % Creazione delle superfici.
    [X,Y] = meshgrid(l_size, tao) ;
    surf(X, Y, C_vol')
    set(gca,'FontSize',24)

    % Definizione titoli e sottotitoli (con dimensioni).
    % Caso "per ogni titolo".
    if subtitle == 1

        [Pt, Ps] = title(sprintf(string(names)),sprintf(string(isin)));
        Pt.FontSize = 28;
        Ps.FontSize = 22;
        Ps.FontAngle = 'italic';

    % Caso "per ogni portafoglio".
    else
              
        Pt = title(sprintf(string(names)));
        Pt.FontSize = 32;

    end

    % Definizione assi (con dimensioni).
    xlabel('Size (in %)','FontSize', 28);
    ylabel('Time (in days)','FontSize', 28);
    zlabel('Costo (in $)','FontSize', 28);
    ax = gca;
    ax.ZAxis.Exponent = 0;

end
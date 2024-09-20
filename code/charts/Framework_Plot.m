%% FRAMEWORK PER GRAFICI.

function [Surface] = Framework_Plot(name_funds_BCC_RP, l_size, tao, IP_Titoli, IP_PTF, subtitle, empty, all_assets, PROP_o_NP)

    % Loop per ogni portafoglio.
    for i = 1 : 1 : length(name_funds_BCC_RP)

        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(i)), 'Sheet', string(name_funds_BCC_RP(i)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};

        switch PROP_o_NP

            case 'PROP'

                % Plot di ogni titolo.
                if all_assets == 1

                    % Loop per ogni titolo.
                    for j = 1 : 1 : length(titles)

                        % Carico la funzione Liquidity_Plots.
                        [Surface] = Liquidity_Plots(l_size, ...
                                                          tao, ...
                                                          IP_Titoli.(name_funds_BCC_RP{i}).(titles{j}), ...
                                                          name_funds_BCC_RP(i), ...
                                                          titles(j), ...
                                                          subtitle);

                    end

                % Plot di ogni portafoglio.
                elseif all_assets == 0

                        % Carico la funzione Liquidity_Plots.
                        [Surface] = Liquidity_Plots(l_size, ...
                                                       tao, ...
                                                       IP_PTF.(name_funds_BCC_RP{i}), ...
                                                       name_funds_BCC_RP(i), ...
                                                       empty, ...
                                                       subtitle);

                end


            case 'NP'

                % Nel NEAR PROPORTIONAL ha senso fare il plot solo di ogni portafoglio.
                % Carico la funzione Liquidity_Plots.
                [Surface] = Liquidity_Plots(l_size, ...
                    tao, ...
                    IP_PTF.(name_funds_BCC_RP{i}), ...
                    name_funds_BCC_RP(i), ...
                    empty, ...
                    subtitle);

        end

    end
    
end

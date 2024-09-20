%% LIQUIDATION COST.

function [Liquidation_Cost] = LC_Fun(name_funds_BCC_RP, Metaorder_Finale_byISIN, all_Ptf_structure, l_size)
    
    % ------------------------------------------------------------------------------------------
    % Funzione che calcola il Liquidation Cost (LC) utilizzando i metaorder
    % simulati e la funzione di Bloomberg (2018) per l'LC.
    % NB: l'ipotesi è che i liquidation cost nel nostro caso devono essere ponderati per
    % il vettore di size [5% - 100%] definito alla base del modello.
    % OUTPUT PRINCIPALI:
    % > Liquidation_Cost, struttura che contiene i LC per ogni titolo di ciascun protafoglio.
    % ------------------------------------------------------------------------------------------
    
    % Pulizia per evitare re-writing.
    clear Liquidation_Cost

    % Loop per ogni portafoglio.
    for k = 1 : 1 : length(name_funds_BCC_RP)
        
        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(k)), 'Sheet', string(name_funds_BCC_RP(k)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};
        fund = readtable(string(name_funds_BCC_RP(k)), 'VariableNamingRule', 'preserve');
        
        % Loop per ogni titolo.
        for i = 1 : 1 : (size(fund,1)-1)
            %% Liquidation Cost.
            Metaorder = Metaorder_Finale_byISIN.(name_funds_BCC_RP{k}).(titles{i});
            
            % Controllare la size.
            totale_quantita_metaorder = sum(Metaorder.Traded_Quantity);
            
            % Prendo i Mid.
            asset_mid_prices = all_Ptf_structure.(name_funds_BCC_RP{k}).(titles{i}).MID(end);
            
            % Inizializzo la variabile summ_C per la sommatoria.
            summ_C = 0;
            
            % Formula Cost Liquidation Bloomberg.
            for kn = 1 : 1 : size(Metaorder, 1)
                
                summ_C = (summ_C + ...
                    ((((Metaorder.Traded_Quantity(kn)) * ...
                    Metaorder.Execution_Price(kn))/(totale_quantita_metaorder))));
                
            end
            
            summ_C = abs((summ_C - asset_mid_prices)/asset_mid_prices);
            
            % Struttura di supporto per ogni titolo.
            cl_store.(titles{i}) = summ_C * l_size';

            % Pulizia per evitare re-writing.
            clear summ_C            
            
        end
                                
        % STRUTTURA FINALE DEL LIQUIDATION COST.
        Liquidation_Cost.(name_funds_BCC_RP{k}) = cl_store;
        
        % Pulizia per evitare re-writing.
        clear cl_store

    end
    
end
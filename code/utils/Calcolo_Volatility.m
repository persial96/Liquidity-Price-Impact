%% CALCOLO VOLATILITA'.

function [vol_asset_prices_year, vol_asset_prices, drift_term] = Calcolo_Volatility(name_funds_BCC_RP, all_Ptf_structure)

    % ------------------------------------------------------------------------------------------
    % Funzione che calcola la volatilità per ogni titolo in portafoglio.
    % OUTPUT PRINCIPALI:
    % > vol_asset_prices_year, matrice contenente la volatilità
    %   ANNUALIZZATA per ogni titolo (in realtà non utilizzata)
    % > vol_asset_prices, matrice contenente la volatilità DAILY per ogni titolo.
    % > drift_term, stima di un termine di drift (media dei rendimenti del
    %   titolo). Utilizzano nel Brownian Bridge.
    % ------------------------------------------------------------------------------------------

    % Loop per ogni portafoglio.
    for k =  1:1:length(name_funds_BCC_RP)

        % Definisco le variabili fund e titles: la prima contiene il fondo che si sta analizzando, la seconda contiene i titoli presenti in
        % quel fondo, definiti per ISINCODE.
        fund = readtable(string(name_funds_BCC_RP(k)), 'Sheet', string(name_funds_BCC_RP(k)), 'VariableNamingRule', 'preserve');
        titles = fund{1:end-1, "ISINCODE"};

        % Loop per ogni titolo.
        for h = 1:1:length(titles)
            
            % Carico i prezzi close per ogni titolo.
            asset_prices = all_Ptf_structure.(name_funds_BCC_RP{k}).(titles{h}).CLOSE;

            % Sostituisco gli NaN (se presenti) tramite opzione lineare.
            asset_prices = fillmissing(asset_prices, 'linear');
            
            % Calcolo i rendimenti (tick2ret).
            returns_asset_prices = tick2ret(asset_prices);
            
            % Calcolo il drift che utilizzerò per il Brownian Bridge (come stima utilizzo la media daily dei rendimenti).
            drift_term(k,h) = mean(returns_asset_prices)/sqrt(252);
            
            % Calcolo la volatilità.
            summ = 0;
            for i = 1:1:length(returns_asset_prices)
                summ = summ + (returns_asset_prices(i) - mean(returns_asset_prices))^2;
            end

            % Definisco la volatilità annualizzata.
            vol_asset_prices_year(k,h) = sqrt((252/(length(returns_asset_prices)-1))  * summ);
            
        end

        % Pulizia per evitare sovrascrizione variabile.
        clear asset_prices

    end

    % Calcolo la daily volatility.
    vol_asset_prices = vol_asset_prices_year/sqrt(252);
    
end
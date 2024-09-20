%% Funzione che include l'equazione di Bloomberg (2018) per il calcolo dell'Impact Price.

function [price_impact, aleatory_bis] = Liquidity_ModelFramework(gamma, ...
                                                                 delta, ...
                                                                 eta, ...
                                                                 tot_shares, ...
                                                                 l_size, ...
                                                                 VE, ...
                                                                 sd_S, ...
                                                                 tao, ...
                                                                 PbP, ...
                                                                 market_cap, ...
                                                                 avg_market_cap, ...
                                                                 nu, ...
                                                                 aleatory)
                                                             
                                                             
    % -------------------------------------------------------------------------------------------------
    % Funzione per il calcolo effettivo dell'Impact Price. Include
    % l'equazione (10) di Bloomberg (2018). Due casi: PbP == 1, allora
    % calcolo in termini vettoriali; PbP == 0, allora calcolo in termini
    % numerici.
    % OUTPUT PRINCIPALI:
    % > price_impact.
    % > aleatory_bis, per lo storing della componente aleatoria,
    % --------------------------------------------------------------------------------------------------
    
    % Inizializzazione delle variabili di storing.
    deterministic = nan(length(l_size), length(tao));
    price_impact = nan(length(l_size), length(tao));

    % Lavoro in termini vettoriali.
    if PbP == 1
        
        % Loop per ogni size.
        for i = 1:length(l_size)
            
            % Loop per ogni tao.
            for j = 1:length(tao)
                                
                % Calcolo della componente deterministica.
                deterministic(i,j) = (sd_S * ((eta)/((1-gamma)*(2-gamma))) * ...
                                     (((l_size(i)*tot_shares)/VE)^delta) * (tao(j))^(1-delta-gamma)) * (market_cap/avg_market_cap)^nu;
                
                % Caricamento della componente aleatoria.                
                aleatory_bis = aleatory;
                
                % Calcolo del price impact finale.
                price_impact(i,j) = deterministic(i,j)*aleatory_bis;
                                                            
            end
            
        end
     
    % Lavoro in termini numerici.    
    else
        
        % Calcolo della componente deterministica.
        deterministic = (sd_S * ((eta)/((1-gamma)*(2-gamma))) * ...
                        (((l_size*tot_shares)/VE)^delta) * (tao)^(1-delta-gamma)) * (market_cap/avg_market_cap)^nu;
        
        % Caricamento della componente aleatoria.            
        aleatory_bis = aleatory;
        
        % Calcolo del price impact finale.
        price_impact = deterministic*aleatory_bis;
        
        
    end

end
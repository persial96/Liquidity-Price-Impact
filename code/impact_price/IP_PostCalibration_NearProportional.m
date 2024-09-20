%% Funzione per calcolo dell'Impact Price con PARAMETRI CALIBRATI e caso NEAR PROPORTIONAL.

function [Final_After_Calibration_NP] = IP_PostCalibration_NearProportional(name_funds_BCC_RP, fund, Aleatory_Store_Decomposed, all_Ptf_structure, Final_Calibrated_Gamma_vsMSCI, Final_Calibrated_Delta_vsMSCI, Final_Calibrated_eta_vsMSCI, Size_Liquidation_NearProportional, vol_asset_prices, tao, PbP, l_size, PV_store)

    % ------------------------------------------------------------------------------------------
    % Calcolo Impact Price con parametri calibrati e caso NEAR
    % PROPORTIONAL. Tao può essere maggiore di 1.
    % OUTPUT PRINCIPALI:
    % > Final_After_Calibration_NP, struttura finale che contiene i
    %   gli impact price per ogni titolo.
    % ------------------------------------------------------------------------------------------


    % Pulizia per evitare re-writing.
    clear fund_per_titoli titles kn n
    
    % Inizializzazione delle variabili di supporto.
    store_check_volume = nan(length(name_funds_BCC_RP), size(fund,1)-1);
    store_check_volume_daily = nan(length(name_funds_BCC_RP), size(fund,1)-1);

    % Loop per ogni portafoglio.
    for j = 1 : 1 : length(name_funds_BCC_RP) 

        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};
        fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        
        % Loop per ogni size.
        for kn = 1 : 1 : length(l_size)

            % Loop per ogni tao.
            for n = 1 : 1 : length(tao)

                % Loop per ogni titolo.
                for i = 1 : 1 : (size(fund,1)-1)

                    % Caricamento della componente aleatoria dalla struttura.
                    aleatory = Aleatory_Store_Decomposed.(name_funds_BCC_RP{j}).(titles{i});

                    % Definizione della variabile che contiene il numero di azioni detenute dell'i-esimo titolo.
                    tot_shares = fund.AzioniValore_Nomi(i);

                    % Caricamento dei Volumi (V) e dell'Expected Daily Volume (VE).
                    [VE, V] = Lettura_Volumi_perIP(fund, ...
                                                   all_Ptf_structure, ...
                                                   j, ...
                                                   i, ...
                                                   name_funds_BCC_RP, ...
                                                   titles);

                    % Store dei volumi.
                    store_check_volume(j,i) = VE;
                    store_check_volume_daily(j,i) = V;

                    % Definizione Market Cap, Average Market Cap e nu (parametro non calibrato fissato = 1).
                    market_cap = fund.Market_CAP(i);
                    avg_market_cap = sum(fund.Market_CAP) / (size(fund,1)-1);
                    nu = 1;
                    
                    % Caricamento dei parametri calibrati dalle rispettive strutture.
                    gamma = Final_Calibrated_Gamma_vsMSCI.(name_funds_BCC_RP{j}).(titles{i});
                    delta = Final_Calibrated_Delta_vsMSCI.(name_funds_BCC_RP{j}).(titles{i});
                    eta = Final_Calibrated_eta_vsMSCI.(name_funds_BCC_RP{j}).(titles{i});

                    % Calcolo dell'impact price per ogni size e per ogni tao per l'i-esimo titolo.
                    Calibrated_Results  = Liquidity_ModelFramework(gamma, ...
                                                                   delta, ...
                                                                   eta, ...
                                                                   tot_shares, ...
                                                                   Size_Liquidation_NearProportional.(name_funds_BCC_RP{j}).(['Size',num2str(kn)]).(['OrizzonteTemporaleDay',num2str(n)])(i), ...
                                                                   VE, ...
                                                                   vol_asset_prices(j,i), ...
                                                                   tao(n), ...
                                                                   PbP, ...
                                                                   market_cap, ...
                                                                   avg_market_cap, ...
                                                                   nu, ...
                                                                   aleatory);

                    % % STORING DELL'IMPACT PRICE.
                    % Struttura di supporto.
                    Calibrated_Results_byISIN.(titles{i})(kn,n) = Calibrated_Results * PV_store(j,i);

                    % Pulizia per evitare re-writing.
                    clear Calibrated_Results

                end

            end

        end

        % % STORING DELLE STRUTTURE FINALI.
        % Struttura IP per ogni titolo nel caso Near Proportional:
        Final_After_Calibration_NP.(name_funds_BCC_RP{j}) = Calibrated_Results_byISIN;    

        % Pulizia per evitare re-writing.
        clear Calibrated_Results_byISIN fund titles fund_per_titoli

    end
    
end
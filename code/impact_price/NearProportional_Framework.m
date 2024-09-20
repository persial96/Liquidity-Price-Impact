%% MAIN Near Proportional.

function Size_Liquidation_NearProportional = NearProportional_Framework(name_funds_BCC_RP, ...
    IP_Weights_Final, Final_Calibrated_Gamma_LC, Final_Calibrated_Delta_LC, Final_Calibrated_eta_LC, Aleatory_Store_Decomposed, ...
    store_check_volume, vol_asset_prices, tao, l_size)

    % ------------------------------------------------------------------------------------------
    % Main per il caso NEAR PROPORTIONAL.
    % OUTPUT PRINCIPALI:
    % > Size_Liquidation_NearProportional, struttura finale che contiene le size ottimizzate
    %   per la liquidazione in caso NP.
    % ------------------------------------------------------------------------------------------
    
    % Pulizia per evitare sovrascrizione variabili.
    clear Size_Liquidation_NearProportional

    % Loop per ogni portafoglio.
    for j = 1 : 1 : length(name_funds_BCC_RP) 

        % Definizione di una variabile che varia l'intervallo di Near
        % Proportional in modo lineare come segue:
        %     > LB = l_size - (0.01 * unit)
        %     > UB = l_size + (0.01 * unit)  
        unit = 0;

        % Loop per ogni size.
        for kk = 1 : 1 : length(l_size)

            % Considero la size da utilizzare e incremento la variabile unit.
            l_size_func = l_size(kk);
            unit = unit + 1;

            % Loop per ogni tao.
            for n = 1 : 1 : length(tao)

                % Considero il tao da utilizzare.
                tao_func = tao(n);
                
                % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
                fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
                titles = fund_per_titoli{1:end-1, "ISINCODE"};
                fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
                
                % Inizializzo le matrici che utilizzerò nella funzione di calibrazione.
                Pesi_ImpactPrice = nan(size(fund,1)-1, 1);
                tot_shares_ImpactPrice = nan(size(fund,1)-1, 1);
                gamma_ImpactPrice = nan(size(fund,1)-1, 1);
                delta_ImpactPrice = nan(size(fund,1)-1, 1);
                eta_ImapactPrice = nan(size(fund,1)-1, 1);
                market_cap_ImpactPrice = nan(size(fund,1)-1, 1);
                avg_market_cap_ImpactPrice = nan(size(fund,1)-1, 1);
                aleatory_ImpactPrice = nan(size(fund,1)-1, 1);
                
                
                % Loop per ogni titolo.
                for i = 1 : 1 : (size(fund,1)-1)

                    % Ogni variabile della funzione obiettivo (che è la funzione del calcolo IP di Bloomberg (2018) ripetuta
                    % per i titolo in portafoglio) viene definita come matrice o vettore (fmincon non può leggere strutture).
                    Pesi_ImpactPrice(i) = IP_Weights_Final.(name_funds_BCC_RP{j}).(titles{i});
                    tot_shares_ImpactPrice(i) = fund.AzioniValore_Nomi(i);
                    gamma_ImpactPrice(i) = Final_Calibrated_Gamma_LC.(name_funds_BCC_RP{j}).(titles{i});
                    delta_ImpactPrice(i) = Final_Calibrated_Delta_LC.(name_funds_BCC_RP{j}).(titles{i});
                    eta_ImapactPrice(i) = Final_Calibrated_eta_LC.(name_funds_BCC_RP{j}).(titles{i});
                    market_cap_ImpactPrice(i) = fund.Market_CAP(i);
                    avg_market_cap_ImpactPrice(i) = sum(fund.Market_CAP) / (size(fund,1)-1);
                    nu = 1;
                    aleatory_ImpactPrice(i) = Aleatory_Store_Decomposed.(name_funds_BCC_RP{j}).(titles{i});
                    
                end
                
                % Calcolo delle size di liquidazione Near Proportional caricando la funzione Calibration_Function_NP.
                [Size_Store, ~] = Calibration_Function_NP(name_funds_BCC_RP, ...
                                                           Pesi_ImpactPrice, ...
                                                           tot_shares_ImpactPrice, ...
                                                           gamma_ImpactPrice, ...
                                                           delta_ImpactPrice, ...
                                                           eta_ImapactPrice, ...
                                                           market_cap_ImpactPrice, ...
                                                           avg_market_cap_ImpactPrice, ...
                                                           aleatory_ImpactPrice, ...
                                                           store_check_volume(j,:), ...
                                                           vol_asset_prices(j,:), ...
                                                           l_size_func, ...
                                                           tao_func, ...
                                                           nu, ...
                                                           unit);
                
                % Stuttura di supporto.
                Store_perTao.(['OrizzonteTemporaleDay',num2str(n)]) = Size_Store';
                
                % Pulizia.
                clear Size_Store

            end

            % Struttura di supporto.
            Store_perSize.(['Size',num2str(kk)]) = Store_perTao;

            % Pulizia.
            clear Store_perTao

        end

        % % STRUTTURA FINALE.
        % Definisco una struttura che contiene le size da utilizzare per calcolare l'IP nel caso Near Proportional, divise per portafoglio, per titolo, 
        % per size e per orizzonte temporale (tao).
        Size_Liquidation_NearProportional.(name_funds_BCC_RP{j}) = Store_perSize;

        % Pulizia.
        clear Store_perSize
        
    end
          
end
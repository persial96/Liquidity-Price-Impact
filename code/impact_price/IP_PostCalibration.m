%% Funzione per calcolo Impact Price con PARAMETRI CALIBRATI e caso PROPORTIONAL.

function [ImpactPrice_PostCalibration_vsMSCI, ImpactPrice_PostCalibration_PTF_vsMSCI] = IP_PostCalibration(name_funds_BCC_RP, Aleatory_Store_Decomposed, all_Ptf_structure, Final_Calibrated_Gamma_vsMSCI, Final_Calibrated_Delta_vsMSCI, Final_Calibrated_eta_vsMSCI, vol_asset_prices, l_size, tao, fund, PbP, PV_store, Surface) 
    
    % -------------------------------------------------------------------------------------------------
    % Funzione che calcolo l'Impact Price per ogni titolo dei portafoglio con parametri
    % calibrati. NB: siamo nel caso PROPORTIONAL, tao può essere maggiore di 1 (dipende 
    % dalla sezione del main).
    % OUTPUT PRINCIPALI:
    % > ImpactPrice_PostCalibration_vsMSCI, struttura con gli IP calibrati per ogni titolo.
    % > ImpactPrice_PostCalibration_PTF_vsMSCI, struttura con gli IP calibrati per ogni portafoglio.
    % --------------------------------------------------------------------------------------------------
    
    % Pulizia per evitare re-writing.
    clear ImpactPrice_PostCalibration_vsMSCI ImpactPrice_PostCalibration_PTF_vsMSCI fund_per_titoli titles
    
    % Inizializzazione delle variabili di supporto.
    weights = nan(length(name_funds_BCC_RP), 1);
    IP_result_ptf = zeros(length(l_size),length(tao),length(name_funds_BCC_RP));
    store_check_volume = nan(length(name_funds_BCC_RP), size(fund,1)-1);
    store_check_volume_daily = nan(length(name_funds_BCC_RP), size(fund,1)-1);

    % % LOOP PER OGNI PORTAFOGLIO.
    for j = 1 : 1 : length(name_funds_BCC_RP)
        
        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};
        fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        
        % % LOOP PER OGNI TITOLO.
        for i = 1 : 1 : (size(fund,1)-1)
            
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
            
            % Calcolo dell'Impact Price calibrato per l'i-esimo titolo.
            Calibrated_Results  = Liquidity_ModelFramework(gamma, ...
                                                           delta, ...
                                                           eta, ...
                                                           tot_shares, ...
                                                           l_size, ...
                                                           VE, ...
                                                           vol_asset_prices(j,i), ...
                                                           tao, ...
                                                           PbP, ...
                                                           market_cap, ...
                                                           avg_market_cap, ...
                                                           nu, ...
                                                           aleatory);
             
            % Calcolo dei pesi.
            weights(i) = fund.Valore_Mercato_Euro(i)/fund.Valore_Mercato_Euro(end); 
            
            % % STORING DELL'IMPACT PRICE CALIBRATO.
            switch Surface
                                 
                  case 'SI'
                
                    % Struttura di supporto.
                    Calibrated_Results_byISIN.(titles{i}) = Calibrated_Results * PV_store(j,i);
                                
                    % % CALCOLO DELL'IMPACT PRICE DI PORTAFOGLIO.
                    IP_result_ptf(:,:,j) = IP_result_ptf(:,:,j) + weights(i) .* (Calibrated_Results * PV_store(j,i));

                  case 'NO'
                
                    % Struttura di supporto.
                    Calibrated_Results_byISIN.(titles{i}) = Calibrated_Results;
                    
                    % % CALCOLO DELL'IMPACT PRICE DI PORTAFOGLIO.
                    IP_result_ptf(:,:,j) = IP_result_ptf(:,:,j) + weights(i) .* (Calibrated_Results);                    
            
            end
            
            % Pulizia per evitare re-writing.
            clear Calibrated_Results
            
        end
        
        % % STORING DELLE STRUTTURE FINALI.
        % Struttura IP calibrato per ogni titolo:
        ImpactPrice_PostCalibration_vsMSCI.(name_funds_BCC_RP{j}) = Calibrated_Results_byISIN;
        % Struttura IP di portafoglio calibrato:
        ImpactPrice_PostCalibration_PTF_vsMSCI.(name_funds_BCC_RP{j}) = IP_result_ptf(:,:,j);
        
        % Pulizia per evitare re-writing.
        clear Calibrated_Results_byISIN titles fund_per_titoli
        
    end
    
end

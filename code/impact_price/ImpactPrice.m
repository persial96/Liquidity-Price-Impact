%% Funzione per calcolo dell'Impact Price con parametri NON CALIBRATI e caso PROPORTIONAL.

function [IP_Ptf, IP_Ptf_MSCI, IP_Weights_Final, IP_Ptf_Decomposed, volume_final, Aleatory_Store_Decomposed, store_check_volume] = ImpactPrice(l_size, fund, tao, name_funds_BCC_RP, IP_Decomposed_MSCI, gamma, delta, eta, all_Ptf_structure, vol_asset_prices, PbP)

    % ------------------------------------------------------------------------------------------
    % Funzione che calcolo l'Impact Price per ogni titolo dei portafoglio con parametri non
    % calibrati. NB: siamo nel caso PROPORTIONAL, con tao = 1 e size = [5%,..., 100%].
    % OUTPUT PRINCIPALI:
    % > IP_Ptf, struttura con gli IP per ogni portafoglio.
    % > IP_Ptf_MSCI, recuperiamo la struttura di IP per ogni portafoglio di MSCI.
    % > IP_Ptf_Decomposed, struttura con gli IP per ogni titolo.
    % > IP_Weights_Final, struttura con i pesi di ogni titolo all'intorno
    %   del sample del fondo considerato (20 titoli).
    % > volume_final, struttura con gli Expected Daily Volume per ogni titolo.
    % > Aleatory_Store_Decomposed, struttura per storing della componente
    %   aleatoria per ogni titolo (necessaria per evitare sovrascrizioni).
    % > store_check_volume, matrice con gli Expected Daily Volume per ogni
    %   titolo. NB: ridondanza con volume_final.
    % ------------------------------------------------------------------------------------------
    
    % Pulisco le strutture di output (necessario qualora si dovesse runnare solo questa parte del modello).
    clear IP_Ptf_Decomposed Aleatory_Store_Decomposed
    
    % Inizializzazione delle variabili di supporto.
    IP_result = nan(length(l_size),length(tao),size(fund,1)-1);
    weights = nan(length(name_funds_BCC_RP), 1);
    IP_result_ptf = zeros(length(l_size),length(tao),length(name_funds_BCC_RP));
    IP_result_ptf_MSCI = zeros(length(l_size),length(tao),length(name_funds_BCC_RP));
    store_check_volume = nan(length(name_funds_BCC_RP), size(fund,1)-1);
    store_check_volume_daily = nan(length(name_funds_BCC_RP), size(fund,1)-1);

    % CICLO IMPACT PRICE.
    % Loop per ogni portafoglio.
    for j = 1 : 1 : length(name_funds_BCC_RP) 

        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};
        fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');

        % Loop per ogni titolo.
        for i = 1 : 1 : (size(fund,1)-1)

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

                % Definizione della variabile aleatoria come estrazione di una lognormale come specificato in Bloomberg (2018).
                aleatory = lognrnd(-((vol_asset_prices(j,i))^2)/2, vol_asset_prices(j,i));

                % Calcolo dell'impact price per ogni size per l'i-esimo titolo.
                [C_vol, aleatory_out] = Liquidity_ModelFramework(gamma, ...
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

                % % STORING DELL'IMPACT PRICE.
                IP_result(:,:,i) = C_vol;
                % Struttura di supporto per l'impact price dell'i-esimo titolo.
                IP_all.(titles{i}) = IP_result(:,:,i);

                % Calcolo del peso dell'i-esimo titolo in portafoglio.
                weights(i) = fund.Valore_Mercato_Euro(i)/fund.Valore_Mercato_Euro(end);

                % % CALCOLO DELL'IMPACT PRICE DI PORTAFOGLIO.
                IP_result_ptf(:,:,j) = IP_result_ptf(:,:,j) + weights(i) * IP_result(:,:,i);
                % Recupero il calcolo dell'impact price di portafoglio anche per MSCI (nell'estrazione prima dell'inizio del loop abbiamo 
                % solo l'IP dei singoli titoli di MSCI).
                IP_result_ptf_MSCI(:,:,j) = IP_result_ptf_MSCI (:,:,j) + weights(i) * IP_Decomposed_MSCI.(name_funds_BCC_RP{j}).(titles{i});

                % % STORING DEI PESI.
                % Struttura di supporto.
                IP_weights.(titles{i}) = weights(i);

                % % STORING DEI VOLUMI.   
                % Struttura di supporto.
                volume_all.(titles{i}) = VE;

                % % STORING DELLA COMPONENTE ALEATORIA (per evitare di estrarla nuovamente per successivi calcoli dell'IP con i parametri calibrati).
                % Struttura di supporto.
                Aleatory_Store.(titles{i}) = aleatory_out;          

                % Pulizia per evitare re-writing.
                clear VE aleatory_out

        end

        % % STORING DELLE STRUTTURE FINALI.
        % Struttura IP di portafoglio:
          IP_Ptf.(name_funds_BCC_RP{j}) = IP_result_ptf(:,:,j);                  % % - Modello
          IP_Ptf_MSCI.(name_funds_BCC_RP{j}) = IP_result_ptf_MSCI(:,:,j);        % % - Benchmark
        % Struttura dei pesi:
          IP_Weights_Final.(name_funds_BCC_RP{j}) = IP_weights;
        % Struttura IP dei singoli titoli:
          IP_Ptf_Decomposed.(name_funds_BCC_RP{j}) = IP_all;
        % Struttura dei volumi:
          volume_final.(name_funds_BCC_RP{j}) = volume_all;
        % Struttura della componente aleatoria per ogni titolo:
          Aleatory_Store_Decomposed.(name_funds_BCC_RP{j}) = Aleatory_Store;    

        % Pulizia per evitare re-writing.
        clear IP_all IP_weights volume_all titles fund_per_titoli Aleatory_Store
            
    end

end

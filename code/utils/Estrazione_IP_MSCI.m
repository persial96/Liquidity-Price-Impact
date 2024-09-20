%% Estrazione Impact Price Modello MSCI.

function [IP_Decomposed_MSCI, matrix_IP_MSCI, PV_store] = Estrazione_IP_MSCI(l_size, name_funds_BCC_RP)

    % ------------------------------------------------------------------------------------------
    % Funzione che estrae gli impact price del modello MSCI diviso per size (5%, ..., 100%) 
    % dal foglio excel _Dati_Liquidazione_Attivi_20220630.xlsx e calcola l'impact price 
    % di portafoglio come una media pesata degli impact price dei singoli titoli.
    % OUTPUT PRINCIPALI:
    % > IP_Decomposed_MSCI, struttura contenente gli Impact Price del modello MSCI 
    %   per ogni titolo di ciascun portafoglio.
    % > matrix_IP_MSCI, matrice contenente gli Impact Price del modello MSCI 
    %   divisto per ogni portafoglio (in realtà non utilizzata).
    % > PV_store, present value di ogni titolo.
    % ------------------------------------------------------------------------------------------
    
    % Inizializzo.
    matrix_IP_MSCI = nan(length(l_size),length(name_funds_BCC_RP));

    % Loop per ogni portafoglio.
    for k = 1 : 1 : length(name_funds_BCC_RP)

        % Carico Dati.
        sum_extension_1 = "Main__PTF_";
        sum_extension_2 = "_position_2022063";
        raw = readtable("_Dati_Liquidazione_Attivi_20220630.xlsx",'Sheet', ...
            [sum_extension_1 + string(name_funds_BCC_RP(k)) + sum_extension_2], 'VariableNamingRule', 'preserve');

        % Cambio nomi colonne per estrazione.
        raw.Properties.VariableNames(1:8) = ["Level","Name","ISIN", "Amount", "Gross_Notional_Holding", "Gross_Notional_Report", "PV", "Present_Value"];

        % Ottengo tabella finale.
        raw_modelled = raw(:, [2, 3, 4, 6, 7, 13, 16, 19, 22, 25, 28]); 

        % Estrazione ISIN.
        ISIN = raw_modelled.ISIN;
        ISIN_new = ISIN(cellfun('isempty', strfind(ISIN,'RIC')));
        ISIN_final = ISIN_new(cellfun('isempty', strfind(ISIN_new,'Unspecified')));

        % Pulizia ISIN.
        match = ["%", "ISIN", "/"];
        ISIN_cleaned = erase(ISIN,match);

        % Definisco il raw che contiene solo gli ISIN che sono presenti nel portafoglio j-esimo.
        raw_modelled.ISIN = ISIN_cleaned;

        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(k)), 'Sheet', string(name_funds_BCC_RP(k)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};

        % Pulisco gli ISIN.
        idx = contains(raw_modelled.ISIN, titles);
        new_raw = [raw_modelled(1,:); raw_modelled(idx, :)]; 
        idx_ISIN_only = contains(ISIN_cleaned, titles);
        new_ISIN = ISIN_cleaned(idx_ISIN_only, :);
        new_raw.ISIN = [""; new_ISIN];
        % Raw finale ordinato per peso di ogni titolo.
        final_raw = sortrows(new_raw, 4, 'descend');
               
        % Carico l'IP di MSCI ad 1 giorno.
        impact_price_MSCI = nan(1, length(l_size));
        
        % Definisco una matrice che contiene tutti gli IP di MSCI (per ogni size).
        for_computation = table2array(final_raw(:,6:11));
        
        % Inizializzo una matrice per il for.
        impact_price_temporaneo = nan(length(l_size), length(titles));
        
        % Loop per ogni titolo.
        for h = 1 : 1 : size(for_computation,1)-1
            
            % Loop per ogni size.
            for i = 1 : 1 : size(for_computation,2)
                
                % Storing dell'IP di MSCI diviso per il present value del titolo.
                impact_price_temporaneo(i,h) = for_computation(h,i) / (final_raw.PV(h));
                impact_price_MSCI(i) = for_computation(1,i) / (final_raw.PV(1));
                
            end
            
            PV_store(k,h) = final_raw.PV(h);
            
            % Struttura di supporto.
            impact_price_MSCI_Decomposed.(titles{h}) = impact_price_temporaneo(:,h);
            
        end

        % % STRUTTURA IN OUTPUT.
        IP_Decomposed_MSCI.(name_funds_BCC_RP{k}) = impact_price_MSCI_Decomposed;

        % Questa matrice contiene gli IP di MSCI per ogni portafoglio, ma in realtà non è utile per l'analisi perché considera tutti gli
        % ISIN di un singolo portafoglio.
        matrix_IP_MSCI(:,k) = impact_price_MSCI';

        % Pulizia di variabili per evitare sovrascrizioni.
        clear raw impact_price_MSCI fund_per_titoli titles impact_price_MSCI_Decomposed

    end

end
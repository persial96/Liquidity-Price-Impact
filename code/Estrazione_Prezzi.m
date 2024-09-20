%% Funzione Estrazione Prezzi (mid, open, close, high, low) e Volumi dei titoli.

function all_Ptf_structure = Estrazione_Prezzi(name_funds_BCC_RP, extension)

    % ------------------------------------------------------------------------------------------
    % Funzione che estrae i prezzi mid, open, close e volumi per ogni titolo
    % dei portafogli e costruisce una struttura che contiene i valori ordinati.
    % OUTPUT PRINCIPALI:
    % > all_Ptf_structure, struttura core del codice in quanto contiene 
    %   i prezzi (H,L,O,C,Mid) e i volumi per ogni titolo di ciascun portafoglio.
    % ------------------------------------------------------------------------------------------
    
    % Loop per ogni portafoglio.
    for k = 1:1:length(name_funds_BCC_RP)
        
        % Definisco le variabili fund e titles: la prima contiene il fondo che si sta analizzando, la seconda contiene i titoli presenti in
        % quel fondo, definiti per ISINCODE.
        fund = readtable(string(name_funds_BCC_RP(k)), 'VariableNamingRule', 'preserve');    
        titles = fund{1:end-1, "ISINCODE"};

        % Loop per ogni titolo.
        for l = 1:1:length(titles)

            % Definisco una stuttura di supporto che contiene i prezzi e i
            % volumi dei titolo l.
            all_prices.(titles{l}) = readtable(strcat(string(name_funds_BCC_RP(k)),extension),  'Sheet', string(titles(l)), 'VariableNamingRule', 'preserve');

        end

        % Associo la struttura di supporto (per 20 titoli) al portafoglio
        % k.
        all_Ptf_structure.(name_funds_BCC_RP{k}) = all_prices;

        clear all_prices

    end

end
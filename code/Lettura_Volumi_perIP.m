%% LETTURA VOLUMI.

function [VE, V] = Lettura_Volumi_perIP(fund, all_Ptf_structure, j, i, name_funds_BCC_RP, titles)

    % -------------------------------------------------------------------------------------------------
    % Funzione che legge i volumi:
    % -----> dai file excel ordinati con i nomi dei
    %        portafogli, nel caso in cui il titolo sia azionario;
    % -----> dal file excel Parametri_Superfici_Liquidita_INVIO_LUCA.xlsx 
    %        dove li considera uguali al typical order size, nel caso in cui il titolo sia azionario;
    % OUTPUT PRINCIPALI:
    % > V, volumi del titolo.
    % > VE, Expected Daily Volume del titolo (come stima utilizziamo la media a 30 giorni dei volumi).
    % --------------------------------------------------------------------------------------------------
    
    % Se i portafogli sono azionari...
    if ( j == 1 ) || (j == 5)

        % allora prendo i VE direttamente dai file excel per ogni portafoglio.
        VE = fund.AVG_VOLUME_20D(i);
        V = all_Ptf_structure.(name_funds_BCC_RP{j}).(titles{i}).VOLUME(end);

    % Se i portafogli sono obbligazionari...
    else              

        % Carico il file Parametri_Superfici_Liquidita_INVIO_LUCA.xlsx e prendo la colonna degli ISIN.
        raw = readtable("Parametri_Superfici_Liquidita_INVIO_LUCA.xlsx", 'Sheet', ...
                                     '_PTF_' + string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        ISIN = raw{:,2};
        
        % Breve sezione di lettura dati per prendere i VE dal file excel in raw. L'ipotesi è che i VE per i bonds sono pari alla typical
        % order size. 
        store_check_sorted = strings(length(titles),1);

        for idd = 1 : 1 : length(titles)
            for kk = 1 : 1 : size(ISIN,1)
                if ismember(ISIN(kk),titles(idd))
                   store_check_sorted(idd) = string(ISIN(kk));
                end
            end
        end

        % Un ulteriore ciclo per controllare i portafogli (tipo AB) che contengono sia azioni sia bond.
        if contains(store_check_sorted(i), titles(i)) == 0

           VE = fund.AVG_VOLUME_20D(i);
           V = all_Ptf_structure.(name_funds_BCC_RP{j}).(titles{i}).VOLUME(end);

        elseif contains(store_check_sorted(i), titles(i)) == 1

               indice = find(table2cell(raw(:,2)) == store_check_sorted(i));
               volumi = table2array(raw(:,8));
               VE = volumi(indice);
               V = VE;

        end  

    end

end
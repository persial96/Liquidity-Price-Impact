%% SIMULAZIONE DEI METAORDER.

function [days_out, Quantities, Time_Finale, Stock_Price] = Metaorder_Simulation(name_funds_BCC_RP, titles, k, i, Number_of_Simulation, Num_Casuale_Duration, Num_Casuale_Prezzi, all_Ptf_structure, vol_asset_prices, drift_term, l_size, class_Stocks_All, class_Bonds, Stock_o_Bond, D)

    % ------------------------------------------------------------------------------------------
    % Funzione che definisce i metaorder simulati come tabelle con 4
    % colonne.
    % OUTPUT PRINCIPALI:
    % > days_out, colonna del giorno di analisi (30/06/2022).
    % > Time_Finale, colonna con vettore di tipo duration per il time.
    % > Quantities, colonna con le quantità tradate simulate con la
    %   funzione randfixedsum (Roger Stafford - Jan. 19, 2006). 
    % > Stock_Price, colonna con i prezzi per ogni trade simulati con
    %   l'utilizzo di un Brownian Bridge.
    % ------------------------------------------------------------------------------------------
    
    % Switch/Case per caso Bonds (class_Bonds) e caso azionario (class_Stocks_All).
    switch Stock_o_Bond

        case class_Bonds

            % Nel caso dei bond, prendiamo i valori della large_order_size direttamente dal file Parametri_Superfici_Liquidita_INVIO_LUCA.xlsx.
            raw = readtable("Parametri_Superfici_Liquidita_INVIO_LUCA.xlsx", 'Sheet', ...
                '_PTF_' + string(name_funds_BCC_RP(k)), 'VariableNamingRule', 'preserve');
            final_raw_ordini = raw(:, [2, 5, 12]);
            find_index = ismember(table2array(final_raw_ordini(:,1)), titles(i));
            % typical_order_size = table2array(final_raw_ordini(find_index, 3));
            large_order_size = table2array(final_raw_ordini(find_index, 2));


        case class_Stocks_All

            % % COLONNA DELLE QUANTITA'.
            % Definisco la variabile Volumi_Medi che include la media a 30 giorni dei volumi di ogni titolo.
            Volumi_Medi = mean(all_Ptf_structure.(name_funds_BCC_RP{k}).(titles{i}).VOLUME(end-30:end));

            % Utilizzo la variabile Volumi_Medi per definire la Large Order Size nel caso di titoli azionari.
            % typical_order_size = 0.05 * Volumi_Medi;
            large_order_size = Volumi_Medi;


    end

    % % COLONNA DELLE QUANTITA'.
    % Calcolo le quantità simulate utilizzando la funzione randfixedsum di TheMathowork (data una somma fissa pari alla large order size, la funzione 
    % mi restituisce un numero di quantità pari alle simulazioni che voglio fare, nell'intervallo 10 - large order size.
    [Quantities, ~] = randfixedsum(Number_of_Simulation, 1, large_order_size,...
        10, large_order_size);

    % % COLONNA DELLE ORE.
    % Prendo il giorno dell'analisi, che sarà uguale all'ultima osservazione nella struttura di portafoglio (dipende in pratica dagli excel che
    % contengono prezzi e volumi per ogni titolo).
    Giorno_di_Analisi = all_Ptf_structure.(name_funds_BCC_RP{k}).(titles{i}).DATE(end);
    % Definisco un vettore che ripete il giorno dell'analisi per tutta la lunghezza del Metaorder (quindi per i Number of Simulation).
    days_out = repelem(Giorno_di_Analisi, Number_of_Simulation, 1);

    % Definisco una variabile per indicare i minuti di mercato in un giorno di borsa americano.
    mkt_minutes = 6.5 * 60;
    % Definisco la lunghezza di una singola osservazione rapportando i minuti di mercato sul numero di simulazione...
    time_lenght = mkt_minutes/Number_of_Simulation;
    % ... e quindi il time vector finale.
    time_vector = linspace(time_lenght, Number_of_Simulation, Number_of_Simulation);

    % Definisco l'orario iniziale di una giornata di borsa (non è in formato duration).
    starting_point = '09:30:00';
    % Trasformo l'orario iniziale in un datetime e ne prendo solo l'orario in formato 'duration'.
    t = datetime(starting_point,'InputFormat','HH:mm:ss');
    Orario_Duration = timeofday(t);

    % In un loop per tutte le simulazioni, definisco il vettore time_temporaneo, che rappresenta il vettore di duration (orari) che inizia dallo
    % starting_point e finisce approsimativamente alle ore 16:00.
    % NB: la costante 1438.5 è un numero trovato attraverso diversi tentativi, che mi consente di ottenere, qualsiasi sia la grandezza delle simulazioni, 
    % un vettore di tempo che inizia alle 09:30 e finisce alle 16:00.
    for kl = 1 : 1 : Number_of_Simulation

        time_temporaneo(kl) = Orario_Duration + (time_lenght * time_vector(kl))/1438.5;

    end

    % La matrice di duration utilizza il Num_Casuale_Duration; il loop ci permette di ottenere in output una variabile che contiene le duration 
    % orarie in ordine casuale e ripetute per un numero casuale di volte.
    start = 1;

    for jj = 1 : length(D)

        mat_duration(start:(D(jj)+start)) = zeros(1,D(jj)+1) + time_temporaneo(Num_Casuale_Duration(jj));
        start = start + D(jj);

    end

    % Ordino questo vettore per ottenere il vettore di Time_Finale.
    Time_Finale = sort(mat_duration)';
    

    % Essendo il processo casuale, può essere che la lunghezza del Time_Finale non corrisponde alla lunghezza del numero di simulazioni.
    % La condizione seguente aggiusta questo problema.
    Adj_Diff = Number_of_Simulation - length(Time_Finale);
    if Adj_Diff > 0

        Time_Finale(end+1) = Time_Finale(end);

    elseif Adj_Diff < 0

        Time_Finale(end) = [];

    end

    % % COLONNA DEI PREZZI.
    % Storing dei prezzi open (O), close (C), high (H) e low (L).
    O = all_Ptf_structure.(name_funds_BCC_RP{k}).(titles{i}).OPEN(end);
    C = all_Ptf_structure.(name_funds_BCC_RP{k}).(titles{i}).CLOSE(end);

    % Considero vol e drift in questo caso entrambi annualizzati.
    vol = vol_asset_prices(k,i)*sqrt(252);
    drift = drift_term(k,i)*sqrt(252);

    % Calcolo i paths per i prezzi simulati.
    Raw_Price = Brownian_Bridge_Prova(O, C, drift, vol, length(time_temporaneo)+1);
    % Il vettore di prezzi temporaneo è una riga del Raw_Price (qui consideriamo la prima).
    Stock_Price_Temp = Raw_Price(1,:);

    % Considero le duration uniche (senza considerare le ripetizioni).
    uniche_duration = unique(Time_Finale);

    % Il ragionamento del loop seguente è lo stesso del loop per le duration, la matrice di prezzi che otteniamo dal loop
    % (mat_price) contiene infatti i prezzi in ordine casuale secondo la variabile Num_Casuale_Prezzi e ripetuti in modo casuale.
    start = 1;
    for jk = 1 : length(uniche_duration)

        index_duration = ismember(Time_Finale, uniche_duration(jk));
        lunghezza_index = length(find(index_duration == 1));
        mat_price(index_duration) = zeros(1,lunghezza_index) + Stock_Price_Temp(Num_Casuale_Prezzi(jk));
        start = start + lunghezza_index;

    end

    % In questo caso il sort non è importante (visto che sono prezzi, e non ore), ma devo trasporre per creare la tabella finale.
    Stock_Price = mat_price';

end

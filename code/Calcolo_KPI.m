%% CALCOLO KPI.

function KPI_Final_byTitle = Calcolo_KPI(Modello, Benchmark, name_funds_BCC_RP, PTF_o_Titles)

        % ------------------------------------------------------------------------------------------
        % Funzione che calcola i KPI per confrontare un modello benchmark con un
        % modello stimato.
        % NB: Modello = modello stimato dall'operatore; Benchmark = modello reale di mercato.
        % OUTPUT PRINCIPALI:
        % > KPI_Final_byTitle: struttura finale che contiene i KPI organizzati in
        %   tabella per ogni titolo dei portafogli.
        % ------------------------------------------------------------------------------------------
    
        % Swtich/Case per calcolo KPI nel caso di IP di portafoglio ('PTF') o di IP di titolo ('Titles').
        switch PTF_o_Titles

            case 'PTF'

                % Loop per ogni portafoglio.
                for j = 1 : 1 : length(name_funds_BCC_RP)

                     % % 1° KPI (differenza)
                    KPI_Diff_Dec = (Modello.(name_funds_BCC_RP{j}) ...
                        - Benchmark.(name_funds_BCC_RP{j}));

                    % % 2° KPI (differenza/benchmark).
                    KPI_Benchmark_Dec = (Modello.(name_funds_BCC_RP{j}) - ...
                        Benchmark.(name_funds_BCC_RP{j})) ./ Benchmark.(name_funds_BCC_RP{j});

                    % % 3° KPI (|1° KPI|)
                    KPI_Diff_Abs_Dec = abs((Modello.(name_funds_BCC_RP{j}) ...
                        - Benchmark.(name_funds_BCC_RP{j})));

                    % % 4° KPI (|2° KPI|)
                    KPI_Benchmark_Abs_Dec = abs((Modello.(name_funds_BCC_RP{j}) - ...
                        Benchmark.(name_funds_BCC_RP{j})) ./ Benchmark.(name_funds_BCC_RP{j}));

                    % Definisco una tabella provvisora.
                    Store_Temp = table(KPI_Diff_Dec,KPI_Benchmark_Dec,KPI_Diff_Abs_Dec,KPI_Benchmark_Abs_Dec, ...
                        'VariableNames',{'(IP - MSCI)';'(IP - MSCI)/MSCI';'|(IP - MSCI)|';'|(IP - MSCI)/MSCI|'}, ...
                        'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});

                    % Struttura finale in output.
                    KPI_Final_byTitle.(name_funds_BCC_RP{j}) = Store_Temp;

                    % Pulizia.
                    clear Store_Temp

                end


            case 'Titles'

                % Loop per ogni portafoglio.
                for j = 1 : 1 : length(name_funds_BCC_RP)
                    
                    % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
                    fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
                    titles = fund_per_titoli{1:end-1, "ISINCODE"};
                    
                    % Loop per ogni titolo.
                    for i = 1 : 1 : length(titles)

                        % % 1° KPI (differenza)
                        KPI_Diff_Dec = (Modello.(name_funds_BCC_RP{j}).(titles{i}) ...
                            - Benchmark.(name_funds_BCC_RP{j}).(titles{i}));

                        % % 2° KPI (differenza/benchmark).
                        KPI_Benchmark_Dec = (Modello.(name_funds_BCC_RP{j}).(titles{i}) - ...
                            Benchmark.(name_funds_BCC_RP{j}).(titles{i})) ./ Benchmark.(name_funds_BCC_RP{j}).(titles{i});

                        % % 3° KPI (|1° KPI|)
                        KPI_Diff_Abs_Dec = abs((Modello.(name_funds_BCC_RP{j}).(titles{i}) ...
                            - Benchmark.(name_funds_BCC_RP{j}).(titles{i})));

                        % % 4° KPI (|2° KPI|)
                        KPI_Benchmark_Abs_Dec = abs((Modello.(name_funds_BCC_RP{j}).(titles{i}) - ...
                            Benchmark.(name_funds_BCC_RP{j}).(titles{i})) ./ Benchmark.(name_funds_BCC_RP{j}).(titles{i}));

                        % Definisco una tabella provvisoria.
                        Store_Temp = table(KPI_Diff_Dec,KPI_Benchmark_Dec,KPI_Diff_Abs_Dec,KPI_Benchmark_Abs_Dec, ...
                            'VariableNames',{'(IP - MSCI)';'(IP - MSCI)/MSCI';'|(IP - MSCI)|';'|(IP - MSCI)/MSCI|'}, ...
                            'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});

                        % Struttura di supporto.
                        store_KPI.(titles{i}) = Store_Temp;

                        % Pulizia.
                        clear Store_Temp

                    end

                    % Struttura finale in output.
                    KPI_Final_byTitle.(name_funds_BCC_RP{j}) = store_KPI;

                    % Pulizia.
                    clear store_KPI

                end

        end

end
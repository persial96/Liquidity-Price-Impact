%% CALIBRAZIONE PARAMETRI.

function [Final_Calibrated_Gamma_LC, Final_Calibrated_Delta_LC, Final_Calibrated_eta_LC] = Calibrazione_Parametri(name_funds_BCC_RP, Aleatory_Store_Decomposed, Benchmark, volume_final, l_size, vol_asset_prices, MSCI_o_LC, tao, Gamma_Calibrato, Delta_Calibrato, Eta_Calibrato)

    % ------------------------------------------------------------------------------------------
    % Funzione per calibrare i parametri Gamma, Delta ed Eta di modello.
    % OUTPUT PRINCIPALI:
    % > Final_Calibrated_Gamma_LC, struttura con gamma calibrati per ogni portafoglio.
    % > Final_Calibrated_Delta_LC, struttura con delta calibrati per ogni portafoglio.
    % > Final_Calibrated_eta_LC, struttura con eta calibrati per ogni portafoglio.
    % ------------------------------------------------------------------------------------------
    
    
    % Pulizia delle variabili e delle strutture per evitare re-writing.
    clear calibrated_gamma_provider calibrated_delta_provider calibrated_eta_provider
    clear calibrated_gamma calibrated_delta calibrated_eta
    clear Final_Calibrated_Gamma_LC Final_Calibrated_Delta_LC Final_Calibrated_eta_LC

    % Loop per ogni portafoglio.
    for j = 1 : 1 : length(name_funds_BCC_RP)

        % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
        fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
        titles = fund_per_titoli{1:end-1, "ISINCODE"};
        fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');

        % Loop per ogni titolo.
        for h = 1 : 1 : length(titles)

            % Carico la componente aleatoria.
            aleatory = Aleatory_Store_Decomposed.(name_funds_BCC_RP{j}).(titles{h});
            % Definisco la superficie benchmark.
            CC = Benchmark.(name_funds_BCC_RP{j}).(titles{h});

            % Condizione se sono presenti NaN sulla superficie in analisi (può succedere soprattutto nel caso simulato).
            if isnan(CC)

                % Se presenti, i risultati della calibrazione sono uguali a
                % quella fatta vs MSCI.
                calibrated_gamma_provider = Gamma_Calibrato.(name_funds_BCC_RP{j}).(titles{h});
                calibrated_delta_provider = Delta_Calibrato.(name_funds_BCC_RP{j}).(titles{h});
                calibrated_eta_provider = Eta_Calibrato.(name_funds_BCC_RP{j}).(titles{h});

            else

                % Se non ci sono NaN, si procede con il lancio della funzione Liquidity_ModelCalibration_vsMSCI e definizione
                % di parametri di modello (già definiti in altre funzioni).
                
                tot_shares = fund.AzioniValore_Nomi(h);
                VE = volume_final.(name_funds_BCC_RP{j}).(titles{h});
                market_cap = fund.Market_CAP(h);
                avg_market_cap = sum(fund.Market_CAP) / (size(fund,1)-1);
                nu = 1;
                
                switch MSCI_o_LC
                    
                    case 'LC'
                        
                        % Calibrazione.
                        [gamma_out, delta_out, eta_out] = Liquidity_ModelCalibration(CC, ...
                            tot_shares, ...
                            l_size, ...
                            VE, ...
                            vol_asset_prices(j,h), ...
                            tao, ...
                            market_cap, ...
                            avg_market_cap, ...
                            nu, ...
                            aleatory, ...
                            MSCI_o_LC, ...
                            Gamma_Calibrato.(name_funds_BCC_RP{j}).(titles{h}), ...
                            Delta_Calibrato.(name_funds_BCC_RP{j}).(titles{h}), ...
                            Eta_Calibrato.(name_funds_BCC_RP{j}).(titles{h}));
                        
                        % Storing dei parametri calibrati.
                        calibrated_gamma_provider = gamma_out;
                        calibrated_delta_provider = delta_out;
                        calibrated_eta_provider = eta_out;
                        
                    case 'MSCI'
                        
                        % Calibrazione.
                        [gamma_out, delta_out, eta_out] = Liquidity_ModelCalibration(CC, ...
                            tot_shares, ...
                            l_size, ...
                            VE, ...
                            vol_asset_prices(j,h), ...
                            tao, ...
                            market_cap, ...
                            avg_market_cap, ...
                            nu, ...
                            aleatory, ...
                            MSCI_o_LC, ...
                            1, ...
                            1, ...
                            1);
                        
                        % Storing dei parametri calibrati.
                        calibrated_gamma_provider = gamma_out;
                        calibrated_delta_provider = delta_out;
                        calibrated_eta_provider = eta_out;
                        
                end
                

            end

            % Struttura di supporto.
            calibrazione_bysize_gamma.(titles{h}) = calibrated_gamma_provider;
            calibrazione_bysize_delta.(titles{h}) = calibrated_delta_provider;
            calibrazione_bysize_eta.(titles{h}) = calibrated_eta_provider;

            % Pulizia delle variabili di storing.
            clear calibrated_gamma calibrated_delta calibrated_eta

        end

        % % STRUTTURE FINALI IN OUTPUT.
        Final_Calibrated_Gamma_LC.(name_funds_BCC_RP{j}) = calibrazione_bysize_gamma;
        Final_Calibrated_Delta_LC.(name_funds_BCC_RP{j}) = calibrazione_bysize_delta;
        Final_Calibrated_eta_LC.(name_funds_BCC_RP{j}) = calibrazione_bysize_eta;

        % Pulizia delle variabili e delle strutture per evitare re-writing.
        clear calibrazione_bysize_gamma calibrazione_bysize_delta calibrazione_bysize_eta

    end

end

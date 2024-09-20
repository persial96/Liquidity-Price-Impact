%%                                            LIQUIDITY - Model Calibration

function [gamma, delta, eta] = Liquidity_ModelCalibration(CO, tot_shares, l_size, VE, sd_S, tao, market_cap, avg_market_cap, nu, aleatory, MSCI_o_LC, Gamma_LB, Delta_LB, Eta_LB)
                                                 
    % ------------------------------------------------------------------------------------------
    % Funzione che definisce la funzione obiettivo da calibrare e il metodo di
    % minimizzazione della funzione obiettivo.
    % 1. Il caso 'LC' è il modello Bloomberg completo, che utilizza il
    %    liquidation cost.
    %    Definito CO il liquidation cost:
    %    argmin sum(IP con parametri non calibrati - CO)^2
    %    Funzione: lsqnonlin.
    % 2. Il caso 'MSCI' è il modello Bloomberg fino alla definizione
    %    dell'IP, che dopo viene calibrato su una superficie nota, in questo
    %    caso quella di MSCI.
    %    Definito CO l'IP di MSCI:
    %    argmin (IP con parametri non calibrati - CO)
    %    Funzione: fminsearch.
    % ------------------------------------------------------------------------------------------

    % Switch/Case per considerare il caso di calibrazione simulativo (contro il Liquidation Cost dei metaorder - 'LC') o il caso di calibrazione contro MSCI ('MSCI').
    switch MSCI_o_LC
        
        case 'LC'
                
                objFun = @(L) ...
                    norm((((sd_S * (L(3)/((1-L(1))*(2-L(1)))) * (((l_size'*tot_shares)/VE).^L(2)) * (tao)^(1-L(2)-L(1))) * (market_cap/avg_market_cap)^nu)*aleatory) - CO);
                
                % Opzioni per l'ottimizzazione.
                options =  optimoptions('lsqnonlin','Display','iter');
                % Utilizzo informazione sui parametri calibrati secondo la
                % minimizzazione contro MSCI (vista l'instabilità della
                % calibrazione con metaorder simulati).
                x0 = [Gamma_LB Delta_LB, Eta_LB];
                
                % Lsqnonlin.
                L = lsqnonlin(objFun, x0, [], [], options);
                
                % % PARAMETRI IN OUTPUT.
                gamma = L(1);
                delta = L(2);
                eta = L(3);
                           
        case 'MSCI'
            
            % Funzione obiettivo da minimizzare.
            objFun = @(L) ...
                norm((((sd_S * ((L(3))/((1-L(1))*(2-L(1)))) * (((l_size'*tot_shares)/VE).^L(2)) * (tao)^(1-L(2)-L(1))) * (market_cap/avg_market_cap)^nu)*aleatory) - CO);
            
            % Opzioni per l'ottimizzazione.
            % Punto iniziale.
            x0 = [0.9 1 0.1];
            
            % Fminsearch.
            L = fminsearch(objFun, x0);
            
            % % PARAMETRI IN OUTPUT.
            gamma = L(1);
            delta = L(2);
            eta = L(3);
            
    end
    

end
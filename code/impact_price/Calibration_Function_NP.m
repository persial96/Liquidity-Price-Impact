%% Ottimizzazione NP.

function [Size_Store, x0] = Calibration_Function_NP(name_funds_BCC_RP, Pesi_ImpactPrice, tot_shares_ImpactPrice, gamma_ImpactPrice, delta_ImpactPrice, eta_ImapactPrice, market_cap_ImpactPrice, avg_market_cap_ImpactPrice, aleatory_ImpactPrice, store_check_volume, vol_asset_prices, l_size, tao, nu, unit)

    % ------------------------------------------------------------------------------------------
    % Funzione che definisce l'object function nel caso NP.
    % OUTPUT PRINCIPALI:
    % > Size_Store, vettore di size ottimizzate nell'intervallo LB - UB.
    % > x0, punto iniziale della minimizzazione (non utilizzato).
    % ------------------------------------------------------------------------------------------
    
    % Definzione della funzione.
    IP = @(Pesi, Vola, Eta, Gamma, Tot_Shares, Volumi, Delta, Tao, Mkt_Cap, Avg_Mkt_Cap, Nu, Num_Aleatorio, L)  ...
        Pesi * (((Vola * ((Eta) / ((1-Gamma)*(2-Gamma))) * ...
        (((L*Tot_Shares) / Volumi)^Delta) * (Tao)^(1-Delta-Gamma)) * ...
        (Mkt_Cap / Avg_Mkt_Cap)^Nu) * Num_Aleatorio);
    
    objFun =  @(L) IP(Pesi_ImpactPrice(1), vol_asset_prices(1), eta_ImapactPrice(1), gamma_ImpactPrice(1),tot_shares_ImpactPrice(1), store_check_volume(1), delta_ImpactPrice(1), ...
                   tao, market_cap_ImpactPrice(1), avg_market_cap_ImpactPrice(1), nu,  aleatory_ImpactPrice(1), L(1)) + ...
                   IP(Pesi_ImpactPrice(2), vol_asset_prices(2), eta_ImapactPrice(2), gamma_ImpactPrice(2),tot_shares_ImpactPrice(2), store_check_volume(2), delta_ImpactPrice(2), ...
                   tao, market_cap_ImpactPrice(2), avg_market_cap_ImpactPrice(2), nu,  aleatory_ImpactPrice(2), L(2)) + ...
                   IP(Pesi_ImpactPrice(3), vol_asset_prices(3), eta_ImapactPrice(3), gamma_ImpactPrice(3),tot_shares_ImpactPrice(3), store_check_volume(3), delta_ImpactPrice(3), ...
                   tao, market_cap_ImpactPrice(3), avg_market_cap_ImpactPrice(3), nu,  aleatory_ImpactPrice(3), L(3)) + ...
                   IP(Pesi_ImpactPrice(4), vol_asset_prices(4), eta_ImapactPrice(4), gamma_ImpactPrice(4),tot_shares_ImpactPrice(4), store_check_volume(4), delta_ImpactPrice(4), ...
                   tao, market_cap_ImpactPrice(4), avg_market_cap_ImpactPrice(4), nu,  aleatory_ImpactPrice(4), L(4)) + ...
                   IP(Pesi_ImpactPrice(5), vol_asset_prices(5), eta_ImapactPrice(5), gamma_ImpactPrice(5),tot_shares_ImpactPrice(5), store_check_volume(5), delta_ImpactPrice(5), ...
                   tao, market_cap_ImpactPrice(5), avg_market_cap_ImpactPrice(5), nu,  aleatory_ImpactPrice(5), L(5)) + ...
                   IP(Pesi_ImpactPrice(6), vol_asset_prices(6), eta_ImapactPrice(6), gamma_ImpactPrice(6),tot_shares_ImpactPrice(6), store_check_volume(6), delta_ImpactPrice(6), ...
                   tao, market_cap_ImpactPrice(6), avg_market_cap_ImpactPrice(6), nu,  aleatory_ImpactPrice(6), L(6)) + ...
                   IP(Pesi_ImpactPrice(7), vol_asset_prices(7), eta_ImapactPrice(7), gamma_ImpactPrice(7),tot_shares_ImpactPrice(7), store_check_volume(7), delta_ImpactPrice(7), ...
                   tao, market_cap_ImpactPrice(7), avg_market_cap_ImpactPrice(7), nu,  aleatory_ImpactPrice(7), L(7)) + ...
                   IP(Pesi_ImpactPrice(8), vol_asset_prices(8), eta_ImapactPrice(8), gamma_ImpactPrice(8),tot_shares_ImpactPrice(8), store_check_volume(8), delta_ImpactPrice(8), ...
                   tao, market_cap_ImpactPrice(8), avg_market_cap_ImpactPrice(8), nu,  aleatory_ImpactPrice(8), L(8)) + ...
                   IP(Pesi_ImpactPrice(9), vol_asset_prices(9), eta_ImapactPrice(9), gamma_ImpactPrice(9),tot_shares_ImpactPrice(9), store_check_volume(9), delta_ImpactPrice(9), ...
                   tao, market_cap_ImpactPrice(9), avg_market_cap_ImpactPrice(9), nu,  aleatory_ImpactPrice(9), L(9)) + ...
                   IP(Pesi_ImpactPrice(10), vol_asset_prices(10), eta_ImapactPrice(10), gamma_ImpactPrice(10),tot_shares_ImpactPrice(10), store_check_volume(10), delta_ImpactPrice(10), ...
                   tao, market_cap_ImpactPrice(10), avg_market_cap_ImpactPrice(10), nu,  aleatory_ImpactPrice(10), L(10)) + ...
                   IP(Pesi_ImpactPrice(11), vol_asset_prices(11), eta_ImapactPrice(11), gamma_ImpactPrice(11),tot_shares_ImpactPrice(11), store_check_volume(11), delta_ImpactPrice(11), ...
                   tao, market_cap_ImpactPrice(11), avg_market_cap_ImpactPrice(11), nu,  aleatory_ImpactPrice(11), L(11)) + ...
                   IP(Pesi_ImpactPrice(12), vol_asset_prices(12), eta_ImapactPrice(12), gamma_ImpactPrice(12),tot_shares_ImpactPrice(12), store_check_volume(12), delta_ImpactPrice(12), ...
                   tao, market_cap_ImpactPrice(12), avg_market_cap_ImpactPrice(12), nu,  aleatory_ImpactPrice(12), L(12)) + ...
                   IP(Pesi_ImpactPrice(13), vol_asset_prices(13), eta_ImapactPrice(13), gamma_ImpactPrice(13),tot_shares_ImpactPrice(13), store_check_volume(13), delta_ImpactPrice(13), ...
                   tao, market_cap_ImpactPrice(13), avg_market_cap_ImpactPrice(13), nu,  aleatory_ImpactPrice(13), L(13)) + ...
                   IP(Pesi_ImpactPrice(14), vol_asset_prices(14), eta_ImapactPrice(14), gamma_ImpactPrice(14),tot_shares_ImpactPrice(14), store_check_volume(14), delta_ImpactPrice(14), ...
                   tao, market_cap_ImpactPrice(14), avg_market_cap_ImpactPrice(14), nu,  aleatory_ImpactPrice(14), L(14)) + ...
                   IP(Pesi_ImpactPrice(15), vol_asset_prices(15), eta_ImapactPrice(15), gamma_ImpactPrice(15),tot_shares_ImpactPrice(15), store_check_volume(15), delta_ImpactPrice(15), ...
                   tao, market_cap_ImpactPrice(15), avg_market_cap_ImpactPrice(15), nu,  aleatory_ImpactPrice(15), L(15)) + ...
                   IP(Pesi_ImpactPrice(16), vol_asset_prices(16), eta_ImapactPrice(16), gamma_ImpactPrice(16),tot_shares_ImpactPrice(16), store_check_volume(16), delta_ImpactPrice(16), ...
                   tao, market_cap_ImpactPrice(16), avg_market_cap_ImpactPrice(16), nu,  aleatory_ImpactPrice(16), L(16)) + ...
                   IP(Pesi_ImpactPrice(17), vol_asset_prices(17), eta_ImapactPrice(17), gamma_ImpactPrice(17),tot_shares_ImpactPrice(17), store_check_volume(17), delta_ImpactPrice(17), ...
                   tao, market_cap_ImpactPrice(17), avg_market_cap_ImpactPrice(17), nu,  aleatory_ImpactPrice(17), L(17)) + ...
                   IP(Pesi_ImpactPrice(18), vol_asset_prices(18), eta_ImapactPrice(18), gamma_ImpactPrice(18),tot_shares_ImpactPrice(18), store_check_volume(18), delta_ImpactPrice(18), ...
                   tao, market_cap_ImpactPrice(18), avg_market_cap_ImpactPrice(18), nu,  aleatory_ImpactPrice(18), L(18)) + ...
                   IP(Pesi_ImpactPrice(19), vol_asset_prices(19), eta_ImapactPrice(19), gamma_ImpactPrice(19),tot_shares_ImpactPrice(19), store_check_volume(19), delta_ImpactPrice(19), ...
                   tao, market_cap_ImpactPrice(19), avg_market_cap_ImpactPrice(19), nu,  aleatory_ImpactPrice(19), L(19)) + ...
                   IP(Pesi_ImpactPrice(20), vol_asset_prices(20), eta_ImapactPrice(20), gamma_ImpactPrice(20),tot_shares_ImpactPrice(20), store_check_volume(20), delta_ImpactPrice(20), ...
                   tao, market_cap_ImpactPrice(20), avg_market_cap_ImpactPrice(20), nu,  aleatory_ImpactPrice(20), L(20));

    % Loop per ogni portafoglio.
    for j = 1 : 1 : length(name_funds_BCC_RP) 
        
        % Struttura del fondo.
        fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');

        % Opzioni per l'ottimizzazione.
        options = optimset('Display','iter'); %, 'PlotFcns',@optimplotfval);      % % NB: la parte commentata consente di ottenere i plot della minimizzazione.
        % Definizione punto iniziale.
        x0 = ones(size(fund,1)-1, 1) * l_size;
        % Definizione lower bounds e upper bounds.
        LB = ones(size(fund,1)-1, 1);
        LB(:) = l_size - (0.01 * unit);
        UB = ones(size(fund,1)-1, 1);
        UB(:) = l_size + (0.01 * unit);
        % Definizione condizione sulla somma delle size trovate: deve essere uguale alla size di liquidazione iniziale.
        Aeq = ones(size(fund,1)-1, 1) * 1/(size(fund,1)-1);
        beq = l_size;
        A = [];
        B = [];
        nonlcon = [];
       
        % Fmincon e storing.
        [Size_perTitolo_NP] = fmincon(objFun, x0, A, B, Aeq', beq, LB, UB, nonlcon, options);
        Size_Store = Size_perTitolo_NP';
        
    end
            
end
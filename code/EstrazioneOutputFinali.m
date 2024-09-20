function [IP_PTF_CalibrazioneMSCI, IP_NP_PTF_CalibrazioneMSCI, IP_PTF_CalibrazioneMetaorder, IP_NP_PTF_CalibrazioneMetaorder, IP_Titoli_CalibrazioneMSCI, IP_NP_Titoli_CalibrazioneMSCI, IP_Titoli_CalibrazioneMetaorder, IP_NP_Titoli_CalibrazioneMetaorder] = EstrazioneOutputFinali(name_funds_BCC_RP, ...
    ImpactPrice_PostCalibration_vsMSCI_Superficie, str_PROP, ImpactPrice_PostCalibration_vsMSCI_NP_Superficie, ...
    str_NP, ImpactPrice_PostCalibration_Metaorder_Superficie, ImpactPrice_PostCalibration_Metaorder_NP_Superficie, ImpactPrice_PostCalibration_vsMSCI_PTF_Superficie, ...
    ImpactPrice_PostCalibration_vsMSCI_NP_PTF_Superficie, ImpactPrice_PostCalibration_Metaorder_PTF_Superficie, ImpactPrice_PostCalibration_Metaorder_NP_PTF_Superficie)

% Loop per ogni portafoglio.
for j = 1 : 1 : length(name_funds_BCC_RP) 
    
    % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
    fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
    titles = fund_per_titoli{1:end-1, "ISINCODE"};
    fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
    
    % Loop per ogni titolo.
    for k = 1 : 1 : length(titles)
        % Converto tutte le strutture di IP in tabella per indicare nomi colonne e righe.
        
        % -----------------------------------------------------------------------------------------------------------------------------------------------%
        % IMPACT PRICE PER TITOLO CALIBRATO SU MSCI.
        Store_Temp_2 = ...
            table(ImpactPrice_PostCalibration_vsMSCI_Superficie.(name_funds_BCC_RP{j}).(titles{k}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'}); 
        Store_Temp_2 = splitvars(Store_Temp_2);
        Store_Temp_2.Properties.VariableNames(1:length(str_PROP)) = cellstr(str_PROP);
        Supporto_2.(titles{k}) = Store_Temp_2;
        
        % IMPACT PRICE PER TITOLO CALIBRATO SU MSCI. (NEAR PROPORTIONAL).
        Store_Temp_3 = ...
            table(ImpactPrice_PostCalibration_vsMSCI_NP_Superficie.(name_funds_BCC_RP{j}).(titles{k}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});
        Store_Temp_3 = splitvars(Store_Temp_3);
        Store_Temp_3.Properties.VariableNames(1:length(str_NP)) = cellstr(str_NP);
        Supporto_3.(titles{k}) = Store_Temp_3;
        
        % -----------------------------------------------------------------------------------------------------------------------------------------------%
        % IMPACT PRICE PER TITOLO CALIBRATO SU METAORDER.
        Store_Temp_22 = ...
            table(ImpactPrice_PostCalibration_Metaorder_Superficie.(name_funds_BCC_RP{j}).(titles{k}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'}); 
        Store_Temp_22 = splitvars(Store_Temp_22);
        Store_Temp_22.Properties.VariableNames(1:length(str_PROP)) = cellstr(str_PROP);
        Supporto_22.(titles{k}) = Store_Temp_22;
        
        % IMPACT PRICE PER TITOLO CALIBRATO SU METAORDER. (NEAR PROPORTIONAL).
        Store_Temp_33 = ...
            table(ImpactPrice_PostCalibration_Metaorder_NP_Superficie.(name_funds_BCC_RP{j}).(titles{k}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});
        Store_Temp_33 = splitvars(Store_Temp_33);
        Store_Temp_33.Properties.VariableNames(1:length(str_NP)) = cellstr(str_NP);
        Supporto_33.(titles{k}) = Store_Temp_33;
        
        clear Store_Temp_2 Store_Temp_3 Store_Temp_22 Store_Temp_33
        
    end
    
    % IMPACT PRICE DI PTF CALIBRATO SU MSCI.
    Store_Temp_1 = ...
        table(ImpactPrice_PostCalibration_vsMSCI_PTF_Superficie.(name_funds_BCC_RP{j}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});
    Store_Temp_1 = splitvars(Store_Temp_1);
    Store_Temp_1.Properties.VariableNames(1:length(str_PROP)) = cellstr(str_PROP);
    IP_PTF_CalibrazioneMSCI.(name_funds_BCC_RP{j}) = Store_Temp_1;
    
    % IMPACT PRICE DI PTF CALIBRATO SUI MSCI (NEAR PROPORTIONAL).
    Store_Temp_4 = ...
        table(ImpactPrice_PostCalibration_vsMSCI_NP_PTF_Superficie.(name_funds_BCC_RP{j}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});
    Store_Temp_4 = splitvars(Store_Temp_4);
    Store_Temp_4.Properties.VariableNames(1:length(str_NP)) = cellstr(str_NP);
    IP_NP_PTF_CalibrazioneMSCI.(name_funds_BCC_RP{j}) = Store_Temp_4;
    
    % IMPACT PRICE DI PTF CALIBRATO SUI METAORDER.
    Store_Temp_11 = ...
        table(ImpactPrice_PostCalibration_Metaorder_PTF_Superficie.(name_funds_BCC_RP{j}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});
    Store_Temp_11 = splitvars(Store_Temp_11);
    Store_Temp_11.Properties.VariableNames(1:length(str_PROP)) = cellstr(str_PROP);
    IP_PTF_CalibrazioneMetaorder.(name_funds_BCC_RP{j}) = Store_Temp_11;
    
    % IMPACT PRICE DI PTF CALIBRATO SUI METAORDER (NEAR PROPORTIONAL).
    Store_Temp_44 = ...
        table(ImpactPrice_PostCalibration_Metaorder_NP_PTF_Superficie.(name_funds_BCC_RP{j}), 'RowNames',{'5%';'10%';'30%';'50%';'80%';'100%'});
    Store_Temp_44 = splitvars(Store_Temp_44);
    Store_Temp_44.Properties.VariableNames(1:length(str_NP)) = cellstr(str_NP);
    IP_NP_PTF_CalibrazioneMetaorder.(name_funds_BCC_RP{j}) = Store_Temp_44;
    
    % IMPACT PRICE PER TITOLO CALIBRATO SU MSCI.
    IP_Titoli_CalibrazioneMSCI.(name_funds_BCC_RP{j}) = Supporto_2;
    
    % IMPACT PRICE PER TITOLO CALIBRATO SU MSCI (NEAR PROPORTIONAL).
    IP_NP_Titoli_CalibrazioneMSCI.(name_funds_BCC_RP{j}) = Supporto_3;
    
    % IMPACT PRICE PER TITOLO CALIBRATO SUI METAORDER.
    IP_Titoli_CalibrazioneMetaorder.(name_funds_BCC_RP{j}) = Supporto_22;
    
    % IMPACT PRICE PER TITOLO CALIBRATO SUI METAORDER (NEAR PROPORTIONAL).
    IP_NP_Titoli_CalibrazioneMetaorder.(name_funds_BCC_RP{j}) = Supporto_33;
    
    clear Store_Temp_1 Store_Temp_4 Supporto_2 Supporto_3 Store_Temp_11 Store_Temp_44 Supporto_22 Supporto_33
    
end
   
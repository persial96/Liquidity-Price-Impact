%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN - LIQUIDITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % % 
% % % Autore: Luca Persia
% % % Collaboratori: Simone Frigerio (BCC R&P), Michele Bonollo (Politecnico di Milano)
% % % Dati: BCC R&P, Bloomberg, MSCI RiskMetrics.
% % %
% % % 
% % % FUNZIONI UTILIZZATE:
% % % > Estrazione_Prezzi
% % % > Calcolo_Volatility
% % % > Estrazione_IP_MSCI
% % % > ImpactPrice
% % % > Liquidity_ModelFramework
% % % > Calibrazione_Parametri
% % % > Calcolo_KPI
% % % > IP_PostCalibration
% % % > NearProportional_Framework
% % % > Calibration_Function_NP
% % % > IP_PostCalibration_NearProportional
% % % > Liquidity_Plots
% % % > Metaorder_Simulation
% % % > LC_Fun
% % % > Liquidity_ModelCalibration
% % % > Brownian_Bridge
% % % > MetaorderFramework
% % % > Framework_Plot
% % %
% % %
% % %
% % %
% % %                                                            // CALIBRAZIONE vs MSCI //
% % %
% % % MODELLO: 
% % % il calcolo delle metriche di liquidità è fatto secondo la funzione (8) per l'Impact Price (IP) di Bloomberg (2018), 
% % % considerando anche la componente aleatoria estratta da una lognormale e il rapporto tra la capitalizzazione di mercato
% % % di un titolo e la media delle capitalizzazioni di mercato dei titoli in un intero portafoglio (in Bloomberg, viene utilizzata la media di un indice).
% % % Per la calibrazione dei parametri Gamma, Delta e Eta viene minimizzata la distanza tra l'IP del modello e l'IP dell'estrazione MSCI,
% % % provider della BCC R&P per il rischio liqudità. Per la minimizzazione si utilizza la funzione fminsearch.
% % %
% % % L'analisi viene svolta sia nel caso di liquidazione PROPORTIONAL (la size è fissa per ogni titolo in portafoglio), sia nel caso di liquidazione
% % % NEAR PROPORTIONAL (la size per ogni titolo può variare in un intervallo a seconda della liquidabilità del titolo stesso).
% % % 
% % % OUTPUT:
% % %
% % % 1. PARAMETRI NON CALIBRATI
% % %    > IP_Decomposed_MSCI: IP estratto da MSCI per ogni titolo di ciascun portafoglio.
% % %    > IP_Ptf: IP del modello Bloomberg per ogni portafoglio, con parametri non calibrati.
% % %    > IP_Ptf_Decomposed: IP del modello Bloomberg per ogni titolo di ciascun portafoglio, con parametri non calibrati.
% % %    > IP_Ptf_MSCI: IP estratto da MSCI per ogni portafoglio.
% % %    > IP_Weights_Final: struttura che contiene i pesi (quantità di quel titolo in portafoglio/quantità 
% % %                        titoli in portafoglio) ogni titolo di ciascun portafoglio.
% % %    > volume_final: struttura che stora i volumi per ogni titolo di ciascun portafoglio.
% % %    > Aleatory_Store_Decomposed: struttura che stora la componente aleatoria per ogni titolo di ciascun portafoglio.
% % %    > store_check_volume: matrice che stora i volumi per ogni titolo di ciascun portafoglio 
% % %                          (è = a volume_final, ma alla fine utilizziamo sempre store_check_volume).
% % %    > KPI_Final_NoCalibrazione: struttura per i KPI.
% % % 
% % %    TEMPO DI RUN STIMATO: 4 minuti.
% % % 
% % % 2. PARAMETRI CALIBRATI
% % %    > Strutture per i parametri calibrati: Final_Calibrated_Gamma_vsMSCI,
% % %                                           Final_Calibrated_Delta_vsMSCI,
% % %                                           Final_Calibrated_eta_vsMSCI.
% % %    > Strutture per l'IP con parametri calibrati: ImpactPrice_PostCalibration_vsMSCI, 
% % %                                                  ImpactPrice_PostCalibration_vsMSCI_PTF.
% % %    > Strutture per i KPI tra modello calibrato e MSCI: KPI_PostCalibration_vsMSCI,
% % %                                                        KPI_PostCalibration_vsMSCI_PTF.
% % %    > Strutture per l'IP con parametri calibrati e orizzonte temporale > 1: ImpactPrice_PostCalibration_vsMSCI_Superficie, 
% % %                                                                            ImpactPrice_PostCalibration_vsMSCI_PTF_Superficie.
% % % 
% % %    TEMPO DI RUN STIMATO: 2 minuti e 30 secondi con tao che va da 1 a 3 giorni.
% % % 
% % % 3. Metodologia NEAR PROPORTIONAL
% % %    > Struttura per le size ottimizzate secondo NP: Size_Liquidation_NearProportional.
% % %    > Strutture per l'IP con parametri calibrati nel caso NP e orizzonte temporale > 1: ImpactPrice_PostCalibration_vsMSCI_NP_Superficie,
% % %                                                                                        ImpactPrice_PostCalibration_vsMSCI_NP_PTF_Superficie.
% % % 
% % %    TEMPO DI RUN STIMATO: 38 minuti e 20 secondi con tao che va da 1 a 3 giorni.
% % % 
% % %
% % %
% % % 
% % %
% % %                                    // CALIBRAZIONE vs Liquidation Cost (LC) stimato su METAORDER SIMULATI //
% % %
% % % MODELLO: 
% % % il calcolo delle metriche di liquidità è fatto secondo la funzione (8) per l'Impact Price (IP) di Bloomberg (2018), 
% % % considerando anche la componente aleatoria estratta da una lognormale e il rapporto tra la capitalizzazione di mercato
% % % di un titolo e la media delle capitalizzazioni di mercato dei titoli in un intero portafoglio (in Bloomberg, viene utilizzata la media di un indice).
% % % Per la calibrazione dei parametri Gamma, Delta e Eta viene minimizzata la distanza tra l'IP del modello e il liquidation cost ottenuto con l'utilizzo di
% % % metaorder simulati secondo un Brownian Bridge.
% % %
% % % Anche in questo caso l'analisi è svolta nel caso PROPORTIONAL e nel
% % % caso NEAR PROPORTIONAL.
% % % 
% % % 
% % % OUTPUT:
% % %
% % % 1. STRUTTURA DEI METAORDER
% % %    > Metaorder_Finale_byISIN: struttura contenente i metaorder simulati per ogni titolo di ciascun portafoglio.
% % %    > Liquidation_Cost: struttura contenente i Liquidation Cost (Equazione 12 di Bloomberg 2018) per ogni titolo di ciascun portafoglio.
% % % 
% % %    TEMPO DI RUN STIMATO: 5 minuti.
% % % 
% % % 2. PARAMETRI CALIBRATI
% % %    > Strutture per i parametri calibrati: Final_Calibrated_Gamma_LC,
% % %                                           Final_Calibrated_Delta_LC,
% % %                                           Final_Calibrated_eta_LC.
% % %    > Strutture per l'IP con parametri calibrati: ImpactPrice_PostCalibration_Metaorder, 
% % %                                                  ImpactPrice_PostCalibration_Metaorder_PTF.
% % %    > Strutture per i KPI tra modello calibrato e MSCI: KPI_PostCalibration_Metaorder,
% % %                                                        KPI_PostCalibration_Metaorder_PTF.
% % %    > Strutture per l'IP con parametri calibrati e orizzonte temporale > 1: ImpactPrice_PostCalibration_Metaorder_Superficie, 
% % %                                                                            ImpactPrice_PostCalibration_Metaorder_PTF_Superficie.
% % % 
% % %    TEMPO DI RUN STIMATO: 2 minuti e 30 secondi con tao che va da 1 a 3 giorni.
% % % 
% % % 3. Metodologia NEAR PROPORTIONAL
% % %    > Struttura per le size ottimizzate secondo NP: Size_Liquidation_NearProportional_Metaorder.
% % %    > Strutture per l'IP con parametri calibrati nel caso NP e orizzonte temporale > 1: ImpactPrice_PostCalibration_Metaorder_NP_Superficie,
% % %                                                                                        ImpactPrice_PostCalibration_Metaorder_NP_PTF_Superficie.
% % % 
% % %    TEMPO DI RUN STIMATO: 38 minuti e 20 secondi con tao che va da 1 a 3 giorni.
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Start
clear
close all
rng(0) % for reproducibility

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LETTURA DATI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% Carico i dati dei singoli portafogli, in particolare i nomi dei portafogli, la descrizione e costruisco la struttura dei portafogli, che
% include i prezzi e i volumi di ogni singolo titolo. Calcolo inoltre la volatilità.

% Definisco l'anagrafica dei portafogli della BCC R&P (portfolio_anagrafica).
portfolio_anagrafica = readtable("Dati_Portafoglio_All.xlsx", 'Sheet', "Anagrafica", 'VariableNamingRule', 'preserve');

% Prendo i nomi dei portafogli (name_funds_BCC_RP) e la struttura di un fondo (fund) per definire la lunghezza delle matrici e delle strutture 
% che serviranno per l'IP.
name_funds_BCC_RP = portfolio_anagrafica{:,"CodicePortafoglio"};
fund = readtable(string(name_funds_BCC_RP(1)), 'VariableNamingRule', 'preserve');
% Definisco l'estensione dei file da caricare.
extension = '.xlsx';

% Estrazione Prezzi e costruzione della struttura di portafoglio (all_Ptf_structure).
all_Ptf_structure = Estrazione_Prezzi(name_funds_BCC_RP, extension);

% Calcolo volatilità daily (vol_asset_prices), volatilità annualizzata (vol_asset_prices_year) e del drift term daily (drift_term).
[vol_asset_prices_year, vol_asset_prices, drift_term] = Calcolo_Volatility(name_funds_BCC_RP, all_Ptf_structure);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINIZIONE PARAMETRI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% DEFINIZIONE PARAMETRI BASE DI MODELLO.
l_size = [0.05, 0.10, 0.30, 0.50, 0.80, 1];
l_size_plot = l_size * 100;
PbP = 1;

% Definizione dei parametri secondo una best estimate (punto iniziale dei parametri).
gamma = 0.7;
delta = 1;
eta = 0.1;

% ESTRAZIONE DELL'IMPACT PRICE DI MSCI.
[IP_Decomposed_MSCI, matrix_IP_MSCI, PV_store]= Estrazione_IP_MSCI(l_size, ...
                                                          name_funds_BCC_RP);
                                                      
% Definizione dei Tao.
tao_PROP = (1:10) / 252; % Proportional Surface
tao_NP = (1:10) / 252; % Near Proportional Surface
tao_NO_SURFACE = 1 / 252;
tao_GRAFICI_PROP = 1:10;
tao_GRAFICI_NP = 1:10;  

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IP e KPI NON CALIBRATI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% CALCOLO DELL'IP SENZA CALIBRAZIONE (BEST ESTIMATE SUI PARAMETRI).
[IP_Ptf, IP_Ptf_MSCI, IP_Weights_Final, IP_Ptf_Decomposed, volume_final, Aleatory_Store_Decomposed, store_check_volume] = ImpactPrice(l_size, ...
                                                                                                                  fund, ...
                                                                                                                  tao_NO_SURFACE, ...
                                                                                                                  name_funds_BCC_RP, ...
                                                                                                                  IP_Decomposed_MSCI, ...
                                                                                                                  gamma, ...
                                                                                                                  delta, ...
                                                                                                                  eta, ...
                                                                                                                  all_Ptf_structure, ...
                                                                                                                  vol_asset_prices, ...
                                                                                                                  PbP);

% KPI Provvisorio di Modello (non calibrato) vs MSCI.
% Pulizia per evitare sovrascrizione.
clear  KPI_Final_NoCalibrazione
% Definizione variabile per lo switch/case.
PTF_o_Titles = 'Titles';

% CALCOLO KPI SENZA CALIBRAZIONE (POCO UTILI)
KPI_Final_NoCalibrazione = Calcolo_KPI(IP_Ptf_Decomposed, ...
                                       IP_Decomposed_MSCI, ...
                                       name_funds_BCC_RP, ...
                                       PTF_o_Titles);

% PTF.
PTF_o_Titles = 'PTF'; 
KPI_Final_NoCalibrazione_PTF = Calcolo_KPI(IP_Ptf, ...
                                       IP_Ptf_MSCI, ...
                                       name_funds_BCC_RP, ...
                                       PTF_o_Titles);                                   
                                             

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALIBRAZIONE vs MSCI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% Variabile per lo switch-case della funzione Calibrazione_Parametri.
MSCI_o_LC = 'MSCI';
% Definisco parametri calibrati uguali ad 1, perché nel caso MSCI non
% utilizziamo nessuna informazione sui parametri.
Gamma_Calibrato = 1;
Delta_Calibrato = 1;
Eta_Calibrato = 1;

% CALIBRAZIONE DEI PARAMETRI.
[Final_Calibrated_Gamma_vsMSCI, Final_Calibrated_Delta_vsMSCI, Final_Calibrated_eta_vsMSCI] = Calibrazione_Parametri(name_funds_BCC_RP, ...
                                                                                                               Aleatory_Store_Decomposed, ...
                                                                                                               IP_Decomposed_MSCI, ...
                                                                                                               volume_final, ...
                                                                                                               l_size, ...
                                                                                                               vol_asset_prices, ...
                                                                                                               MSCI_o_LC, ...
                                                                                                               tao_NO_SURFACE, ...
                                                                                                               Gamma_Calibrato, ...
                                                                                                               Delta_Calibrato, ...
                                                                                                               Eta_Calibrato);

                                                                                                           
% Ri-definisco input di modello: tempo e size (in questo caso tao sarà un vettore).
Surface = 'NO'; % se tao = 1 e per calcolo KPI con MSCI.

% CALCOLO IP POST CALIBRATION.
[ImpactPrice_PostCalibration_vsMSCI, ImpactPrice_PostCalibration_vsMSCI_PTF]  = IP_PostCalibration(name_funds_BCC_RP, ...
                                             Aleatory_Store_Decomposed, ...
                                             all_Ptf_structure, ...
                                             Final_Calibrated_Gamma_vsMSCI, ...
                                             Final_Calibrated_Delta_vsMSCI, ...
                                             Final_Calibrated_eta_vsMSCI, ...
                                             vol_asset_prices, ...
                                             l_size, ...
                                             tao_NO_SURFACE, ...
                                             fund, ...
                                             PbP, ...
                                             PV_store,...
                                             Surface);

                                         
% CALCOLO KPI POST CALIBRAZIONE (PROPORTIONAL).
PTF_o_Titles = 'Titles';
KPI_PostCalibration_vsMSCI = Calcolo_KPI(ImpactPrice_PostCalibration_vsMSCI, ...
                                         IP_Decomposed_MSCI, ...
                                         name_funds_BCC_RP, ...
                                         PTF_o_Titles);  
PTF_o_Titles = 'PTF';                                
KPI_PostCalibration_vsMSCI_PTF = Calcolo_KPI(ImpactPrice_PostCalibration_vsMSCI_PTF, ...
                                             IP_Ptf_MSCI, ...
                                             name_funds_BCC_RP, ...
                                             PTF_o_Titles);                                    

    
                                         
%% RICALCOLO SUPERFICIE CON PIU' TAO PER OTTENERE I PLOT (da utilizzare nella sezione di plotting).
% Ri-definisco input di modello: tempo e size (in questo caso tao sarà un vettore).
Surface = 'SI';

% Funzione IP_PostCalibration con un tao vettoriale (PROPORTIONAL).
[ImpactPrice_PostCalibration_vsMSCI_Superficie, ImpactPrice_PostCalibration_vsMSCI_PTF_Superficie]  = IP_PostCalibration(name_funds_BCC_RP, ...
                                             Aleatory_Store_Decomposed, ...
                                             all_Ptf_structure, ...
                                             Final_Calibrated_Gamma_vsMSCI, ...
                                             Final_Calibrated_Delta_vsMSCI, ...
                                             Final_Calibrated_eta_vsMSCI, ...
                                             vol_asset_prices, ...
                                             l_size, ...
                                             tao_PROP, ...
                                             fund, ...
                                             PbP, ...
                                             PV_store, ...
                                             Surface);
           
                                         
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NEAR PROPORTIONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %
% (DIRETTAMENTE CALCOLATO CON TAO VETTORIALE PERCHE' NON CONFRONTABILE CON MSCI).

% % CALCOLO DELLE SIZE NEL CASO NEAR PROPORIONAL.
Size_Liquidation_NearProportional = NearProportional_Framework(name_funds_BCC_RP, ...
                                                               IP_Weights_Final, ...
                                                               Final_Calibrated_Gamma_vsMSCI, ...
                                                               Final_Calibrated_Delta_vsMSCI, ...
                                                               Final_Calibrated_eta_vsMSCI, ...
                                                               Aleatory_Store_Decomposed, ...
                                                               store_check_volume, ...
                                                               vol_asset_prices, ...
                                                               tao_NP, ...
                                                               l_size);

                                                          

% % RICALCOLO SUPERFICIE LIQUIDITA' CON PIU' TAO E NP.
clear Final_After_Calibration_NP Final_After_Calibration_PTF_NP

% Calcolo dell'Impact Price per ogni size e per ogni titolo, quindi PbP = 0, ovvero non lavoriamo con vettori.
PbP = 0;

% Caricamento della funzione per il calcolo dell'IP nel caso NP.
[ImpactPrice_PostCalibration_vsMSCI_NP_Superficie] = IP_PostCalibration_NearProportional(name_funds_BCC_RP, ...
                                                                   fund, ...
                                                                   Aleatory_Store_Decomposed, ...
                                                                   all_Ptf_structure, ...
                                                                   Final_Calibrated_Gamma_vsMSCI, ...
                                                                   Final_Calibrated_Delta_vsMSCI, ...
                                                                   Final_Calibrated_eta_vsMSCI, ...
                                                                   Size_Liquidation_NearProportional, ...
                                                                   vol_asset_prices, ...
                                                                   tao_NP, ...
                                                                   PbP, ...
                                                                   l_size, ...
                                                                   PV_store);


% % RECUPERO SUPERFICIE NEAR PROPORTIONAL ANCHE PER OGNI PORTAFOGLIO.
% Inizializzazione.
IP_result_ptf = zeros(length(l_size),length(tao_NP),length(name_funds_BCC_RP));

% Loop per ogni portafoglio.
for j = 1 : 1 : length(name_funds_BCC_RP) 
    
    % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
    fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
    titles = fund_per_titoli{1:end-1, "ISINCODE"};
    fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
    
    % Loop per ogni size.
    for kn = 1 : 1 : length(l_size)
        
        % Loop per ogni tao.
        for n = 1 : 1 : length(tao_NP)
    
            % Loop per ogni titolo.
            for i = 1 : 1 : (size(fund,1)-1)
                
                % Calcolo dell'IP di portafoglio nel caso NP come sommatoria degli IP dei singoli titoli ponderati per i rispettivi pesi.
                IP_result_ptf(kn,n,j) = IP_result_ptf(kn,n,j) + ...
                                        IP_Weights_Final.(name_funds_BCC_RP{j}).(titles{i}) .* ...
                                        ImpactPrice_PostCalibration_vsMSCI_NP_Superficie.(name_funds_BCC_RP{j}).(titles{i})(kn,n);

            end
            
        end
        
    end
    
    % % STORING DELLA STRUTTURA FINALE.
    % Impact Price per ogni portafoglio nel caso NP:
    ImpactPrice_PostCalibration_vsMSCI_NP_PTF_Superficie.(name_funds_BCC_RP{j}) = IP_result_ptf(:,:,j);   
        
    % Pulizia per evitare re-writing.
    clear fund titles fund_per_titoli
            
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT SUPERFICI CALIBRATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% % NB: il tao e l_size devono avere la stessa lunghezza del Impact Price di ogni titolo o di ogni portafoglio usati nel caso PROPORTIONAL. 
% % NB: Tao deve essere > 1 per ottenere i plot.

% Definizione di una variabile binaria per il plot per ogni portafoglio (= 0) o per ogni titolo di ogni portafoglio (= 1).
% !NB!: qualora si volesse ottenere la superficie titolo per titolo, conviene "eliminare" il primo loop, ovvero definire i = al numero del portafoglio
%       che contiene quel titolo. In questo modo, si ottengono 20 plot (se si considera l'analisi con 20 titoli per ogni portafoglio. Lasciando i = 1 :
%       1 : length(name_funds_BCC_RP) il codice gira lo stesso, ma si ottiene un numero di plot elevato, pari a (titoli in portafoglio x numero di portafoglio analizzati).
all_assets = 0;
% Definizione della variabile subtitle che indicherà il singolo ISIN nel caso in cui all_assets è attivata (= 1).
subtitle = all_assets;
% Variabile "di supporto" per inserire il titles nel caso si vuole il plot solo per ogni portafoglio (hint: potrebbe essere sostituita da uno swtich/case).
empty = 0;

% % % PROPORTIONAL PLOT. 
PROP_o_NP = 'PROP';
[Surface_Prop] = Framework_Plot(name_funds_BCC_RP, ...
                           l_size_plot, tao_GRAFICI_PROP, ...
                           ImpactPrice_PostCalibration_vsMSCI_Superficie, ImpactPrice_PostCalibration_vsMSCI_PTF_Superficie, ...
                           subtitle, empty, all_assets, PROP_o_NP);
                       
% % % NEAR PROPORTIONAL PLOT.
% NB: solo empty = 0, perché NP è di portafoglio.
empty = 0;
PROP_o_NP = 'NP';
[Surface_NP] = Framework_Plot(name_funds_BCC_RP, ...
                           l_size_plot, tao_GRAFICI_NP, ...
                           ImpactPrice_PostCalibration_vsMSCI_Superficie, ImpactPrice_PostCalibration_vsMSCI_NP_PTF_Superficie, ...
                           subtitle, empty, all_assets, PROP_o_NP);

                       

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALIBRAZIONE METAORDER SIMULATI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% Classi per mercato EUROPEO o AMERICANO.
class_EUR = {'EUR', 'CHF'};
class_USD = {'USD'};
% Classe azionaria.
class_Stocks = {'AOR'};
% Classe Nasdaq e SP.
class_Stocks_US_NSDQ = {'OTC         00'};
class_Stocks_US_SP = {'NEW YORK    00'};
% Classe bonds.
class_Bonds = {'TS.', 'O..'};
% Classe per tutte le azioni.
class_Stocks_All = {'AOR', 'OTC         00', 'NEW YORK    00'};
% Numero di scenari (per il Brownian Bridge).
nPaths = 1000;
% Orizzonte temporale (per il Brownian Bridge).
T = 1/252;
% Ridefinizione size.
l_size = [0.05, 0.10, 0.30, 0.50, 0.80, 1];

% COSTRUZIONE DEI METAORDER.
Metaorder_Finale_byISIN = MetaorderFramework(name_funds_BCC_RP, ...
                                             class_EUR, ...
                                             class_Bonds, ...
                                             class_Stocks_All, ...
                                             all_Ptf_structure, ...
                                             vol_asset_prices, ...
                                             drift_term, ...
                                             l_size, ...
                                             class_Stocks_US_NSDQ, ...
                                             class_Stocks_US_SP);

% CALCOLO DEL LIQUIDATION COST.
Liquidation_Cost = LC_Fun(name_funds_BCC_RP, ...
                          Metaorder_Finale_byISIN, ...
                          all_Ptf_structure, l_size);

% CALIBRAZIONE PARAMETRI. 
MSCI_o_LC = 'LC';
% In questo caso invece, come parametri calibrati utilizzo quelli ricavati dalla calibrazione contro MSCI (che riteniamo il vero modello da utilizzare).
Gamma_Calibrato = Final_Calibrated_Gamma_vsMSCI;
Delta_Calibrato = Final_Calibrated_Delta_vsMSCI;
Eta_Calibrato = Final_Calibrated_eta_vsMSCI;
% Lancio il framework di calibrazione.
[Final_Calibrated_Gamma_LC, Final_Calibrated_Delta_LC, Final_Calibrated_Eta_LC] = Calibrazione_Parametri(name_funds_BCC_RP, ...
                                                                            Aleatory_Store_Decomposed, ...
                                                                            Liquidation_Cost, ...
                                                                            volume_final, ...
                                                                            l_size, ...
                                                                            vol_asset_prices, ...
                                                                            MSCI_o_LC, ...
                                                                            tao_NO_SURFACE, ...
                                                                            Gamma_Calibrato, ...
                                                                            Delta_Calibrato, ...
                                                                            Eta_Calibrato);

% CALCOLO IP CON PARAMETRI CALIBRATI.
% Ri-definisco input di modello: tempo e size (in questo caso tao sarà un vettore).
PbP = 1;
Surface = 'NO';

% CALCOLO IP POST CALIBRATION.
clear ImpactPrice_PostCalibration_Metaorder ImpactPrice_PostCalibration_Metaorder_PTF
[ImpactPrice_PostCalibration_Metaorder, ImpactPrice_PostCalibration_Metaorder_PTF]  = IP_PostCalibration(name_funds_BCC_RP, ...
                                             Aleatory_Store_Decomposed, ...
                                             all_Ptf_structure, ...
                                             Final_Calibrated_Gamma_LC, ...
                                             Final_Calibrated_Delta_LC, ...
                                             Final_Calibrated_Eta_LC, ...
                                             vol_asset_prices, ...
                                             l_size, ...
                                             tao_NO_SURFACE, ...
                                             fund, ...
                                             PbP, ...
                                             PV_store, ...
                                             Surface);
                                         
% CALCOLO KPI.
PTF_o_Titles = 'Titles';
KPI_PostCalibration_Metaorder = Calcolo_KPI(ImpactPrice_PostCalibration_Metaorder, ...
                                            IP_Decomposed_MSCI, ...
                                            name_funds_BCC_RP, ...
                                            PTF_o_Titles); 
 
PTF_o_Titles = 'PTF';                                
KPI_PostCalibration_Metaorder_PTF = Calcolo_KPI(ImpactPrice_PostCalibration_Metaorder_PTF, ...
                                             IP_Ptf_MSCI, ...
                                             name_funds_BCC_RP, ...
                                             PTF_o_Titles);  
                                         
% CALCOLO DELLE SUPERFICI (TAO > 1).
Surface = 'SI';

% CALCOLO IP POST CALIBRATION CON PIU' TAO.
[ImpactPrice_PostCalibration_Metaorder_Superficie, ImpactPrice_PostCalibration_Metaorder_PTF_Superficie]  = IP_PostCalibration(name_funds_BCC_RP, ...
                                                                                                                     Aleatory_Store_Decomposed, ...
                                                                                                                     all_Ptf_structure, ...
                                                                                                                     Final_Calibrated_Gamma_LC, ...
                                                                                                                     Final_Calibrated_Delta_LC, ...
                                                                                                                     Final_Calibrated_Eta_LC, ...
                                                                                                                     vol_asset_prices, ...
                                                                                                                     l_size, ...
                                                                                                                     tao_PROP, ...
                                                                                                                     fund, ...
                                                                                                                     PbP, ...
                                                                                                                     PV_store, ...
                                                                                                                     Surface);

                                                                                                                 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASO NEAR PROPORTIONAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %
% (DIRETTAMENTE CALCOLATO CON TAO VETTORIALE PERCHE' NON CONFRONTABILE CON MSCI).

% % CALCOLO DELLE SIZE NEL CASO NEAR PROPORIONAL.
Size_Liquidation_NearProportional_Metaorder = NearProportional_Framework(name_funds_BCC_RP, ...
                                                               IP_Weights_Final, ...
                                                               Final_Calibrated_Gamma_LC, ...
                                                               Final_Calibrated_Delta_LC, ...
                                                               Final_Calibrated_Eta_LC, ...
                                                               Aleatory_Store_Decomposed, ...
                                                               store_check_volume, ...
                                                               vol_asset_prices, ...
                                                               tao_NP, ...
                                                               l_size);

                                                          

% % Ricalcolo superficie liquidità con più tao e NP.
clear Final_After_Calibration_NP Final_After_Calibration_PTF_NP
% Calcolo dell'Impact Price per ogni size e per ogni titolo, quindi PbP = 0, ovvero non lavoriamo con vettori.
PbP = 0;
% Caricamento della funzione per il calcolo dell'IP nel caso NP.
[ImpactPrice_PostCalibration_Metaorder_NP_Superficie] = IP_PostCalibration_NearProportional(name_funds_BCC_RP, ...
                                                                   fund, ...
                                                                   Aleatory_Store_Decomposed, ...
                                                                   all_Ptf_structure, ...
                                                                   Final_Calibrated_Gamma_LC, ...
                                                                   Final_Calibrated_Delta_LC, ...
                                                                   Final_Calibrated_Eta_LC, ...
                                                                   Size_Liquidation_NearProportional_Metaorder, ...
                                                                   vol_asset_prices, ...
                                                                   tao_NP, ...
                                                                   PbP, ...
                                                                   l_size, ...
                                                                   PV_store);


% % RECUPERO SUPERFICIE NEAR PROPORTIONAL ANCHE PER OGNI PORTAFOGLIO.
% Inizializzazione.
IP_result_ptf = zeros(length(l_size),length(tao_NP),length(name_funds_BCC_RP));

% Loop per ogni portafoglio.
for j = 1 : 1 : length(name_funds_BCC_RP) 
    
    % Estrazione struttura del j-esimo portafoglio e dei titoli che contiene.
    fund_per_titoli = readtable(string(name_funds_BCC_RP(j)), 'Sheet', string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
    titles = fund_per_titoli{1:end-1, "ISINCODE"};
    fund = readtable(string(name_funds_BCC_RP(j)), 'VariableNamingRule', 'preserve');
    
    % Loop per ogni size.
    for kn = 1 : 1 : length(l_size)
        
        % Loop per ogni tao.
        for n = 1 : 1 : length(tao_NP)
    
            % Loop per ogni titolo.
            for i = 1 : 1 : (size(fund,1)-1)
                
                % Calcolo dell'IP di portafoglio nel caso NP come sommatoria degli IP dei singoli titoli ponderati per i rispettivi pesi.
                IP_result_ptf(kn,n,j) = IP_result_ptf(kn,n,j) + ...
                                        IP_Weights_Final.(name_funds_BCC_RP{j}).(titles{i}) .* ...
                                        ImpactPrice_PostCalibration_Metaorder_NP_Superficie.(name_funds_BCC_RP{j}).(titles{i})(kn,n);

            end
            
        end
        
    end
    
    % % STORING DELLA STRUTTURA FINALE.
    % Impact Price per ogni portafoglio nel caso NP:
    ImpactPrice_PostCalibration_Metaorder_NP_PTF_Superficie.(name_funds_BCC_RP{j}) = IP_result_ptf(:,:,j);   
        
    % Pulizia per evitare re-writing.
    clear fund titles fund_per_titoli
            
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT SUPERFICI CALIBRATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % %

% % NB: il tao e l_size devono avere la stessa lunghezza del Impact Price di ogni titolo o di ogni portafoglio usati nel caso PROPORTIONAL. 
% % NB: Tao deve essere > 1 per ottenere i plot.

% Definizione di una variabile binaria per il plot per ogni portafoglio (= 0) o per ogni titolo di ogni portafoglio (= 1).
% !NB!: qualora si volesse ottenere la superficie titolo per titolo, conviene "eliminare" il primo loop, ovvero definire i = al numero del portafoglio
%       che contiene quel titolo. In questo modo, si ottengono 20 plot (se si considera l'analisi con 20 titoli per ogni portafoglio. Lasciando i = 1 :
%       1 : length(name_funds_BCC_RP) il codice gira lo stesso, ma si ottiene un numero di plot elevato, pari a (titoli in portafoglio x numero di portafoglio analizzati).
all_assets = 0;
% Definizione della variabile subtitle che indicherà il singolo ISIN nel caso in cui all_assets è attivata (= 1).
subtitle = all_assets;
% Variabile "di supporto" per inserire il titles nel caso si vuole il plot solo per ogni portafoglio (hint: potrebbe essere sostituita da uno swtich/case).
empty = 0;

% % % PROPORTIONAL PLOT. 
PROP_o_NP = 'PROP';
[Surface_Prop_Metaorder] = Framework_Plot(name_funds_BCC_RP, ...
                           l_size_plot, tao_PROP, ...
                           ImpactPrice_PostCalibration_Metaorder_Superficie, ImpactPrice_PostCalibration_Metaorder_PTF_Superficie, ...
                           subtitle, empty, all_assets, PROP_o_NP);
                       
% % % NEAR PROPORTIONAL PLOT.
% NB: solo empty = 0, perché NP è di portafoglio.
empty = 0;
PROP_o_NP = 'NP';
[Surface_NP_Metaorder] = Framework_Plot(name_funds_BCC_RP, ...
                           l_size_plot, tao_NP, ...
                           ImpactPrice_PostCalibration_Metaorder_Superficie, ImpactPrice_PostCalibration_Metaorder_NP_PTF_Superficie, ...
                           subtitle, empty, all_assets, PROP_o_NP);
                       
                       
                       
                       
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONVERSIONI FINALI MATRICI IN TABELLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % % 
% LA CONVERSIONE E' FATTA DIRETTAMENTE SOLO SULLE SUPERFICI.

% Definisco nome colonne in accordo con lunghezza tao.
str_PROP = strings(1,length(tao_PROP));
str_NP = strings(1,length(tao_NP));
for s = 1 : 1 : length(tao_PROP)
    str_PROP(s) = "Day " + tao_PROP(s);
end
for s = 1 : 1 : length(tao_NP)
    str_NP(s) = "Day " + tao_NP(s);
end

% % % OUTPUT FINALI IN FORMATO STRUTTURA + TABELLA.

    [Output_IP_PTF_CalibrazioneMSCI, ...
    Output_IP_NP_PTF_CalibrazioneMSCI, ...
    Output_IP_PTF_CalibrazioneMetaorder, ...
    Output_IP_NP_PTF_CalibrazioneMetaorder, ...
    Output_IP_Titoli_CalibrazioneMSCI, ...
    Output_IP_NP_Titoli_CalibrazioneMSCI, ...
    Output_IP_Titoli_CalibrazioneMetaorder, ...
    Output_IP_NP_Titoli_CalibrazioneMetaorder] = EstrazioneOutputFinali(name_funds_BCC_RP, ...
    ImpactPrice_PostCalibration_vsMSCI_Superficie, str_PROP, ImpactPrice_PostCalibration_vsMSCI_NP_Superficie, ...
    str_NP, ImpactPrice_PostCalibration_Metaorder_Superficie, ImpactPrice_PostCalibration_Metaorder_NP_Superficie, ...
    ImpactPrice_PostCalibration_vsMSCI_PTF_Superficie, ImpactPrice_PostCalibration_vsMSCI_NP_PTF_Superficie, ...
    ImpactPrice_PostCalibration_Metaorder_PTF_Superficie, ImpactPrice_PostCalibration_Metaorder_NP_PTF_Superficie);   


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % % 

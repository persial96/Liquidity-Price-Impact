%% Funzione per simulare Stock Paths con BROWNIAN BRIDGE.

function price = Brownian_Bridge_Prova(O, C, drift, vol, traiding_days)

    % ------------------------------------------------------------------------------------------
    % Funzione che simula scenari di prezzo utilizzando un processo del tipo
    % Brownian Bridge, con punto di inizio uguale ad O (Open Price) e punto
    % finale uguale a C (Close Price).
    % OUTPUT PRINCIPALI:
    % > price, una matrice di dimensioni n_simulations x traiding_days, che
    %   contiene i prezzi simulati.
    % ------------------------------------------------------------------------------------------
    
    % Numero di paths.
    n_simulations = 1000;

    % Inizializzazione e storing dei valori di apertura e chiusura.
    dt = 1/(traiding_days-1);
    x = zeros(n_simulations, traiding_days);
    x(:,1) = O;
    x(:,end) = C;

    % Calcolo del drift in log.
    drift_in_logspace = drift - 0.5 * vol^2;

    % Brownina Bridge.
        for n = 2 : 1 : (traiding_days-1)

            s = n * dt;
            t = s - dt;
            T = 1;
            a = x(:, n - 1);
            b = x(:, end);
            dw = (b - a - drift_in_logspace * (T - t)) / vol;
            mean = (s - t) / (T - t) * dw;
            var = (T - s) * (s - t) / (T - t);
            samples = mean + sqrt(var) * randn(n_simulations,1);
            x(:, n) = a + drift_in_logspace * dt + vol * samples;   

        end

    % Storing dell'output.
    price = x;

end


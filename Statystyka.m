for plik_num = 1:69
    folder = 'poziom0'; 
    nazwa_pliku = sprintf('%s/0_%d.csv', folder, plik_num);
     try
        T = readtable(nazwa_pliku,'Delimiter', ',');
    catch
        fprintf('Nie udało się wczytać pliku: %s – pomijam.\n', nazwa_pliku);
        continue;  % Przejdź do następnej iteracji
    end
    
    mac_column = T{:,1};
    mac_column = string(mac_column);
    is_mac = ~startsWith(mac_column, "Scan");
    mac_addresses = mac_column(is_mac);
    unique_mac = unique(mac_addresses);
    tabela = T{:,[1 3]}
    % Załóżmy, że dane są w cell array o nazwie 'tabela'
    % i kolumna 2 zawiera wartości typu '-79.00dBm' albo ''
    
    for i = 1:size(tabela,1)
        rssi = tabela{i,2};  % pobierz tekst z 2. kolumny
        if ~isempty(rssi)
            % Usuń 'dBm' i zamień na liczbę
            cleaned = strrep(rssi, 'dBm', '');
            tabela{i,2} = str2double(cleaned);
        else
            % Pozostaw puste
            tabela{i,2} = NaN;
        end
    end
    
    % Krok 1: Usuń wiersze typu 'Scan #' (czyli tam, gdzie MAC nie jest adresem)
    macs_all = tabela(:,1);     % Pierwsza kolumna (adresy MAC lub 'Scan #')
    rssi_all = tabela(:,2);     % Druga kolumna (liczby lub NaN)
    
    % Filtruj tylko prawidłowe adresy MAC (pomijamy 'Scan #' itd.)
    is_mac = cellfun(@(x) contains(x, ':'), macs_all);  % Adres MAC zawiera ':'
    
    macs = macs_all(is_mac);
    rssi = cell2mat(rssi_all(is_mac));
    
    % Krok 2: Znajdź unikalne adresy MAC
    unique_macs = unique(macs);
    
    % Krok 3: Dla każdego MAC-a zbierz przypisane do niego wartości RSSI
    mac_tabela = struct();  % struktura do przechowywania wyników
    
    for i = 1:length(unique_macs)
        mac = unique_macs{i};
        
        % Indeksy wszystkich wystąpień danego MAC-a
        idx = strcmp(macs, mac);
        
        % Przypisane wartości RSSI
        rssi_values = rssi(idx);
        
        % Zapisz do struktury (np. mac_tabela.mac1 = [-79, -81, ...])
        mac_tabela.(matlab.lang.makeValidName(mac)) = rssi_values;
    end
    
    % docelowa liczba pomiarów (liczba skanów)
    N = 300;
    
    % Przejdź po wszystkich MAC-ach w strukturze
    mac_fields = fieldnames(mac_tabela);
    
    for i = 1:length(mac_fields)
        mac = mac_fields{i};
        values = mac_tabela.(mac);
        len = length(values);
        
        if len < N
            % ile brakujących wartości?
            missing = N - len;
            
            % uzupełnij wektorem -100
            values = [values; repmat(-1000, missing, 1)];
            
            % zapisz z powrotem
            mac_tabela.(mac) = values;
        end
    end
    
    
    mac_fields = fieldnames(mac_tabela);
    figure;
    hold on;
    
    colors = lines(length(mac_fields));  % paleta kolorów
    
    for i = 1:length(mac_fields)
        mac = mac_fields{i};
        values = mac_tabela.(mac);
        
        % Estymacja gęstości
        [f, xi] = ksdensity(values,'Bandwidth',50);
        
        % Wykres
        plot(xi, f, 'DisplayName', mac, 'Color', colors(i,:));
    end
    
    hold off;
    xlabel('RSSI [dBm]');
    ylabel('Gęstość');
    title(sprintf('Kernel Density Estimate dla adresów MAC (%s)', nazwa_pliku));
    legend('Location', 'best');
    grid on;
    xticks(-1200:20:100);
    set(gcf, 'Position', [0,0,1920, 1080]);  % [x, y, width, height]
    % Ścieżka do folderu, gdzie chcesz zapisać plik
    folderPath = 'C:\Users\Damian\OneDrive\Obrazy\Dokumenty\PomiarymocysygnałuProjektBadawczy\wykresy';
    
    % Nazwa pliku PNG
    fileName = sprintf('0_%d.png', plik_num);;
    
    % Pełna ścieżka do zapisu
    fullFilePath = fullfile(folderPath, fileName);
    
    % Upewnij się, że folder istnieje – jeśli nie, to go utwórz
    if ~exist(folderPath, 'dir')
        mkdir(folderPath);
    end
    
    % Zapis figury jako plik PNG
    saveas(gcf, fullFilePath);
end

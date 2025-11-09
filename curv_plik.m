clear; clc; close all;

% === 1. Folder z danymi ===
input_folder = 'poziom0';  % <-- tu umieść swoje pliki CSV
files = dir(fullfile(input_folder, '*.csv'));

if isempty(files)
    error('Brak plików CSV w folderze: %s', input_folder);
end

fprintf('\n=== Analiza RSSI dla %d plików CSV ===\n\n', numel(files));

% === 2. Folder wyjściowy ===
main_outdir = 'Wyniki_RSSI';
if ~exist(main_outdir, 'dir')
    mkdir(main_outdir);
end

% === 3. Pętla po wszystkich plikach ===
for f = 1:numel(files)
    filename = files(f).name;
    filepath = fullfile(input_folder, filename);
    fprintf('Przetwarzanie pliku: %s\n', filename);

    % === Wczytanie danych ===
    fid = fopen(filepath, 'r');
    data = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    data = data{1};

    % === Parsowanie danych (MAC, RSSI) ===
    macs = {};
    rssi = [];
    for i = 1:length(data)
        line = data{i};
        parts = split(line, ',');
        if numel(parts) >= 3
            mac = strtrim(parts{1});
            rssi_str = strrep(parts{3}, 'dBm', '');
            val = str2double(rssi_str);
            if ~isnan(val)
                macs{end+1,1} = mac;
                rssi(end+1,1) = val;
            end
        end
    end

    unique_macs = unique(macs);
    fprintf('Znaleziono %d unikalnych adresów MAC\n', numel(unique_macs));

    % === Folder na wyniki dla tego pliku ===
    outdir = fullfile(main_outdir, erase(filename, '.csv'));
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    % === Przygotowanie tabeli wyników ===
    results = table('Size', [0 10], ...
        'VariableTypes', {'string','double','double','double','double','double','double','double','double','double'}, ...
        'VariableNames', {'MAC','a1','b1','c1','R2','RMSE','SSE','p_chi2','p_ks','p_ad'});

    % === Analiza każdego MAC ===
    for m = 1:numel(unique_macs)
        mac = unique_macs{m};
        idx = strcmp(macs, mac);
        rssi_mac = rssi(idx);

        if numel(rssi_mac) < 10
            fprintf(' MAC %s: za mało danych (%d pomiarów)\n', mac, numel(rssi_mac));
            continue;
        end

% === Histogram ===
[counts, edges] = histcounts(rssi_mac, 'Normalization', 'pdf');
centers = edges(1:end-1) + diff(edges)/2;

% Usuń punkty zerowe (bez danych)
nonzero_idx = counts > 0;
centers = centers(nonzero_idx);
counts = counts(nonzero_idx);

% Sprawdź, czy mamy wystarczającą ilość punktów do dopasowania
if numel(centers) < 3
    fprintf('  MAC %s: zbyt mało danych do dopasowania Gaussa (%d punktów)\n', mac, numel(centers));
    continue;
end

% === Dopasowanie Gaussa ===
% === Dopasowanie Gaussa z ograniczeniami i obsługą błędów ===
ft = fittype('gauss1');

% Początkowe wartości i ograniczenia
startA = max(counts);
startB = mean(rssi_mac);
startC = std(rssi_mac);

opts = fitoptions('Method', 'NonlinearLeastSquares', ...
    'StartPoint', [startA, startB, startC], ...
    'Lower', [0, min(rssi_mac)-10, 0.1], ...
    'Upper', [2*max(counts), max(rssi_mac)+10, 10*std(rssi_mac)], ...
    'Display', 'off');

try
    [curve_fit, gof] = fit(centers', counts', ft, opts);
catch ME
    fprintf('MAC %s: dopasowanie Gaussa nie powiodło się (%s)\n', mac, ME.message);
    continue; % przejdź do kolejnego MAC
end


        % === Testy normalności ===
        rssi_clean = rssi_mac(~isnan(rssi_mac) & ~isinf(rssi_mac));
        try, [~, p_chi2] = chi2gof(rssi_clean); catch, p_chi2 = NaN; end
        try, [~, p_ks] = kstest((rssi_clean - mean(rssi_clean)) / std(rssi_clean)); catch, p_ks = NaN; end
        try, [~, p_ad] = adtest(rssi_clean); catch, p_ad = NaN; end

        % === Wykres ===
        fig = figure('Visible','off');
        plot(curve_fit, centers, counts, 'o');
        title(sprintf('Dopasowanie Gaussa + testy normalności\nMAC: %s', mac), 'Interpreter', 'none');
        xlabel('RSSI [dBm]');
        ylabel('Prawdopodobieństwo');
        legend('Dane pomiarowe', 'Dopasowany Gauss', 'Location', 'best');
        grid on;

        % === Opis wyników na wykresie ===
        annotation_text = sprintf(['R^2 = %.4f | RMSE = %.4f\n' ...
            'p(χ²) = %.4e | p(KS) = %.4e | p(AD) = %.4e'], ...
            gof.rsquare, gof.rmse, p_chi2, p_ks, p_ad);

        ax = gca;
        x_lim = ax.XLim;
        y_lim = ax.YLim;
        text(x_lim(1) + 0.7*(x_lim(2) - x_lim(1)), ...
             y_lim(1) + 0.9*(y_lim(2) - y_lim(1)), ...
             annotation_text, ...
             'FontSize', 10, ...
             'BackgroundColor', [1 1 1 0.8], ...
             'EdgeColor', [0.8 0.8 0.8], ...
             'VerticalAlignment', 'top', ...
             'HorizontalAlignment', 'left');

        % === Zapis wykresu jako PNG (300 dpi) ===
        safe_mac = strrep(mac, ':', '-');
        png_name = sprintf('%s_%s.png', erase(filename, '.csv'), safe_mac);
        exportgraphics(fig, fullfile(outdir, png_name), 'Resolution', 300);
        close(fig);

        fprintf('   Zapisano wykres PNG dla %s\n', mac);

        % === Zapis wyników do tabeli ===
        new_row = {mac, curve_fit.a1, curve_fit.b1, curve_fit.c1, ...
                   gof.rsquare, gof.rmse, gof.sse, ...
                   p_chi2, p_ks, p_ad};
        results = [results; new_row];
    end

    % === Zapis wyników do CSV ===
    out_file = fullfile(outdir, sprintf('wyniki_%s', filename));
    writetable(results, out_file);
    fprintf(' Wyniki zapisano: %s\n\n', out_file);
end

fprintf('\nZakończono analizę wszystkich plików!\n');
fprintf(' Wszystkie wyniki i wykresy zapisano w folderze: %s\n', main_outdir);

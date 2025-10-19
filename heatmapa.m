% Wczytanie danych z pliku CSV
dane = readtable('daneMapaCieplna.csv');  % Załaduj tabelę z pliku CSV

% Zidentyfikowanie ostatniej kolumny
last_column = dane{:, end};  % {dane(:, end)} wyciąga dane z ostatniej kolumny

% Filtruj wiersze, gdzie ostatnia kolumna ma wartość 1
filtered_data = dane(last_column == 1, [1, end]);  % Wybór pierwszej i ostatniej kolumny

% Wyświetlenie wyników
disp(filtered_data);
dupa=dane(1:101,[1,144,145]);
x = dupa.x;  % Kolumna x
y = dupa.y;  % Kolumna y
z = dupa.x9c_d5_7d_7a_58_cf;  % Kolumna z (wartości do mapowania na kolory)

% Tworzenie siatki punktów na podstawie unikalnych wartości x i y
[X, Y] = meshgrid(unique(x), unique(y));

% Wartości w siatce (spłaszczamy dane do macierzy Z)
Z = NaN(length(unique(y)), length(unique(x)));  % Inicjalizujemy NaN, aby później przypisać wartości

% Wypełnianie macierzy Z odpowiednimi wartościami
for i = 1:length(x)
    xi = find(unique(x) == x(i));  % Znajdowanie indeksu dla x
    yi = find(unique(y) == y(i));  % Znajdowanie indeksu dla y
    Z(yi, xi) = z(i);  % Przypisanie wartości z kolumny 'x9c_d5_7d_7a_58_cf'
end

% Tworzenie heatmapy
figure;
h=heatmap(unique(x), unique(y), Z, 'Colormap', jet);
h.YDisplayData = flipud(h.YDisplayData);  % equivalent to 'YDir', 'Reverse'
% Dodanie etykiet
xlabel('X [m]');
ylabel('Y [m]');
title('Heatmapa dla punktu dostępowego 9c:d5:7d:7a:58:cf poziom 0');

figure
w=heatmap(dupa,'x','y','ColorVariable','x9c_d5_7d_7a_58_cf')
w.YDisplayData = flipud(h.YDisplayData);  % equivalent to 'YDir', 'Reverse'


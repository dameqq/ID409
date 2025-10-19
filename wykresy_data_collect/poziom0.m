
% Współrzędne ścian (poziomych)
walls = [
    0, 0.1;
    5.2, 5.3;
    7.9, 8.0;
];
hold on
% Przykładowe punkty (możesz zmienić na swoje)
x = [0 0 25 25 29 29 64 64 79 79 114 114 0 0 25 25 0 0 25 25 27 27 29 29 68 29 29 79 77 77 79 79 82 82 114 114 82 114 64 64 64 68 68 70 70 47 46 68 70 70 95 97 78 78 78 76 76 70 70 68 68 0];
y = [0 5.2 5.2 0 0 5.2 5.2 0 0 5.2 5.2 0 0 7.9 7.9 13.6 13.6 7.9 7.9 25.5 25.5 13.6 13.6 7.9 7.9 7.9 13.6 13.6 13.6 7.9 7.9 13.6 13.6 7.9 7.9 13.6 13.6 13.6 13.6 7.9 13.6 13.6 18.6 18.6 36 36 26 18.6 18.6 36 36 26 18.6 13.6 18.6 18.6 36 36 18.6 18.6 13.6 13.6];

% Domknięcie kształtu (jeśli chcesz zamknąć go w pętlę)
x(end+1) = x(1);
y(end+1) = y(1);
corridor_length = 115
corridor_width = 36
% Rysowanie
plot(x, y, 'LineWidth', 2);
grid on;
axis equal;
title('Łączenie punktów w kształt');
xlabel('X');
ylabel('Y');
%test point poziom1
x_tp = [13,25.81,25.81,43.4,68.5,80,86,102,107,112]
y_tp = [6,26.71,17.23,5.3,3.9,8.5,5.9,5.3,6.5,7.8]
plot(x_tp, y_tp, 'r.','MarkerSize', 25);
%
% Parametry rozmieszczenia RP
x_step = 5;
y_step = 1.3;
x_rp = 5:x_step:114;
y_rp = [5.3,6.5,7.8]

% Tworzenie siatki punktów RP
[X_rp, Y_rp] = meshgrid(x_rp, y_rp);

% Rysowanie RP
x_rp1=[26,26,26,26,26,26,26,70,70,72.5,72.5,75, 65,65,70,70,75,75,70,72.5,75,70,72.5,75,72.5,72.5,72.5,72.5,72.5,72.5,72.5]
y_rp2= [8.6,11.1,13.6,16.1,18.6,21.1,23.6,12.8,10.3,12.8,10.3,12.8,0.1,2.6,0.1,2.6,0.1,2.6,15.3,15.3,15.3,17.8,17.8,17.8 35.3,20.3,22.8,25.3,27.8,30.3,32.8]
plot(X_rp, Y_rp, 'b.', 'MarkerSize', 25);
plot(x_rp1,y_rp2,'b.', 'MarkerSize', 25);



% Styl wykresu
axis equal;
xlim([0 corridor_length]);
ylim([0 corridor_width]);
xlabel('X [m]');
ylabel('Y [m]');
title('Rozkład punktów dla 0 piętra budynku stare ETI Politechnika Gdańska');
grid on;
legend('Ściany budynku', 'punkty testowe','punkty referencyjne')
xticks(0:5:115)
yticks(0:2:36)
set(gca, 'Position', [0.03 0.1 0.95 0.8]);  % [x y width height]
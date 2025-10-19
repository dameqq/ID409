import csv
import os

# Pobierz dane od użytkownika
plik_wejsciowy = input("Podaj nazwę pliku CSV wejściowego (np. dane.csv): ")

# Sprawdź czy plik istnieje
if not os.path.isfile(plik_wejsciowy):
    print(f"Plik '{plik_wejsciowy}' nie istnieje.")
    exit()

wartosc_do_zmiany = input("Podaj wartość do zamiany w 5. kolumnie: ")
nowa_wartosc = input("Podaj nową wartość: ")

# Zmieniamy nazwę pliku wyjściowego, żeby nie nadpisać oryginału
plik_wyjsciowy = plik_wejsciowy

# Wczytanie i modyfikacja danych
with open(plik_wejsciowy, newline='', encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    wiersze = []
    for wiersz in reader:
        if len(wiersz) > 4 and wiersz[4] == wartosc_do_zmiany:
            wiersz[4] = nowa_wartosc
        wiersze.append(wiersz)

# Zapis do nowego pliku
with open(plik_wyjsciowy, 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile, delimiter=',')
    writer.writerows(wiersze)

print(f"Zakończono. Zmienione dane zapisano do pliku: {plik_wyjsciowy}")

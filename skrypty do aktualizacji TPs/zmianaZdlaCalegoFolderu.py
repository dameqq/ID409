import csv
import os


folder_path = 'poziom7'  # <- zmień na rzeczywistą ścieżkę
files_list = []

# Iteracja po plikach w folderze
for filename in os.listdir(folder_path):
    file_path = os.path.join(folder_path, filename)
    if os.path.isfile(file_path):
        files_list.append(file_path)

print(files_list)
# Pobierz dane od użytkownika

for path in files_list:
    plik_wejsciowy = path
    #plik_wejsciowy = input("Podaj nazwę pliku CSV wejściowego (np. dane.csv): ")
    print(path)
    # Sprawdź czy plik istnieje
    if not os.path.isfile(plik_wejsciowy):
        print(f"Plik '{plik_wejsciowy}' nie istnieje.")
        exit()

    wartosc_do_zmiany = '27.9'
    nowa_wartosc = '25.9'

    # Zmieniamy nazwę pliku wyjściowego, żeby nie nadpisać oryginału
    plik_wyjsciowy = plik_wejsciowy

    # Wczytanie i modyfikacja danych
    with open(plik_wejsciowy, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        wiersze = []
        for wiersz in reader:
           
            
            if len(wiersz) > 4 and wiersz[6] == wartosc_do_zmiany:
                wiersz[6] = nowa_wartosc
                
            wiersze.append(wiersz)

    # Zapis do nowego pliku
    with open(plik_wyjsciowy, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        writer.writerows(wiersze)

    print(f"Zakończono. Zmienione dane zapisano do pliku: {plik_wyjsciowy}")
    

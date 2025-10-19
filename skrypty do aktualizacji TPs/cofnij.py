



import os
import csv
import re

# Zmień tę ścieżkę na folder, gdzie masz swoje pliki .csv
folder_path = "C:\\Users\\Damian\\OneDrive\\Obrazy\\Dokumenty\\PomiarymocysygnałuProjektBadawczy\\poziom0"  # <- Zmień na odpowiedn



# Dla plików 1_NR.csv (bez liter) – y wg reszty z dzielenia przez 3, x dowolne
def expected_y_for_regular(rp_number):
    mod = rp_number % 3
    if mod == 1:
        return 5.3
    elif mod == 2:
        return 6.5
    else:
        return 7.8

# Dla plików 1_NR d (d = dolne)
expected_values_d = {
    1: (26, 8.6),
    2: (26, 11.1),
    3: (26, 13.6),
    4: (26, 16.1),
    5: (26, 18.6),
    6: (26, 21.1),
    7: (26, 23.6),
    8: (26, 25.0),
}

# Dla plików 1_NR h (h = wysokie)
expected_values_h = {
    1: (70, 10.3),
    2: (70, 12.8),
    3: (72.5, 10.3),
    4: (72.5, 12.8),
    5: (75, 10.3),
    6: (75, 12.8),
}

def process_file(file_path, new_file_path, expected_x=None, expected_y=None):
    x_values = []
    y_values = []

    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter=',')
        for row in reader:
            if len(row) < 7 or row[0].strip().startswith("Scan"):
                continue
            try:
                x = float(row[4].strip())
                y = float(row[5].strip())
                x_values.append(x)
                y_values.append(y)
            except ValueError:
                continue

    # Sprawdzanie expected_x, jeśli podane
    if expected_x is not None:
        if not all(abs(x - expected_x) < 0.1 for x in x_values):
            print(f"[BŁĄD X] {file_path}: x nie jest równy {expected_x} dla wszystkich wierszy")

    # Sprawdzanie expected_y, jeśli podane
    if expected_y is not None:
        if not all(abs(y - expected_y) < 0.1 for y in y_values):
            print(f"[BŁĄD Y] {file_path}: y nie jest równe {expected_y} dla wszystkich wierszy")

    # Jeśli nie podano expected_x, sprawdzaj zmianę x co 5
    if expected_x is None and x_values:
        unique_x = sorted(set(x_values))
        for i in range(1, len(unique_x)):
            delta = unique_x[i] - unique_x[i - 1]
            if abs(delta - 5) > 0.1:
                print(f"[BŁĄD X] {file_path}: x nie zmienia się co 5 (różnica {delta})")
                break

    # Jeśli nie podano expected_y i to plik bez liter, sprawdzaj y wg reszty z dzielenia przez 3
    if expected_y is None and y_values:
        pass  # już obsłużone powyżej lub można rozszerzyć jeśli trzeba

    # Zmiana nazwy pliku
    os.rename(file_path, new_file_path)
    print(f"[OK] Zmieniono nazwę: {os.path.basename(file_path)} → {os.path.basename(new_file_path)}")

# Główna pętla
for filename in os.listdir(folder_path):
    # Obsługa nazw 1_NR.csv, 1_NR d.csv, 1_NR h.csv
    m = re.match(r"0_(\d+)([dh])?\.csv", filename)
    if m:
        rp_number = int(m.group(1))
        suffix = m.group(2)  # 'd', 'h' lub None

        old_path = os.path.join(folder_path, filename)
        new_filename = f"1_{rp_number}"
        if suffix:
            new_filename += suffix
        new_filename += ".csv"
        new_path = os.path.join(folder_path, new_filename)

        if suffix == 'd':
            expected_x, expected_y = expected_values_d.get(rp_number, (None, None))
        elif suffix == 'h':
            expected_x, expected_y = expected_values_h.get(rp_number, (None, None))
        else:
            expected_x = None
            expected_y = expected_y_for_regular(rp_number)

        process_file(old_path, new_path, expected_x, expected_y)

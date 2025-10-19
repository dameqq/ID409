import csv,sys
import difflib
testPoints =[]
poziomy =['poziom0','poziom1','poziom2','poziom3','poziom4','poziom5','poziom6','poziom7']
for i in range(0, 8):  # Pętla po numerach od 1 do 7
    if i == 0:
        # Dla i == 0 dodajemy dodatkowe ciągi '0_1d', '0_1h', ...
        for k in range(1, 9):  # Tylko jeden numer dla j (j = 1)
            testPoints.append(f"poziom0/0_{k}d.csv")
        for k in range(1, 26):  # Tylko jeden numer dla j (j = 1)    
            testPoints.append(f"poziom0/0_{k}h.csv")
    if i > 0:
        # Dla i == 0 dodajemy dodatkowe ciągi '0_1d', '0_1h', ...
        for k in range(1, 8):  # Tylko jeden numer dla j (j = 1)
            testPoints.append(f"poziom{i}/{i}_{k}d.csv")
        for k in range(1, 7):  # Tylko jeden numer dla j (j = 1)    
            testPoints.append(f"poziom{i}/{i}_{k}h.csv")
    for j in range(1, 70):  # Pętla po numerach od 1 do 69
        testPoints.append(f"poziom{i}/{i}_{j}.csv")  # Tworzenie stringa w formacie 'i_j' i dodanie do listy

# Jeśli chcesz wyświetlić wynik:
print(testPoints)
#testPoints = ['poziom4/4_1.csv','poziom4/4_11.csv','poziom4/4_50.csv']       
w = 0
adresy =[]
for file_name in testPoints:
    try:
        with open(file_name,'r') as csv_file, \
            open('plik_wyjsciowy.csv', 'w',newline='') as outfile:
            csv_reader = csv.reader(csv_file)
            writer = csv.writer(outfile)
        
                            
            for line in csv_reader:
                if len(line) > 1 and any(cell.strip() for cell in line):
                    adress = line[0]
                    x = line[4]
                    y = line[5]
                    z = line[6]
                    moc = line[2]
                    line[2]= moc.replace('dBm','')
                    #writer.writerow(line)  # Zapisujemy tylko te linie, które mają więcej niż jeden element
                    adresNow = line[0].replace(" ", "") # Pobieramy wartość z pierwszej kolumny
                    
                    # Sprawdzamy, czy wartość z pierwszej kolumny już jest w tablicy
                    if adresNow in adresy:
                        #print(f"Znaleziono duplikat: {adresNow}")
                        continue
                    else:
                        # Jeśli nie ma duplikatu, dodajemy do tablicy
                        adresy.append(adresNow)
                        #adresy.append(file_name)
                        w=w+ 2
                        #adresy.append(file_name)
                        #print(f"Nowa wartość: {adresNow}")
                    #print(line)
                else:
                    #print(f"Pomijam linię: {line}")  # Wydrukuj linię, jeśli jest niewłaściwa (opcja do debugowania)
                    continue
            print(adresy)
            print(len(adresy))
    except FileNotFoundError:
    # Jeśli plik nie istnieje, zostanie wyświetlony ten komunikat
        print("Błąd: Plik nie istnieje!")
with open('baza.csv', 'a',newline='') as outfile:
    writer = csv.writer(outfile)
    adresy.append('x')
    adresy.append('y')
    adresy.append('z')
    writer.writerow(adresy)
for file_name in testPoints:
    try:       
        with open(file_name,'r') as csv_file, \
            open('baza.csv', 'a',newline='') as outfile:
            csv_reader = csv.reader(csv_file)
            writer = csv.writer(outfile)
           
            liniaDanych=[]
            for w in range(0,len(adresy)):
                liniaDanych.append('-100')
                
            lines = list(csv_reader)
            
            # Iterujemy przez linie
            for index, line in enumerate(lines):
            #first_line = next(csv_reader, None) 
            #for line in csv_reader:
                if len(line) > 2 and any(cell.strip() for cell in line):
                    adres = line[0]
                    moc = line[2].replace('dBm','').replace('.00','')
                    
                    #liniaDanych[-3] = line[4].replace('.',',')
                    #liniaDanych[-2] = line[5].replace('.',',')
                    #liniaDanych[-1] = line[6].replace('.',',')
                    liniaDanych[-3] = line[4]
                    liniaDanych[-2] = line[5]
                    liniaDanych[-1] = line[6]
                    for w in range(0,len(adresy)):
                        if adres == adresy[w]:
                            liniaDanych[w] = moc
                    if index == len(lines) - 1:  # Ostatnia linia
                        writer.writerow(liniaDanych)

                else:
                    
                    if index == 0:  # Ostatnia linia
                        continue
                    writer.writerow(liniaDanych)
                    
                    liniaDanych=[]
                    for w in range(0,len(adresy)):
                        liniaDanych.append('-100')
    except FileNotFoundError:
    # Jeśli plik nie istnieje, zostanie wyświetlony ten komunikat
        print("Błąd: Plik nie istnieje!")




            
import os
import requests
import csv
from datetime import datetime, timedelta
import time

def descargar_archivo(url, nombre_archivo, intentos=5):
    for i in range(intentos):
        response = requests.get(url)
        if response.status_code == 200:
            with open(nombre_archivo, "wb") as file:
                file.write(response.content)
            return True
        else:
            print(f"Error al descargar el archivo (Intento {i+1})")
            time.sleep(1)  # Esperar un segundo antes de intentar nuevamente
    return False

fecha = input("Por favor, ingresa una fecha de Pronóstico de demanda (YYYY-MM-DD): ")
print("La fecha escogida es,", fecha)

year, month, day = map(int, fecha.split('-'))

url_base = "https://app-portalxmcore01.azurewebsites.net/administracion-archivos/ficheros/descarga-archivo?ruta=M:/InformacionAgentes/Usuarios/Publico/DEMANDAS/Pronostico%20Oficial/YYYY-MM/PRONSINMMDD.txt&nombreBlobContainer=storageportalxm"

nueva_seccion = f"{year}-{month:02d}/PRONSIN{month:02d}{day:02d}.txt"
url = url_base.replace("YYYY-MM/PRONSINMMDD.txt", nueva_seccion)

if descargar_archivo(url, f"url_para_descargar_{year}.txt"):
    with open(f"url_para_descargar_{year}.txt", "r") as file:
        first_line = file.readline()
        url = first_line.split('"url":"')[1].split('"')[0]
        if descargar_archivo(url, f"pronostico_demanda/PRONSIN{year}_{month:02d}{day:02d}.csv"):
            os.remove(f"url_para_descargar_{year}.txt")
        else:
            print("Error al descargar el archivo CSV")
else:
    print("Error al descargar el archivo")
    exit()

# Transformation --------------------------------------------------
archivo_fuente = f"pronostico_demanda/PRONSIN{year}_{month:02d}{day:02d}.csv"
archivo_salida2 = f"pronostico_demanda/T2PRONSIN{year}_{month:02d}{day:02d}.csv"

with open(archivo_fuente, 'r') as csv_file:
    csv_reader = csv.reader(csv_file)
    transposed_data = zip(*csv_reader)

with open(archivo_salida2, 'w', newline='') as csv_file:
    csv_writer = csv.writer(csv_file)
    csv_writer.writerows(transposed_data)

archivo_salida = f"pronostico_demanda/TPRONSIN{year}_{month:02d}{day:02d}.csv"

fecha_actual = datetime(year, month, day)
with open(archivo_salida2, 'r') as csv_file:
    with open(archivo_salida, 'w', newline='') as output_csv:
        csv_reader = csv.reader(csv_file)
        csv_writer = csv.writer(output_csv)
        csv_writer.writerow(['Fecha'] + next(csv_reader))
        for row in csv_reader:
            csv_writer.writerow([fecha_actual.strftime('%Y-%m-%d')] + row)
            fecha_actual += timedelta(days=1)

os.remove(archivo_salida2)

echo "Por favor, ingresa una fecha de Pronóstico de demanda (YYYY-MM-DD):"
read fecha

echo "La fecha escogida es, $fecha"

year=$(echo "$fecha" | cut -d '-' -f 1)
month=$(echo "$fecha" | cut -d '-' -f 2)
day=$(echo "$fecha" | cut -d '-' -f 3)

url_base="https://app-portalxmcore01.azurewebsites.net/administracion-archivos/ficheros/descarga-archivo?ruta=M:/InformacionAgentes/Usuarios/Publico/DEMANDAS/Pronostico%20Oficial/YYYY-MM/PRONSINMMDD.txt&nombreBlobContainer=storageportalxm"

nueva_seccion="$year-$month/PRONSIN$month$day.txt"
url=$(echo "$url_base" | sed "s#YYYY-MM/PRONSINMMDD.txt#$nueva_seccion#g")

wget -O "url_para_descargar.txt" -t 5 "$url"

head -n 1 url_para_descargar.txt | grep -o '"url":"[^"]*"' | cut -c 7- | xargs wget -O pronostico_demanda/PRONSIN$month$day.csv

rm -rf url_para_descargar.txt

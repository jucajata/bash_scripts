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


# Transformation --------------------------------------------------
# Nombre del archivo CSV de entrada

archivo_fuente="pronostico_demanda/PRONSIN$month$day.csv"

# Nombre del archivo CSV de salida
archivo_salida2="pronostico_demanda/T2PRONSIN$month$day.csv"

# Usamos awk para realizar la transposición
awk -F, '{
    for (i=1; i<=NF; i++) {
        if (NR == 1) {
            col[i] = $i -n;
        } else {
            col[i] = col[i] "," $i -n;
        }
    }
}
END {
    for (i=1; i<=NF; i++) {
        print col[i];
    }
}' "$archivo_fuente" > "$archivo_salida2"

archivo_salida="pronostico_demanda/TPRONSIN$month$day.csv"

# Agregar la columna de fechas al principio del archivo
awk -v fecha="$fecha" 'BEGIN {FS=OFS=","} {
    if (NR == 1) {
        print "Fecha", $0
    } else {
        print fecha, $0
        cmd = "date -d \"" fecha " +1 day\" +\"%Y-%m-%d\""
        cmd | getline fecha
        close(cmd)
    }
}' "$archivo_salida2" > "$archivo_salida"

rm -rf $archivo_salida2

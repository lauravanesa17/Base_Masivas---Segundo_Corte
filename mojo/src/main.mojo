from std.sys import argv

from etl import ejecutar_etl


def main() raises:
    var argumentos = argv()
    if len(argumentos) != 6:
        print("Uso: mojo run main.mojo personas.json articulos.json ventas.json resultados esquema.sql")
        raise Error("Faltan rutas del ETL")
    var resumen = ejecutar_etl(argumentos[1], argumentos[2], argumentos[3], argumentos[4], argumentos[5])
    print(resumen)

# ETL: lee el extracto de MongoDB, valida en Mojo y carga SQLite.
from std.python import Python, PythonObject

from limpieza import limpiar_valor_numerico, recortar
from validacion import (
    validar_persona,
    validar_articulo,
    validar_venta,
    validar_integridad_referencial,
    telefono_valido,
)


def _leer_json(ruta: String) raises -> PythonObject:
    var json = Python.import_module("json")
    var pathlib = Python.import_module("pathlib")
    return json.loads(pathlib.Path(ruta).read_text(encoding="utf-8"))


def _como_texto(valor: PythonObject) raises -> String:
    var builtins = Python.import_module("builtins")
    var texto = String(builtins.str(valor))
    if texto == "None":
        return ""
    return recortar(texto)


def _fecha_o_vacio(valor: String) -> String:
    if valor.byte_length() != 10:
        return ""
    if String(valor[byte=4]) != "-" or String(valor[byte=7]) != "-":
        return ""
    var i = 0
    while i < 10:
        if i != 4 and i != 7:
            var caracter = String(valor[byte=i])
            if caracter < "0" or caracter > "9":
                return ""
        i += 1
    return valor


def ejecutar_etl(
    ruta_personas: String,
    ruta_articulos: String,
    ruta_ventas: String,
    ruta_resultados: String,
    ruta_esquema: String,
) raises -> String:
    """EXTRACT del JSON ya sacado de Mongo, VALIDATE, TRANSFORM y LOAD en SQLite.

    Python solo entra para leer JSON y hablar con sqlite3. Las reglas son Mojo.
    """
    var json = Python.import_module("json")
    var pathlib = Python.import_module("pathlib")
    var sqlite3 = Python.import_module("sqlite3")
    var builtins = Python.import_module("builtins")

    var crudas_personas = _leer_json(ruta_personas)
    var crudos_articulos = _leer_json(ruta_articulos)
    var crudas_ventas = _leer_json(ruta_ventas)

    var personas_ok = builtins.list()
    var articulos_ok = builtins.list()
    var ventas_ok = builtins.list()
    var vistos_documentos = builtins.set()
    var vistos_articulos = builtins.set()
    var vistos_ventas = builtins.set()

    var personas_descartadas = 0
    var telefonos_nulos = 0
    var articulos_descartados = 0
    var articulos_duplicados = 0
    var ventas_duplicadas = 0
    var venta_comprador = 0
    var venta_articulo = 0
    var venta_cantidad = 0
    var venta_precio = 0
    var venta_huerfana = 0

    var total_personas = Int(String(builtins.str(builtins.len(crudas_personas))))
    var i = 0
    while i < total_personas:
        var fila_persona = crudas_personas[i]
        var documento = _como_texto(fila_persona["numeroDocumento"])
        var telefono = _como_texto(fila_persona["telefono"])
        var estado_persona = validar_persona(documento, telefono)
        if estado_persona == "documento_invalido":
            personas_descartadas += 1
        else:
            var canonico_persona = limpiar_valor_numerico(documento)
            if vistos_documentos.__contains__(canonico_persona):
                personas_descartadas += 1
            else:
                vistos_documentos.add(canonico_persona)
                var tel = String("")
                if estado_persona == "ok" and telefono_valido(telefono):
                    tel = recortar(telefono)
                else:
                    telefonos_nulos += 1
                personas_ok.append(
                    Python.list(
                        canonico_persona,
                        _como_texto(fila_persona["nombres"]),
                        _como_texto(fila_persona["primerApellido"]),
                        _como_texto(fila_persona["segundoApellido"]),
                        _fecha_o_vacio(_como_texto(fila_persona["fechaNacimiento"])),
                        tel,
                        _como_texto(fila_persona["direccion"]),
                        _como_texto(fila_persona["email"]),
                    )
                )
        i += 1

    var total_articulos = Int(String(builtins.str(builtins.len(crudos_articulos))))
    i = 0
    while i < total_articulos:
        var fila_articulo = crudos_articulos[i]
        var identificador = _como_texto(fila_articulo["idArticulo"])
        var precio_articulo = _como_texto(fila_articulo["precioArticulo"])
        var cantidad_articulo = _como_texto(fila_articulo["cantidadArticulo"])
        var estado_articulo = validar_articulo(identificador, precio_articulo, cantidad_articulo)
        if estado_articulo != "ok":
            articulos_descartados += 1
        else:
            var canonico_articulo = limpiar_valor_numerico(identificador)
            if vistos_articulos.__contains__(canonico_articulo):
                articulos_duplicados += 1
            else:
                vistos_articulos.add(canonico_articulo)
                articulos_ok.append(
                    Python.list(
                        builtins.int(canonico_articulo),
                        _como_texto(fila_articulo["nombreArticulo"]),
                        builtins.float(limpiar_valor_numerico(precio_articulo)),
                        builtins.int(limpiar_valor_numerico(cantidad_articulo)),
                    )
                )
        i += 1

    var total_ventas = Int(String(builtins.str(builtins.len(crudas_ventas))))
    i = 0
    while i < total_ventas:
        var fila_venta = crudas_ventas[i]
        var venta = _como_texto(fila_venta["idVenta"])
        var comprador = _como_texto(fila_venta["idComprador"])
        var articulo = _como_texto(fila_venta["idArticulo"])
        var cantidad_venta = _como_texto(fila_venta["cantidadProductos"])
        var total_venta = _como_texto(fila_venta["precioTotal"])
        var estado_venta = validar_venta(comprador, articulo, cantidad_venta, total_venta)
        if estado_venta == "comprador_invalido":
            venta_comprador += 1
        elif estado_venta == "articulo_invalido":
            venta_articulo += 1
        elif estado_venta == "cantidad_invalida":
            venta_cantidad += 1
        elif estado_venta == "precio_invalido":
            venta_precio += 1
        else:
            var comprador_ok = limpiar_valor_numerico(comprador)
            var articulo_ok = limpiar_valor_numerico(articulo)
            var existe_comprador = False
            var existe_articulo = False
            if vistos_documentos.__contains__(comprador_ok):
                existe_comprador = True
            if vistos_articulos.__contains__(articulo_ok):
                existe_articulo = True
            if not validar_integridad_referencial(comprador_ok, articulo_ok, existe_comprador, existe_articulo):
                if not existe_comprador:
                    venta_comprador += 1
                else:
                    venta_articulo += 1
            elif vistos_ventas.__contains__(venta):
                ventas_duplicadas += 1
            else:
                vistos_ventas.add(venta)
                ventas_ok.append(
                    Python.list(
                        builtins.int(limpiar_valor_numerico(venta)),
                        comprador_ok,
                        builtins.int(articulo_ok),
                        builtins.int(limpiar_valor_numerico(cantidad_venta)),
                        builtins.float(limpiar_valor_numerico(total_venta)),
                    )
                )
        i += 1
    var destino = pathlib.Path(ruta_resultados)
    destino.mkdir(parents=True, exist_ok=True)
    var base = pathlib.Path(ruta_resultados) / "almacen.sqlite"
    if base.exists():
        base.unlink()
    var conexion = sqlite3.connect(String(base))
    conexion.execute("PRAGMA foreign_keys = ON")
    var esquema = pathlib.Path(ruta_esquema).read_text(encoding="utf-8")
    conexion.executescript(esquema)
    conexion.executemany(
        """
        INSERT INTO PERSONAS (
            numeroDocumento, nombres, primerApellido, segundoApellido,
            fechaNacimiento, telefono, direccion, email
        ) VALUES (?, ?, ?, ?, NULLIF(?, ''), NULLIF(?, ''), ?, ?)
        """,
        personas_ok,
    )
    conexion.executemany(
        """
        INSERT INTO ARTICULOS (idArticulo, nombreArticulo, precioArticulo, cantidadArticulo)
        VALUES (?, ?, ?, ?)
        """,
        articulos_ok,
    )
    conexion.executemany(
        """
        INSERT INTO VENTAS (idVenta, idComprador, idArticulo, cantidadProductos, precioTotal)
        VALUES (?, ?, ?, ?, ?)
        """,
        ventas_ok,
    )
    conexion.commit()
    conexion.close()

    var reporte = builtins.dict()
    reporte["personas_recibidas"] = total_personas
    reporte["personas_limpias"] = Int(String(builtins.str(builtins.len(personas_ok))))
    reporte["personas_descartadas"] = personas_descartadas
    reporte["telefonos_nulos"] = telefonos_nulos
    reporte["articulos_recibidos"] = total_articulos
    reporte["articulos_limpios"] = Int(String(builtins.str(builtins.len(articulos_ok))))
    reporte["articulos_descartados"] = articulos_descartados
    reporte["articulos_duplicados"] = articulos_duplicados
    reporte["ventas_recibidas"] = total_ventas
    reporte["ventas_integras"] = Int(String(builtins.str(builtins.len(ventas_ok))))
    reporte["ventas_duplicadas"] = ventas_duplicadas
    var causas = builtins.dict()
    causas["comprador_invalido_o_inexistente"] = venta_comprador
    causas["articulo_invalido_o_inexistente"] = venta_articulo
    causas["cantidad_no_confiable"] = venta_cantidad
    causas["precio_no_confiable"] = venta_precio
    causas["referencia_huerfana"] = venta_huerfana
    reporte["descartes_ventas"] = causas
    var ruta_reporte = pathlib.Path(ruta_resultados) / "reporte_etl.json"
    pathlib.Path(ruta_reporte).write_text(json.dumps(reporte, indent=2), encoding="utf-8")
    return String(json.dumps(reporte, indent=2))

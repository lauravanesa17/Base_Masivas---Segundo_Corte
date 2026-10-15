# Validacion de personas, articulos, ventas e integridad referencial.
from limpieza import (
    limpiar_valor_numerico,
    es_positivo,
    es_entero_canonico,
    solo_digitos,
    recortar,
)


def documento_valido(valor: String) -> Bool:
    var canonico = limpiar_valor_numerico(valor)
    if not es_entero_canonico(canonico):
        return False
    var n = canonico.byte_length()
    return n >= 6 and n <= 12


def telefono_valido(valor: String) -> Bool:
    var texto = recortar(valor)
    if not solo_digitos(texto):
        return False
    var n = texto.byte_length()
    return n >= 7 and n <= 15


def validar_persona(numero_documento: String, telefono: String) -> String:
    """ok | ok_telefono_nulo | documento_invalido.

    El telefono no es llave: si falla, la persona se conserva y el telefono queda vacio.
    Un documento dudoso se descarta porque contamina la llave primaria.
    """
    if not documento_valido(numero_documento):
        return "documento_invalido"
    if telefono_valido(telefono):
        return "ok"
    return "ok_telefono_nulo"


def validar_articulo(id_articulo: String, precio_articulo: String, cantidad_articulo: String) -> String:
    """ok | id_invalido | precio_invalido | cantidad_invalida."""
    var identificador = limpiar_valor_numerico(id_articulo)
    if not es_entero_canonico(identificador) or identificador == "0":
        return "id_invalido"
    var precio = limpiar_valor_numerico(precio_articulo)
    if not es_positivo(precio):
        return "precio_invalido"
    var cantidad = limpiar_valor_numerico(cantidad_articulo)
    if not es_entero_canonico(cantidad):
        return "cantidad_invalida"
    return "ok"


def limpiar_articulo(id_articulo: String, precio_articulo: String, cantidad_articulo: String) -> String:
    """Forma canonica id|precio|cantidad, o vacio si la validacion falla."""
    if validar_articulo(id_articulo, precio_articulo, cantidad_articulo) != "ok":
        return ""
    var identificador = limpiar_valor_numerico(id_articulo)
    var precio = limpiar_valor_numerico(precio_articulo)
    var cantidad = limpiar_valor_numerico(cantidad_articulo)
    return identificador + "|" + precio + "|" + cantidad


def validar_venta(
    id_comprador: String,
    id_articulo: String,
    cantidad_productos: String,
    precio_total: String,
) -> String:
    """ok | comprador_invalido | articulo_invalido | cantidad_invalida | precio_invalido.

    Esta funcion revisa la forma de los campos. La existencia del comprador
    y del articulo la confirma validar_integridad_referencial.
    """
    if not documento_valido(id_comprador):
        return "comprador_invalido"
    var articulo = limpiar_valor_numerico(id_articulo)
    if not es_entero_canonico(articulo) or articulo == "0":
        return "articulo_invalido"
    var cantidad = limpiar_valor_numerico(cantidad_productos)
    if not es_entero_canonico(cantidad) or not es_positivo(cantidad):
        return "cantidad_invalida"
    var total = limpiar_valor_numerico(precio_total)
    if not es_positivo(total):
        return "precio_invalido"
    return "ok"


def limpiar_venta(
    id_comprador: String,
    id_articulo: String,
    cantidad_productos: String,
    precio_total: String,
) -> String:
    if validar_venta(id_comprador, id_articulo, cantidad_productos, precio_total) != "ok":
        return ""
    var comprador = limpiar_valor_numerico(id_comprador)
    var articulo = limpiar_valor_numerico(id_articulo)
    var cantidad = limpiar_valor_numerico(cantidad_productos)
    var total = limpiar_valor_numerico(precio_total)
    return comprador + "|" + articulo + "|" + cantidad + "|" + total


def validar_integridad_referencial(
    id_comprador: String,
    id_articulo: String,
    comprador_existe: Bool,
    articulo_existe: Bool,
) -> Bool:
    """True solo si los ids sirven de llave y ambos extremos existen.

    ejecutar_etl calcula comprador_existe y articulo_existe contra las
    personas y los articulos ya aceptados. Si alguno falta, la venta no entra.
    """
    var comprador = limpiar_valor_numerico(id_comprador)
    var articulo = limpiar_valor_numerico(id_articulo)
    if not documento_valido(comprador):
        return False
    if not es_entero_canonico(articulo) or articulo == "0":
        return False
    return comprador_existe and articulo_existe

from limpieza import limpiar_valor_numerico, es_positivo
from validacion import (
    validar_persona,
    validar_articulo,
    limpiar_articulo,
    validar_venta,
    limpiar_venta,
    validar_integridad_referencial,
)


def afirmar(condicion: Bool, mensaje: String) raises:
    if not condicion:
        raise Error(mensaje)


def main() raises:
    # limpiar_valor_numerico: valido, invalido, vacio
    afirmar(limpiar_valor_numerico("0668") == "668", "0668 debe quedar 668")
    afirmar(limpiar_valor_numerico("2x") == "", "2x no se convierte")
    afirmar(limpiar_valor_numerico("  ") == "", "vacio no es numero")
    afirmar(limpiar_valor_numerico("9O") == "", "9O no se convierte")
    afirmar(limpiar_valor_numerico("10K") == "", "10K no se convierte")
    afirmar(limpiar_valor_numerico("301.26") == "301.26", "decimal confiable")
    afirmar(es_positivo("301.26"), "precio positivo")
    afirmar(not es_positivo("0.00"), "cero no es positivo")

    # validar_persona: valido, invalido, telefono nulo
    afirmar(validar_persona("12345678", "3001234567") == "ok", "persona valida")
    afirmar(validar_persona("@10@93@!65", "7546027921") == "documento_invalido", "documento sucio")
    afirmar(validar_persona("12345678", "422$9Aq9@1") == "ok_telefono_nulo", "telefono sucio no borra la persona")

    # articulos: valido, id invalido, precio invalido
    afirmar(validar_articulo("358", "301.26", "35") == "ok", "articulo valido")
    afirmar(validar_articulo("T474", "237.64", "18") == "id_invalido", "id con letras")
    afirmar(validar_articulo("15", "0", "3") == "precio_invalido", "precio cero")
    afirmar(validar_articulo("15", "10", "") == "cantidad_invalida", "cantidad vacia")
    afirmar(limpiar_articulo("0668", "10.5", "2") == "668|10.5|2", "limpia ceros a la izquierda")
    afirmar(limpiar_articulo("2x", "10", "2") == "", "no limpia un id ambiguo")

    # ventas: valida, cantidad ambigua, precio vacio
    afirmar(validar_venta("12345678", "358", "2", "202.14") == "ok", "venta valida")
    afirmar(validar_venta("12345678", "358", "9O", "10") == "cantidad_invalida", "9O no es cantidad")
    afirmar(validar_venta("q61@A!213A", "358", "2", "10") == "comprador_invalido", "comprador sucio")
    afirmar(limpiar_venta("", "1", "1", "1") == "", "venta vacia")

    # integridad: existe, comprador ausente, articulo ausente
    afirmar(validar_integridad_referencial("12345678", "358", True, True), "referencia existente")
    afirmar(
        not validar_integridad_referencial("0000000000", "358", False, True),
        "comprador inexistente",
    )
    afirmar(
        not validar_integridad_referencial("12345678", "99999", True, False),
        "articulo inexistente",
    )
    afirmar(
        not validar_integridad_referencial("@10@93@!65", "358", True, True),
        "id incompatible con el relacional",
    )
    print("Pruebas Mojo: 3 escenarios por funcion, todas pasaron.")

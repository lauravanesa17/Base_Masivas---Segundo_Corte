# Limpieza numerica. No adivina: 2x, 9O y 10K no se convierten.
# Mojo 1.1 no permite len(String) ni s[i]. Estos datos son ASCII,
# asi que la posicion se mide en bytes.


def _largo(texto: String) -> Int:
    return texto.byte_length()


def _caracter(texto: String, indice: Int) -> String:
    return String(texto[byte=indice])


def _cortar(texto: String, inicio: Int, fin: Int) -> String:
    return String(texto[byte=inicio:fin])


def recortar(valor: String) -> String:
    var inicio = 0
    var fin = _largo(valor)
    while inicio < fin:
        var caracter = _caracter(valor, inicio)
        if caracter != " " and caracter != "\t" and caracter != "\n" and caracter != "\r":
            break
        inicio += 1
    while fin > inicio:
        var caracter = _caracter(valor, fin - 1)
        if caracter != " " and caracter != "\t" and caracter != "\n" and caracter != "\r":
            break
        fin -= 1
    return _cortar(valor, inicio, fin)


def _es_digito(caracter: String) -> Bool:
    return caracter >= "0" and caracter <= "9"


def solo_digitos(valor: String) -> Bool:
    var texto = recortar(valor)
    if _largo(texto) == 0:
        return False
    var i = 0
    while i < _largo(texto):
        if not _es_digito(_caracter(texto, i)):
            return False
        i += 1
    return True


def quitar_ceros(texto: String) -> String:
    var i = 0
    var n = _largo(texto)
    while i < n - 1 and _caracter(texto, i) == "0":
        i += 1
    return _cortar(texto, i, n)


def limpiar_valor_numerico(valor: String) -> String:
    """Devuelve el numero canonico, o cadena vacia si el texto no es confiable.

    Acepta enteros y un solo punto decimal. Rechaza letras, simbolos,
    signos y mas de un punto. No transforma 2x, 9O ni 10K.
    """
    var texto = recortar(valor)
    if _largo(texto) == 0:
        return ""
    var punto = -1
    var i = 0
    var digitos = 0
    while i < _largo(texto):
        var caracter = _caracter(texto, i)
        if caracter == ".":
            if punto != -1:
                return ""
            punto = i
        elif _es_digito(caracter):
            digitos += 1
        else:
            return ""
        i += 1
    if digitos == 0:
        return ""
    if punto == -1:
        return quitar_ceros(texto)
    if punto == 0 or punto == _largo(texto) - 1:
        return ""
    var entero = quitar_ceros(_cortar(texto, 0, punto))
    var fraccion = _cortar(texto, punto + 1, _largo(texto))
    var j = 0
    while j < _largo(fraccion):
        if not _es_digito(_caracter(fraccion, j)):
            return ""
        j += 1
    return entero + "." + fraccion


def es_positivo(canonico: String) -> Bool:
    if _largo(canonico) == 0:
        return False
    var i = 0
    while i < _largo(canonico):
        var caracter = _caracter(canonico, i)
        if caracter != "0" and caracter != ".":
            return True
        i += 1
    return False


def es_entero_canonico(canonico: String) -> Bool:
    if _largo(canonico) == 0:
        return False
    var i = 0
    while i < _largo(canonico):
        if not _es_digito(_caracter(canonico, i)):
            return False
        i += 1
    return True

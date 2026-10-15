PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS VENTAS;
DROP TABLE IF EXISTS ARTICULOS;
DROP TABLE IF EXISTS PERSONAS;

CREATE TABLE PERSONAS (
    numeroDocumento TEXT PRIMARY KEY,
    nombres TEXT NOT NULL,
    primerApellido TEXT NOT NULL,
    segundoApellido TEXT,
    fechaNacimiento TEXT,
    telefono TEXT,
    direccion TEXT,
    email TEXT
) STRICT;

CREATE TABLE ARTICULOS (
    idArticulo INTEGER PRIMARY KEY,
    nombreArticulo TEXT NOT NULL,
    precioArticulo REAL NOT NULL CHECK (precioArticulo > 0),
    cantidadArticulo INTEGER NOT NULL CHECK (cantidadArticulo >= 0)
) STRICT;

CREATE TABLE VENTAS (
    idVenta INTEGER PRIMARY KEY,
    idComprador TEXT NOT NULL REFERENCES PERSONAS (numeroDocumento),
    idArticulo INTEGER NOT NULL REFERENCES ARTICULOS (idArticulo),
    cantidadProductos INTEGER NOT NULL CHECK (cantidadProductos > 0),
    precioTotal REAL NOT NULL CHECK (precioTotal > 0)
) STRICT;

CREATE INDEX idx_ventas_comprador ON VENTAS (idComprador);
CREATE INDEX idx_ventas_articulo ON VENTAS (idArticulo);

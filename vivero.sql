-- sudo service postgresql start
-- sudo -u postgres psql

-- ELIMINATE TABLES IF EXISTS
DROP TABLE IF EXISTS compra, cliente, empleado, producto, vivero, zona CASCADE;
DROP DATABASE IF EXISTS vivero;

-- CREATE DATABASE
CREATE DATABASE vivero;

-- CREATE TABLE PRODUCTO
CREATE TABLE producto (
  id_producto SERIAL PRIMARY KEY
);

-- CREATE TABLE ZONA
CREATE TABLE zona (
  id_zona SERIAL PRIMARY KEY,
  id_producto INT NOT NULL,
  tipo VARCHAR(50),
  productividad DECIMAL CHECK (productividad >= 0 AND productividad <=1) NOT NULL,
  altitud DECIMAL,
  latitud DECIMAL,
  stock INT CHECK (stock >= 0) NOT NULL,

  FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto) ON DELETE CASCADE
);

-- CREATE TABLE VIVERO
CREATE TABLE vivero (
  id_vivero SERIAL PRIMARY KEY,
  id_zona INT NOT NULL,
  stock INT CHECK (stock >= 0) NOT NULL,

  FOREIGN KEY (id_zona) REFERENCES ZONA(id_zona) ON DELETE CASCADE
);

-- CREATE TABLE CLIENTE
CREATE TABLE cliente (
  id_cliente SERIAL PRIMARY KEY,
  bonificacion DECIMAL NOT NULL,
  compra_mensual DECIMAL NOT NULL
);

-- CREATE TABLE COMPRA
CREATE TABLE compra (
  id_compra SERIAL PRIMARY KEY,
  id_producto INT NOT NULL,
  id_cliente INT NOT NULL,

  FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto) ON DELETE CASCADE,
  FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE CASCADE
);

-- CREATE TABLE EMPLEADO
CREATE TABLE empleado (
  empleado_id SERIAL PRIMARY KEY,
  id_producto INT NOT NULL,
  productividad DECIMAL CHECK (productividad > 0),
  historico TEXT,
  id_vivero INT NOT NULL,

  FOREIGN KEY (id_vivero) REFERENCES vivero(id_vivero) ON DELETE CASCADE,
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON DELETE CASCADE
);

-- TRIGGERS

CREATE OR REPLACE FUNCTION actualizar_stock_zona() RETURNS TRIGGER AS $$
BEGIN
  UPDATE zona
  SET stock = (
    SELECT SUM(vivero.stock)
    FROM vivero
    WHERE vivero.id_zona = NEW.id_zona
  )
  WHERE zona.id_zona = NEW.id_zona;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_stock_zona
AFTER INSERT OR UPDATE OR DELETE ON vivero
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock_zona();


-- Insertar 5 filas en la tabla PRODUCTO
INSERT INTO producto DEFAULT VALUES;
INSERT INTO producto DEFAULT VALUES;
INSERT INTO producto DEFAULT VALUES;
INSERT INTO producto DEFAULT VALUES;
INSERT INTO producto DEFAULT VALUES;

-- Insertar 5 filas en la tabla ZONA
INSERT INTO zona (id_producto, tipo, productividad, altitud, latitud, stock)
VALUES
  (1, 'Costa', 0.85, 1000.0, 35.1234, 500),
  (2, 'Jardín', 0.75, 900.5, 36.5678, 600),
  (3, 'Jardín', 0.92, 1100.0, 37.8765, 700),
  (4, 'Desierto', 0.78, 850.5, 38.7654, 800),
  (5, 'Bosque', 0.93, 950.0, 39.4321, 900);

-- Insertar 5 filas en la tabla VIVERO
INSERT INTO vivero (id_zona, stock)
VALUES
  (1, 200),
  (2, 250),
  (2, 180),
  (4, 220),
  (5, 270);

-- Insertar 5 filas en la tabla CLIENTE
INSERT INTO cliente (bonificacion, compra_mensual)
VALUES
  (0.1, 1000.0),
  (0.15, 1500.0),
  (0.2, 2000.0),
  (0.25, 2500.0),
  (0.3, 3000.0);

-- Insertar 5 filas en la tabla COMPRA
INSERT INTO compra (id_producto, id_cliente)
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5);

-- Insertar 5 filas en la tabla EMPLEADO
INSERT INTO empleado (id_producto, productividad, historico, id_vivero)
VALUES
  (1, 0.9, 'Historia 1', 1),
  (2, 0.85, 'Historia 2', 2),
  (3, 0.88, 'Historia 3', 3),
  (4, 0.92, 'Historia 4', 4),
  (5, 0.87, 'Historia 5', 5);
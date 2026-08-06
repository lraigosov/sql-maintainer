-- Dataset Base para el Curso SQL (derivado de pensum_sql.md)
-- Dialecto: T-SQL (adaptable a otros motores con mínimos cambios)

IF OBJECT_ID('dbo.dim_clientes') IS NOT NULL DROP TABLE dbo.dim_clientes;
IF OBJECT_ID('dbo.dim_productos') IS NOT NULL DROP TABLE dbo.dim_productos;
IF OBJECT_ID('dbo.dim_regiones') IS NOT NULL DROP TABLE dbo.dim_regiones;
IF OBJECT_ID('dbo.fact_ventas') IS NOT NULL DROP TABLE dbo.fact_ventas;
IF OBJECT_ID('dbo.fact_suscripciones') IS NOT NULL DROP TABLE dbo.fact_suscripciones;
IF OBJECT_ID('dbo.fact_inventario') IS NOT NULL DROP TABLE dbo.fact_inventario;
GO

CREATE TABLE dbo.dim_clientes (
    cliente_id INT IDENTITY PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NULL,
    fecha_alta DATE NOT NULL,
    segmento NVARCHAR(50) NULL,
    region_id INT NOT NULL,
    CONSTRAINT uq_dim_clientes_email UNIQUE(email)
);

CREATE TABLE dbo.dim_regiones (
    region_id INT IDENTITY PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    pais NVARCHAR(100) NOT NULL,
    zona NVARCHAR(50) NULL
);

CREATE TABLE dbo.dim_productos (
    producto_id INT IDENTITY PRIMARY KEY,
    nombre NVARCHAR(120) NOT NULL,
    categoria NVARCHAR(50) NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    costo_unitario DECIMAL(12,2) NOT NULL,
    activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.fact_ventas (
    venta_id BIGINT IDENTITY PRIMARY KEY,
    fecha DATE NOT NULL,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    descuento_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    canal NVARCHAR(50) NOT NULL,
    CONSTRAINT fk_fact_ventas_cliente FOREIGN KEY (cliente_id) REFERENCES dbo.dim_clientes(cliente_id),
    CONSTRAINT fk_fact_ventas_producto FOREIGN KEY (producto_id) REFERENCES dbo.dim_productos(producto_id)
);

CREATE TABLE dbo.fact_suscripciones (
    suscripcion_id BIGINT IDENTITY PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    plan NVARCHAR(50) NOT NULL,
    mrr DECIMAL(12,2) NOT NULL,
    activo BIT NOT NULL,
    CONSTRAINT fk_fact_sus_cliente FOREIGN KEY (cliente_id) REFERENCES dbo.dim_clientes(cliente_id)
);

CREATE TABLE dbo.fact_inventario (
    inventario_id BIGINT IDENTITY PRIMARY KEY,
    producto_id INT NOT NULL,
    fecha DATE NOT NULL,
    stock_inicial INT NOT NULL,
    stock_final INT NOT NULL,
    reposiciones INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_fact_inv_producto FOREIGN KEY (producto_id) REFERENCES dbo.dim_productos(producto_id)
);
GO

-- Datos mínimos (ejemplos simples para ejercicios; ampliar según necesidad)
INSERT INTO dbo.dim_regiones (nombre, pais, zona) VALUES
('Norte', 'Colombia', 'NOR'),
('Sur', 'Colombia', 'SUR'),
('Centro', 'Colombia', 'CEN');

INSERT INTO dbo.dim_clientes (nombre, email, fecha_alta, segmento, region_id) VALUES
('Cliente A', 'a@example.com', '2023-01-10', 'Retail', 1),
('Cliente B', 'b@example.com', '2023-02-15', 'Enterprise', 2),
('Cliente C', 'c@example.com', '2023-02-20', 'Retail', 3),
('Cliente D', NULL, '2023-03-05', 'SMB', 1);

INSERT INTO dbo.dim_productos (nombre, categoria, precio_unitario, costo_unitario, activo) VALUES
('Producto X', 'Accesorios', 50, 30, 1),
('Producto Y', 'Software', 200, 80, 1),
('Producto Z', 'Accesorios', 75, 40, 1);

INSERT INTO dbo.fact_ventas (fecha, cliente_id, producto_id, cantidad, descuento_pct, canal) VALUES
('2023-04-01', 1, 1, 2, 0, 'Online'),
('2023-04-02', 2, 2, 1, 5, 'Directo'),
('2023-04-03', 1, 3, 5, 0, 'Online'),
('2023-04-04', 3, 1, 1, 10, 'Distribuidor'),
('2023-04-05', 4, 2, 3, 0, 'Online');

INSERT INTO dbo.fact_suscripciones (cliente_id, fecha_inicio, fecha_fin, plan, mrr, activo) VALUES
(2, '2023-01-01', NULL, 'Premium', 500, 1),
(3, '2023-02-01', '2023-07-01', 'Basic', 100, 0),
(1, '2023-02-15', NULL, 'Standard', 250, 1);

INSERT INTO dbo.fact_inventario (producto_id, fecha, stock_inicial, stock_final, reposiciones) VALUES
(1, '2023-04-01', 100, 98, 0),
(2, '2023-04-01', 50, 49, 0),
(3, '2023-04-01', 200, 195, 10);

-- Vistas analíticas iniciales (simplificación para ejercicios intermedios)
IF OBJECT_ID('dbo.vw_kpi_ventas_diarias') IS NOT NULL DROP VIEW dbo.vw_kpi_ventas_diarias;
GO
CREATE VIEW dbo.vw_kpi_ventas_diarias AS
SELECT 
    v.fecha,
    SUM(v.cantidad * p.precio_unitario * (1 - v.descuento_pct/100)) AS ingreso_bruto,
    SUM(v.cantidad * p.costo_unitario) AS costo_total,
    SUM(v.cantidad) AS unidades,
    COUNT(DISTINCT v.cliente_id) AS clientes_distintos
FROM dbo.fact_ventas v
JOIN dbo.dim_productos p ON v.producto_id = p.producto_id
GROUP BY v.fecha;
GO

-- Índices sugeridos (no crear automáticamente, ejemplo de discusión en módulos senior)
-- CREATE NONCLUSTERED INDEX IX_fact_ventas_cliente_fecha ON dbo.fact_ventas(cliente_id, fecha);
-- CREATE NONCLUSTERED INDEX IX_fact_ventas_producto_fecha ON dbo.fact_ventas(producto_id, fecha);
-- Validar selectividad antes de crear.

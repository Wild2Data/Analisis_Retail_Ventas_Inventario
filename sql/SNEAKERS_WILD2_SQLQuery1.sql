/* ============================================================
 PROYECTO: Sneakers de Wild2
 MODELO: Inventory & Logistics Optimization Framework
 CONTEXTO:
 Este modelo fue diseñado directamente en SQL Server con el
 objetivo de tener control total sobre el esquema, los tipos
 de datos y las relaciones, evitando dependencias frágiles
 de herramientas de importación.

 El modelo sigue un enfoque de ESQUEMA ESTRELLA y está
 preparado para análisis avanzado en Power BI.
============================================================ */


/* ============================================================
 1. CREACIÓN DE ESQUEMAS
============================================================ */

CREATE SCHEMA dim;
GO

CREATE SCHEMA fact;
GO


/* ============================================================
 2. CREACIÓN DE DIMENSIONES
============================================================ */

-- DIM_PRODUCTO: Catálogo de sneakers
CREATE TABLE dim.producto (
    producto_id INT PRIMARY KEY,
    marca NVARCHAR(50),
    modelo NVARCHAR(100),
    colorway NVARCHAR(50),
    anio_lanzamiento INT,
    edicion_limitada BIT,
    precio_retail DECIMAL(10,2),
    precio_reventa_estimado DECIMAL(10,2),
    url_imagen NVARCHAR(500)
);

-- DIM_SUCURSAL: Tiendas físicas en CDMX
CREATE TABLE dim.sucursal (
    sucursal_id INT PRIMARY KEY,
    nombre_sucursal NVARCHAR(100),
    zona_ciudad NVARCHAR(50)
);

-- DIM_PROVEEDOR: Canales de abastecimiento
CREATE TABLE dim.proveedor (
    proveedor_id INT PRIMARY KEY,
    nombre_proveedor NVARCHAR(100),
    lead_time_dias INT,
    indice_confiabilidad DECIMAL(4,2)
);

-- DIM_MEDIO_PAGO: Métodos de pago y comisiones
CREATE TABLE dim.medio_pago (
    medio_pago_id INT PRIMARY KEY,
    medio_pago NVARCHAR(50),
    comision_pct DECIMAL(5,2)
);

-- DIM_FECHA: Calendario para análisis temporal
CREATE TABLE dim.fecha (
    fecha DATE PRIMARY KEY,
    anio INT,
    mes INT,
    nombre_mes NVARCHAR(20),
    semana INT,
    es_fin_semana BIT
);


/* ============================================================
 3. CREACIÓN DE TABLAS DE HECHOS
============================================================ */

-- FACT_VENTAS: Transacciones de venta
CREATE TABLE fact.ventas (
    venta_id INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    producto_id INT,
    sucursal_id INT,
    medio_pago_id INT,
    unidades_vendidas INT,
    ingreso DECIMAL(12,2),
    costo_comision DECIMAL(12,2),
    CONSTRAINT fk_ventas_fecha FOREIGN KEY (fecha) REFERENCES dim.fecha(fecha),
    CONSTRAINT fk_ventas_producto FOREIGN KEY (producto_id) REFERENCES dim.producto(producto_id),
    CONSTRAINT fk_ventas_sucursal FOREIGN KEY (sucursal_id) REFERENCES dim.sucursal(sucursal_id),
    CONSTRAINT fk_ventas_medio_pago FOREIGN KEY (medio_pago_id) REFERENCES dim.medio_pago(medio_pago_id)
);

-- FACT_INVENTARIO_DIARIO: Snapshot diario de inventario
CREATE TABLE fact.inventario_diario (
    fecha DATE,
    producto_id INT,
    sucursal_id INT,
    unidades_disponibles INT,
    unidades_en_pedido INT,
    valor_inventario DECIMAL(12,2),
    demanda_promedio_diaria DECIMAL(10,2),
    dias_cobertura DECIMAL(10,2),
    CONSTRAINT pk_inventario PRIMARY KEY (fecha, producto_id, sucursal_id),
    CONSTRAINT fk_inv_fecha FOREIGN KEY (fecha) REFERENCES dim.fecha(fecha),
    CONSTRAINT fk_inv_producto FOREIGN KEY (producto_id) REFERENCES dim.producto(producto_id),
    CONSTRAINT fk_inv_sucursal FOREIGN KEY (sucursal_id) REFERENCES dim.sucursal(sucursal_id)
);

-- FACT_ORDENES_COMPRA: Pedidos a proveedores
CREATE TABLE fact.ordenes_compra (
    orden_compra_id NVARCHAR(20) PRIMARY KEY,
    producto_id INT,
    sucursal_id INT,
    proveedor_id INT,
    fecha_orden DATE,
    fecha_esperada DATE,
    fecha_recepcion DATE,
    unidades_ordenadas INT,
    unidades_recibidas INT,
    CONSTRAINT fk_oc_producto FOREIGN KEY (producto_id) REFERENCES dim.producto(producto_id),
    CONSTRAINT fk_oc_sucursal FOREIGN KEY (sucursal_id) REFERENCES dim.sucursal(sucursal_id),
    CONSTRAINT fk_oc_proveedor FOREIGN KEY (proveedor_id) REFERENCES dim.proveedor(proveedor_id)
);


/* ============================================================
 4. CARGA DE DIMENSIONES (CATÁLOGOS BASE)
============================================================ */

INSERT INTO dim.producto VALUES
(3001,'Nike','Dunk Low Panda','Blanco/Negro',2021,0,150.00,220.00,'https://example.com/dunk_panda.jpg'),
(3002,'Jordan','Air Jordan 1 Low Travis Scott','Medium Olive',2024,1,200.00,550.00,'https://example.com/aj1_travis.jpg'),
(3003,'Nike','Air Force 1 White','Triple White',2020,0,130.00,160.00,'https://example.com/af1_white.jpg'),
(3004,'Jordan','Air Jordan 4 Bred Reimagined','Negro/Rojo',2024,1,210.00,480.00,'https://example.com/aj4_bred.jpg'),
(3005,'adidas','Yeezy Boost 350 V2 Zebra','Blanco/Negro',2022,1,230.00,420.00,'https://example.com/yeezy_zebra.jpg'),
(3006,'Nike','SB Dunk Low Futura','Azul/Blanco',2023,1,180.00,390.00,'https://example.com/sb_dunk_futura.jpg'),
(3007,'New Balance','2002R','Gris',2022,0,160.00,210.00,'https://example.com/nb_2002r.jpg'),
(3008,'ASICS','GEL-NYC','Gris/Plata',2023,0,170.00,190.00,'https://example.com/asics_gel_nyc.jpg'),
(3009,'Nike','Kobe 6 Protro','Grinch',2024,1,190.00,600.00,'https://example.com/kobe_6.jpg'),
(3010,'Jordan','Air Jordan 3 J Balvin','Medellin Sunset',2023,1,220.00,520.00,'https://example.com/aj3_balvin.jpg'),
(3011,'Puma','Suede Classic','Negro',2019,0,110.00,130.00,'https://example.com/puma_suede.jpg'),
(3012,'Nike','Air Max 90','Blanco/Gris',2020,0,140.00,180.00,'https://example.com/airmax_90.jpg');

INSERT INTO dim.sucursal VALUES
(1,'Sneaker Store Polanco','Zona Poniente'),
(2,'Sneaker Store Roma Condesa','Zona Centro Sur'),
(3,'Sneaker Store Santa Fe','Zona Corporativa'),
(4,'Sneaker Store Centro Historico','Zona Centro');

INSERT INTO dim.proveedor VALUES
(601,'Nike Mexico Directo',10,0.95),
(602,'Distribuidor Sneaker LATAM',18,0.88),
(603,'Boutique Autorizada',14,0.90),
(604,'Marketplace Consignacion',7,0.85),
(605,'Importador Independiente',25,0.75);

INSERT INTO dim.medio_pago VALUES
(1,'Efectivo',0.00),
(2,'Tarjeta Debito',1.10),
(3,'Tarjeta Credito',2.60),
(4,'Pago en Linea',3.40),
(5,'Transferencia',0.80);


/* ============================================================
 5. POBLADO DE DIM_FECHA (CALENDARIO 2024)
============================================================ */

DECLARE @fecha DATE = '2024-01-01';

WHILE @fecha <= '2024-12-31'
BEGIN
    INSERT INTO dim.fecha VALUES (
        @fecha,
        YEAR(@fecha),
        MONTH(@fecha),
        DATENAME(MONTH, @fecha),
        DATEPART(WEEK, @fecha),
        CASE WHEN DATENAME(WEEKDAY, @fecha) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
    );

    SET @fecha = DATEADD(DAY, 1, @fecha);
END;


/* ============================================================
 6. GENERACIÓN DE DATOS DE HECHOS (SIMULACIÓN REALISTA)
============================================================ */

-- VENTAS (cada 3 días)
INSERT INTO fact.ventas
SELECT
    f.fecha,
    p.producto_id,
    s.sucursal_id,
    m.medio_pago_id,
    ABS(CHECKSUM(NEWID())) % 3 + 1,
    ROUND(p.precio_retail * (ABS(CHECKSUM(NEWID())) % 25 + 105) / 100.0, 2),
    ROUND(
        (p.precio_retail * (ABS(CHECKSUM(NEWID())) % 25 + 105) / 100.0)
        * m.comision_pct / 100.0, 2
    )
FROM dim.fecha f
CROSS JOIN dim.producto p
CROSS JOIN dim.sucursal s
CROSS JOIN dim.medio_pago m
WHERE DATEPART(DAY, f.fecha) % 3 = 0;

-- INVENTARIO DIARIO
INSERT INTO fact.inventario_diario
SELECT
    f.fecha,
    p.producto_id,
    s.sucursal_id,
    ABS(CHECKSUM(NEWID())) % 80 + 5,
    ABS(CHECKSUM(NEWID())) % 30,
    ROUND(p.precio_retail * (ABS(CHECKSUM(NEWID())) % 80 + 5), 2),
    ROUND((ABS(CHECKSUM(NEWID())) % 25 + 3) / 10.0, 2),
    ROUND(
        (ABS(CHECKSUM(NEWID())) % 80 + 5) /
        NULLIF((ABS(CHECKSUM(NEWID())) % 25 + 3) / 10.0, 0), 2
    )
FROM dim.fecha f
CROSS JOIN dim.producto p
CROSS JOIN dim.sucursal s;

-- ÓRDENES DE COMPRA
DECLARE @i INT = 1;

WHILE @i <= 300
BEGIN
    DECLARE @fecha_orden DATE =
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 330, '2024-01-01');

    DECLARE @lead INT =
        (SELECT TOP 1 lead_time_dias FROM dim.proveedor ORDER BY NEWID());

    INSERT INTO fact.ordenes_compra
    SELECT TOP 1
        CONCAT('OC-',10000 + @i),
        p.producto_id,
        s.sucursal_id,
        pr.proveedor_id,
        @fecha_orden,
        DATEADD(DAY,@lead,@fecha_orden),
        DATEADD(DAY,@lead + ABS(CHECKSUM(NEWID())) % 4,@fecha_orden),
        ABS(CHECKSUM(NEWID())) % 40 + 10,
        ABS(CHECKSUM(NEWID())) % 38 + 8
    FROM dim.producto p
    CROSS JOIN dim.sucursal s
    CROSS JOIN dim.proveedor pr
    ORDER BY NEWID();

    SET @i += 1;
END;


/* ============================================================
 7. VISTAS DE CONSUMO PARA POWER BI
============================================================ */

CREATE SCHEMA vw;
GO

SELECT name 
FROM sys.schemas
WHERE name = 'vw';


CREATE VIEW vw.vw_ventas AS
SELECT
    v.venta_id,
    v.fecha,
    f.anio,
    f.mes,
    f.nombre_mes,
    f.semana,
    f.es_fin_semana,
    p.marca,
    p.modelo,
    p.edicion_limitada,
    s.nombre_sucursal,
    s.zona_ciudad,
    m.medio_pago,
    v.unidades_vendidas,
    v.ingreso,
    v.costo_comision,
    (v.ingreso - v.costo_comision) AS ingreso_neto_estimado,
    CASE WHEN p.edicion_limitada = 1 THEN 'Edición Limitada' ELSE 'General Release' END AS tipo_producto
FROM fact.ventas v
JOIN dim.fecha f ON v.fecha = f.fecha
JOIN dim.producto p ON v.producto_id = p.producto_id
JOIN dim.sucursal s ON v.sucursal_id = s.sucursal_id
JOIN dim.medio_pago m ON v.medio_pago_id = m.medio_pago_id;

CREATE VIEW vw.vw_inventario_diario AS
SELECT
    i.fecha,
    f.anio,
    f.mes,
    p.marca,
    p.modelo,
    s.nombre_sucursal,
    i.unidades_disponibles,
    i.unidades_en_pedido,
    i.valor_inventario,
    i.dias_cobertura,
    CASE 
        WHEN i.dias_cobertura < 7 THEN 'Riesgo Alto'
        WHEN i.dias_cobertura BETWEEN 7 AND 15 THEN 'Riesgo Medio'
        ELSE 'Stock Saludable'
    END AS nivel_riesgo
FROM fact.inventario_diario i
JOIN dim.fecha f ON i.fecha = f.fecha
JOIN dim.producto p ON i.producto_id = p.producto_id
JOIN dim.sucursal s ON i.sucursal_id = s.sucursal_id;

CREATE VIEW vw.vw_ordenes_compra AS
SELECT
    oc.orden_compra_id,
    oc.fecha_orden,
    oc.fecha_esperada,
    oc.fecha_recepcion,
    p.marca,
    p.modelo,
    s.nombre_sucursal,
    pr.nombre_proveedor,
    oc.unidades_ordenadas,
    oc.unidades_recibidas,
    DATEDIFF(DAY, oc.fecha_esperada, oc.fecha_recepcion) AS dias_retraso,
    CASE WHEN oc.fecha_recepcion > oc.fecha_esperada THEN 1 ELSE 0 END AS orden_con_retraso
FROM fact.ordenes_compra oc
JOIN dim.producto p ON oc.producto_id = p.producto_id
JOIN dim.sucursal s ON oc.sucursal_id = s.sucursal_id
JOIN dim.proveedor pr ON oc.proveedor_id = pr.proveedor_id;


/* ============================================================
 8. VALIDACIONES FINALES
============================================================ */

SELECT COUNT(*) AS fechas FROM dim.fecha;
SELECT COUNT(*) AS ventas FROM fact.ventas;
SELECT COUNT(*) AS inventario FROM fact.inventario_diario;
SELECT COUNT(*) AS ordenes FROM fact.ordenes_compra;
SELECT COUNT(*) FROM vw.vw_ventas;
SELECT COUNT(*) FROM vw.vw_inventario_diario;
SELECT COUNT(*) FROM vw.vw_ordenes_compra;

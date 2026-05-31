-- Consulta 1 Lista de todas las habitaciones disponibles al día de hoy (Utilizar rangos de fechas)
SET @fecha_inicio = '2026-05-30';
SET @fecha_fin    = '2026-05-30';
 
SELECT h.id, h.numero, ch.descripcion AS tipo, ch.precio_noche
FROM habitacion h
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
WHERE h.id NOT IN (
        SELECT e.id_habitacion FROM estancia e
        WHERE e.fecha_checkin <= @fecha_fin
          AND (e.fecha_checkout >= @fecha_inicio OR e.fecha_checkout IS NULL)
      )
  AND h.id NOT IN (
        SELECT d.id_habitacion FROM detalle_reservacion d
        JOIN reservacion r ON r.id = d.id_reservacion
        WHERE r.estado <> 'Cancelada'
          AND r.fecha_entrada <= @fecha_fin
          AND r.fecha_salida  >= @fecha_inicio
      )
ORDER BY h.numero;

-- Consulta 2 Listado de clientes hospedados mostrando fecha de ingreso, fecha de fin de reserva, nombre y tipo de habitación
SELECT c.nombre, c.apellido, e.fecha_checkin, r.fecha_salida, h.numero, ch.descripcion
FROM cliente c, reservacion r, estancia e, habitacion h, categoria_habitacion ch
WHERE c.id = r.id_cliente
  AND r.id = e.id_reservacion
  AND e.id_habitacion = h.id
  AND h.id_categoria_habitacion = ch.id
  AND e.fecha_checkin IS NOT NULL
  AND e.fecha_checkout IS NULL;

-- Consulta 3 Reporte de clientes que tienen reserva en una fecha específica y no han hecho check-in
SET @fecha = '2026-06-05';  
SELECT r.id AS reserva, CONCAT(c.nombre,' ',c.apellido) AS cliente,
       r.fecha_entrada, r.fecha_salida, r.estado, r.tipo
FROM reservacion r
JOIN cliente c ON c.id = r.id_cliente
WHERE @fecha BETWEEN r.fecha_entrada AND r.fecha_salida
  AND r.estado <> 'Cancelada'
  AND NOT EXISTS (
        SELECT 1 FROM estancia e
        WHERE e.id_reservacion = r.id AND e.fecha_checkin IS NOT NULL
      )
ORDER BY r.fecha_entrada;

-- Consulta 4 Reporte de ocupación de habitaciones por tipo en base a fecha especificada.
SET @fecha = '2021-01-27';
SELECT ch.descripcion AS tipo,
       COUNT(h.id) AS total_habitaciones,
       SUM(CASE WHEN EXISTS (
             SELECT 1 FROM estancia e
             WHERE e.id_habitacion = h.id
               AND e.fecha_checkin <= @fecha
               AND (e.fecha_checkout IS NULL OR e.fecha_checkout >= @fecha)
           ) THEN 1 ELSE 0 END) AS ocupadas
FROM habitacion h
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
GROUP BY ch.id, ch.descripcion
ORDER BY ch.descripcion;

-- Consulta 5 Proyección de reservas futuras en los próximos 7 días.
SELECT r.id AS reserva, CONCAT(c.nombre,' ',c.apellido) AS cliente,
       r.fecha_entrada, r.fecha_salida, r.estado, r.tipo
FROM reservacion r
JOIN cliente c ON c.id = r.id_cliente
WHERE r.fecha_entrada BETWEEN '2026-05-30' AND '2026-05-30' + INTERVAL 7 DAY
ORDER BY r.fecha_entrada;

-- Consulta 6 Reservas canceladas en el último mes (utilizar rango de fechas).
SET @fecha_inicio = '2026-05-01';
SET @fecha_fin    = '2026-06-01';
 
SELECT r.id AS reserva, CONCAT(c.nombre,' ',c.apellido) AS cliente,
       r.fecha_entrada, r.fecha_salida,
       can.fecha AS fecha_cancelacion, can.motivo, can.monto_dev
FROM reservacion r
JOIN cliente c       ON c.id = r.id_cliente
JOIN cancelacion can ON can.id_reservacion = r.id
WHERE r.estado = 'Cancelada'
  AND can.fecha BETWEEN @fecha_inicio AND @fecha_fin
ORDER BY can.fecha DESC;

-- Consulta 7 Reporte de clientes que han reservado mas de 5 veces (Potenciales VIP).

SELECT c.id, CONCAT(c.nombre,' ',c.apellido) AS cliente, c.tipo,
       COUNT(r.id) AS num_reservas
FROM cliente c
JOIN reservacion r ON r.id_cliente = c.id
GROUP BY c.id
HAVING COUNT(r.id) > 5;

-- Consulta 8 Reporte de los servicios mas utilizados por los clientes en un rango de fechas.
SET @fecha_inicio = '2021-01-01';
SET @fecha_fin    = '2026-05-30';
 
SELECT s.nombre AS servicio, cs.tipo AS categoria,
       COUNT(*) AS veces_solicitado
FROM consumo_servicio co
JOIN servicio s       ON s.id  = co.id_servicio
JOIN categoria_serv cs ON cs.id = s.id_categoria_serv
WHERE co.fecha BETWEEN @fecha_inicio AND @fecha_fin
GROUP BY s.id
ORDER BY veces_solicitado DESC;

-- Consulta 9 Reporte rápido de finanzas, ingresos generados por rango de fechas específico.
SET @fecha_inicio = '2023-04-01';
SET @fecha_fin    = '2026-03-01';
 
SELECT SUM(f.subtotal)    AS subtotal,
       SUM(f.descuento)   AS descuentos,
       SUM(f.retenciones) AS retenciones,
       SUM(f.total)       AS ingreso_total
FROM factura f
WHERE f.estado_pago = 'Pagada'
  AND f.fecha BETWEEN @fecha_inicio AND @fecha_fin;

-- Consulta 10 Facturas emitidas en un rango de fechas y monto cobrado.
SET @fecha_inicio = '2023-01-01';
SET @fecha_fin    = '2024-05-30';
 
SELECT f.id AS factura, CONCAT(c.nombre,' ',c.apellido) AS cliente,
       f.fecha, f.estado_pago, f.metodo, f.total
FROM factura f
JOIN cliente c ON c.id = f.id_cliente
WHERE f.fecha BETWEEN @fecha_inicio AND @fecha_fin
ORDER BY f.fecha;

-- Consulta 11 Reporte de los mejores clientes del hotel, Top 10
SELECT c.id, CONCAT(c.nombre,' ',c.apellido) AS cliente, c.tipo,
      SUM(f.total) AS gasto_total
FROM cliente c
JOIN factura f ON f.id_cliente = c.id
WHERE f.estado_pago = 'Pagada'
GROUP BY c.id
ORDER BY gasto_total DESC
LIMIT 10;

-- Consulta 12 Reporte de habitaciones que no han sido ocupadas en el ultimo mes (basarse en rango de fechas)
SET @fecha_inicio = '2026-05-01' - INTERVAL 1 MONTH;
SET @fecha_fin    = '2026-06-01';
 
SELECT h.id, h.numero, ch.descripcion AS tipo
FROM habitacion h
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
WHERE h.id NOT IN (
        SELECT e.id_habitacion FROM estancia e
        WHERE e.fecha_checkin <= @fecha_fin
          AND (e.fecha_checkout >= @fecha_inicio OR e.fecha_checkout IS NULL)
      )
ORDER BY h.numero;

-- Consulta 13 Duración promedio de estancias por tipo de habitación.
SELECT ch.descripcion AS tipo,
       COUNT(*) AS estancias_finalizadas,
       ROUND(AVG(DATEDIFF(e.fecha_checkout, e.fecha_checkin)),1) AS noches_promedio
FROM estancia e
JOIN habitacion h            ON h.id  = e.id_habitacion
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
WHERE e.fecha_checkout IS NOT NULL
GROUP BY ch.id
ORDER BY noches_promedio DESC;

-- Consulta 14 Servicios no utilizados en el último mes (utilizar rango de fechas).
SELECT s.nombre, s.descripcion
FROM servicio s
WHERE s.id NOT IN (
    SELECT cs.id_servicio
    FROM consumo_servicio cs
    WHERE cs.fecha >= '2026-05-01'
      AND cs.fecha <= '2026-06-01'
);

-- Consulta 15 Reservas de habitaciones clasificadas por tipo de habitación en el último año (utilizar rango de
-- fechas) con la idea de conocer la demanda de las habitaciones.
SELECT ch.descripcion, COUNT(*) AS num_reservas
FROM reservacion r, estancia e, habitacion h, categoria_habitacion ch
WHERE r.id = e.id_reservacion
  AND e.id_habitacion = h.id
  AND h.id_categoria_habitacion = ch.id
  AND r.fecha_entrada >= '2025-05-01'
  AND r.fecha_entrada <= '2026-06-01'
GROUP BY ch.descripcion
ORDER BY COUNT(r.id) DESC;

-- Consulta 16: Clientes que cancelaron mas de 2 reservas: fechas, tipo de habitacion y motivo.
SELECT c.id, CONCAT(c.nombre,' ',c.apellido) AS cliente,
       COUNT(can.id) AS cancelaciones,
       GROUP_CONCAT(DISTINCT can.motivo SEPARATOR ' | ') AS motivos,
       GROUP_CONCAT(DISTINCT ch.descripcion SEPARATOR ' | ') AS tipos_habitacion,
       GROUP_CONCAT(can.fecha ORDER BY can.fecha SEPARATOR ', ') AS fechas
FROM cancelacion can
JOIN reservacion r ON r.id = can.id_reservacion
JOIN cliente c     ON c.id = r.id_cliente
LEFT JOIN detalle_reservacion d ON d.id_reservacion = r.id
LEFT JOIN habitacion h          ON h.id = d.id_habitacion
LEFT JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
GROUP BY c.id
HAVING COUNT(can.id) > 2
ORDER BY cancelaciones DESC;

-- Consulta 17 Reporte de número de reservas por país de origen del cliente.
SELECT c.pais, COUNT(*) as num_reservas
FROM cliente c, reservacion r
WHERE c.id = r.id_cliente
GROUP BY c.pais
ORDER BY COUNT(r.id) DESC;

-- Consulta 18 Promedio de facturación diaria (utilizar rango de fechas) para conocer la tendencia de ingresos por
-- día.
SET @fecha_inicio = '2021-01-01';
SET @fecha_fin    = '2026-06-01';
 
SELECT ROUND(AVG(total_dia),2) AS promedio_facturacion_diaria
FROM (
    SELECT f.fecha, SUM(f.total) AS total_dia
    FROM factura f
    WHERE f.estado_pago = 'Pagada'
      AND f.fecha BETWEEN @fecha_inicio AND @fecha_fin
    GROUP BY f.fecha
) AS por_dia;

-- Consulta 19 Clientes sin email registrado.
SELECT c.nombre, c.apellido, c.telefono
FROM cliente c
WHERE c.correo IS NULL;

-- Consulta 20 Reporte de clientes VIP hospedados actualmente (utilizar rango de fechas)
SET @fecha_inicio = '2026-06-01';
SET @fecha_fin    = '2026-06-01';
 
SELECT CONCAT(c.nombre,' ',c.apellido) AS cliente, c.tipo,
       e.fecha_checkin, h.numero AS habitacion, ch.descripcion AS tipo_habitacion
FROM estancia e
JOIN reservacion r          ON r.id  = e.id_reservacion
JOIN cliente c              ON c.id  = r.id_cliente
JOIN habitacion h           ON h.id  = e.id_habitacion
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
WHERE c.tipo = 'VIP'
  AND e.fecha_checkin <= @fecha_fin
  AND (e.fecha_checkout IS NULL OR e.fecha_checkout >= @fecha_inicio)
ORDER BY e.fecha_checkin;

-- Consulta 21 Reporte para auditar los cambios de estado de una habitación específica la cual debe mostrar
-- reserva, cliente, fecha, costo, nombre de agente de mostrador.
SELECT b.fecha_hora, b.estado_anterior, b.estado_nuevo,
       c.nombre, c.apellido,
       emp.nombre, emp.apellido,
       r.id, f.total
FROM bitacora_habitacion b, estancia e, reservacion r, cliente c, empleado emp, factura f
WHERE b.id_estancia = e.id
  AND e.id_reservacion = r.id
  AND r.id_cliente = c.id
  AND b.id_empleado = emp.id
  AND f.id_reservacion = r.id
  AND b.id_habitacion = 3001;

-- Consulta 22 Reporte de facturas sin pagar o pendientes de pago (utilizar rango de fechas).
SELECT c.nombre, c.apellido, f.fecha, f.total, f.estado_pago
FROM cliente c, factura f
WHERE c.id = f.id_cliente
  AND f.estado_pago = 'Pendiente'
  AND f.fecha >= '2025-01-01'
  AND f.fecha <= '2025-05-24';

-- Consulta 23  Listado de reservas expiradas que no se actualizaron (con el enfoque en la detección de errores de
-- operaciones).
SELECT c.nombre, c.apellido, r.fecha_entrada, r.fecha_salida, r.estado
FROM cliente c, reservacion r
WHERE c.id = r.id_cliente
  AND r.fecha_salida < '2025-05-25'
  AND r.estado NOT IN ('Completada', 'Cancelada');

-- Consulta 24 Porcentaje de ocupacion mensual por tipo de habitacion
--     (rango de fechas).
SET @fecha_inicio = '2026-01-01';
SET @fecha_fin    = '2026-12-31';
 
WITH RECURSIVE meses AS (
    SELECT DATE_FORMAT(@fecha_inicio,'%Y-%m-01') AS mes
    UNION ALL
    SELECT mes + INTERVAL 1 MONTH FROM meses
    WHERE mes + INTERVAL 1 MONTH <= @fecha_fin
)
SELECT DATE_FORMAT(m.mes,'%Y-%m') AS mes,
       ch.descripcion AS tipo,
       COUNT(DISTINCT h.id) AS total_habitaciones,
       COUNT(DISTINCT e.id_habitacion) AS habitaciones_ocupadas,
       ROUND(100 * COUNT(DISTINCT e.id_habitacion) / COUNT(DISTINCT h.id), 2) AS ocupacion_pct
FROM meses m
JOIN categoria_habitacion ch
JOIN habitacion h ON h.id_categoria_habitacion = ch.id
LEFT JOIN estancia e ON e.id_habitacion = h.id
     AND e.fecha_checkin <= LAST_DAY(m.mes)
     AND (e.fecha_checkout >= m.mes OR e.fecha_checkout IS NULL)
GROUP BY m.mes, ch.id
ORDER BY m.mes, ch.descripcion;

-- Consulta 25 Ingresos por tipo de habitacion
SET @fecha_inicio = '2021-01-01';
SET @fecha_fin    = '2026-05-30';
 
SELECT ch.descripcion AS tipo,
       SUM(f.total) AS ingreso
FROM factura f
JOIN reservacion r           ON r.id  = f.id_reservacion
JOIN detalle_reservacion d   ON d.id_reservacion = r.id
JOIN habitacion h            ON h.id  = d.id_habitacion
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
WHERE f.estado_pago = 'Pagada'
  AND f.fecha BETWEEN @fecha_inicio AND @fecha_fin
GROUP BY ch.id
ORDER BY ingreso DESC;

-- Consulta 26 Reporte de empleados y el bono acumulado por rango de fechas específico.
SET @fecha_inicio = '2024-01-01';
SET @fecha_fin    = '2025-05-30';
 
SELECT CONCAT(emp.nombre,' ',emp.apellido) AS empleado, emp.puesto,
       COUNT(b.id) AS num_bonos, SUM(b.monto) AS bono_acumulado
FROM bono b
JOIN nomina n   ON n.id  = b.id_nomina
JOIN empleado emp ON emp.id = n.id_empleado
WHERE b.fecha_inicio BETWEEN @fecha_inicio AND @fecha_fin
GROUP BY emp.id
ORDER BY bono_acumulado DESC;

-- Consulta 27 Listado servicios mas utilizados por Clientes VIP.
SELECT s.nombre AS servicio, cs.tipo AS categoria,
       COUNT(*) AS veces_solicitado
FROM consumo_servicio co
JOIN servicio s        ON s.id  = co.id_servicio
JOIN categoria_serv cs ON cs.id = s.id_categoria_serv
JOIN estancia e        ON e.id  = co.id_estancia
JOIN reservacion r     ON r.id  = e.id_reservacion
JOIN cliente c         ON c.id  = r.id_cliente
WHERE c.tipo = 'VIP'
GROUP BY s.id
ORDER BY veces_solicitado DESC;

-- Consulta 28 Reporte de quejas registradas en base a un rango de fechas dado y clasificado por el departamento
-- al que fue aplicada la queja
SET @fecha_inicio = '2021-01-01';
SET @fecha_fin    = '2026-05-30';
 
SELECT emp.puesto AS departamento, COUNT(*) AS num_quejas,
       SUM(q.estado = 'Resuelta') AS resueltas,
       SUM(q.estado <> 'Resuelta') AS pendientes
FROM queja q
JOIN empleado emp ON emp.id = q.id_empleado
WHERE q.fecha BETWEEN @fecha_inicio AND @fecha_fin
GROUP BY emp.puesto
ORDER BY num_quejas DESC;

-- Consulta 29 S Departamento con mejor rating de satisfaccion
SET @fecha_inicio = '2021-01-01';
SET @fecha_fin    = '2026-05-30';
 
SELECT emp.puesto AS departamento,
       ROUND(AVG(s.cal_general),2)  AS rating_general,
       ROUND(AVG(s.cal_servicio),2) AS rating_servicio,
       COUNT(*) AS encuestas
FROM satisfaccion s
JOIN estancia e   ON e.id  = s.id_estancia
JOIN empleado emp ON emp.id = e.id_empleado
WHERE s.fecha_hora BETWEEN @fecha_inicio AND @fecha_fin
GROUP BY emp.puesto
ORDER BY rating_general DESC
LIMIT 1;

-- Consulta 30 Habitaciones ocupadas por mayor duracion de estancia,
--     clasificadas por tipo de habitacion (rango de fechas).
SET @fecha_inicio = '2026-01-01';
SET @fecha_fin    = '2026-03-30';
 
SELECT ch.descripcion AS tipo, h.numero AS habitacion,
       CONCAT(c.nombre,' ',c.apellido) AS cliente,
       e.fecha_checkin, e.fecha_checkout,
       DATEDIFF(IFNULL(e.fecha_checkout, '2026-05-30'), e.fecha_checkin) AS noches
FROM estancia e
JOIN habitacion h            ON h.id  = e.id_habitacion
JOIN categoria_habitacion ch ON ch.id = h.id_categoria_habitacion
JOIN reservacion r           ON r.id  = e.id_reservacion
JOIN cliente c               ON c.id  = r.id_cliente
WHERE e.fecha_checkin BETWEEN @fecha_inicio AND @fecha_fin
ORDER BY ch.descripcion, noches DESC;
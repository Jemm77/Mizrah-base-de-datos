--Consulta 1 Lista de todas las habitaciones disponibles al día de hoy (Utilizar rangos de fechas)
SELECT h.numero, h.estado, h.capacidad, ch.descripcion, ch.precio_noche
FROM habitacion h, categoria_habitacion ch
WHERE h.id_categoria_habitacion = ch.id
  AND h.estado = 'Disponible';

--Consulta 2 Listado de clientes hospedados mostrando fecha de ingreso, fecha de fin de reserva, nombre y tipo de habitación
SELECT c.nombre, c.apellido, e.fecha_checkin, r.fecha_salida, h.numero, ch.descripcion
FROM cliente c, reservacion r, estancia e, habitacion h, categoria_habitacion ch
WHERE c.id = r.id_cliente
  AND r.id = e.id_reservacion
  AND e.id_habitacion = h.id
  AND h.id_categoria_habitacion = ch.id
  AND e.fecha_checkin IS NOT NULL
  AND e.fecha_checkout IS NULL;

--Consulta 3 Reporte de clientes que tienen reserva en una fecha específica y no han hecho check-in
SELECT c.nombre, c.apellido, r.fecha_entrada, r.fecha_salida, r.estado
FROM cliente c, reservacion r
WHERE c.id = r.id_cliente
  AND r.fecha_entrada <= '2025-06-01'
  AND r.fecha_salida  >= '2025-06-01'
  AND r.id NOT IN (
      SELECT e.id_reservacion
      FROM estancia e
  );

--Consulta 4 Reporte de ocupación de habitaciones por tipo en base a fecha especificada.
SELECT ch.descripcion, COUNT(h.id) AS habitaciones_ocupadas
FROM habitacion h, categoria_habitacion ch, estancia e, reservacion r
WHERE h.id_categoria_habitacion = ch.id
  AND h.id = e.id_habitacion
  AND e.id_reservacion = r.id
  AND r.fecha_entrada <= '2025-06-01'
  AND r.fecha_salida  >= '2025-06-01'
GROUP BY ch.descripcion;

--Consulta 5 Proyección de reservas futuras en los próximos 7 días.
SELECT c.nombre, c.apellido, r.fecha_entrada, r.fecha_salida, r.estado
FROM cliente c, reservacion r
WHERE c.id = r.id_cliente
  AND r.fecha_entrada >= '2025-05-25'
  AND r.fecha_entrada <= '2025-06-01';

--Consulta 6 Reservas canceladas en el último mes (utilizar rango de fechas).
SELECT c.nombre, c.apellido, r.fecha_entrada, r.fecha_salida, ca.motivo, ca.fecha
FROM cliente c, reservacion r, cancelacion ca
WHERE c.id = r.id_cliente
  AND r.id = ca.id_reservacion
  AND ca.fecha >= '2025-05-01'
  AND ca.fecha <= '2025-06-01';

--Consulta 7 Reporte de clientes que han reservado mas de 5 veces (Potenciales VIP).
SELECT c.nombre, c.apellido, COUNT(r.id)
FROM cliente c, reservacion r
WHERE c.id = r.id_cliente
GROUP BY c.id, c.nombre, c.apellido
HAVING COUNT(r.id) > 5;

--Consulta 8 Reporte de los servicios mas utilizados por los clientes en un rango de fechas.
SELECT s.nombre, SUM(cs.cantidad)
FROM servicio s, consumo_servicio cs
WHERE s.id = cs.id_servicio
  AND cs.fecha >= '2025-01-01'
  AND cs.fecha <= '2025-02-01'
GROUP BY s.id, s.nombre
ORDER BY SUM(cs.cantidad) DESC;

--Consulta 9 Reporte rápido de finanzas, ingresos generados por rango de fechas específico.
SELECT SUM(f.total) 
FROM factura f
WHERE f.fecha >= '2025-01-01'
  AND f.fecha <= '2025-05-24';

--Consulta 10 Facturas emitidas en un rango de fechas y monto cobrado.
SELECT c.nombre, c.apellido, f.fecha, f.total
FROM cliente c, factura f
WHERE c.id = f.id_cliente
  AND f.fecha >= '2025-01-01'
  AND f.fecha <= '2025-05-31';

--Consulta 11 TReporte de los mejores clientes del hotel, Top 10
SELECT c.nombre, c.apellido, SUM(f.total)
FROM cliente c, factura f
WHERE c.id = f.id_cliente
GROUP BY c.id, c.nombre, c.apellido
ORDER BY SUM(f.total) DESC

--Consulta 12 Reporte de habitaciones que no han sido ocupadas en el ultimo mes (basarse en rango de fechas)
SELECT h.numero, ch.descripcion, h.estado
FROM habitacion h, categoria_habitacion ch
WHERE h.id_categoria_habitacion = ch.id
  AND h.id NOT IN (
      SELECT e.id_habitacion
      FROM estancia e
      WHERE e.fecha_checkin >= '2025-04-01'
        AND e.fecha_checkin <= '2025-05-01'
  );

--Consulta 13 Duración promedio de estancias por tipo de habitación.
SELECT ch.descripcion, AVG(DATEDIFF(e.fecha_checkout, e.fecha_checkin))
FROM estancia e, habitacion h, categoria_habitacion ch
WHERE e.id_habitacion = h.id
  AND h.id_categoria_habitacion = ch.id
  AND e.fecha_checkout IS NOT NULL
GROUP BY ch.descripcion;

-- Consulta 14 Servicios no utilizados en el último mes (utilizar rango de fechas).
SELECT s.nombre, s.descripcion
FROM servicio s
WHERE s.id NOT IN (
    SELECT cs.id_servicio
    FROM consumo_servicio cs
    WHERE cs.fecha >= '2025-04-01'
      AND cs.fecha <= '2025-05-01'
);

-- Consulta 15 Reservas de habitaciones clasificadas por tipo de habitación en el último año (utilizar rango de
-- fechas) con la idea de conocer la demanda de las habitaciones.
SELECT ch.descripcion, COUNT(r.id)
FROM reservacion r, estancia e, habitacion h, categoria_habitacion ch
WHERE r.id = e.id_reservacion
  AND e.id_habitacion = h.id
  AND h.id_categoria_habitacion = ch.id
  AND r.fecha_entrada >= '2024-01-01'
  AND r.fecha_entrada <= '2025-01-01'
GROUP BY ch.descripcion
ORDER BY COUNT(r.id) DESC;


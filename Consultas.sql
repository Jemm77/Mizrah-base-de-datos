-- Consulta 1 Lista de todas las habitaciones disponibles al día de hoy (Utilizar rangos de fechas)
SELECT h.numero, h.estado, h.capacidad, ch.descripcion, ch.precio_noche
FROM habitacion h, categoria_habitacion ch
WHERE h.id_categoria_habitacion = ch.id
  AND h.estado = 'Disponible';

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
SELECT c.nombre, c.apellido, r.fecha_entrada, r.fecha_salida, r.estado
FROM cliente c, reservacion r
WHERE c.id = r.id_cliente
  AND r.fecha_entrada <= '2025-06-01'
  AND r.fecha_salida  >= '2025-06-01'
  AND r.id NOT IN (
      SELECT e.id_reservacion
      FROM estancia e
  );


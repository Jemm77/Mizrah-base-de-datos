USE hotel;

--a. Registrar una nueva reserva.
DELIMITER //
CREATE PROCEDURE sp_registrar_reserva(
    IN p_id_cliente INT,
    IN p_fecha_entrada DATE,
    IN p_fecha_salida DATE,
    IN p_tipo VARCHAR(50),
    IN p_id_habitacion INT
)
BEGIN
    INSERT INTO reservacion (id_cliente, fecha_entrada, fecha_salida, direccion, estado, tipo, identificacion)
    VALUES (p_id_cliente, p_fecha_entrada, p_fecha_salida, 'N/A', 'Confirmada', p_tipo, CONCAT('RES-', p_id_cliente, '-', p_id_habitacion));

    INSERT INTO detalle_reservacion (id_reservacion, id_habitacion)
    VALUES (LAST_INSERT_ID(), p_id_habitacion);
END //
DELIMITER ;



--b. Actualizar el estado de una habitación: "Ocupado" o "Disponible".
DELIMITER //
CREATE PROCEDURE sp_actualizar_estado_habitacion(
    IN p_id_habitacion INT,
    IN p_estado VARCHAR(25)
)
BEGIN
    UPDATE habitacion SET estado = p_estado WHERE id = p_id_habitacion;
END //
DELIMITER ;


--c. Para acelerar el check-out de los huéspedes genera una factura rápida del cliente.
DELIMITER //
CREATE PROCEDURE sp_factura_rapida(
    IN p_id_reservacion INT
)
BEGIN
    DECLARE v_id_cliente INT;
    DECLARE v_total FLOAT;

    SELECT id_cliente INTO v_id_cliente FROM reservacion WHERE id = p_id_reservacion;
    SELECT IFNULL(SUM(total), 0) INTO v_total FROM consumo_servicio WHERE id_estancia = p_id_reservacion;

    INSERT INTO factura (id_cliente, id_reservacion, fecha, estado_pago, descuento, metodo, retenciones, subtotal, total)
    VALUES (v_id_cliente, p_id_reservacion, CURDATE(), 'Pendiente', 0, 'Efectivo', 0, v_total, v_total);
END //
DELIMITER ;

--d. Verificación de disponibilidad de habitaciones antes de la reservación.
DELIMITER //
CREATE PROCEDURE sp_verificar_disponibilidad()
BEGIN
    SELECT h.id, h.numero, h.estado, ch.descripcion, ch.precio_noche
    FROM habitacion h, categoria_habitacion ch
    WHERE h.id_categoria_habitacion = ch.id
      AND h.estado = 'Disponible';
END //
DELIMITER ;



--e. Registro de servicios utilizados por un cliente.
DELIMITER //
CREATE PROCEDURE sp_registrar_servicio(
    IN p_id_servicio INT,
    IN p_id_estancia INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio FLOAT;
    SELECT precio INTO v_precio FROM servicio WHERE id = p_id_servicio;

    INSERT INTO consumo_servicio (id_servicio, id_estancia, precio_unidad, fecha, hora, total, cantidad)
    VALUES (p_id_servicio, p_id_estancia, v_precio, CURDATE(), CURTIME(), v_precio * p_cantidad, p_cantidad);
END //
DELIMITER ;


--f. Cancelar una reserva cuando el cliente cancela, y liberar la habitación o habitaciones reservadas.
DELIMITER //
CREATE PROCEDURE sp_cancelar_reserva(
    IN p_id_reservacion INT
)
BEGIN
    UPDATE reservacion SET estado = 'Cancelada' WHERE id = p_id_reservacion;
    UPDATE habitacion SET estado = 'Disponible'
    WHERE id = (SELECT id_habitacion FROM detalle_reservacion WHERE id_reservacion = p_id_reservacion LIMIT 1);
END //
DELIMITER ;



--g. Cuando el cliente sea VIP debe actualizar datos de cliente frecuente.
DELIMITER //
CREATE PROCEDURE sp_actualizar_cliente_vip(
    IN p_id_cliente INT
)
BEGIN
    UPDATE cliente SET tipo = 'VIP' WHERE id = p_id_cliente;
END //
DELIMITER ;

--h. Listar los clientes hospedados en tiempo real.
DELIMITER //
CREATE PROCEDURE sp_clientes_hospedados()
BEGIN
    SELECT c.nombre, c.apellido, h.numero, e.fecha_checkin
    FROM cliente c, reservacion r, estancia e, habitacion h
    WHERE c.id = r.id_cliente
      AND r.id = e.id_reservacion
      AND e.id_habitacion = h.id
      AND e.fecha_checkout IS NULL;
END //
DELIMITER ;


--i. Reporte de ingresos por mes.
DELIMITER //
CREATE PROCEDURE sp_ingresos_por_mes(
    IN p_anio INT
)
BEGIN
    SELECT MONTH(fecha) AS mes, SUM(total) AS ingresos
    FROM factura
    WHERE YEAR(fecha) = p_anio
    GROUP BY MONTH(fecha)
    ORDER BY mes;
END //
DELIMITER ;



--j. Asignar upgrade de habitación automático a clientes VIP.
DELIMITER //
CREATE PROCEDURE sp_upgrade_habitacion_vip(
    IN p_id_reservacion INT
)
BEGIN
    DECLARE v_id_habitacion INT;

    SELECT h.id INTO v_id_habitacion
    FROM habitacion h, categoria_habitacion ch
    WHERE h.id_categoria_habitacion = ch.id
      AND h.estado = 'Disponible'
    ORDER BY ch.precio_noche DESC
    LIMIT 1;

    UPDATE detalle_reservacion SET id_habitacion = v_id_habitacion
    WHERE id_reservacion = p_id_reservacion;
END //
DELIMITER ;

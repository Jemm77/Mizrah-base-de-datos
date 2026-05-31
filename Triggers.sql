USE hotel;

-- a. Cuando un cliente realiza check-in, la habitacion cambia a "Ocupado"
DELIMITER //
CREATE TRIGGER tr_checkin_ocupa_habitacion
AFTER INSERT ON estancia
FOR EACH ROW
BEGIN
    IF NEW.fecha_checkin IS NOT NULL THEN
        UPDATE habitacion SET estado = 'Ocupado' WHERE id = NEW.id_habitacion;
    END IF;
END //
DELIMITER ;

-- b. Al terminar la estancia, liberar automaticamente la habitacion
DELIMITER //
CREATE TRIGGER tr_checkout_libera_habitacion
AFTER UPDATE ON estancia
FOR EACH ROW
BEGIN
    IF NEW.fecha_checkout IS NOT NULL THEN
        UPDATE habitacion SET estado = 'Disponible' WHERE id = NEW.id_habitacion;
    END IF;
END //
DELIMITER ;

-- c. Llevar una bitacora cada vez que cambie de estado una habitacion
DELIMITER //
CREATE TRIGGER tr_bitacora_habitacion
AFTER UPDATE ON habitacion
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO bitacora_habitacion(id_habitacion, estado_anterior, estado_nuevo, fecha_hora)
        VALUES (NEW.id, OLD.estado, NEW.estado, NOW());
    END IF;
END //
DELIMITER ;

-- d. Cada vez que un cliente se registre, agregarlo a clientes_potenciales_vip
DELIMITER //
CREATE TRIGGER tr_cliente_potencial_vip
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO clientes_potenciales_vip(id_cliente, fecha_registro)
    VALUES (NEW.id, CURDATE());
END //
DELIMITER ;

-- e. Cada vez que un cliente VIP hace una reserva actualizar su contador personal
DELIMITER //
CREATE TRIGGER tr_contador_vip
AFTER INSERT ON reservacion
FOR EACH ROW
BEGIN
    DECLARE v_tipo VARCHAR(20);
    SELECT tipo INTO v_tipo FROM cliente WHERE id = NEW.id_cliente;

    IF v_tipo = 'VIP' THEN
        UPDATE cliente SET contador_reservas = contador_reservas + 1 WHERE id = NEW.id_cliente;
    END IF;
END //
DELIMITER ;

-- f. Validar que fecha_salida sea mayor que fecha_entrada
DELIMITER //
CREATE TRIGGER tr_valida_fechas_reservacion_ins
BEFORE INSERT ON reservacion
FOR EACH ROW
BEGIN
    IF NEW.fecha_salida <= NEW.fecha_entrada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de salida debe ser mayor que la fecha de entrada.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_valida_fechas_reservacion_upd
BEFORE UPDATE ON reservacion
FOR EACH ROW
BEGIN
    IF NEW.fecha_salida <= NEW.fecha_entrada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de salida debe ser mayor que la fecha de entrada.';
    END IF;
END //
DELIMITER ;

-- g. Control automatico del inventario de habitaciones
DELIMITER //
CREATE TRIGGER tr_inventario_habitacion
BEFORE INSERT ON estancia
FOR EACH ROW
BEGIN
    DECLARE v_estado VARCHAR(25);
    SELECT estado INTO v_estado FROM habitacion WHERE id = NEW.id_habitacion;

    IF v_estado <> 'Disponible' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La habitacion no esta disponible.';
    END IF;
END //
DELIMITER ;

-- h. Si la fecha de entrada pasa y no se hizo check-in, cancelar reserva de forma automatica
SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE EVENT ev_cancela_reservas_vencidas
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY)
DO
BEGIN
    UPDATE reservacion r
    LEFT JOIN estancia e ON e.id_reservacion = r.id
    SET r.estado = 'Cancelada'
    WHERE r.fecha_entrada < CURDATE()
      AND r.estado <> 'Cancelada'
      AND e.id IS NULL;
END //
DELIMITER ;

-- i. Evitar servicios registrados con precios negativos o cero
DELIMITER //
CREATE TRIGGER tr_valida_precio_servicio_ins
BEFORE INSERT ON servicio
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio del servicio debe ser mayor que cero.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_valida_precio_servicio_upd
BEFORE UPDATE ON servicio
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio del servicio debe ser mayor que cero.';
    END IF;
END //
DELIMITER ;

-- j. Cancelacion de una reserva se penaliza con 55% del costo si esta fuera de plazo
DELIMITER //
CREATE TRIGGER tr_cancelacion_penalizacion
BEFORE INSERT ON cancelacion
FOR EACH ROW
BEGIN
    DECLARE v_fecha_entrada DATE;
    DECLARE v_dias INT;

    SELECT fecha_entrada INTO v_fecha_entrada FROM reservacion WHERE id = NEW.id_reservacion;
    SET v_dias = DATEDIFF(v_fecha_entrada, NEW.fecha);

    IF v_dias >= 3 THEN
        SET NEW.monto_dev = NEW.monto;
    ELSE
        SET NEW.monto_dev = NEW.monto * 0.45;
    END IF;
END //
DELIMITER ;

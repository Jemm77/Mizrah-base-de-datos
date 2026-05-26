
CREATE database hotel;

USE hotel;

CREATE table rol(
id INT auto_increment primary key,
nombre_rol VARCHAR(50),
descripcion TEXT
)AUTO_INCREMENT = 4000;

CREATE table categoria_serv(
id INT auto_increment primary key,
tipo VARCHAR(10),
descripcion TEXT,
estado TINYINT(1)
)AUTO_INCREMENT = 4000;

CREATE table categoria_habitacion(
id INT auto_increment primary key,
precio_noche FLOAT,
descripcion TEXT
)AUTO_INCREMENT = 4000;

CREATE table cliente(
id INT auto_increment primary key,
nombre VARCHAR(50),
apellido VARCHAR(50),
telefono VARCHAR(20),
direccion VARCHAR(50),
tipo VARCHAR(20),
correo VARCHAR(50),
sexo CHAR,
rfc VARCHAR(25)
)AUTO_INCREMENT = 4000;

CREATE table usuario(
id INT auto_increment primary key,
id_rol INT,
fecha_creacion DATE,
estado TINYINT(1),
telefono VARCHAR(20),
contrasena TEXT,
correo VARCHAR(100),
foreign key (id_rol) references rol(id)
)AUTO_INCREMENT = 4000;

CREATE table empleado(
id INT auto_increment primary key,
id_usuario INT,
puesto VARCHAR(20),
salario FLOAT(10,2),
direccion VARCHAR(250),
fecha_cont DATE,
telefono VARCHAR(20),
nombre VARCHAR(100),
apellido VARCHAR(100),
foreign key (id_usuario) references usuario(id)
)AUTO_INCREMENT = 4000;

CREATE table nomina(
id INT auto_increment primary key,
id_empleado INT,
estado_pago VARCHAR(20),
horas_extra INT,
fecha_inicio DATE,
fecha_fin DATE,
salario_neto FLOAT(10,2),
impuestos FLOAT(10,2),
fecha_pago DATE,
salario_base FLOAT(10,2),
foreign key (id_empleado) references empleado(id)
)AUTO_INCREMENT = 4000;

CREATE table habitacion(
id INT auto_increment primary key,
id_categoria_habitacion INT,
estado varchar(25),
ext_tel INT,
capacidad INT,
numero INT,
foreign key (id_categoria_habitacion) references categoria_habitacion(id)
)AUTO_INCREMENT = 3000;

CREATE table reservacion(
id INT auto_increment primary key,
id_cliente INT,
fecha_entrada DATE,
fecha_salida DATE,
direccion VARCHAR(50),
estado VARCHAR(25),
tipo VARCHAR(50) NOT NULL,
identificacion VARCHAR(50) NOT NULL,
foreign key (id_cliente) references cliente(id)
)AUTO_INCREMENT = 1000;

CREATE table detalle_reservacion(
id INT auto_increment primary key,
id_reservacion INT,
foreign key (id_reservacion) references reservacion(id)
)AUTO_INCREMENT = 2000;

CREATE table estancia(
id INT auto_increment primary key,
id_reservacion INT,
id_habitacion INT,
fecha_checkin DATE,
fecha_checkout DATE,
hora_checkin TIME,
hora_checkout TIME,
estado TINYINT,
foreign key (id_reservacion) references reservacion(id),
foreign key (id_habitacion) references habitacion(id)
)AUTO_INCREMENT = 4000;

CREATE table satisfaccion(
id INT auto_increment primary key,
fecha_hora DATETIME,
cal_servicio INT,
cal_general INT,
comentarios TEXT,
id_estancia INT,
FOREIGN KEY (id_estancia) references estancia(id)
)AUTO_INCREMENT = 4000;

CREATE table queja(
id INT auto_increment primary key,
id_cliente INT,
id_estancia INT,
id_empleado INT,
estado VARCHAR(25),
fecha DATE,
hora TIME,
descripcion TEXT,
foreign key (id_cliente) references cliente(id),
foreign key (id_estancia) references estancia(id),
foreign key (id_empleado) references empleado(id)
)AUTO_INCREMENT = 4000;

CREATE table fondo(
id INT auto_increment primary key,
id_reservacion INT,
motivo_rete TEXT,
monto_rete FLOAT(10,2),
monto_fondo FLOAT(10,2),
monto_dev FLOAT (10,2),
fecha_cobro DATE,
foreign key (id_reservacion) references reservacion(id)
)AUTO_INCREMENT = 4000;

CREATE table cancelacion(
id INT auto_increment primary key,
id_reservacion INT,
id_fondo INT,
monto FLOAT(10,2),
monto_dev FLOAT(10,2),
motivo TEXT,
fecha DATE,
foreign key (id_reservacion) references reservacion(id),
foreign key (id_fondo) references fondo(id)
)AUTO_INCREMENT = 4000;

CREATE table factura(
id INT auto_increment primary key,
id_cliente INT,
id_reservacion INT,
fecha DATE,
estado_pago VARCHAR(20) DEFAULT 'Pendiente',
descuento FLOAT,
metodo VARCHAR(25),
retenciones FLOAT,
subtotal FLOAT,
total FLOAT,
foreign key (id_cliente) references cliente(id),
foreign key (id_reservacion) references reservacion(id)
)AUTO_INCREMENT = 4000;

CREATE table acompanante(
id INT auto_increment primary key,
id_reservacion INT,
telefono VARCHAR(20),
sexo CHAR,
nombre VARCHAR(50),
apellido VARCHAR(50),
fecha_nac DATE,
foreign key (id_reservacion) references reservacion(id)
)AUTO_INCREMENT = 4000;

CREATE table servicio(
id INT auto_increment primary key,
id_categoria_serv INT,
nombre VARCHAR(50),
descripcion TEXT,
estado TINYINT(1),
precio FLOAT(10,2),
foreign key (id_categoria_serv) references categoria_serv(id)
)AUTO_INCREMENT = 4000;

CREATE table consumo_servicio(
id INT auto_increment primary key,
id_servicio INT,
id_estancia INT,
precio_unidad FLOAT(10,2),
fecha DATE,
hora TIME,
total FLOAT(10,2),
cantidad INT,
foreign key (id_servicio) references servicio(id),
foreign key (id_estancia) references estancia(id)
)AUTO_INCREMENT = 4000;

CREATE table paquete_promo(
id INT auto_increment primary key,
id_servicio INT,
id_reservacion INT,
descuento FLOAT(10,2),
nombre VARCHAR(50),
descripcion TEXT,
estado TINYINT(1),
precio FLOAT(10,2),
fecha_inicio DATE,
fecha_fin DATE,
foreign key (id_servicio) references servicio(id),
foreign key (id_reservacion) references reservacion(id)
)AUTO_INCREMENT = 4000;

CREATE table bono(
id INT auto_increment primary key,
id_nomina INT,
monto FLOAT(10,2),
emisor VARCHAR(20),
fecha_fin DATE,
foreign key(id_nomina) references nomina(id)
)AUTO_INCREMENT = 4000;
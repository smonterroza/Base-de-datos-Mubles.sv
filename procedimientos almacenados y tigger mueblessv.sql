USE mueblessv;

-- procedimientos para la base de datos     

DROP PROCEDURE IF EXISTS sp_insertar_administrador;
DROP PROCEDURE IF EXISTS sp_insertar_cliente;
DROP PROCEDURE IF EXISTS sp_insertar_color;
DROP PROCEDURE IF EXISTS sp_insertar_categoria;
DROP PROCEDURE IF EXISTS sp_insertar_material;
DROP PROCEDURE IF EXISTS sp_insertar_mueble;
DROP PROCEDURE IF EXISTS sp_insertar_producto_semanal;
DROP PROCEDURE IF EXISTS sp_insertar_pedido;
DROP PROCEDURE IF EXISTS sp_insertar_detalle_pedido;
DROP PROCEDURE IF EXISTS sp_insertar_valoracion;
DROP PROCEDURE IF EXISTS sp_insertar_etiqueta;


-- TRIGGER para el control del stock
DELIMITER $$
CREATE TRIGGER verificar_stock
AFTER INSERT ON tb_detalles_pedidos
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    DECLARE cantidad_pedido INT;
    
    SELECT stock INTO stock_actual FROM tb_muebles WHERE id_mueble = NEW.id_mueble;
    SELECT cantidad_pedido INTO cantidad_pedido FROM tb_detalles_pedidos WHERE id_detalle_pedido = NEW.id_detalle_pedido;
    
    IF cantidad_pedido > stock_actual THEN
        UPDATE tb_muebles SET stock = stock - cantidad_pedido WHERE id_mueble = NEW.id_mueble;
    END IF;
END;
$$ DELIMITER ;


-- insertar tabla clientes
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_cliente(
    IN p_clave_cliente VARCHAR(60),
    IN p_nombre_cliente VARCHAR(60),
    IN p_apellido_cliente VARCHAR(60),
    IN p_dui_cliente VARCHAR(10),
    IN p_telefono_cliente VARCHAR(10),
    IN p_direccion_cliente VARCHAR(60),
    IN p_correo_cliente VARCHAR(60)
)
BEGIN
    INSERT INTO tb_clientes(clave_cliente, nombre_cliente, apellido_cliente, dui_cliente, telefono_cliente, direccion_cliente, correo_cliente)
    VALUES(p_clave_cliente, p_nombre_cliente, p_apellido_cliente, p_dui_cliente, p_telefono_cliente, p_direccion_cliente, p_correo_cliente);
END;
$$ DELIMITER ;


-- insertar tabla administradores
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_administrador(
    IN p_alias_administrador VARCHAR(50),
    IN p_clave_administrador VARCHAR(120),
    IN p_nombre_administrador VARCHAR(60),
    IN p_apellido_administrador VARCHAR(60),
    IN p_correo_administrador VARCHAR(60),
    IN p_telefono_administrador INT
)
BEGIN

        INSERT INTO tb_administradores(alias_administrador, clave_administrador, nombre_administrador, apellido_administrador, coreo_administrador, telefono_administrador)
        VALUES(p_alias_administrador, p_clave_administrador, p_nombre_administrador, p_apellido_administrador, p_correo_administrador, p_telefono_administrador);
    
END;
$$ DELIMITER ;

SELECT * from tb_clientes


-- insertar tabla colores
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_color(
    IN p_nombre_color VARCHAR(40)
)
BEGIN
    IF NOT EXISTS (SELECT * FROM tb_colores WHERE nombre_color = p_nombre_color) THEN
        INSERT INTO tb_colores(nombre_color)
        VALUES(p_nombre_color);
        ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El color ya existe';
    END IF;
END;
$$ DELIMITER ;


-- insertar tabla categorias
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_categoria(
    IN p_nombre_categoria VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT * FROM tb_categorias WHERE nombre_categoria = p_nombre_categoria) THEN
        INSERT INTO tb_categorias(nombre_categoria)
        VALUES(p_nombre_categoria);
        ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoria ya existe';
    END IF;
END ;
$$ DELIMITER ;

-- insertar tabla materiales
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_material(
    IN p_nombre_material VARCHAR(60)
    
)
BEGIN
    IF NOT EXISTS (SELECT * FROM tb_materiales WHERE nombre_material = p_nombre_material) THEN
        INSERT INTO tb_materiales(nombre_material)
        VALUES(p_nombre_material);
	ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El material ya existe';
    END IF;
END;
$$ DELIMITER ;

-- insertar tabla muebles
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_mueble(
    IN p_nombre_mueble VARCHAR(60),
    IN p_descripcion_mueble TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_precio_antiguo DECIMAL(10,2),
    IN p_estado ENUM('disponible','agotado'),
    IN p_stock INT,
    IN p_id_categoria INT,
    IN p_id_color INT,
    IN p_id_material INT,
    IN p_id_administrador INT,
    IN p_URL VARCHAR(60)
)
BEGIN
        DECLARE idmueble INT;
        INSERT INTO tb_muebles(nombre_mueble, descripcion_mueble, precio, precio_antiguo, estado, stock, id_categoria, id_color, id_material, id_administrador)
        VALUES(p_nombre_mueble, p_descripcion_mueble, p_precio, p_precio_antiguo, p_estado, p_stock, p_id_categoria, p_id_color, p_id_material, p_id_administrador);
        
        SET idmueble = LAST_INSERT_ID();
        INSERT INTO tb_fotos(url, id_mueble) VALUES (p_URL, idmueble);
    
END;
$$ DELIMITER ;

-- insertar tabla productos semanales
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_producto_semanal(
    IN p_id_mueble INT
)
BEGIN

        INSERT INTO tb_productos_semanales(id_mueble)
        VALUES(p_id_mueble);
    
END;
$$ DELIMITER ;

-- insertar tabla pedidos
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_pedido(
    IN p_estado_pedido ENUM ('pendiente','entregado'),
    IN p_fecha_entrega DATE,
    IN p_direccion_pedido VARCHAR(80),
    IN p_id_cliente INT
)
BEGIN

        INSERT INTO tb_pedidos(estado_pedido, fecha_entrega, direccion_pedido, id_cliente)
        VALUES(p_estado_pedido, p_fecha_entrega, p_direccion_pedido, p_id_cliente);
    
END;
$$ DELIMITER ;

-- insertar tabla detalles pedidos
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_detalle_pedido(
    IN p_cantidad_pedido INT,
    IN p_precio_pedido DECIMAL(10,2),
    IN p_id_pedido INT,
    IN p_id_mueble INT
)
BEGIN

		DECLARE cantidad INT;
        DECLARE precio_unitario  FLOAT;
        DECLARE precio_pedido FLOAT;
        
		SET cantidad = p_cantidad_pedido;
        SET precio_unitario = (SELECT precio FROM tb_muebles WHERE id_mueble = p_id_mueble);
		SET precio_pedido = cantidad * precio_unitario;
        
        INSERT INTO tb_detalles_pedidos(cantidad_pedido, precio_pedido, id_pedido, id_mueble)
        VALUES(p_cantidad_pedido, precio_pedido, p_id_pedido, p_id_mueble);
    
END;
$$ DELIMITER ;

select * from tb_muebles;
select * from tb_detalles_pedidos

-- insertar tabla valoraciones
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_valoracion(
    IN p_id_detalle_pedido INT,
    IN p_valoracion DECIMAL(5,1),
    IN p_mensaje TEXT
)
BEGIN
IF p_valoracion >= 0 AND p_valoracion <= 5 THEN
    IF NOT EXISTS (SELECT * FROM tb_valoraciones WHERE id_detalle_pedido = p_id_detalle_pedido) THEN
        INSERT INTO tb_valoraciones(id_detalle_pedido, valoracion, mensaje)
        VALUES(p_id_detalle_pedido, p_valoracion, p_mensaje);
    END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La valoracion ya existe';
    END IF;
END;
$$ DELIMITER ;

-- insertar tabla etiquetas
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_insertar_etiqueta(
    IN p_nombre_etiqueta VARCHAR(40),
    IN p_id_mueble INT
)
BEGIN
    IF NOT EXISTS (SELECT * FROM tb_etiquetas WHERE nombre_etiqueta = p_nombre_etiqueta) THEN
        INSERT INTO tb_etiquetas(nombre_etiqueta, id_mueble)
        VALUES(p_nombre_etiqueta, p_id_mueble);
        ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La etiqueta ya existe';
    END IF;
END;
$$ DELIMITER ;


-- llamadas procedimiento insertar
CALL sp_insertar_cliente('1234', 'Juan', 'Perez', '12345678-9', 77777777, 'San Salvador', 'OSCARADADAS@gmail.com');
CALL sp_insertar_cliente('5678', 'Maria', 'Lopez', '87654321-6', 88888888, 'San Miguel', 'mariadddddd@gmail.com');
CALL sp_insertar_cliente('9012', 'Pedro', 'Gomez', '98765432-3', 99999999, 'Santa Tecla', 'pedrooooooo@gmail.com');
CALL sp_insertar_cliente('7890', 'Luis', 'Hernandez', '34567890-6', 55555555, 'Santa Ana', 'luishhhhhhh@gmail.com');
CALL sp_insertar_cliente('2345', 'Laura', 'Torres', '45678901-8', 44444444, 'Sonsonate', 'lauraaaaaaa@gmail.com');
CALL sp_insertar_cliente('6789', 'Carlos', 'Garcia', '56789012-3', 33333333, 'San Vicente', 'carlossssss@gmail.com');
CALL sp_insertar_cliente('0123', 'Sofia', 'Ramirez', '67890123-7', 22222222, 'Usulutan', 'sofiaaaaaaa@gmail.com');
CALL sp_insertar_cliente('4567', 'Diego', 'Sanchez', '78901234-5', 11111111, 'Ahuachapan', 'diegoooooooo@gmail.com');
CALL sp_insertar_cliente('8901', 'Valeria', 'Luna', '89012345-6', 99999999, 'La Union', 'valeriaaaaa@gmail.com');
CALL sp_insertar_cliente('2345', 'Roberto', 'Mendoza', '90123456-6', 88888888, 'Morazan', 'robertoooooo@gmail.com');
CALL sp_insertar_cliente('6789', 'Fernanda', 'Castro', '12345678-9', 77777777, 'Chalatenango', 'fernandaaaa@gmail.com');
CALL sp_insertar_cliente('0123', 'Gabriel', 'Ortiz', '23456789-6', 66666666, 'Cuscatlan', 'gabrielllll@gmail.com');
CALL sp_insertar_cliente('4567', 'Daniela', 'Gutierrez', '34567890-5', 55555555, 'La Paz', 'danielaaaaa@gmail.com');
CALL sp_insertar_cliente('8901', 'Javier', 'Rivas', '45678901-6', 44444444, 'San Marcos', 'javierrrrrr@gmail.com');
CALL sp_insertar_cliente('2345', 'Isabella', 'Navarro', '56789012-6', 33333333, 'San Juan Opico', 'isabellaaaa@gmail.com');
CALL sp_insertar_cliente('6789', 'Andres', 'Santos', '67890123-9', 22222222, 'Zacatecoluca', 'andressssss@gmail.com');
CALL sp_insertar_cliente('0123', 'Camila', 'Vargas', '78901234-3', 11111111, 'San Rafael Cedros', 'camilaaaaaa@gmail.com');
CALL sp_insertar_cliente('4567', 'Mateo', 'Castillo', '89012345-2', 99999999, 'San Martin', 'mateoooooooo@gmail.com');
CALL sp_insertar_cliente('8901', 'Valentina', 'Herrera', '90123456-5', 88888888, 'San Sebastian', 'valentinaaaa@gmail.com');
CALL sp_insertar_cliente('2345', 'Alejandro', 'Lopez', '12345678-2', 77777777, 'Suchitoto', 'alejandrrrr@gmail.com');
CALL sp_insertar_cliente('6789', 'Sara', 'Gomez', '23456789-4', 66666666, 'Juayua', 'saritaaaaaa@gmail.com');
CALL sp_insertar_cliente('0123', 'Nicolas', 'Perez', '34567890-4', 55555555, 'Ataco', 'nicolasssss@gmail.com');
CALL sp_insertar_cliente('4567', 'Lucia', 'Hernandez', '45678901-4', 44444444, 'Concepcion de Ataco', 'luciaaaaaa@gmail.com');
CALL sp_insertar_cliente('8901', 'Maximiliano', 'Torres', '56789012-1', 33333333, 'Nahuizalco', 'maximilianoooo@gmail.com');


-- llamadas insertar admins
CALL sp_insertar_administrador('admin1', 'password1', 'John', 'Doe', 'john.doe@example.com', 99999999);
CALL sp_insertar_administrador('admin2', 'password2', 'Jane', 'Smith', 'jane.smith@example.com', 88888888);
CALL sp_insertar_administrador('admin3', 'password3', 'Michael', 'Johnson', 'michael.johnson@example.com', 77777777);
CALL sp_insertar_administrador('admin4', 'password4', 'Emily', 'Brown', 'emily.brown@example.com', 66666666);
CALL sp_insertar_administrador('admin5', 'password5', 'Daniel', 'Wilson', 'daniel.wilson@example.com', 55555555);
CALL sp_insertar_administrador('admin6', 'password6', 'Olivia', 'Taylor', 'olivia.taylor@example.com', 44444444);
CALL sp_insertar_administrador('admin7', 'password7', 'Matthew', 'Anderson', 'matthew.anderson@example.com', 33333333);
CALL sp_insertar_administrador('admin8', 'password8', 'Sophia', 'Thomas', 'sophia.thomas@example.com', 22222222);
CALL sp_insertar_administrador('admin9', 'password9', 'David', 'Martinez', 'david.martinez@example.com', 11111111);
CALL sp_insertar_administrador('admin10', 'password10', 'Emma', 'Harris', 'emma.harris@example.com', 99999998);
CALL sp_insertar_administrador('admin11', 'password11', 'James', 'Clark', 'james.clark@example.com', 88888887);
CALL sp_insertar_administrador('admin12', 'password12', 'Ava', 'Lewis', 'ava.lewis@example.com', 77777776);
CALL sp_insertar_administrador('admin13', 'password13', 'Joseph', 'Lee', 'joseph.lee@example.com', 66666665);
CALL sp_insertar_administrador('admin14', 'password14', 'Mia', 'Walker', 'mia.walker@example.com', 55555554);
CALL sp_insertar_administrador('admin15', 'password15', 'Benjamin', 'Hall', 'benjamin.hall@example.com', 44444443);
CALL sp_insertar_administrador('admin16', 'password16', 'Charlotte', 'Young', 'charlotte.young@example.com', 33333332);
CALL sp_insertar_administrador('admin17', 'password17', 'Daniel', 'King', 'daniel.king@example.com', 22222221);
CALL sp_insertar_administrador('admin18', 'password18', 'Emily', 'Wright', 'emily.wright@example.com', 11111110);
CALL sp_insertar_administrador('admin19', 'password19', 'Ethan', 'Lopez', 'ethan.lopez@example.com', 99999997);
CALL sp_insertar_administrador('admin20', 'password20', 'Grace', 'Scott', 'grace.scott@example.com', 88888886);
CALL sp_insertar_administrador('admin21', 'password21', 'Henry', 'Green', 'henry.green@example.com', 77777775);
CALL sp_insertar_administrador('admin22', 'password22', 'Isabella', 'Adams', 'isabella.adams@example.com', 66666664);
CALL sp_insertar_administrador('admin23', 'password23', 'Jacob', 'Baker', 'jacob.baker@example.com', 55555553);
CALL sp_insertar_administrador('admin24', 'password24', 'Liam', 'Carter', 'liam.carter@example.com', 44444442);
CALL sp_insertar_administrador('admin25', 'password25', 'Madison', 'Cook', 'madison.cook@example.com', 33333331);


-- CALLS PARA INSERTAR COLORES 

CALL sp_insertar_color('Rojo');
CALL sp_insertar_color('Azul');
CALL sp_insertar_color('Verde');


-- CALLS PARA INSERTAR CATEGORIAS 

CALL sp_insertar_categoria('Sala');
CALL sp_insertar_categoria('Comedor');
CALL sp_insertar_categoria('Dormitorio');
CALL sp_insertar_categoria('Oficina');

-- CALLS PARA INSERTAR MATERIALES

CALL sp_insertar_material('Madera');
CALL sp_insertar_material('Vidrio');
CALL sp_insertar_material('Metal');


-- CALL PARA INSERTAR MUEBLES
CALL sp_insertar_mueble('Silla', 'Silla de madera', 50.00, 60.00, 'disponible', 10, 1, 1, 1, 1, 'https://www.google.com');
CALL sp_insertar_mueble('Mesa', 'Mesa de dasda', 100.00, 120.00, 'disponible', 15, 2, 2, 2, 3, 'https://www.google.com');
CALL sp_insertar_mueble('Sofá', 'Sofá de cuero', 200.00, 250.00, 'disponible', 13, 3, 3, 3, 3, 'https://www.google.com');
CALL sp_insertar_mueble('Escritorio', 'Escritorio de madera', 80.00, 100.00, 'disponible', 18, 3, 3, 3, 4, 'https://www.google.com');
CALL sp_insertar_mueble('Cama', 'Cama matrimonial', 150.00, 180.00, 'disponible', 12, 3, 3, 3, 5, 'https://www.google.com');
CALL sp_insertar_mueble('Armario', 'Armario de metal', 120.00, 150.00, 'disponible', 14, 3, 3, 3, 6, 'https://www.google.com');
CALL sp_insertar_mueble('Estantería', 'Estantería de madera', 60.00, 80.00, 'disponible', 16, 3, 3, 3, 7, 'https://www.google.com');
CALL sp_insertar_mueble('Mesa de centro', 'Mesa de centro de vidrio', 90.00, 110.00, 'disponible', 27, 3, 3, 3, 8, 'https://www.google.com');
CALL sp_insertar_mueble('Silla de escritorio', 'Silla de escritorio ergonómica', 70.00, 90.00, 'disponible', 9, 3, 3, 3, 9, 'https://www.google.com');
CALL sp_insertar_mueble('Sillón', 'Sillón reclinable', 180.00, 200.00, 'disponible', 21, 3, 3, 3, 10, 'https://www.google.com');
CALL sp_insertar_mueble('Mesita de noche', 'Mesita de noche de madera', 40.00, 50.00, 'disponible', 5, 3, 3, 3, 11, 'https://www.google.com');
CALL sp_insertar_mueble('Escritorio de esquina', 'Escritorio de esquina de vidrio', 120.00, 140.00, 'disponible', 8, 3, 3, 3, 12, 'https://www.google.com');
CALL sp_insertar_mueble('Sofá cama', 'Sofá cama de tela', 250.00, 280.00, 'disponible', 23, 3, 3, 3, 13, 'https://www.google.com');
CALL sp_insertar_mueble('Mesa de comedor', 'Mesa de comedor de madera', 150.00, 180.00, 'disponible', 34, 3, 3, 3, 14, 'https://www.google.com');
CALL sp_insertar_mueble('Cómoda', 'Cómoda de madera', 100.00, 120.00, 'disponible', 6, 3, 3, 3, 15, 'https://www.google.com');
CALL sp_insertar_mueble('Banco', 'Banco de metal', 30.00, 40.00, 'disponible', 23, 3, 3, 3, 16, 'https://www.google.com');
CALL sp_insertar_mueble('Mesa auxiliar', 'Mesa auxiliar de vidrio', 60.00, 80.00, 'disponible', 37, 3, 3, 3, 17, 'https://www.google.com');
CALL sp_insertar_mueble('Silla de comedor', 'Silla de comedor de madera', 50.00, 70.00, 'disponible', 29, 3, 3, 3, 18, 'https://www.google.com');
CALL sp_insertar_mueble('Silla de oficina', 'Silla de oficina ergonómica', 80.00, 100.00, 'disponible', 22, 3, 3, 3, 19, 'https://www.google.com');
CALL sp_insertar_mueble('Sillón reclinable', 'Sillón reclinable de cuero', 200.00, 230.00, 'disponible', 31, 3, 3, 3, 20, 'https://www.google.com');
CALL sp_insertar_mueble('Mesa de estudio', 'Mesa de estudio de madera', 70.00, 90.00, 'disponible', 28, 3, 3, 3, 21, 'https://www.google.com');
CALL sp_insertar_mueble('Sofá de dos plazas', 'Sofá de dos plazas de tela', 180.00, 200.00, 'disponible', 33, 3, 3, 3, 22, 'https://www.google.com');
CALL sp_insertar_mueble('Mesa de café', 'Mesa de café de vidrio', 90.00, 110.00, 'disponible', 27, 3, 3, 3, 23, 'https://www.google.com');
CALL sp_insertar_mueble('Silla de estudio', 'Silla de estudio ergonómica', 60.00, 80.00, 'disponible', 29, 3, 3, 3, 24, 'https://www.google.com');
CALL sp_insertar_mueble('Cama individual', 'Cama individual de madera', 120.00, 140.00, 'disponible', 32, 3, 3, 3, 25, 'https://www.google.com');



-- CALLS PARA INSERTAR PRODUCTOS SEMANALES
CALL sp_insertar_producto_semanal(1);
CALL sp_insertar_producto_semanal(2);
CALL sp_insertar_producto_semanal(3);
CALL sp_insertar_producto_semanal(4);
CALL sp_insertar_producto_semanal(5);
CALL sp_insertar_producto_semanal(6);
CALL sp_insertar_producto_semanal(7);
CALL sp_insertar_producto_semanal(8);
CALL sp_insertar_producto_semanal(9);
CALL sp_insertar_producto_semanal(10);
CALL sp_insertar_producto_semanal(11);
CALL sp_insertar_producto_semanal(12);
CALL sp_insertar_producto_semanal(13);
CALL sp_insertar_producto_semanal(14);
CALL sp_insertar_producto_semanal(15);
CALL sp_insertar_producto_semanal(16);
CALL sp_insertar_producto_semanal(17);
CALL sp_insertar_producto_semanal(18);
CALL sp_insertar_producto_semanal(19);
CALL sp_insertar_producto_semanal(20);
CALL sp_insertar_producto_semanal(21);
CALL sp_insertar_producto_semanal(22);
CALL sp_insertar_producto_semanal(23);
CALL sp_insertar_producto_semanal(24);
CALL sp_insertar_producto_semanal(25);


-- CALLS PARA INSERTAR PEDIDOS
CALL sp_insertar_pedido('pendiente', '2021-05-10', 'San Salvador', 1);
CALL sp_insertar_pedido('pendiente', '2021-05-11', 'San Francisco', 2);
CALL sp_insertar_pedido('pendiente', '2021-05-12', 'New York', 3);
CALL sp_insertar_pedido('pendiente', '2021-05-13', 'Los Angeles', 4);
CALL sp_insertar_pedido('pendiente', '2021-05-14', 'Chicago', 5);
CALL sp_insertar_pedido('pendiente', '2021-05-15', 'Houston', 6);
CALL sp_insertar_pedido('pendiente', '2021-05-16', 'Phoenix', 7);
CALL sp_insertar_pedido('pendiente', '2021-05-17', 'Philadelphia', 8);
CALL sp_insertar_pedido('pendiente', '2021-05-18', 'San Antonio', 9);
CALL sp_insertar_pedido('pendiente', '2021-05-19', 'San Diego', 10);
CALL sp_insertar_pedido('pendiente', '2021-05-20', 'Dallas', 11);
CALL sp_insertar_pedido('pendiente', '2021-05-21', 'San Jose', 12);
CALL sp_insertar_pedido('pendiente', '2021-05-22', 'Austin', 13);
CALL sp_insertar_pedido('pendiente', '2021-05-23', 'Jacksonville', 14);
CALL sp_insertar_pedido('pendiente', '2021-05-24', 'Fort Worth', 15);
CALL sp_insertar_pedido('pendiente', '2021-05-25', 'Columbus', 16);
CALL sp_insertar_pedido('pendiente', '2021-05-26', 'Charlotte', 17);
CALL sp_insertar_pedido('pendiente', '2021-05-27', 'San Francisco', 18);
CALL sp_insertar_pedido('pendiente', '2021-05-28', 'Indianapolis', 19);
CALL sp_insertar_pedido('pendiente', '2021-05-29', 'Seattle', 20);
CALL sp_insertar_pedido('pendiente', '2021-05-30', 'Denver', 21);
CALL sp_insertar_pedido('pendiente', '2021-05-31', 'Washington', 22);
CALL sp_insertar_pedido('pendiente', '2021-06-01', 'Boston', 23);
CALL sp_insertar_pedido('pendiente', '2021-06-02', 'Nashville', 24);
CALL sp_insertar_pedido('pendiente', '2021-06-03', 'Memphis', 24);

-- calls para insertar detalles pedidos
CALL sp_insertar_detalle_pedido(1, 50.00, 1, 1);
CALL sp_insertar_detalle_pedido(2, 100.00, 2, 2);
CALL sp_insertar_detalle_pedido(3, 200.00, 3, 3);   
CALL sp_insertar_detalle_pedido(4, 80.00, 4, 4);
CALL sp_insertar_detalle_pedido(5, 150.00, 5, 5);
CALL sp_insertar_detalle_pedido(6, 120.00, 6, 6);
CALL sp_insertar_detalle_pedido(7, 60.00, 7, 7);
CALL sp_insertar_detalle_pedido(8, 90.00, 8, 8);
CALL sp_insertar_detalle_pedido(9, 70.00, 9, 9);
CALL sp_insertar_detalle_pedido(10, 180.00, 10, 10);
CALL sp_insertar_detalle_pedido(11, 40.00, 11, 11);
CALL sp_insertar_detalle_pedido(12, 120.00, 12, 12);
CALL sp_insertar_detalle_pedido(13, 250.00, 13, 13);
CALL sp_insertar_detalle_pedido(14, 150.00, 14, 14);
CALL sp_insertar_detalle_pedido(15, 100.00, 15, 15);
CALL sp_insertar_detalle_pedido(16, 30.00, 16, 16);
CALL sp_insertar_detalle_pedido(17, 60.00, 17, 17);
CALL sp_insertar_detalle_pedido(18, 50.00, 18, 18);
CALL sp_insertar_detalle_pedido(19, 80.00, 19, 19);
CALL sp_insertar_detalle_pedido(20, 200.00, 20, 20);
CALL sp_insertar_detalle_pedido(21, 70.00, 21, 21);
CALL sp_insertar_detalle_pedido(22, 180.00, 22, 22);
CALL sp_insertar_detalle_pedido(23, 90.00, 23, 23);
CALL sp_insertar_detalle_pedido(24, 60.00, 24, 24);
CALL sp_insertar_detalle_pedido(25, 120.00, 24, 24);

-- CALLS PARA INSERTAR VALORACIONES
CALL sp_insertar_valoracion(1, 5.0, 'Excelente');
CALL sp_insertar_valoracion(2, 4.5, 'Muy bueno');
CALL sp_insertar_valoracion(3, 4.0, 'Bueno');
CALL sp_insertar_valoracion(4, 3.5, 'Regular');
CALL sp_insertar_valoracion(5, 3.0, 'Malo');
CALL sp_insertar_valoracion(6, 2.5, 'Muy malo');
CALL sp_insertar_valoracion(7, 2.0, 'Pésimo');
CALL sp_insertar_valoracion(8, 1.5, 'Muy pésimo');
CALL sp_insertar_valoracion(9, 1.0, 'Horrible');
CALL sp_insertar_valoracion(10, 0.5, 'Muy horrible');
CALL sp_insertar_valoracion(11, 0.0, 'Pésimo');
CALL sp_insertar_valoracion(12, 5.0, 'Excelente');
CALL sp_insertar_valoracion(13, 4.5, 'Muy bueno');
CALL sp_insertar_valoracion(14, 4.0, 'Bueno');
CALL sp_insertar_valoracion(15, 3.5, 'Regular');
CALL sp_insertar_valoracion(16, 3.0, 'Malo');
CALL sp_insertar_valoracion(17, 2.5, 'Muy malo');
CALL sp_insertar_valoracion(18, 2.0, 'Pésimo');
CALL sp_insertar_valoracion(19, 1.5, 'Muy pésimo');
CALL sp_insertar_valoracion(20, 1.0, 'Horrible');
CALL sp_insertar_valoracion(21, 0.5, 'Muy horrible');
CALL sp_insertar_valoracion(22, 0.0, 'Pésimo');
CALL sp_insertar_valoracion(23, 5.0, 'Excelente');
CALL sp_insertar_valoracion(24, 4.5, 'Muy bueno');
CALL sp_insertar_valoracion(25, 4.0, 'Bueno');

-- calls para insertar etiquetas

CALL sp_insertar_etiqueta('Madera', 1);
CALL sp_insertar_etiqueta('Vidrio', 2);
CALL sp_insertar_etiqueta('Metal', 3);
CALL sp_insertar_etiqueta('Sala', 4);
CALL sp_insertar_etiqueta('Comedor', 5);
CALL sp_insertar_etiqueta('Dormitorio', 6);



select * from tb_clientes;
select * from tb_administradores;
select * from tb_colores;
select * from tb_categorias;    
select * from tb_materiales;
select * from tb_muebles;
select * from tb_productos_semanales;
select * from tb_pedidos;
select * from tb_detalles_pedidos;
select * from tb_valoraciones;
select * from tb_etiquetas;

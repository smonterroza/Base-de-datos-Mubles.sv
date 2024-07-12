DROP DATABASE IF EXISTS Mueblessv;
CREATE DATABASE Mueblessv;
USE Mueblessv;


CREATE TABLE tb_clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
	alias_cliente varchar(30) NOT NULL UNIQUE,
    clave_cliente VARCHAR(60) NOT NULL,
    nombre_cliente VARCHAR(60) NOT NULL,
    apellido_cliente VARCHAR(60) NOT NULL,
    dui_cliente VARCHAR(10) NOT NULL UNIQUE,
    telefono_cliente VARCHAR(9) NOT NULL UNIQUE,
    direccion_cliente VARCHAR(80) NOT NULL,
	estado_cliente enum('Activo','Desactivo') NOT NULL DEFAULT 'Activo',
    correo_cliente VARCHAR(60) NOT NULL,
    fecha_creacion DATE DEFAULT NOW(),
    CONSTRAINT CHK_tbclientes_correo CHECK (correo_cliente REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
    CONSTRAINT CHK_tbclientes_dui CHECK (dui_cliente REGEXP '^[0-9]{8}-[0-9]{1}$'),
    CONSTRAINT CHK_tbclientes_telefono CHECK (telefono_cliente REGEXP '^[0-9]{4}-[0-9]{4}$')
);


CREATE TABLE tb_administradores (
	id_administrador INT AUTO_INCREMENT PRIMARY KEY,
    alias_administrador VARCHAR (50) NOT NULL,
    clave_administrador VARCHAR(120) NOT NULL,
    nombre_administrador VARCHAR(60) NOT NULL,
    apellido_administrador VARCHAR(60) NOT NULL,
    coreo_administrador VARCHAR (60) NOT NULL UNIQUE,
    telefono_administrador VARCHAR (9) NOT NULL UNIQUE,
	CONSTRAINT CHK_tbadministradores_telefono CHECK (telefono_administrador REGEXP '^[0-9]{4}-[0-9]{4}$'),
	CONSTRAINT FK_tbadministradore_correo CHECK (coreo_administrador REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$')
);


CREATE TABLE tb_colores (
	 id_color INT AUTO_INCREMENT PRIMARY KEY,
	 nombre_color VARCHAR (40) NOT NULL UNIQUE
);


CREATE TABLE tb_materiales (
	id_material INT AUTO_INCREMENT PRIMARY KEY,
	nombre_material VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE tb_categorias(
	id_categoria INT AUTO_INCREMENT PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE tb_muebles (
    id_mueble INT AUTO_INCREMENT PRIMARY KEY,
    nombre_mueble VARCHAR (60) NOT NULL,
    descripcion_mueble TEXT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    precio_antiguo DECIMAL(10,2) NOT NULL,
    estado ENUM('disponible','agotado') NOT NULL,
    stock INT NOT NULL,
    id_categoria INT ,
    id_color INT ,
    id_material INT , 
    id_administrador INT,
    CONSTRAINT FK_tbmuebles_stock CHECK (stock >= 0),
    CONSTRAINT FK_tbmuebles_precio CHECK (precio >= 0),
    CONSTRAINT Fk_tbcategorias_tbmuebles FOREIGN KEY (id_categoria) REFERENCES tb_categorias (id_categoria),
    CONSTRAINT Fk_tbcolores_tbmuebles FOREIGN KEY (id_color) REFERENCES tb_colores (id_color),
    CONSTRAINT Fk_tbmateriales_tbmuebles FOREIGN KEY (id_material) REFERENCES tb_materiales (id_material),
    CONSTRAINT Fk_tbadministradores_tbmuebles FOREIGN KEY (id_administrador) REFERENCES tb_administradores(id_administrador)
);


CREATE TABLE tb_productos_semanales (
	id_producto_semanaL INT AUTO_INCREMENT PRIMARY KEY ,
    id_mueble INT,
    CONSTRAINT FK_tbmuebles_tbproductossemanal
    FOREIGN KEY (id_mueble)
    REFERENCES tb_muebles(id_mueble)
);


CREATE TABLE tb_pedidos(
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    estado_pedido ENUM ('Pendiente','Finalizado'),
    fecha_pedido DATE DEFAULT NOW(),
    fecha_entrega DATE,
    direccion_pedido VARCHAR(80),
    id_cliente INT, 
    CONSTRAINT FK_tbclientes_tbpedidos
    FOREIGN KEY (id_cliente)
    REFERENCES tb_clientes(id_cliente),
    CONSTRAINT FK_tbpedidos_fechapedido CHECK (fecha_entrega > fecha_pedido)
); 

CREATE TABLE tb_detalles_pedidos (
	
    id_detalle_pedido INT AUTO_INCREMENT PRIMARY KEY,
    cantidad_pedido INT,
    precio_pedido DECIMAL(10,2),
    id_pedido INT, 
    id_mueble INT,
     CONSTRAINT Fk_tbdetalles_tbpedidos FOREIGN KEY (id_pedido) REFERENCES tb_pedidos(id_pedido),
     CONSTRAINT Fk_tbdetalles_tbmuebles FOREIGN KEY (id_mueble) REFERENCES tb_muebles(id_mueble),
	CONSTRAINT Fk_preciopedido_tbdetalle CHECK (precio_pedido >= 0)
    
);


CREATE TABLE tb_fotos (
	id_foto INT AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(60),
    id_mueble INT, 
    CONSTRAINT FK_tbmuebles_tfotos
    FOREIGN KEY (id_mueble)
    REFERENCES tb_muebles(id_mueble)
);

CREATE TABLE tb_valoraciones (
	id_valoracion INT AUTO_INCREMENT PRIMARY KEY,
    id_detalle_pedido INT,
	valoracion DECIMAL(5,1),
    mensaje TEXT, 
    CONSTRAINT Fk_valoracion_mensaje CHECK (valoracion >= 0 and valoracion <= 5),
    CONSTRAINT Fk_tbvaloraciones_tbdetalles FOREIGN KEY (id_detalle_pedido) REFERENCES tb_detalles_pedidos (id_detalle_pedido)
);

CREATE TABLE tb_etiquetas (
    id_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_etiqueta VARCHAR(40),
    id_mueble INT, 
    CONSTRAINT FK_tbmmuebles_tbetiquetas
    FOREIGN KEY (id_mueble)
    REFERENCES tb_muebles(id_mueble)
);

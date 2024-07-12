

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `mueblessv`
--
CREATE DATABASE IF NOT EXISTS `mueblessv` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `mueblessv`;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `actualizar_pedido`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_pedido` (IN `cantidad` INT, IN `id_mueble_pedido` INT, IN `id_detalle_pedido` INT)   BEGIN
    DECLARE precio_mueble DECIMAL(10,2);
    
    -- Obtener el precio del mueble
    SELECT precio INTO precio_mueble FROM tb_muebles WHERE id_mueble = id_mueble_pedido;

    -- Actualizar la cantidad y el precio del pedido en tb_detalles_pedidos
    UPDATE tb_detalles_pedidos
    SET cantidad_pedido = cantidad,
        precio_pedido = cantidad * precio_mueble
    WHERE id_detalle_pedido = id_detalle_pedido AND id_mueble = id_mueble_pedido;
END$$

DROP PROCEDURE IF EXISTS `agregar_detalle_pedido`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_detalle_pedido` (IN `p_id_cliente` INT, IN `p_id_mueble` INT, IN `p_cantidad_pedido` INT)   BEGIN
    DECLARE v_id_pedido INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_cantidad_pedido_actual INT;

    -- Verificar si existe un pedido en proceso para el cliente
    SELECT id_pedido 
    INTO v_id_pedido 
    FROM tb_pedidos 
    WHERE id_cliente = p_id_cliente AND estado_pedido = 'en proceso'
    LIMIT 1;

    -- Si no existe un pedido en proceso, crear uno
    IF v_id_pedido IS NULL THEN
        INSERT INTO tb_pedidos (id_cliente, estado_pedido)
        VALUES (p_id_cliente, 'en proceso');
        
        -- Obtener el id del nuevo pedido creado
        SET v_id_pedido = LAST_INSERT_ID();
    END IF;

    -- Obtener el precio del mueble
    SELECT precio 
    INTO v_precio 
    FROM tb_muebles 
    WHERE id_mueble = p_id_mueble;

    -- Verificar si ya existe un detalle de pedido para el mueble
    IF NOT EXISTS (SELECT 1 FROM tb_detalles_pedidos WHERE id_mueble = p_id_mueble AND id_pedido = v_id_pedido) THEN
        -- Insertar el nuevo detalle de pedido
        INSERT INTO tb_detalles_pedidos (cantidad_pedido, precio_pedido, id_pedido, id_mueble)
        VALUES (p_cantidad_pedido, v_precio * p_cantidad_pedido, v_id_pedido, p_id_mueble);
    ELSE
        -- Obtener la cantidad actual del pedido
        SELECT cantidad_pedido 
        INTO v_cantidad_pedido_actual 
        FROM tb_detalles_pedidos 
        WHERE id_mueble = p_id_mueble AND id_pedido = v_id_pedido;
        
        -- Actualizar el detalle del pedido con la nueva cantidad
        UPDATE tb_detalles_pedidos 
        SET cantidad_pedido = cantidad_pedido + p_cantidad_pedido, 
            precio_pedido = precio_pedido + (v_precio * p_cantidad_pedido) 
        WHERE id_mueble = p_id_mueble AND id_pedido = v_id_pedido;
    END IF;

    -- Actualizar el stock del mueble
    UPDATE tb_muebles
    SET stock = stock - p_cantidad_pedido
    WHERE id_mueble = p_id_mueble;

    -- Verificar si el stock ha llegado a cero
    IF (SELECT stock FROM tb_muebles WHERE id_mueble = p_id_mueble) = 0 THEN
        UPDATE tb_muebles
        SET estado = 'agotado'
        WHERE id_mueble = p_id_mueble;
    END IF;

END$$

DROP PROCEDURE IF EXISTS `checkDisponibilidad`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkDisponibilidad` (IN `p_id_detalle` INT, IN `p_cantidad` INT)   BEGIN
    DECLARE v_cantidad_detalle INT;

    -- Obtener la cantidad actual del detalle del pedido para el mueble específico
   SELECT cantidad_pedido 
	INTO v_cantidad_detalle 
    FROM tb_detalles_pedidos 
    WHERE id_detalle_pedido = p_id_detalle
    LIMIT 1;

    -- Comparar la cantidad pasada como parámetro con la cantidad del detalle del pedido
    IF p_cantidad > v_cantidad_detalle THEN
		 SELECT 0 as disponibilidad;
    ELSE
        SELECT 1 as disponibilidad;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `eliminar_detalle_pedido`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_detalle_pedido` (IN `p_id_detalle_pedido` INT)   BEGIN
    DECLARE v_id_mueble INT;
    DECLARE v_cantidad_pedido INT;

    -- Obtener el id_mueble y la cantidad del detalle del pedido a eliminar
    SELECT id_mueble, cantidad_pedido 
    INTO v_id_mueble, v_cantidad_pedido
    FROM tb_detalles_pedidos 
    WHERE id_detalle_pedido = p_id_detalle_pedido;

    -- Verificar si se encontró el detalle del pedido
    IF v_id_mueble IS NOT NULL THEN
        -- Eliminar el detalle del pedido
        DELETE FROM tb_detalles_pedidos 
        WHERE id_detalle_pedido = p_id_detalle_pedido;

        -- Actualizar el stock del mueble
        UPDATE tb_muebles
        SET stock = stock + v_cantidad_pedido
        WHERE id_mueble = v_id_mueble;

        -- Verificar si el stock ha dejado de ser cero
        IF (SELECT stock FROM tb_muebles WHERE id_mueble = v_id_mueble) > 0 THEN
            UPDATE tb_muebles
            SET estado = 'disponible'
            WHERE id_mueble = v_id_mueble AND estado = 'agotado';
        END IF;
    ELSE
        -- Manejo de error si no se encuentra el detalle del pedido
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el detalle del pedido para eliminar.';
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_insertar_administrador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insertar_administrador` (IN `p_alias_administrador` VARCHAR(50), IN `p_clave_administrador` VARCHAR(120), IN `p_nombre_administrador` VARCHAR(60), IN `p_apellido_administrador` VARCHAR(60), IN `p_correo_administrador` VARCHAR(60), IN `p_telefono_administrador` INT)   BEGIN

        INSERT INTO tb_administradores(alias_administrador, clave_administrador, nombre_administrador, apellido_administrador, coreo_administrador, telefono_administrador)
        VALUES(p_alias_administrador, p_clave_administrador, p_nombre_administrador, p_apellido_administrador, p_correo_administrador, p_telefono_administrador);
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_administradores`
--

DROP TABLE IF EXISTS `tb_administradores`;
CREATE TABLE `tb_administradores` (
  `id_administrador` int(11) NOT NULL,
  `alias_administrador` varchar(50) NOT NULL,
  `clave_administrador` varchar(120) NOT NULL,
  `nombre_administrador` varchar(60) NOT NULL,
  `apellido_administrador` varchar(60) NOT NULL,
  `coreo_administrador` varchar(60) NOT NULL,
  `telefono_administrador` varchar(9) NOT NULL
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_categorias`
--

DROP TABLE IF EXISTS `tb_categorias`;
CREATE TABLE `tb_categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_clientes`
--

DROP TABLE IF EXISTS `tb_clientes`;
CREATE TABLE `tb_clientes` (
  `id_cliente` int(11) NOT NULL,
  `alias_cliente` varchar(30) NOT NULL,
  `clave_cliente` varchar(60) NOT NULL,
  `nombre_cliente` varchar(60) NOT NULL,
  `apellido_cliente` varchar(60) NOT NULL,
  `dui_cliente` varchar(10) NOT NULL,
  `telefono_cliente` varchar(9) NOT NULL,
  `direccion_cliente` varchar(80) NOT NULL,
  `estado_cliente` enum('Activo','Desactivo') NOT NULL DEFAULT 'Activo',
  `correo_cliente` varchar(60) NOT NULL,
  `fecha_creacion` date DEFAULT current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_colores`
--

DROP TABLE IF EXISTS `tb_colores`;
CREATE TABLE `tb_colores` (
  `id_color` int(11) NOT NULL,
  `nombre_color` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_detalles_pedidos`
--

DROP TABLE IF EXISTS `tb_detalles_pedidos`;
CREATE TABLE `tb_detalles_pedidos` (
  `id_detalle_pedido` int(11) NOT NULL,
  `cantidad_pedido` int(11) DEFAULT NULL,
  `precio_pedido` decimal(10,2) DEFAULT NULL,
  `id_pedido` int(11) DEFAULT NULL,
  `id_mueble` int(11) DEFAULT NULL
) ;

--
-- Disparadores `tb_detalles_pedidos`
--
DROP TRIGGER IF EXISTS `trg_update_stock_after_update`;
DELIMITER $$
CREATE TRIGGER `trg_update_stock_after_update` AFTER UPDATE ON `tb_detalles_pedidos` FOR EACH ROW BEGIN
    DECLARE diff INT;

    -- Calcular la diferencia entre la nueva cantidad y la cantidad antigua
    SET diff = NEW.cantidad_pedido - OLD.cantidad_pedido;

    -- Actualizar el stock en la tabla tb_muebles
    UPDATE tb_muebles
    SET stock = stock - diff
    WHERE id_mueble = NEW.id_mueble;

    -- Verificar si el stock ha llegado a cero y actualizar el estado
    IF (SELECT stock FROM tb_muebles WHERE id_mueble = NEW.id_mueble) = 0 THEN
        UPDATE tb_muebles
        SET estado = 'agotado'
        WHERE id_mueble = NEW.id_mueble;
    ELSE
        UPDATE tb_muebles
        SET estado = 'disponible'
        WHERE id_mueble = NEW.id_mueble;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_etiquetas`
--

DROP TABLE IF EXISTS `tb_etiquetas`;
CREATE TABLE `tb_etiquetas` (
  `id_etiqueta` int(11) NOT NULL,
  `nombre_etiqueta` varchar(40) DEFAULT NULL,
  `id_mueble` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_fotos`
--

DROP TABLE IF EXISTS `tb_fotos`;
CREATE TABLE `tb_fotos` (
  `id_foto` int(11) NOT NULL,
  `url` varchar(60) DEFAULT NULL,
  `id_mueble` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_materiales`
--

DROP TABLE IF EXISTS `tb_materiales`;
CREATE TABLE `tb_materiales` (
  `id_material` int(11) NOT NULL,
  `nombre_material` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_muebles`
--

DROP TABLE IF EXISTS `tb_muebles`;
CREATE TABLE `tb_muebles` (
  `id_mueble` int(11) NOT NULL,
  `nombre_mueble` varchar(15) NOT NULL,
  `descripcion_mueble` text NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `precio_antiguo` decimal(10,2) NOT NULL,
  `estado` enum('disponible','agotado') NOT NULL,
  `stock` int(11) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `id_color` int(11) DEFAULT NULL,
  `id_material` int(11) DEFAULT NULL,
  `id_administrador` int(11) DEFAULT NULL,
  `imagen` varchar(50) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_pedidos`
--

DROP TABLE IF EXISTS `tb_pedidos`;
CREATE TABLE `tb_pedidos` (
  `id_pedido` int(11) NOT NULL,
  `estado_pedido` enum('pendiente','entregado','en proceso') DEFAULT NULL,
  `fecha_pedido` date DEFAULT current_timestamp(),
  `fecha_entrega` date DEFAULT NULL,
  `direccion_pedido` varchar(80) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_productos_semanales`
--

DROP TABLE IF EXISTS `tb_productos_semanales`;
CREATE TABLE `tb_productos_semanales` (
  `id_producto_semanaL` int(11) NOT NULL,
  `id_mueble` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tb_valoraciones`
--

DROP TABLE IF EXISTS `tb_valoraciones`;
CREATE TABLE `tb_valoraciones` (
  `id_valoracion` int(11) NOT NULL,
  `id_detalle_pedido` int(11) DEFAULT NULL,
  `valoracion` decimal(5,1) DEFAULT NULL,
  `mensaje` text DEFAULT NULL
) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `tb_administradores`
--
ALTER TABLE `tb_administradores`
  ADD PRIMARY KEY (`id_administrador`),
  ADD UNIQUE KEY `alias_administrador` (`alias_administrador`),
  ADD UNIQUE KEY `coreo_administrador` (`coreo_administrador`),
  ADD UNIQUE KEY `telefono_administrador` (`telefono_administrador`);

--
-- Indices de la tabla `tb_categorias`
--
ALTER TABLE `tb_categorias`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `nombre_categoria` (`nombre_categoria`);

--
-- Indices de la tabla `tb_clientes`
--
ALTER TABLE `tb_clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `dui_cliente` (`dui_cliente`),
  ADD UNIQUE KEY `telefono_cliente` (`telefono_cliente`),
  ADD UNIQUE KEY `correo_cliente` (`correo_cliente`);

--
-- Indices de la tabla `tb_colores`
--
ALTER TABLE `tb_colores`
  ADD PRIMARY KEY (`id_color`),
  ADD UNIQUE KEY `nombre_color` (`nombre_color`);

--
-- Indices de la tabla `tb_detalles_pedidos`
--
ALTER TABLE `tb_detalles_pedidos`
  ADD PRIMARY KEY (`id_detalle_pedido`),
  ADD KEY `Fk_tbdetalles_tbpedidos` (`id_pedido`),
  ADD KEY `Fk_tbdetalles_tbmuebles` (`id_mueble`);

--
-- Indices de la tabla `tb_etiquetas`
--
ALTER TABLE `tb_etiquetas`
  ADD PRIMARY KEY (`id_etiqueta`),
  ADD KEY `FK_tbmmuebles_tbetiquetas` (`id_mueble`);

--
-- Indices de la tabla `tb_fotos`
--
ALTER TABLE `tb_fotos`
  ADD PRIMARY KEY (`id_foto`),
  ADD KEY `FK_tbmuebles_tfotos` (`id_mueble`);

--
-- Indices de la tabla `tb_materiales`
--
ALTER TABLE `tb_materiales`
  ADD PRIMARY KEY (`id_material`),
  ADD UNIQUE KEY `nombre_material` (`nombre_material`);

--
-- Indices de la tabla `tb_muebles`
--
ALTER TABLE `tb_muebles`
  ADD PRIMARY KEY (`id_mueble`),
  ADD KEY `Fk_tbcategorias_tbmuebles` (`id_categoria`),
  ADD KEY `Fk_tbcolores_tbmuebles` (`id_color`),
  ADD KEY `Fk_tbmateriales_tbmuebles` (`id_material`),
  ADD KEY `Fk_tbadministradores_tbmuebles` (`id_administrador`);

--
-- Indices de la tabla `tb_pedidos`
--
ALTER TABLE `tb_pedidos`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `FK_tbclientes_tbpedidos` (`id_cliente`);

--
-- Indices de la tabla `tb_productos_semanales`
--
ALTER TABLE `tb_productos_semanales`
  ADD PRIMARY KEY (`id_producto_semanaL`),
  ADD KEY `FK_tbmuebles_tbproductossemanal` (`id_mueble`);

--
-- Indices de la tabla `tb_valoraciones`
--
ALTER TABLE `tb_valoraciones`
  ADD PRIMARY KEY (`id_valoracion`),
  ADD KEY `Fk_tbvaloraciones_tbdetalles` (`id_detalle_pedido`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `tb_administradores`
--
ALTER TABLE `tb_administradores`
  MODIFY `id_administrador` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_categorias`
--
ALTER TABLE `tb_categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_clientes`
--
ALTER TABLE `tb_clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_colores`
--
ALTER TABLE `tb_colores`
  MODIFY `id_color` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_detalles_pedidos`
--
ALTER TABLE `tb_detalles_pedidos`
  MODIFY `id_detalle_pedido` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_etiquetas`
--
ALTER TABLE `tb_etiquetas`
  MODIFY `id_etiqueta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_fotos`
--
ALTER TABLE `tb_fotos`
  MODIFY `id_foto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_materiales`
--
ALTER TABLE `tb_materiales`
  MODIFY `id_material` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_muebles`
--
ALTER TABLE `tb_muebles`
  MODIFY `id_mueble` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_pedidos`
--
ALTER TABLE `tb_pedidos`
  MODIFY `id_pedido` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_productos_semanales`
--
ALTER TABLE `tb_productos_semanales`
  MODIFY `id_producto_semanaL` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tb_valoraciones`
--
ALTER TABLE `tb_valoraciones`
  MODIFY `id_valoracion` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tb_detalles_pedidos`
--
ALTER TABLE `tb_detalles_pedidos`
  ADD CONSTRAINT `Fk_tbdetalles_tbmuebles` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`),
  ADD CONSTRAINT `Fk_tbdetalles_tbpedidos` FOREIGN KEY (`id_pedido`) REFERENCES `tb_pedidos` (`id_pedido`);

--
-- Filtros para la tabla `tb_etiquetas`
--
ALTER TABLE `tb_etiquetas`
  ADD CONSTRAINT `FK_tbmmuebles_tbetiquetas` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`);

--
-- Filtros para la tabla `tb_fotos`
--
ALTER TABLE `tb_fotos`
  ADD CONSTRAINT `FK_tbmuebles_tfotos` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`);

--
-- Filtros para la tabla `tb_muebles`
--
ALTER TABLE `tb_muebles`
  ADD CONSTRAINT `Fk_tbadministradores_tbmuebles` FOREIGN KEY (`id_administrador`) REFERENCES `tb_administradores` (`id_administrador`),
  ADD CONSTRAINT `Fk_tbcategorias_tbmuebles` FOREIGN KEY (`id_categoria`) REFERENCES `tb_categorias` (`id_categoria`),
  ADD CONSTRAINT `Fk_tbcolores_tbmuebles` FOREIGN KEY (`id_color`) REFERENCES `tb_colores` (`id_color`),
  ADD CONSTRAINT `Fk_tbmateriales_tbmuebles` FOREIGN KEY (`id_material`) REFERENCES `tb_materiales` (`id_material`);

--
-- Filtros para la tabla `tb_pedidos`
--
ALTER TABLE `tb_pedidos`
  ADD CONSTRAINT `FK_tbclientes_tbpedidos` FOREIGN KEY (`id_cliente`) REFERENCES `tb_clientes` (`id_cliente`);

--
-- Filtros para la tabla `tb_productos_semanales`
--
ALTER TABLE `tb_productos_semanales`
  ADD CONSTRAINT `FK_tbmuebles_tbproductossemanal` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`);

--
-- Filtros para la tabla `tb_valoraciones`
--
ALTER TABLE `tb_valoraciones`
  ADD CONSTRAINT `Fk_tbvaloraciones_tbdetalles` FOREIGN KEY (`id_detalle_pedido`) REFERENCES `tb_detalles_pedidos` (`id_detalle_pedido`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

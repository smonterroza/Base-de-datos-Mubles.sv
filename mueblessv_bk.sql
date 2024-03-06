-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: mueblessv
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tb_administradores`
--

DROP TABLE IF EXISTS `tb_administradores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_administradores` (
  `id_administrador` int(11) NOT NULL AUTO_INCREMENT,
  `alias_administrador` varchar(50) NOT NULL,
  `clave_administrador` varchar(120) NOT NULL,
  `nombre_administrador` varchar(60) NOT NULL,
  `apellido_administrador` varchar(60) NOT NULL,
  `coreo_administrador` varchar(60) NOT NULL,
  `telefono_administrador` int(11) NOT NULL,
  PRIMARY KEY (`id_administrador`),
  UNIQUE KEY `coreo_administrador` (`coreo_administrador`),
  UNIQUE KEY `telefono_administrador` (`telefono_administrador`),
  CONSTRAINT `CHK_tbadministradore_telefono` CHECK (`telefono_administrador` >= 1000000 and `telefono_administrador` <= 9999999999),
  CONSTRAINT `FK_tbadministradore_correo` CHECK (`coreo_administrador` regexp '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_administradores`
--

LOCK TABLES `tb_administradores` WRITE;
/*!40000 ALTER TABLE `tb_administradores` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_administradores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_categorias`
--

DROP TABLE IF EXISTS `tb_categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_categorias` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(50) NOT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre_categoria` (`nombre_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_categorias`
--

LOCK TABLES `tb_categorias` WRITE;
/*!40000 ALTER TABLE `tb_categorias` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_clientes`
--

DROP TABLE IF EXISTS `tb_clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_clientes` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `clave_cliente` varchar(60) NOT NULL,
  `nombre_cliente` varchar(60) NOT NULL,
  `apellido_cliente` varchar(60) NOT NULL,
  `dui_cliente` varchar(10) NOT NULL,
  `telefono_cliente` int(11) NOT NULL,
  `direccion_cliente` varchar(80) NOT NULL,
  `correo_cliente` varchar(60) NOT NULL,
  `fecha_creacion` date DEFAULT current_timestamp(),
  PRIMARY KEY (`id_cliente`),
  CONSTRAINT `CHK_tbclientes_correo` CHECK (`correo_cliente` regexp '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
  CONSTRAINT `CHK_tbclientes_dui` CHECK (`dui_cliente` regexp '^[0-9]{8}-[0-9]{1}$'),
  CONSTRAINT `CHK_tbclientes_telefono` CHECK (`telefono_cliente` >= 1000000 and `telefono_cliente` <= 9999999999)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_clientes`
--

LOCK TABLES `tb_clientes` WRITE;
/*!40000 ALTER TABLE `tb_clientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_colores`
--

DROP TABLE IF EXISTS `tb_colores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_colores` (
  `id_color` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_color` varchar(40) NOT NULL,
  PRIMARY KEY (`id_color`),
  UNIQUE KEY `nombre_color` (`nombre_color`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_colores`
--

LOCK TABLES `tb_colores` WRITE;
/*!40000 ALTER TABLE `tb_colores` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_colores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_detalles_pedidos`
--

DROP TABLE IF EXISTS `tb_detalles_pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_detalles_pedidos` (
  `id_detalle_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `cantidad_pedido` int(11) DEFAULT NULL,
  `precio_pedido` decimal(10,2) DEFAULT NULL,
  `id_pedido` int(11) DEFAULT NULL,
  `id_mueble` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_detalle_pedido`),
  KEY `Fk_tbdetalles_tbpedidos` (`id_pedido`),
  KEY `Fk_tbdetalles_tbmuebles` (`id_mueble`),
  CONSTRAINT `Fk_tbdetalles_tbmuebles` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`),
  CONSTRAINT `Fk_tbdetalles_tbpedidos` FOREIGN KEY (`id_pedido`) REFERENCES `tb_clientes` (`id_cliente`),
  CONSTRAINT `Fk_preciopedido_tbdetalle` CHECK (`precio_pedido` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_detalles_pedidos`
--

LOCK TABLES `tb_detalles_pedidos` WRITE;
/*!40000 ALTER TABLE `tb_detalles_pedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_detalles_pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_etiquetas`
--

DROP TABLE IF EXISTS `tb_etiquetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_etiquetas` (
  `id_etiqueta` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_etiqueta` varchar(40) DEFAULT NULL,
  `id_mueble` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_etiqueta`),
  KEY `FK_tbmmuebles_tbetiquetas` (`id_mueble`),
  CONSTRAINT `FK_tbmmuebles_tbetiquetas` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_etiquetas`
--

LOCK TABLES `tb_etiquetas` WRITE;
/*!40000 ALTER TABLE `tb_etiquetas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_etiquetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_fotos`
--

DROP TABLE IF EXISTS `tb_fotos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_fotos` (
  `id_foto` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(60) DEFAULT NULL,
  `id_mueble` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_foto`),
  KEY `FK_tbmuebles_tfotos` (`id_mueble`),
  CONSTRAINT `FK_tbmuebles_tfotos` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_fotos`
--

LOCK TABLES `tb_fotos` WRITE;
/*!40000 ALTER TABLE `tb_fotos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_fotos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_materiales`
--

DROP TABLE IF EXISTS `tb_materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_materiales` (
  `id_material` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_material` varchar(60) NOT NULL,
  PRIMARY KEY (`id_material`),
  UNIQUE KEY `nombre_material` (`nombre_material`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_materiales`
--

LOCK TABLES `tb_materiales` WRITE;
/*!40000 ALTER TABLE `tb_materiales` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_materiales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_muebles`
--

DROP TABLE IF EXISTS `tb_muebles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_muebles` (
  `id_mueble` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_mueble` varchar(60) NOT NULL,
  `descripcion_mueble` text NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `precio_antiguo` decimal(10,2) NOT NULL,
  `estado` enum('disponible','agotado') NOT NULL,
  `stock` int(11) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `id_color` int(11) DEFAULT NULL,
  `id_material` int(11) DEFAULT NULL,
  `id_administrador` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_mueble`),
  KEY `Fk_tbcategorias_tbmuebles` (`id_categoria`),
  KEY `Fk_tbcolores_tbmuebles` (`id_color`),
  KEY `Fk_tbmateriales_tbmuebles` (`id_material`),
  KEY `Fk_tbadministradores_tbmuebles` (`id_administrador`),
  CONSTRAINT `Fk_tbadministradores_tbmuebles` FOREIGN KEY (`id_administrador`) REFERENCES `tb_administradores` (`id_administrador`),
  CONSTRAINT `Fk_tbcategorias_tbmuebles` FOREIGN KEY (`id_categoria`) REFERENCES `tb_categorias` (`id_categoria`),
  CONSTRAINT `Fk_tbcolores_tbmuebles` FOREIGN KEY (`id_color`) REFERENCES `tb_colores` (`id_color`),
  CONSTRAINT `Fk_tbmateriales_tbmuebles` FOREIGN KEY (`id_material`) REFERENCES `tb_materiales` (`id_material`),
  CONSTRAINT `FK_tbmuebles_stock` CHECK (`stock` >= 0),
  CONSTRAINT `FK_tbmuebles_precio` CHECK (`precio` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_muebles`
--

LOCK TABLES `tb_muebles` WRITE;
/*!40000 ALTER TABLE `tb_muebles` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_muebles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_pedidos`
--

DROP TABLE IF EXISTS `tb_pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_pedidos` (
  `id_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `estado_pedido` enum('pendiente','entregado') DEFAULT NULL,
  `fecha_pedido` date DEFAULT current_timestamp(),
  `fecha_entrega` date DEFAULT NULL,
  `direccion_pedido` varchar(80) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `FK_tbclientes_tbpedidos` (`id_cliente`),
  CONSTRAINT `FK_tbclientes_tbpedidos` FOREIGN KEY (`id_cliente`) REFERENCES `tb_clientes` (`id_cliente`),
  CONSTRAINT `FK_tbpedidos_fechapedido` CHECK (`fecha_entrega` < `fecha_pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_pedidos`
--

LOCK TABLES `tb_pedidos` WRITE;
/*!40000 ALTER TABLE `tb_pedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_productos_semanales`
--

DROP TABLE IF EXISTS `tb_productos_semanales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_productos_semanales` (
  `id_producto_semanaL` int(11) NOT NULL AUTO_INCREMENT,
  `id_mueble` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_producto_semanaL`),
  KEY `FK_tbmuebles_tbproductossemanal` (`id_mueble`),
  CONSTRAINT `FK_tbmuebles_tbproductossemanal` FOREIGN KEY (`id_mueble`) REFERENCES `tb_muebles` (`id_mueble`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_productos_semanales`
--

LOCK TABLES `tb_productos_semanales` WRITE;
/*!40000 ALTER TABLE `tb_productos_semanales` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_productos_semanales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_valoraciones`
--

DROP TABLE IF EXISTS `tb_valoraciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_valoraciones` (
  `id_valoracion` int(11) NOT NULL AUTO_INCREMENT,
  `id_detalle_pedido` int(11) DEFAULT NULL,
  `valoracion` decimal(5,1) DEFAULT NULL,
  `mensaje` text DEFAULT NULL,
  PRIMARY KEY (`id_valoracion`),
  KEY `Fk_tbvaloraciones_tbdetalles` (`id_detalle_pedido`),
  CONSTRAINT `Fk_tbvaloraciones_tbdetalles` FOREIGN KEY (`id_detalle_pedido`) REFERENCES `tb_detalles_pedidos` (`id_detalle_pedido`),
  CONSTRAINT `Fk_valoracion_mensaje` CHECK (`valoracion` >= 0 and `valoracion` <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_valoraciones`
--

LOCK TABLES `tb_valoraciones` WRITE;
/*!40000 ALTER TABLE `tb_valoraciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_valoraciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-03-06 12:01:32

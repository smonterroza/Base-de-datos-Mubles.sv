USE Mueblessv;

DROP FUNCTION IF EXISTS eliminarcolor;

DELIMITER $$
CREATE FUNCTION eliminarcolor(nombrecolor VARCHAR(50))
RETURNS INT
BEGIN
    DECLARE modificado INT;
    
    DELETE FROM tb_colores WHERE nombre_color = nombrecolor;
    SET modificado = ROW_COUNT();
    
    RETURN modificado;
END;
$$ DELIMITER ;


SELECT eliminarcolor('Morado');
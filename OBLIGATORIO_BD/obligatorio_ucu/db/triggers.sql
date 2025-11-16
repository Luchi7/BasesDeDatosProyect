USE ucu_salas;

DROP FUNCTION IF EXISTS es_exento_por_sala;
DELIMITER $$
CREATE FUNCTION es_exento_por_sala(p_ci VARCHAR(20), p_id_sala INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
  DECLARE v_tipo ENUM('libre','posgrado','docente');
  DECLARE v_es_docente INT DEFAULT 0;
  DECLARE v_es_posgrado INT DEFAULT 0;

  -- Tipo de sala para ver si aplica excepcion
  SELECT s.tipo_sala INTO v_tipo FROM sala s WHERE s.id_sala = p_id_sala;

  -- Si la persona es docente en algun programa
  SELECT COUNT(*) INTO v_es_docente
  FROM participante_programa_academico ppa
  WHERE ppa.ci_participante = p_ci AND ppa.rol = 'docente';

  -- Si es alumno de posgrado
  SELECT COUNT(*) INTO v_es_posgrado
  FROM participante_programa_academico ppa
  JOIN programa_academico pa ON pa.id_programa = ppa.id_programa
  WHERE ppa.ci_participante = p_ci AND ppa.rol='alumno' AND pa.tipo='posgrado';

  -- Si se cumple la excepcion segun la sala
  RETURN (v_tipo='docente' AND v_es_docente>0) OR (v_tipo='posgrado' AND v_es_posgrado>0);
END$$
DELIMITER ;
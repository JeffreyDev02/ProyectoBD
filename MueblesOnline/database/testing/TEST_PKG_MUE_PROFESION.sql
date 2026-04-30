-- =============================================================================
-- Pruebas manuales — PKG_MUE_PROFESION
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar profesión de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PROFESION.PR_PROFESION_INSERTAR(
    P_PRF_NOMBRE        => 'Ingeniero QA',
    P_PRF_ESPECIALIDAD  => 'Pruebas de Software',
    P_PRF_DESCRIPCION   => 'Especialista en control de calidad',
    O_PRF_PROFESION     => V_ID,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener profesión insertada ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(60);
  V_ESP  VARCHAR2(100);
  V_DESC VARCHAR2(150);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(PRF_Profesion) INTO V_ID FROM MUE_PROFESION WHERE PRF_Nombre = 'Ingeniero QA';

  PKG_MUE_PROFESION.PR_PROFESION_OBTENER(
    P_PRF_PROFESION    => V_ID,
    O_PRF_NOMBRE       => V_NOM,
    O_PRF_ESPECIALIDAD => V_ESP,
    O_PRF_DESCRIPCION  => V_DESC,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' ESP=' || V_ESP);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_PID  NUMBER;
  V_NOM  VARCHAR2(60);
  V_ESP  VARCHAR2(100);
  V_DESC VARCHAR2(150);
BEGIN
  PKG_MUE_PROFESION.PR_PROFESION_LISTAR(
    P_FILTRO_NOMBRE => 'Ingeniero',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_PID, V_NOM, V_ESP, V_DESC;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_PID || ' ' || V_NOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRF_Profesion) INTO V_ID FROM MUE_PROFESION WHERE PRF_Nombre = 'Ingeniero QA';

  PKG_MUE_PROFESION.PR_PROFESION_ACTUALIZAR(
    P_PRF_PROFESION    => V_ID,
    P_PRF_NOMBRE       => 'Ingeniero QA (mod)',
    P_PRF_ESPECIALIDAD => 'Automatización de Pruebas',
    P_PRF_DESCRIPCION  => 'Descripción actualizada',
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT PRF_Profesion, PRF_Nombre, PRF_Especialidad
  FROM MUE_PROFESION
 WHERE PRF_Nombre LIKE 'Ingeniero QA%'
 ORDER BY PRF_Profesion;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PROFESION.PR_PROFESION_INSERTAR(
    P_PRF_NOMBRE        => '   ',
    P_PRF_ESPECIALIDAD  => NULL,
    P_PRF_DESCRIPCION   => NULL,
    O_PRF_PROFESION     => V_ID,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar profesión de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRF_Profesion) INTO V_ID FROM MUE_PROFESION WHERE PRF_Nombre LIKE 'Ingeniero QA%';

  PKG_MUE_PROFESION.PR_PROFESION_ELIMINAR(
    P_PRF_PROFESION => V_ID,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_PROFESION WHERE PRF_Nombre LIKE 'Ingeniero QA%';
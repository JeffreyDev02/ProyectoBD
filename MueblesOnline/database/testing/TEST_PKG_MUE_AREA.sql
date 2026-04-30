-- =============================================================================
-- Pruebas manuales — PKG_MUE_AREA
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar área de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_AREA.PR_AREA_INSERTAR(
    P_ARE_AREA_FUNCIONAL => 'Área Prueba QA',
    P_ARE_DESCRIPCION    => 'Área creada para pruebas de calidad',
    O_ARE_AREA           => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener el área recién insertada ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_CAT  TIMESTAMP;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID FROM MUE_AREA WHERE ARE_Area_Funcional = 'Área Prueba QA';

  PKG_MUE_AREA.PR_AREA_OBTENER(
    P_ARE_AREA           => V_ID,
    O_ARE_AREA_FUNCIONAL => V_NOM,
    O_ARE_DESCRIPCION    => V_DESC,
    O_ARE_CREATED_AT     => V_CAT,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' DESC=' || V_DESC);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_AID  NUMBER;
  V_NOM  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_CAT  TIMESTAMP;
BEGIN
  PKG_MUE_AREA.PR_AREA_LISTAR(
    P_FILTRO_NOMBRE => 'Prueba',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_AID, V_NOM, V_DESC, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_AID || ' ' || V_NOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar área ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID FROM MUE_AREA WHERE ARE_Area_Funcional = 'Área Prueba QA';

  PKG_MUE_AREA.PR_AREA_ACTUALIZAR(
    P_ARE_AREA           => V_ID,
    P_ARE_AREA_FUNCIONAL => 'Área Prueba QA (mod)',
    P_ARE_DESCRIPCION    => 'Descripción actualizada en prueba',
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT ARE_Area, ARE_Area_Funcional, ARE_Descripcion
  FROM MUE_AREA
 WHERE ARE_Area_Funcional LIKE 'Área Prueba QA%'
 ORDER BY ARE_Area;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_AREA.PR_AREA_INSERTAR(
    P_ARE_AREA_FUNCIONAL => '   ',
    P_ARE_DESCRIPCION    => 'No debería insertarse',
    O_ARE_AREA           => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: área inexistente ===
DECLARE
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_AREA.PR_AREA_ELIMINAR(
    P_ARE_AREA => -999,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Eliminar área de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID FROM MUE_AREA WHERE ARE_Area_Funcional LIKE 'Área Prueba QA%';

  PKG_MUE_AREA.PR_AREA_ELIMINAR(
    P_ARE_AREA => V_ID,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_AREA WHERE ARE_Area_Funcional LIKE 'Área Prueba QA%';
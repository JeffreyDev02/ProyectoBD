-- =============================================================================
-- Pruebas manuales — PKG_MUE_TALLER_PRODUCCION
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar taller de producción de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_TALLER_PRODUCCION.PR_TALLER_INSERTAR(
    P_TPR_DESCRIPCION => 'Taller de prueba QA',
    P_TPR_ZONA        => '5',
    P_TPR_MUNICIPIO   => 'Guatemala',
    P_TPR_CIUDAD      => 'Guatemala',
    O_TPR_TALLER      => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener taller insertado ===
DECLARE
  V_ID   NUMBER;
  V_DESC VARCHAR2(200);
  V_ZONA VARCHAR2(30);
  V_MUN  VARCHAR2(60);
  V_CIU  VARCHAR2(60);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(TPR_Taller_Produccion) INTO V_ID
    FROM MUE_TALLER_PRODUCCION WHERE TPR_Descripcion = 'Taller de prueba QA';

  PKG_MUE_TALLER_PRODUCCION.PR_TALLER_OBTENER(
    P_TPR_TALLER      => V_ID,
    O_TPR_DESCRIPCION => V_DESC,
    O_TPR_ZONA        => V_ZONA,
    O_TPR_MUNICIPIO   => V_MUN,
    O_TPR_CIUDAD      => V_CIU,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' DESC=' || V_DESC || ' ZONA=' || V_ZONA || ' MUN=' || V_MUN);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_TID  NUMBER;
  V_DESC VARCHAR2(200);
  V_ZONA VARCHAR2(30);
  V_MUN  VARCHAR2(60);
  V_CIU  VARCHAR2(60);
BEGIN
  PKG_MUE_TALLER_PRODUCCION.PR_TALLER_LISTAR(
    P_FILTRO_MUNICIPIO => 'Guatemala',
    O_CURSOR           => V_CUR,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_TID, V_DESC, V_ZONA, V_MUN, V_CIU;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_TID || ' ' || V_DESC || ' Zona=' || V_ZONA);
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
  SELECT MAX(TPR_Taller_Produccion) INTO V_ID
    FROM MUE_TALLER_PRODUCCION WHERE TPR_Descripcion = 'Taller de prueba QA';

  PKG_MUE_TALLER_PRODUCCION.PR_TALLER_ACTUALIZAR(
    P_TPR_TALLER      => V_ID,
    P_TPR_DESCRIPCION => 'Taller de prueba QA (mod)',
    P_TPR_ZONA        => '7',
    P_TPR_MUNICIPIO   => 'Mixco',
    P_TPR_CIUDAD      => 'Guatemala',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT TPR_Taller_Produccion, TPR_Descripcion, TPR_Zona, TPR_Municipio
  FROM MUE_TALLER_PRODUCCION
 WHERE TPR_Descripcion LIKE 'Taller de prueba QA%'
 ORDER BY TPR_Taller_Produccion;

PROMPT === 6) Caso negativo: ID inexistente ===
DECLARE
  V_DESC VARCHAR2(200);
  V_ZONA VARCHAR2(30);
  V_MUN  VARCHAR2(60);
  V_CIU  VARCHAR2(60);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  PKG_MUE_TALLER_PRODUCCION.PR_TALLER_OBTENER(
    P_TPR_TALLER      => 99999,
    O_TPR_DESCRIPCION => V_DESC,
    O_TPR_ZONA        => V_ZONA,
    O_TPR_MUNICIPIO   => V_MUN,
    O_TPR_CIUDAD      => V_CIU,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar taller de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(TPR_Taller_Produccion) INTO V_ID
    FROM MUE_TALLER_PRODUCCION WHERE TPR_Descripcion LIKE 'Taller de prueba QA%';

  PKG_MUE_TALLER_PRODUCCION.PR_TALLER_ELIMINAR(
    P_TPR_TALLER => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_TALLER_PRODUCCION WHERE TPR_Descripcion LIKE 'Taller de prueba QA%';
-- =============================================================================
-- Pruebas manuales — PKG_MUE_PERMISO
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar permiso de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PERMISO.PR_PERMISO_INSERTAR(
    P_PER_CODIGO      => 'PERM_QA_001',
    P_PER_DESCRIPCION => 'Permiso creado para pruebas de calidad',
    O_PER_PERMISO     => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener el permiso recién insertado ===
DECLARE
  V_ID   NUMBER;
  V_COD  VARCHAR2(30);
  V_DESC VARCHAR2(200);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(PER_Permiso) INTO V_ID FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_QA_001';

  PKG_MUE_PERMISO.PR_PERMISO_OBTENER(
    P_PER_PERMISO     => V_ID,
    O_PER_CODIGO      => V_COD,
    O_PER_DESCRIPCION => V_DESC,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' COD=' || V_COD || ' DESC=' || V_DESC);
END;
/

PROMPT === 3) Listar con filtro por código ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_PID  NUMBER;
  V_COD  VARCHAR2(30);
  V_DESC VARCHAR2(200);
BEGIN
  PKG_MUE_PERMISO.PR_PERMISO_LISTAR(
    P_FILTRO_CODIGO => 'PERM_QA',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_PID, V_COD, V_DESC;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_PID || ' COD=' || V_COD);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar permiso ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PER_Permiso) INTO V_ID FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_QA_001';

  PKG_MUE_PERMISO.PR_PERMISO_ACTUALIZAR(
    P_PER_PERMISO     => V_ID,
    P_PER_CODIGO      => 'PERM_QA_001_MOD',
    P_PER_DESCRIPCION => 'Descripción actualizada en prueba',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT PER_Permiso, PER_Codigo, PER_Descripcion
  FROM MUE_PERMISO
 WHERE PER_Codigo LIKE 'PERM_QA%'
 ORDER BY PER_Permiso;

PROMPT === 6) Caso negativo: código vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PERMISO.PR_PERMISO_INSERTAR(
    P_PER_CODIGO      => '   ',
    P_PER_DESCRIPCION => 'No debería insertarse',
    O_PER_PERMISO     => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: código duplicado ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PERMISO.PR_PERMISO_INSERTAR(
    P_PER_CODIGO      => 'PERM_QA_001_MOD',
    P_PER_DESCRIPCION => 'Intento de código duplicado',
    O_PER_PERMISO     => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Caso negativo: permiso inexistente ===
DECLARE
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PERMISO.PR_PERMISO_ELIMINAR(
    P_PER_PERMISO => -999,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 9) Eliminar permiso de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PER_Permiso) INTO V_ID FROM MUE_PERMISO WHERE PER_Codigo LIKE 'PERM_QA%';

  PKG_MUE_PERMISO.PR_PERMISO_ELIMINAR(
    P_PER_PERMISO => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_PERMISO WHERE PER_Codigo LIKE 'PERM_QA%';
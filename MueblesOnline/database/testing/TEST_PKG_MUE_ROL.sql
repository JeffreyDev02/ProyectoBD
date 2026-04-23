-- =============================================================================
-- Pruebas manuales — PKG_MUE_ROL
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar rol de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ROL.PR_ROL_INSERTAR(
    P_ROL_NOMBRE      => 'Rol Prueba QA',
    P_ROL_DESCRIPCION => 'Rol creado para pruebas de calidad',
    O_ROL_ROL         => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener el rol recién insertado ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol) INTO V_ID FROM MUE_ROL WHERE ROL_Nombre = 'Rol Prueba QA';

  PKG_MUE_ROL.PR_ROL_OBTENER(
    P_ROL_ROL         => V_ID,
    O_ROL_NOMBRE      => V_NOM,
    O_ROL_DESCRIPCION => V_DESC,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' DESC=' || V_DESC);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_RID  NUMBER;
  V_NOM  VARCHAR2(50);
  V_DESC VARCHAR2(200);
BEGIN
  PKG_MUE_ROL.PR_ROL_LISTAR(
    P_FILTRO_NOMBRE => 'Prueba',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_RID, V_NOM, V_DESC;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_RID || ' NOM=' || V_NOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar rol ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol) INTO V_ID FROM MUE_ROL WHERE ROL_Nombre = 'Rol Prueba QA';

  PKG_MUE_ROL.PR_ROL_ACTUALIZAR(
    P_ROL_ROL         => V_ID,
    P_ROL_NOMBRE      => 'Rol Prueba QA (mod)',
    P_ROL_DESCRIPCION => 'Descripción actualizada en prueba',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT ROL_Rol, ROL_Nombre, ROL_Descripcion
  FROM MUE_ROL
 WHERE ROL_Nombre LIKE 'Rol Prueba QA%'
 ORDER BY ROL_Rol;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ROL.PR_ROL_INSERTAR(
    P_ROL_NOMBRE      => '   ',
    P_ROL_DESCRIPCION => 'No debería insertarse',
    O_ROL_ROL         => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: rol inexistente ===
DECLARE
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ROL.PR_ROL_ELIMINAR(
    P_ROL_ROL => -999,
    O_COD_RET => V_RET,
    O_MSG     => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Eliminar rol de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol) INTO V_ID FROM MUE_ROL WHERE ROL_Nombre LIKE 'Rol Prueba QA%';

  PKG_MUE_ROL.PR_ROL_ELIMINAR(
    P_ROL_ROL => V_ID,
    O_COD_RET => V_RET,
    O_MSG     => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_ROL WHERE ROL_Nombre LIKE 'Rol Prueba QA%';
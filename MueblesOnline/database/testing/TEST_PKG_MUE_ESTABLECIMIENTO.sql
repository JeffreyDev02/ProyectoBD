-- =============================================================================
-- Pruebas manuales — PKG_MUE_ESTABLECIMIENTO
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar establecimiento ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ESTABLECIMIENTO.PR_ESTABLECIMIENTO_INSERTAR(
    P_EST_NOMBRE       => 'Establecimiento QA',
    P_EST_MUNICIPIO    => 'Guatemala',
    P_EST_DEPARTAMENTO => 'Guatemala',
    P_EST_PAIS         => 'Guatemala',
    P_EST_DIRECCION    => 'Zona 10',
    O_EST_ESTABLECIMIENTO => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Obtener establecimiento ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(50);
  V_MUN  VARCHAR2(40);
  V_DEP  VARCHAR2(40);
  V_PAIS VARCHAR2(40);
  V_DIR  VARCHAR2(50);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(EST_Establecimiento) INTO V_ID FROM MUE_ESTABLECIMIENTO WHERE EST_Nombre = 'Establecimiento QA';
  PKG_MUE_ESTABLECIMIENTO.PR_ESTABLECIMIENTO_OBTENER(
    P_EST_ESTABLECIMIENTO => V_ID,
    O_EST_NOMBRE          => V_NOM,
    O_EST_MUNICIPIO       => V_MUN,
    O_EST_DEPARTAMENTO    => V_DEP,
    O_EST_PAIS            => V_PAIS,
    O_EST_DIRECCION       => V_DIR,
    O_COD_RET             => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' DIR=' || V_DIR);
END;
/

PROMPT === 3) Listar establecimientos ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_NOM  VARCHAR2(50);
  V_MUN  VARCHAR2(40);
  V_DEP  VARCHAR2(40);
  V_PAIS VARCHAR2(40);
  V_DIR  VARCHAR2(50);
BEGIN
  PKG_MUE_ESTABLECIMIENTO.PR_ESTABLECIMIENTO_LISTAR(
    P_FILTRO_NOMBRE => 'QA',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  LOOP
    FETCH V_CUR INTO V_ID, V_NOM, V_MUN, V_DEP, V_PAIS, V_DIR;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  ID=' || V_ID || ' NOM=' || V_NOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar establecimiento ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(EST_Establecimiento) INTO V_ID FROM MUE_ESTABLECIMIENTO WHERE EST_Nombre = 'Establecimiento QA';
  PKG_MUE_ESTABLECIMIENTO.PR_ESTABLECIMIENTO_ACTUALIZAR(
    P_EST_ESTABLECIMIENTO => V_ID,
    P_EST_NOMBRE          => 'Establecimiento QA (mod)',
    P_EST_MUNICIPIO       => 'Mixco',
    P_EST_DEPARTAMENTO    => 'Guatemala',
    P_EST_PAIS            => 'Guatemala',
    P_EST_DIRECCION       => 'Zona 11',
    O_COD_RET             => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Caso negativo: nombre vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ESTABLECIMIENTO.PR_ESTABLECIMIENTO_INSERTAR(
    P_EST_NOMBRE       => '  ',
    P_EST_MUNICIPIO    => 'X',
    P_EST_DEPARTAMENTO => 'X',
    P_EST_PAIS         => 'X',
    P_EST_DIRECCION    => NULL,
    O_EST_ESTABLECIMIENTO => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Eliminar establecimiento ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(EST_Establecimiento) INTO V_ID FROM MUE_ESTABLECIMIENTO WHERE EST_Nombre LIKE 'Establecimiento QA%';
  PKG_MUE_ESTABLECIMIENTO.PR_ESTABLECIMIENTO_ELIMINAR(
    P_EST_ESTABLECIMIENTO => V_ID,
    O_COD_RET             => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin ESTABLECIMIENTO. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_ESTABLECIMIENTO WHERE EST_Nombre LIKE 'Establecimiento QA%';
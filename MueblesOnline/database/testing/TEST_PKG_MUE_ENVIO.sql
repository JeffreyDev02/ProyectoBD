-- =============================================================================
-- Pruebas manuales — PKG_MUE_ENVIO
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar empresa de envío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ENVIO.PR_ENVIO_INSERTAR(
    P_ENV_NOMBRE_COMPANIA => 'Envíos QA S.A.',
    P_ENV_TELEFONO        => 55551234,
    O_ENV_ENVIO           => V_ID,
    O_COD_RET             => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Obtener empresa de envío ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(150);
  V_TEL  NUMBER;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(ENV_Envio) INTO V_ID FROM MUE_ENVIO WHERE ENV_Nombre_Compania = 'Envíos QA S.A.';
  PKG_MUE_ENVIO.PR_ENVIO_OBTENER(
    P_ENV_ENVIO           => V_ID,
    O_ENV_NOMBRE_COMPANIA => V_NOM,
    O_ENV_TELEFONO        => V_TEL,
    O_COD_RET             => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' TEL=' || V_TEL);
END;
/

PROMPT === 3) Listar empresas de envío ===
DECLARE
  V_CUR SYS_REFCURSOR;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
  V_ID  NUMBER;
  V_NOM VARCHAR2(150);
  V_TEL NUMBER;
BEGIN
  PKG_MUE_ENVIO.PR_ENVIO_LISTAR(
    P_FILTRO_NOMBRE => 'QA',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  LOOP
    FETCH V_CUR INTO V_ID, V_NOM, V_TEL;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  ID=' || V_ID || ' NOM=' || V_NOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar empresa de envío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ENV_Envio) INTO V_ID FROM MUE_ENVIO WHERE ENV_Nombre_Compania = 'Envíos QA S.A.';
  PKG_MUE_ENVIO.PR_ENVIO_ACTUALIZAR(
    P_ENV_ENVIO           => V_ID,
    P_ENV_NOMBRE_COMPANIA => 'Envíos QA S.A. (mod)',
    P_ENV_TELEFONO        => 55559999,
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
  PKG_MUE_ENVIO.PR_ENVIO_INSERTAR(
    P_ENV_NOMBRE_COMPANIA => '  ',
    P_ENV_TELEFONO        => 12345678,
    O_ENV_ENVIO           => V_ID,
    O_COD_RET             => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Eliminar empresa de envío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ENV_Envio) INTO V_ID FROM MUE_ENVIO WHERE ENV_Nombre_Compania LIKE 'Envíos QA%';
  PKG_MUE_ENVIO.PR_ENVIO_ELIMINAR(
    P_ENV_ENVIO => V_ID,
    O_COD_RET   => V_RET,
    O_MSG       => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin ENVIO. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_ENVIO WHERE ENV_Nombre_Compania LIKE 'Envíos QA%';
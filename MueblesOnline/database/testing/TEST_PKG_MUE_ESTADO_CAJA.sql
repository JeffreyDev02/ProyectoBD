-- =============================================================================
-- Pruebas manuales — PKG_MUE_ESTADO_CAJA
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar estado de caja de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ESTADO_CAJA.PR_ESTADO_CAJA_INSERTAR(
    P_ECA_ESTADO   => 'ABIERTA QA',
    O_ECA_ESTADO_C => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener estado de caja insertado ===
DECLARE
  V_ID  NUMBER;
  V_EST VARCHAR2(50);
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ECA_Estado_Caja) INTO V_ID FROM MUE_ESTADO_CAJA WHERE ECA_Estado = 'ABIERTA QA';

  PKG_MUE_ESTADO_CAJA.PR_ESTADO_CAJA_OBTENER(
    P_ECA_ESTADO_C => V_ID,
    O_ECA_ESTADO   => V_EST,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' ESTADO=' || V_EST);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR SYS_REFCURSOR;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
  V_EID NUMBER;
  V_EST VARCHAR2(50);
BEGIN
  PKG_MUE_ESTADO_CAJA.PR_ESTADO_CAJA_LISTAR(
    P_FILTRO_ESTADO => 'ABIERTA',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_EID, V_EST;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_EID || ' ' || V_EST);
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
  SELECT MAX(ECA_Estado_Caja) INTO V_ID FROM MUE_ESTADO_CAJA WHERE ECA_Estado = 'ABIERTA QA';

  PKG_MUE_ESTADO_CAJA.PR_ESTADO_CAJA_ACTUALIZAR(
    P_ECA_ESTADO_C => V_ID,
    P_ECA_ESTADO   => 'ABIERTA QA (mod)',
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT ECA_Estado_Caja, ECA_Estado
  FROM MUE_ESTADO_CAJA
 WHERE ECA_Estado LIKE 'ABIERTA QA%'
 ORDER BY ECA_Estado_Caja;

PROMPT === 6) Caso negativo: estado vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ESTADO_CAJA.PR_ESTADO_CAJA_INSERTAR(
    P_ECA_ESTADO   => '   ',
    O_ECA_ESTADO_C => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar estado de caja de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ECA_Estado_Caja) INTO V_ID FROM MUE_ESTADO_CAJA WHERE ECA_Estado LIKE 'ABIERTA QA%';

  PKG_MUE_ESTADO_CAJA.PR_ESTADO_CAJA_ELIMINAR(
    P_ECA_ESTADO_C => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_ESTADO_CAJA WHERE ECA_Estado LIKE 'ABIERTA QA%';
-- =============================================================================
-- Pruebas manuales — PKG_MUE_ENTREGA_COMPRA
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar entrega de compra de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ENTREGA_COMPRA.PR_ENTREGA_COMPRA_INSERTAR(
    P_ECM_FECHA    => DATE '2025-01-15',
    O_ECM_ENTREGA  => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener entrega insertada ===
DECLARE
  V_ID    NUMBER;
  V_FECHA DATE;
  V_RET   NUMBER;
  V_MSG   VARCHAR2(4000);
BEGIN
  SELECT MAX(ECM_Entrega_Compra) INTO V_ID
    FROM MUE_ENTREGA_COMPRA WHERE ECM_Fecha = DATE '2025-01-15';

  PKG_MUE_ENTREGA_COMPRA.PR_ENTREGA_COMPRA_OBTENER(
    P_ECM_ENTREGA => V_ID,
    O_ECM_FECHA   => V_FECHA,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' FECHA=' || TO_CHAR(V_FECHA, 'YYYY-MM-DD'));
END;
/

PROMPT === 3) Listar con filtro de fecha ===
DECLARE
  V_CUR   SYS_REFCURSOR;
  V_RET   NUMBER;
  V_MSG   VARCHAR2(4000);
  V_EID   NUMBER;
  V_FECHA DATE;
BEGIN
  PKG_MUE_ENTREGA_COMPRA.PR_ENTREGA_COMPRA_LISTAR(
    P_FILTRO_FECHA => DATE '2025-01-15',
    O_CURSOR       => V_CUR,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_EID, V_FECHA;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_EID || ' Fecha=' || TO_CHAR(V_FECHA, 'YYYY-MM-DD'));
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
  SELECT MAX(ECM_Entrega_Compra) INTO V_ID
    FROM MUE_ENTREGA_COMPRA WHERE ECM_Fecha = DATE '2025-01-15';

  PKG_MUE_ENTREGA_COMPRA.PR_ENTREGA_COMPRA_ACTUALIZAR(
    P_ECM_ENTREGA => V_ID,
    P_ECM_FECHA   => DATE '2025-02-20',
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT ECM_Entrega_Compra, ECM_Fecha
  FROM MUE_ENTREGA_COMPRA
 WHERE ECM_Fecha = DATE '2025-02-20'
 ORDER BY ECM_Entrega_Compra;

PROMPT === 6) Caso negativo: ID inexistente ===
DECLARE
  V_FECHA DATE;
  V_RET   NUMBER;
  V_MSG   VARCHAR2(4000);
BEGIN
  PKG_MUE_ENTREGA_COMPRA.PR_ENTREGA_COMPRA_OBTENER(
    P_ECM_ENTREGA => 99999,
    O_ECM_FECHA   => V_FECHA,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar entrega de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ECM_Entrega_Compra) INTO V_ID
    FROM MUE_ENTREGA_COMPRA WHERE ECM_Fecha = DATE '2025-02-20';

  PKG_MUE_ENTREGA_COMPRA.PR_ENTREGA_COMPRA_ELIMINAR(
    P_ECM_ENTREGA => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_ENTREGA_COMPRA WHERE ECM_Fecha = DATE '2025-02-20';
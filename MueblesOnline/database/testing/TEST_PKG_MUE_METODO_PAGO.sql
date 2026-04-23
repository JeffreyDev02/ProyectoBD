-- =============================================================================
-- Pruebas manuales — PKG_MUE_METODO_PAGO
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar método de pago ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_METODO_PAGO.PR_METODO_PAGO_INSERTAR(
    P_MPA_METODO      => 'Método QA',
    O_MPA_METODO_PAGO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Obtener método de pago ===
DECLARE
  V_ID  NUMBER;
  V_MET VARCHAR2(50);
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MPA_Metodo_Pago) INTO V_ID FROM MUE_METODO_PAGO WHERE MPA_Metodo = 'Método QA';
  PKG_MUE_METODO_PAGO.PR_METODO_PAGO_OBTENER(
    P_MPA_METODO_PAGO => V_ID,
    O_MPA_METODO      => V_MET,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' METODO=' || V_MET);
END;
/

PROMPT === 3) Listar métodos de pago ===
DECLARE
  V_CUR SYS_REFCURSOR;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
  V_ID  NUMBER;
  V_MET VARCHAR2(50);
BEGIN
  PKG_MUE_METODO_PAGO.PR_METODO_PAGO_LISTAR(
    P_FILTRO_METODO => 'QA',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  LOOP
    FETCH V_CUR INTO V_ID, V_MET;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  ID=' || V_ID || ' MET=' || V_MET);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar método de pago ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MPA_Metodo_Pago) INTO V_ID FROM MUE_METODO_PAGO WHERE MPA_Metodo = 'Método QA';
  PKG_MUE_METODO_PAGO.PR_METODO_PAGO_ACTUALIZAR(
    P_MPA_METODO_PAGO => V_ID,
    P_MPA_METODO      => 'Método QA (mod)',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
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
  PKG_MUE_METODO_PAGO.PR_METODO_PAGO_INSERTAR(
    P_MPA_METODO      => '  ',
    O_MPA_METODO_PAGO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Eliminar método de pago ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MPA_Metodo_Pago) INTO V_ID FROM MUE_METODO_PAGO WHERE MPA_Metodo LIKE 'Método QA%';
  PKG_MUE_METODO_PAGO.PR_METODO_PAGO_ELIMINAR(
    P_MPA_METODO_PAGO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin METODO_PAGO. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_METODO_PAGO WHERE MPA_Metodo LIKE 'Método QA%';
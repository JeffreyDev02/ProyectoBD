SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar nota de crédito (Camino Feliz) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_NOTA_CREDITO.PR_NOTA_CREDITO_INSERTAR(
    P_FAC_FACTURA     => 1,
    P_NCR_FECHA       => SYSDATE,
    P_NCR_MONTO       => 100.00,
    P_NCR_MOTIVO      => 'Devolución parcial de producto por daño menor',
    O_NCR_NOTA_CREDITO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Caso Negativo: Monto excede total de factura ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  -- Intento de aplicar nota de crédito por un valor exagerado
  PKG_MUE_NOTA_CREDITO.PR_NOTA_CREDITO_INSERTAR(
    P_FAC_FACTURA     => 1,
    P_NCR_FECHA       => SYSDATE,
    P_NCR_MONTO       => 999999.99,
    P_NCR_MOTIVO      => 'Error de monto excedido',
    O_NCR_NOTA_CREDITO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener detalle de nota de crédito ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_ID_N NUMBER; V_FAC NUMBER; V_MON NUMBER; V_MOT VARCHAR2(200);
BEGIN
  SELECT MAX(NCR_Nota_Credito) INTO V_ID FROM MUE_NOTA_CREDITO WHERE FAC_Factura = 1;

  PKG_MUE_NOTA_CREDITO.PR_NOTA_CREDITO_OBTENER(
    P_NCR_NOTA_CREDITO => V_ID,
    O_CURSOR           => V_CUR,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_N, V_FAC, V_MON, V_MOT;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MONTO=' || V_MON || ' MOTIVO=' || V_MOT);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar nota de crédito ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(NCR_Nota_Credito) INTO V_ID FROM MUE_NOTA_CREDITO WHERE FAC_Factura = 1;

  PKG_MUE_NOTA_CREDITO.PR_NOTA_CREDITO_ACTUALIZAR(
    P_NCR_NOTA_CREDITO => V_ID,
    P_FAC_FACTURA      => 1,
    P_NCR_FECHA        => SYSDATE,
    P_NCR_MONTO        => 150.00,
    P_NCR_MOTIVO       => 'Motivo actualizado: Ajuste de precio',
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Eliminar nota de crédito (Limpieza) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(NCR_Nota_Credito) INTO V_ID FROM MUE_NOTA_CREDITO WHERE FAC_Factura = 1;

  PKG_MUE_NOTA_CREDITO.PR_NOTA_CREDITO_ELIMINAR(
    P_NCR_NOTA_CREDITO => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Debe ser 0 si se eliminó) ===
SELECT COUNT(1) AS CANT FROM MUE_NOTA_CREDITO WHERE FAC_Factura = 1;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar nota de débito (Camino Feliz) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_NOTA_DEBITO.PR_NOTA_DEBITO_INSERTAR(
    P_FAC_FACTURA     => 1,
    P_NDE_FECHA       => SYSDATE,
    P_NDE_MONTO       => 75.00,
    P_NDE_MOTIVO      => 'Cargo adicional por servicio de flete no contemplado',
    O_NDE_NOTA_DEBITO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Caso Negativo: Factura inexistente ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_NOTA_DEBITO.PR_NOTA_DEBITO_INSERTAR(
    P_FAC_FACTURA     => 999999, 
    P_NDE_FECHA       => SYSDATE,
    P_NDE_MONTO       => 10.00,
    P_NDE_MOTIVO      => 'Prueba de error',
    O_NDE_NOTA_DEBITO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener nota de débito ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_ID_D NUMBER; V_FAC NUMBER; V_MON NUMBER; V_MOT VARCHAR2(200);
BEGIN
  SELECT MAX(NDE_Nota_Debito) INTO V_ID FROM MUE_NOTA_DEBITO WHERE FAC_Factura = 1;

  PKG_MUE_NOTA_DEBITO.PR_NOTA_DEBITO_OBTENER(
    P_NDE_NOTA_DEBITO => V_ID,
    O_CURSOR          => V_CUR,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_D, V_FAC, V_MON, V_MOT;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MONTO=' || V_MON || ' MOTIVO=' || V_MOT);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar nota de débito ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(NDE_Nota_Debito) INTO V_ID FROM MUE_NOTA_DEBITO WHERE FAC_Factura = 1;

  PKG_MUE_NOTA_DEBITO.PR_NOTA_DEBITO_ACTUALIZAR(
    P_NDE_NOTA_DEBITO => V_ID,
    P_FAC_FACTURA      => 1,
    P_NDE_FECHA        => SYSDATE,
    P_NDE_MONTO        => 80.00,
    P_NDE_MOTIVO       => 'Motivo actualizado: Ajuste por redondeo de flete',
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Eliminar nota de débito (Limpieza) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(NDE_Nota_Debito) INTO V_ID FROM MUE_NOTA_DEBITO WHERE FAC_Factura = 1;

  PKG_MUE_NOTA_DEBITO.PR_NOTA_DEBITO_ELIMINAR(
    P_NDE_NOTA_DEBITO => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_NOTA_DEBITO WHERE FAC_Factura = 1;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Generar factura desde una Orden de Venta ===
DECLARE
  V_ID_FAC NUMBER;
  V_ID_OV  NUMBER;
  V_RET    NUMBER;
  V_MSG    VARCHAR2(4000);
BEGIN
  V_ID_OV := 1;

  PKG_MUE_FACTURA.PR_FACTURA_GENERAR_DESDE_ORDEN(
    P_MOV_ORDEN_VENTA => V_ID_OV,
    P_MPA_METODO_PAGO => 1, 
    P_EMP_EMPLEADO    => 1, 
    O_FAC_FACTURA     => V_ID_FAC,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID_FACTURA=' || V_ID_FAC);
END;
/

PROMPT === 2) Caso Negativo: Método de pago inexistente ===
DECLARE
  V_ID_FAC NUMBER;
  V_RET    NUMBER;
  V_MSG    VARCHAR2(4000);
BEGIN
  PKG_MUE_FACTURA.PR_FACTURA_INSERTAR(
    P_FAC_NUMERO      => 'FAC-ERR-99',
    P_FAC_FECHA       => SYSDATE,
    P_MOV_ORDEN_VENTA => 1,
    P_EMP_EMPLEADO    => 1,
    P_FAC_SUBTOTAL    => 100.00,
    P_FAC_IMPUESTO    => 12.00,
    P_FAC_TOTAL       => 112.00,
    P_MPA_METODO_PAGO => 9999, 
    P_EST_ESTADO      => 1,
    O_FAC_FACTURA     => V_ID_FAC,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener detalle de factura ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_NUM  VARCHAR2(20); V_TOT NUMBER; V_MET VARCHAR2(50);
BEGIN
  SELECT MAX(FAC_Factura) INTO V_ID FROM MUE_FACTURA;

  PKG_MUE_FACTURA.PR_FACTURA_OBTENER(
    P_FAC_FACTURA => V_ID,
    O_CURSOR      => V_CUR,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  
  FETCH V_CUR INTO V_NUM, V_TOT, V_MET;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NUMERO=' || V_NUM || ' TOTAL=' || V_TOT);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar estado de factura ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(FAC_Factura) INTO V_ID FROM MUE_FACTURA;

  PKG_MUE_FACTURA.PR_FACTURA_ACTUALIZAR(
    P_FAC_FACTURA     => V_ID,
    P_FAC_NUMERO      => 'FAC-QA-MOD',
    P_FAC_FECHA       => SYSDATE,
    P_MOV_ORDEN_VENTA => 1,
    P_EMP_EMPLEADO    => 1,
    P_FAC_SUBTOTAL    => 500.00,
    P_FAC_IMPUESTO    => 60.00,
    P_FAC_TOTAL       => 560.00,
    P_MPA_METODO_PAGO => 1,
    P_EST_ESTADO      => 2, 
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Eliminar factura de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(FAC_Factura) INTO V_ID FROM MUE_FACTURA;

  PKG_MUE_FACTURA.PR_FACTURA_ELIMINAR(
    P_FAC_FACTURA => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Conteo de facturas) ===
SELECT COUNT(1) AS CANT FROM MUE_FACTURA;
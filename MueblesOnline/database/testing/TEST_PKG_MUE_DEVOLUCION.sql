SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar devolución de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_DEVOLUCION.PR_DEVOLUCION_INSERTAR(
    P_FAC_FACTURA      => 1,
    P_PRO_PRODUCTO     => 1,
    P_DEV_FECHA        => SYSDATE,
    P_DEV_CANTIDAD     => 1,
    P_DEV_MOTIVO       => 'Producto con defecto de fábrica en tapicería',
    O_DEV_DEVOLUCION   => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
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
  PKG_MUE_DEVOLUCION.PR_DEVOLUCION_INSERTAR(
    P_FAC_FACTURA      => 99999,
    P_PRO_PRODUCTO     => 1,
    P_DEV_FECHA        => SYSDATE,
    P_DEV_CANTIDAD     => 1,
    P_DEV_MOTIVO       => 'Prueba error factura',
    O_DEV_DEVOLUCION   => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener detalle de devolución ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_ID_D NUMBER; V_FAC NUMBER; V_PRO NUMBER; V_CAN NUMBER; V_MOT VARCHAR2(200);
BEGIN
  SELECT MAX(DEV_Devolucion) INTO V_ID FROM MUE_DEVOLUCION WHERE FAC_Factura = 1;

  PKG_MUE_DEVOLUCION.PR_DEVOLUCION_OBTENER(
    P_DEV_DEVOLUCION => V_ID,
    O_CURSOR         => V_CUR,
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_D, V_FAC, V_PRO, V_CAN, V_MOT;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' CANT_DEVUELTA=' || V_CAN || ' MOTIVO=' || V_MOT);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar motivo de devolución ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(DEV_Devolucion) INTO V_ID FROM MUE_DEVOLUCION WHERE FAC_Factura = 1;

  PKG_MUE_DEVOLUCION.PR_DEVOLUCION_ACTUALIZAR(
    P_DEV_DEVOLUCION => V_ID,
    P_FAC_FACTURA    => 1,
    P_PRO_PRODUCTO   => 1,
    P_DEV_FECHA      => SYSDATE,
    P_DEV_CANTIDAD   => 1,
    P_DEV_MOTIVO     => 'Motivo Actualizado: Daño estructural en pata izquierda',
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Eliminar registro de devolución ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(DEV_Devolucion) INTO V_ID FROM MUE_DEVOLUCION WHERE FAC_Factura = 1;

  PKG_MUE_DEVOLUCION.PR_DEVOLUCION_ELIMINAR(
    P_DEV_DEVOLUCION => V_ID,
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_DEVOLUCION WHERE FAC_Factura = 1;
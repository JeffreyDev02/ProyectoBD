SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar orden de venta inicial ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ORDEN_VENTA.PR_ORDEN_INSERTAR(
    P_SED_SEDE           => 1,
    P_USU_USUARIO        => 1,
    P_MOV_FECHA_ORDEN    => SYSDATE,
    P_MOV_ESTADO         => 'PENDIENTE',
    P_MOV_TOTAL          => 0,
    P_MOV_OBSERVACIONES  => 'Orden de prueba QA',
    O_MOV_ORDEN_VENTA    => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Obtener orden de venta ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_ID_O NUMBER; V_SED NUMBER; V_USU NUMBER; V_FEC DATE; V_EST VARCHAR2(20); V_TOT NUMBER;
BEGIN
  SELECT MAX(MOV_Orden_Venta) INTO V_ID FROM MUE_ORDEN_VENTA WHERE MOV_Observaciones = 'Orden de prueba QA';

  PKG_MUE_ORDEN_VENTA.PR_ORDEN_OBTENER(
    P_MOV_ORDEN_VENTA => V_ID,
    O_CURSOR          => V_CUR,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_O, V_SED, V_USU, V_FEC, V_EST, V_TOT;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' ESTADO=' || V_EST || ' TOTAL_ACTUAL=' || V_TOT);
  CLOSE V_CUR;
END;
/

PROMPT === 3) Cambiar estado de la orden ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MOV_Orden_Venta) INTO V_ID FROM MUE_ORDEN_VENTA WHERE MOV_Observaciones = 'Orden de prueba QA';

  PKG_MUE_ORDEN_VENTA.PR_ORDEN_CAMBIAR_ESTADO(
    P_MOV_ORDEN_VENTA => V_ID,
    P_MOV_ESTADO      => 'APROBADA',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('ESTADO RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 4) Probar Recalcular Total (Simulación manual) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MOV_Orden_Venta) INTO V_ID FROM MUE_ORDEN_VENTA WHERE MOV_Observaciones = 'Orden de prueba QA';


  PKG_MUE_ORDEN_VENTA.PR_ORDEN_RECALCULAR_TOTAL(
    P_MOV_ORDEN_VENTA => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RECALCULO RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Actualizar observaciones de la orden ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MOV_Orden_Venta) INTO V_ID FROM MUE_ORDEN_VENTA WHERE MOV_Observaciones = 'Orden de prueba QA';

  PKG_MUE_ORDEN_VENTA.PR_ORDEN_ACTUALIZAR(
    P_MOV_ORDEN_VENTA => V_ID,
    P_SED_SEDE           => 1,
    P_USU_USUARIO        => 1,
    P_MOV_FECHA_ORDEN    => SYSDATE,
    P_MOV_ESTADO         => 'APROBADA',
    P_MOV_OBSERVACIONES  => 'Orden QA - Actualizada para facturación',
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Eliminar orden de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MOV_Orden_Venta) INTO V_ID FROM MUE_ORDEN_VENTA WHERE MOV_Observaciones LIKE 'Orden QA%';

  PKG_MUE_ORDEN_VENTA.PR_ORDEN_ELIMINAR(
    P_MOV_ORDEN_VENTA => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Registros restantes) ===
SELECT COUNT(1) AS CANT FROM MUE_ORDEN_VENTA WHERE MOV_Observaciones LIKE 'Orden QA%';
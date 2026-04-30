SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Apertura de Caja (Registro Inicial) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  -- Se abre la caja con un saldo inicial de 500.00
  PKG_MUE_CIERRE_CAJA.PR_CIERRE_INSERTAR(
    P_SED_SEDE           => 1,
    P_USU_USUARIO        => 1,
    P_CIE_FECHA          => SYSDATE,
    P_CIE_SALDO_INICIAL  => 500.00,
    P_CIE_INGRESOS       => 0,
    P_CIE_EGRESOS        => 0,
    P_CIE_SALDO_FINAL    => 0,
    P_CIE_DIFERENCIA     => 0,
    P_CIE_OBSERVACIONES  => 'Apertura de turno mañana',
    P_EST_ESTADO         => 1, 
    O_CIE_CIERRE         => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID_CIERRE=' || V_ID);
END;
/

PROMPT === 2) Ejecutar Cierre de Caja (Cuadre de Valores) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  -- Buscamos la caja abierta para la sede 1
  SELECT MAX(CIE_Cierre) INTO V_ID FROM MUE_CIERRE_CAJA WHERE SED_Sede = 1 AND EST_Estado = 1;

  -- Se procesa el cierre con ventas por 1500.00 y gastos por 100.00
  -- Saldo esperado: 500 (ini) + 1500 (ing) - 100 (egr) = 1900.00
  PKG_MUE_CIERRE_CAJA.PR_CIERRE_ACTUALIZAR(
    P_CIE_CIERRE         => V_ID,
    P_SED_SEDE           => 1,
    P_USU_USUARIO        => 1,
    P_CIE_FECHA          => SYSDATE,
    P_CIE_SALDO_INICIAL  => 500.00,
    P_CIE_INGRESOS       => 1500.00,
    P_CIE_EGRESOS        => 100.00,
    P_CIE_SALDO_FINAL    => 1900.00,
    P_CIE_DIFERENCIA     => 0,
    P_CIE_OBSERVACIONES  => 'Cierre de turno sin novedades',
    P_EST_ESTADO         => 2, 
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('CIERRE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener reporte de cierre específico ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID_C NUMBER;
  V_ID   NUMBER; V_FEC DATE; V_INI NUMBER; V_ING NUMBER; V_EGR NUMBER; V_FIN NUMBER; V_EST NUMBER;
BEGIN
  SELECT MAX(CIE_Cierre) INTO V_ID_C FROM MUE_CIERRE_CAJA WHERE SED_Sede = 1;

  PKG_MUE_CIERRE_CAJA.PR_CIERRE_OBTENER(
    P_CIE_CIERRE => V_ID_C,
    O_CURSOR     => V_CUR,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  
  FETCH V_CUR INTO V_ID, V_FEC, V_INI, V_ING, V_EGR, V_FIN, V_EST;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' FECHA=' || V_FEC || ' SALDO_FINAL=' || V_FIN);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Listar cierres por Sede ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_FEC  DATE; V_FIN NUMBER; V_OBS VARCHAR2(200);
BEGIN
  PKG_MUE_CIERRE_CAJA.PR_CIERRE_LISTAR(
    P_SED_SEDE => 1,
    O_CURSOR   => V_CUR,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  
  DBMS_OUTPUT.PUT_LINE('HISTORIAL DE CIERRES SEDE 1:');
  LOOP
    FETCH V_CUR INTO V_FEC, V_FIN, V_OBS; 
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  [' || V_FEC || '] Total: ' || V_FIN || ' | Obs: ' || V_OBS);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 5) Eliminar registro de cierre (Solo QA) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CIE_Cierre) INTO V_ID FROM MUE_CIERRE_CAJA WHERE SED_Sede = 1;

  PKG_MUE_CIERRE_CAJA.PR_CIERRE_ELIMINAR(
    P_CIE_CIERRE => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Estado de cierres) ===
SELECT CIE_Fecha, CIE_Saldo_Inicial, CIE_Saldo_Final, EST_Estado 
FROM MUE_CIERRE_CAJA 
WHERE SED_Sede = 1;
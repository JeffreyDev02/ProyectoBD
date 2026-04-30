SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar registro de evento (Log de Error) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_EVENTO_APLICACION.PR_EVENTO_INSERTAR(
    P_EVE_TIPO          => 'ERROR',
    P_EVE_DESCRIPCION   => 'Fallo en la sincronización con el servicio de correos',
    P_EVE_MODULO        => 'NOTIFICACIONES',
    P_EVE_FECHA         => SYSTIMESTAMP,
    P_USU_USUARIO       => 1,
    O_EVE_EVENTO        => V_ID,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID_EVENTO=' || V_ID);
END;
/

PROMPT === 2) Obtener detalle de un evento específico ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID_E NUMBER;
  -- Variables para fetch
  V_ID   NUMBER; V_TIP VARCHAR2(20); V_DSC VARCHAR2(500); V_MOD VARCHAR2(50); V_FEC TIMESTAMP;
BEGIN
  SELECT MAX(EVE_Evento) INTO V_ID_E FROM MUE_EVENTO_APLICACION WHERE EVE_Modulo = 'NOTIFICACIONES';

  PKG_MUE_EVENTO_APLICACION.PR_EVENTO_OBTENER(
    P_EVE_EVENTO => V_ID_E,
    O_CURSOR     => V_CUR,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  
  FETCH V_CUR INTO V_ID, V_TIP, V_DSC, V_MOD, V_FEC;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' TIPO=' || V_TIP || ' MODULO=' || V_MOD);
  DBMS_OUTPUT.PUT_LINE('DESC=' || V_DSC);
  CLOSE V_CUR;
END;
/

PROMPT === 3) Listar eventos por tipo (Filtro) ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_FEC  TIMESTAMP; V_MOD VARCHAR2(50); V_DSC VARCHAR2(500);
BEGIN
  PKG_MUE_EVENTO_APLICACION.PR_EVENTO_LISTAR(
    P_EVE_TIPO => 'ERROR',
    O_CURSOR   => V_CUR,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  
  DBMS_OUTPUT.PUT_LINE('LISTADO DE ERRORES REGISTRADOS:');
  LOOP
    FETCH V_CUR INTO V_FEC, V_MOD, V_DSC; 
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  [' || V_FEC || '] Mod: ' || V_MOD || ' | ' || V_DSC);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Eliminar eventos antiguos (Limpieza de logs) ===
DECLARE
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  -- Se asume un procedimiento que limpie por fecha o ID específico
  PKG_MUE_EVENTO_APLICACION.PR_EVENTO_ELIMINAR(
    P_EVE_EVENTO => NULL, 
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LIMPIEZA RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Conteos) ===
SELECT EVE_Tipo, COUNT(*) AS TOTAL 
FROM MUE_EVENTO_APLICACION 
GROUP BY EVE_Tipo;
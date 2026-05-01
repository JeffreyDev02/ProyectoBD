SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Registro de cierre de caja (apertura / inicio) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_CIERRE_CAJA.PR_CIERRE_INSERTAR(
    P_SED_SEDE          => 1,
    P_CCA_FECHA_INICIO  => SYSTIMESTAMP,
    P_CCA_FECHA_FIN     => NULL,
    P_CCA_MONTO_INICIAL => 500.00,
    P_CCA_MONTO_FINAL   => NULL,
    P_ECA_ESTADO        => 1,
    O_CCA_CIERRE        => V_ID,
    O_COD_RET           => V_RET,
    O_MSG                 => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' CCA_Cierre_Caja=' || V_ID);
END;
/

PROMPT === 2) Actualizar cierre (cuadre / cierre formal) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CCA_Cierre_Caja) INTO V_ID FROM MUE_CIERRE_CAJA WHERE SED_Sede = 1 AND ECA_Estado = 1;

  PKG_MUE_CIERRE_CAJA.PR_CIERRE_ACTUALIZAR(
    P_CCA_CIERRE        => V_ID,
    P_SED_SEDE          => 1,
    P_CCA_FECHA_INICIO  => SYSTIMESTAMP,
    P_CCA_FECHA_FIN     => SYSTIMESTAMP,
    P_CCA_MONTO_INICIAL => 500.00,
    P_CCA_MONTO_FINAL   => 1900.00,
    P_ECA_ESTADO        => 2,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('ACTUALIZAR RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener un cierre por PK ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID_C NUMBER;
  V_PK   NUMBER;
  V_SED  NUMBER;
  V_INI  TIMESTAMP;
  V_FIN  TIMESTAMP;
  V_MI   NUMBER;
  V_MF   NUMBER;
  V_EST  NUMBER;
  V_CA   TIMESTAMP;
BEGIN
  SELECT MAX(CCA_Cierre_Caja) INTO V_ID_C FROM MUE_CIERRE_CAJA WHERE SED_Sede = 1;

  PKG_MUE_CIERRE_CAJA.PR_CIERRE_OBTENER(
    P_CCA_CIERRE => V_ID_C,
    O_CURSOR     => V_CUR,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );

  FETCH V_CUR INTO V_PK, V_SED, V_INI, V_FIN, V_MI, V_MF, V_EST, V_CA;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' PK=' || V_PK || ' MONTO_FINAL=' || V_MF);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Listar cierres por sede ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_PK   NUMBER;
  V_SED  NUMBER;
  V_INI  TIMESTAMP;
  V_FIN  TIMESTAMP;
  V_MI   NUMBER;
  V_MF   NUMBER;
  V_EST  NUMBER;
  V_CA   TIMESTAMP;
BEGIN
  PKG_MUE_CIERRE_CAJA.PR_CIERRE_LISTAR(
    P_SED_SEDE => 1,
    O_CURSOR   => V_CUR,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );

  DBMS_OUTPUT.PUT_LINE('LISTADO SEDE 1:');
  LOOP
    FETCH V_CUR INTO V_PK, V_SED, V_INI, V_FIN, V_MI, V_MF, V_EST, V_CA;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  PK=' || V_PK || ' INI=' || V_INI || ' MF=' || V_MF || ' EST=' || V_EST);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 5) Eliminar último cierre (solo QA) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CCA_Cierre_Caja) INTO V_ID FROM MUE_CIERRE_CAJA WHERE SED_Sede = 1;

  PKG_MUE_CIERRE_CAJA.PR_CIERRE_ELIMINAR(
    P_CCA_CIERRE => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación (columnas según DDL) ===
SELECT CCA_Cierre_Caja,
       SED_Sede,
       CCA_Fecha_Inicio,
       CCA_Fecha_Fin,
       CCA_Monto_Inicial,
       CCA_Monto_Final,
       ECA_Estado
  FROM MUE_CIERRE_CAJA
 WHERE SED_Sede = 1;

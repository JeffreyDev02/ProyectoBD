SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar nueva cuenta bancaria ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_CUENTA.PR_CUENTA_INSERTAR(
    P_BAN_BANCO        => 1,
    P_TDC_TIPO_CUENTA  => 1,
    P_CUE_NUMERO       => '001-998877-05',
    P_CUE_NOMBRE       => 'Cuenta Principal Operativa',
    P_CUE_ACTIVA       => 1,
    O_CUE_CUENTA       => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Caso Negativo: Número de cuenta duplicado ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_CUENTA.PR_CUENTA_INSERTAR(
    P_BAN_BANCO        => 1,
    P_TDC_TIPO_CUENTA  => 1,
    P_CUE_NUMERO       => '001-998877-05', 
    P_CUE_NOMBRE       => 'Cuenta Espejo Error',
    P_CUE_ACTIVA       => 1,
    O_CUE_CUENTA       => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Obtener detalle de la cuenta ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_ID_C NUMBER; V_BAN NUMBER; V_NUM VARCHAR2(50); V_NOM VARCHAR2(100); V_ACT NUMBER;
BEGIN
  SELECT MAX(CUE_Cuenta) INTO V_ID FROM MUE_CUENTA WHERE CUE_Numero = '001-998877-05';

  PKG_MUE_CUENTA.PR_CUENTA_OBTENER(
    P_CUE_CUENTA => V_ID,
    O_CURSOR     => V_CUR,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_C, V_BAN, V_NUM, V_NOM, V_ACT;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' CUENTA=' || V_NUM || ' NOMBRE=' || V_NOM);
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar nombre y estado de la cuenta ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CUE_Cuenta) INTO V_ID FROM MUE_CUENTA WHERE CUE_Numero = '001-998877-05';

  PKG_MUE_CUENTA.PR_CUENTA_ACTUALIZAR(
    P_CUE_CUENTA       => V_ID,
    P_BAN_BANCO        => 1,
    P_TDC_TIPO_CUENTA  => 1,
    P_CUE_NUMERO       => '001-998877-05',
    P_CUE_NOMBRE       => 'Cuenta Operativa - Nodo Central',
    P_CUE_ACTIVA       => 0,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Eliminar cuenta bancaria de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CUE_Cuenta) INTO V_ID FROM MUE_CUENTA WHERE CUE_Numero = '001-998877-05';

  PKG_MUE_CUENTA.PR_CUENTA_ELIMINAR(
    P_CUE_CUENTA => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_CUENTA WHERE CUE_Numero = '001-998877-05';
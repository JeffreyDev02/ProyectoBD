SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar primer precio activo ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PRECIO.PR_PRECIO_INSERTAR(
    P_PRO_PRODUCTO   => 1,
    P_PRE_VALOR      => 1500.00,
    P_PRE_FECHA_INI  => SYSDATE,
    P_PRE_FECHA_FIN  => SYSDATE + 30,
    P_PRE_ACTIVO     => 1,
    O_PRE_PRECIO     => V_ID,
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Caso Negativo: Fecha Inicio mayor a Fin ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PRECIO.PR_PRECIO_INSERTAR(
    P_PRO_PRODUCTO   => 1,
    P_PRE_VALOR      => 2000.00,
    P_PRE_FECHA_INI  => SYSDATE + 10,
    P_PRE_FECHA_FIN  => SYSDATE + 5,
    P_PRE_ACTIVO     => 1,
    O_PRE_PRECIO     => V_ID,
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 3) Validar Unicidad: Insertar nuevo precio activo ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
  V_ACT NUMBER;
BEGIN
  PKG_MUE_PRECIO.PR_PRECIO_INSERTAR(
    P_PRO_PRODUCTO   => 1,
    P_PRE_VALOR      => 1800.00,
    P_PRE_FECHA_INI  => SYSDATE + 31,
    P_PRE_FECHA_FIN  => SYSDATE + 60,
    P_PRE_ACTIVO     => 1,
    O_PRE_PRECIO     => V_ID,
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  
  SELECT COUNT(1) INTO V_ACT FROM MUE_PRECIO WHERE PRO_Producto = 1 AND PRE_Activo = 1;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' PRECIOS_ACTIVOS_TOTAL=' || V_ACT);
END;
/

PROMPT === 4) Obtener precio actual del producto ===
DECLARE
  V_CUR   SYS_REFCURSOR;
  V_RET   NUMBER;
  V_MSG   VARCHAR2(4000);
  V_ID_P  NUMBER; V_PRO NUMBER; V_VAL NUMBER; V_INI DATE; V_FIN DATE; V_ACT NUMBER;
BEGIN
  PKG_MUE_PRECIO.PR_PRECIO_OBTENER(
    P_PRO_PRODUCTO => 1,
    O_CURSOR       => V_CUR,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  
  FETCH V_CUR INTO V_ID_P, V_PRO, V_VAL, V_INI, V_FIN, V_ACT;
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' VALOR=' || V_VAL || ' ESTADO=' || V_ACT);
  CLOSE V_CUR;
END;
/

PROMPT === 5) Actualizar precio existente ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRE_Precio) INTO V_ID FROM MUE_PRECIO WHERE PRO_Producto = 1;

  PKG_MUE_PRECIO.PR_PRECIO_ACTUALIZAR(
    P_PRE_PRECIO     => V_ID,
    P_PRO_PRODUCTO   => 1,
    P_PRE_VALOR      => 1950.00,
    P_PRE_FECHA_INI  => SYSDATE + 31,
    P_PRE_FECHA_FIN  => SYSDATE + 90,
    P_PRE_ACTIVO     => 1,
    O_COD_RET        => V_RET,
    O_MSG            => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Eliminar precio ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRE_Precio) INTO V_ID FROM MUE_PRECIO WHERE PRO_Producto = 1;

  PKG_MUE_PRECIO.PR_PRECIO_ELIMINAR(
    P_PRE_PRECIO => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificacion final (Registros de prueba) ===
SELECT PRE_Precio, PRO_Producto, PRE_Valor, PRE_Activo 
FROM MUE_PRECIO 
WHERE PRO_Producto = 1;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === 1) Insertar producto de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PRODUCTO.PR_PRODUCTO_INSERTAR(
    P_CAT_CATEGORIA     => 1,
    P_PRO_NOMBRE        => 'Comedor Minimalista QA',
    P_PRO_DESCRIPCION   => 'Mesa de madera con 6 sillas gris',
    P_PRO_PRECIO_VENTA  => 4500.00,
    P_PRO_STOCK         => 15,
    P_PRO_MARCA         => 'Muebles Pro',
    P_PRO_MODELO        => 'MIN-2026',
    P_PRO_MATERIAL      => 'Madera/Tela',
    P_PRO_COLOR         => 'Gris/Roble',
    P_PRO_PESO          => 85,
    P_PRO_CODIGO_BARRA  => '740123456789',
    O_PRO_PRODUCTO      => V_ID,
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 2) Obtener producto por ID ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER;
  V_NOM  VARCHAR2(100); V_PRE NUMBER; V_STK NUMBER; V_MAR VARCHAR2(50);
BEGIN
  SELECT MAX(PRO_Producto) INTO V_ID FROM MUE_PRODUCTO WHERE PRO_Nombre = 'Comedor Minimalista QA';

  PKG_MUE_PRODUCTO.PR_PRODUCTO_OBTENER(
    P_PRO_PRODUCTO => V_ID,
    O_CURSOR       => V_CUR,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  

  FETCH V_CUR INTO V_ID, V_NOM, V_PRE, V_STK; 
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' PRODUCTO=' || V_NOM || ' PRECIO=' || V_PRE);
  CLOSE V_CUR;
END;
/

PROMPT === 3) Actualizar información del producto ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRO_Producto) INTO V_ID FROM MUE_PRODUCTO WHERE PRO_Nombre = 'Comedor Minimalista QA';

  PKG_MUE_PRODUCTO.PR_PRODUCTO_ACTUALIZAR(
    P_PRO_PRODUCTO      => V_ID,
    P_CAT_CATEGORIA     => 1,
    P_PRO_NOMBRE        => 'Comedor Minimalista QA (Editado)',
    P_PRO_DESCRIPCION   => 'Mesa de madera con 4 sillas',
    P_PRO_PRECIO_VENTA  => 3800.00,
    P_PRO_STOCK         => 10,
    P_PRO_MARCA         => 'Muebles Pro',
    P_PRO_MODELO        => 'MIN-V2',
    P_PRO_MATERIAL      => 'Madera',
    P_PRO_COLOR         => 'Negro',
    P_PRO_PESO          => 70,
    P_PRO_CODIGO_BARRA  => '740123456789',
    O_COD_RET           => V_RET,
    O_MSG               => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 4) Cargar Foto (Prueba de BLOB) ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
  V_BLOB BLOB;
BEGIN
  SELECT MAX(PRO_Producto) INTO V_ID FROM MUE_PRODUCTO WHERE PRO_Nombre LIKE 'Comedor Minimalista%';
  

  DBMS_LOB.CREATETEMPORARY(V_BLOB, FALSE);

  PKG_MUE_PRODUCTO.PR_PRODUCTO_ACTUALIZAR_FOTO(
    P_PRO_PRODUCTO => V_ID,
    P_PRO_FOTO     => V_BLOB,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('FOTO RET=' || V_RET || ' MSG=' || V_MSG);
  
  DBMS_LOB.FREETEMPORARY(V_BLOB);
END;
/

PROMPT === 5) Listar productos activos ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_ID   NUMBER; V_NOM VARCHAR2(100);
BEGIN
  PKG_MUE_PRODUCTO.PR_PRODUCTO_LISTAR(
    O_CURSOR  => V_CUR,
    O_COD_RET => V_RET,
    O_MSG     => V_MSG
  );
  
  LOOP
    FETCH V_CUR INTO V_ID, V_NOM; 
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  - ID: ' || V_ID || ' Nombre: ' || V_NOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 6) Eliminar producto de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRO_Producto) INTO V_ID FROM MUE_PRODUCTO WHERE PRO_Nombre LIKE 'Comedor Minimalista%';

  PKG_MUE_PRODUCTO.PR_PRODUCTO_ELIMINAR(
    P_PRO_PRODUCTO => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === Verificación final (Debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_PRODUCTO WHERE PRO_Nombre LIKE 'Comedor Minimalista%';
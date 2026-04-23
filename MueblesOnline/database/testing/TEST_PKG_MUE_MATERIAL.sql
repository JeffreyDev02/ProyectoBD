-- =============================================================================
-- Pruebas manuales — PKG_MUE_MATERIAL
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar material de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_MATERIAL.PR_MATERIAL_INSERTAR(
    P_MAT_NOMBRE      => 'Madera QA',
    P_MAT_PRECIO      => 150.00,
    P_MAT_DESCRIPCION => 'Material de prueba',
    P_MAT_STOCK_TOTAL => 100,
    O_MAT_MATERIAL    => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener material insertado ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(20);
  V_PRE  NUMBER;
  V_DESC VARCHAR2(40);
  V_STK  NUMBER;
  V_CAT  TIMESTAMP(6);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(MAT_Material) INTO V_ID FROM MUE_MATERIAL WHERE MAT_Nombre = 'Madera QA';

  PKG_MUE_MATERIAL.PR_MATERIAL_OBTENER(
    P_MAT_MATERIAL    => V_ID,
    O_MAT_NOMBRE      => V_NOM,
    O_MAT_PRECIO      => V_PRE,
    O_MAT_DESCRIPCION => V_DESC,
    O_MAT_STOCK_TOTAL => V_STK,
    O_MAT_CREATED_AT  => V_CAT,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' PRECIO=' || V_PRE || ' STOCK=' || V_STK);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_MID  NUMBER;
  V_NOM  VARCHAR2(20);
  V_PRE  NUMBER;
  V_DESC VARCHAR2(40);
  V_STK  NUMBER;
  V_CAT  TIMESTAMP(6);
BEGIN
  PKG_MUE_MATERIAL.PR_MATERIAL_LISTAR(
    P_FILTRO_NOMBRE => 'Madera',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_MID, V_NOM, V_PRE, V_DESC, V_STK, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_MID || ' ' || V_NOM || ' Precio=' || V_PRE);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MAT_Material) INTO V_ID FROM MUE_MATERIAL WHERE MAT_Nombre = 'Madera QA';

  PKG_MUE_MATERIAL.PR_MATERIAL_ACTUALIZAR(
    P_MAT_MATERIAL    => V_ID,
    P_MAT_NOMBRE      => 'Madera QA (mod)',
    P_MAT_PRECIO      => 175.50,
    P_MAT_DESCRIPCION => 'Descripción actualizada',
    P_MAT_STOCK_TOTAL => 120,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT MAT_Material, MAT_Nombre, MAT_Precio, MAT_Stock_Total
  FROM MUE_MATERIAL
 WHERE MAT_Nombre LIKE 'Madera QA%'
 ORDER BY MAT_Material;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_MATERIAL.PR_MATERIAL_INSERTAR(
    P_MAT_NOMBRE      => '   ',
    P_MAT_PRECIO      => NULL,
    P_MAT_DESCRIPCION => NULL,
    P_MAT_STOCK_TOTAL => NULL,
    O_MAT_MATERIAL    => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar material de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(MAT_Material) INTO V_ID FROM MUE_MATERIAL WHERE MAT_Nombre LIKE 'Madera QA%';

  PKG_MUE_MATERIAL.PR_MATERIAL_ELIMINAR(
    P_MAT_MATERIAL => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_MATERIAL WHERE MAT_Nombre LIKE 'Madera QA%';
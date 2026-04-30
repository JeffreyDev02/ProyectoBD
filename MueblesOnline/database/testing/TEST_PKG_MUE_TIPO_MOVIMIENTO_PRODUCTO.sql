-- =============================================================================
-- Pruebas manuales — PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar tipo de movimiento producto de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO.PR_TIPO_MOV_PRO_INSERTAR(
    P_TMP_TIPO        => 'SALIDA QA',
    P_TMP_DESCRIPCION => 'Movimiento de prueba de salida de producto',
    O_TMP_TIPO_MOV    => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener tipo de movimiento insertado ===
DECLARE
  V_ID   NUMBER;
  V_TIPO VARCHAR2(40);
  V_DESC VARCHAR2(100);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(TMP_Tipo_Movimiento_Producto) INTO V_ID
    FROM MUE_TIPO_MOVIMIENTO_PRODUCTO WHERE TMP_Tipo = 'SALIDA QA';

  PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO.PR_TIPO_MOV_PRO_OBTENER(
    P_TMP_TIPO_MOV    => V_ID,
    O_TMP_TIPO        => V_TIPO,
    O_TMP_DESCRIPCION => V_DESC,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' TIPO=' || V_TIPO || ' DESC=' || V_DESC);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_TID  NUMBER;
  V_TIPO VARCHAR2(40);
  V_DESC VARCHAR2(100);
BEGIN
  PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO.PR_TIPO_MOV_PRO_LISTAR(
    P_FILTRO_TIPO => 'SALIDA',
    O_CURSOR      => V_CUR,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_TID, V_TIPO, V_DESC;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_TID || ' ' || V_TIPO);
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
  SELECT MAX(TMP_Tipo_Movimiento_Producto) INTO V_ID
    FROM MUE_TIPO_MOVIMIENTO_PRODUCTO WHERE TMP_Tipo = 'SALIDA QA';

  PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO.PR_TIPO_MOV_PRO_ACTUALIZAR(
    P_TMP_TIPO_MOV    => V_ID,
    P_TMP_TIPO        => 'SALIDA QA (mod)',
    P_TMP_DESCRIPCION => 'Descripción actualizada',
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT TMP_Tipo_Movimiento_Producto, TMP_Tipo, TMP_Descripcion
  FROM MUE_TIPO_MOVIMIENTO_PRODUCTO
 WHERE TMP_Tipo LIKE 'SALIDA QA%'
 ORDER BY TMP_Tipo_Movimiento_Producto;

PROMPT === 6) Caso negativo: tipo vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO.PR_TIPO_MOV_PRO_INSERTAR(
    P_TMP_TIPO        => '   ',
    P_TMP_DESCRIPCION => NULL,
    O_TMP_TIPO_MOV    => V_ID,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar tipo de movimiento de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(TMP_Tipo_Movimiento_Producto) INTO V_ID
    FROM MUE_TIPO_MOVIMIENTO_PRODUCTO WHERE TMP_Tipo LIKE 'SALIDA QA%';

  PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO.PR_TIPO_MOV_PRO_ELIMINAR(
    P_TMP_TIPO_MOV => V_ID,
    O_COD_RET      => V_RET,
    O_MSG          => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_TIPO_MOVIMIENTO_PRODUCTO WHERE TMP_Tipo LIKE 'SALIDA QA%';
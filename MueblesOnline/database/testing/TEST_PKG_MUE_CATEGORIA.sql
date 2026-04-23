-- =============================================================================
-- Pruebas manuales — PKG_MUE_CATEGORIA
-- =============================================================================
-- Pruebas manuales — PKG_MUE_CATEGORIA
-- =============================================================================
-- Pruebas manuales — PKG_MUE_CATEGORIA
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar categoría ===
DECLARE V_ID NUMBER; V_RET NUMBER; V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_CATEGORIA.PR_CATEGORIA_INSERTAR('Tipo QA', 'Categoría QA', V_ID, V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG); END IF;
END;
/

PROMPT === 2) Obtener categoría ===
DECLARE V_ID NUMBER; V_TIPO VARCHAR2(20); V_NOM VARCHAR2(20); V_RET NUMBER; V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CAT_Categoria) INTO V_ID FROM MUE_CATEGORIA WHERE CAT_Tipo = 'Tipo QA';
  PKG_MUE_CATEGORIA.PR_CATEGORIA_OBTENER(V_ID, V_TIPO, V_NOM, V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' TIPO=' || V_TIPO || ' NOM=' || V_NOM);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE V_CUR SYS_REFCURSOR; V_RET NUMBER; V_MSG VARCHAR2(4000); V_ID NUMBER; V_TIPO VARCHAR2(20); V_NOM VARCHAR2(20);
BEGIN
  PKG_MUE_CATEGORIA.PR_CATEGORIA_LISTAR('QA', V_CUR, V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP FETCH V_CUR INTO V_ID, V_TIPO, V_NOM; EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  ID=' || V_ID || ' TIPO=' || V_TIPO || ' NOM=' || V_NOM);
  END LOOP; CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar categoría ===
DECLARE V_ID NUMBER; V_RET NUMBER; V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CAT_Categoria) INTO V_ID FROM MUE_CATEGORIA WHERE CAT_Tipo = 'Tipo QA';
  PKG_MUE_CATEGORIA.PR_CATEGORIA_ACTUALIZAR(V_ID, 'Tipo QA mod', 'Cat mod', V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa ===
SELECT CAT_Categoria, CAT_Tipo, CAT_Nombre FROM MUE_CATEGORIA WHERE CAT_Tipo LIKE 'Tipo QA%';

PROMPT === 6) Caso negativo: tipo vacío ===
DECLARE V_ID NUMBER; V_RET NUMBER; V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_CATEGORIA.PR_CATEGORIA_INSERTAR('  ', 'Sin tipo', V_ID, V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: ID inexistente ===
DECLARE V_RET NUMBER; V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_CATEGORIA.PR_CATEGORIA_ELIMINAR(-999, V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Eliminar categoría ===
DECLARE V_ID NUMBER; V_RET NUMBER; V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(CAT_Categoria) INTO V_ID FROM MUE_CATEGORIA WHERE CAT_Tipo LIKE 'Tipo QA%';
  PKG_MUE_CATEGORIA.PR_CATEGORIA_ELIMINAR(V_ID, V_RET, V_MSG);
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_CATEGORIA WHERE CAT_Tipo LIKE 'Tipo QA%';
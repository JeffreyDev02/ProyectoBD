-- =============================================================================
-- Pruebas manuales — PKG_MUE_ALMACEN
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar almacén de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_ALMACEN.PR_ALMACEN_INSERTAR(
    P_ALM_ZONA         => '12',
    P_ALM_MUNICIPIO    => 'Guatemala',
    P_ALM_DEPARTAMENTO => 'Guatemala',
    O_ALM_ALMACEN      => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener almacén insertado ===
DECLARE
  V_ID   NUMBER;
  V_ZONA VARCHAR2(20);
  V_MUN  VARCHAR2(30);
  V_DEP  VARCHAR2(40);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(ALM_Almacen) INTO V_ID FROM MUE_ALMACEN WHERE ALM_Zona = '12' AND ALM_Municipio = 'Guatemala';

  PKG_MUE_ALMACEN.PR_ALMACEN_OBTENER(
    P_ALM_ALMACEN      => V_ID,
    O_ALM_ZONA         => V_ZONA,
    O_ALM_MUNICIPIO    => V_MUN,
    O_ALM_DEPARTAMENTO => V_DEP,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' ZONA=' || V_ZONA || ' MUN=' || V_MUN || ' DEP=' || V_DEP);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_AID  NUMBER;
  V_ZONA VARCHAR2(20);
  V_MUN  VARCHAR2(30);
  V_DEP  VARCHAR2(40);
BEGIN
  PKG_MUE_ALMACEN.PR_ALMACEN_LISTAR(
    P_FILTRO_MUNICIPIO => 'Guatemala',
    O_CURSOR           => V_CUR,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_AID, V_ZONA, V_MUN, V_DEP;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_AID || ' Zona=' || V_ZONA || ' Mun=' || V_MUN);
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
  SELECT MAX(ALM_Almacen) INTO V_ID FROM MUE_ALMACEN WHERE ALM_Zona = '12' AND ALM_Municipio = 'Guatemala';

  PKG_MUE_ALMACEN.PR_ALMACEN_ACTUALIZAR(
    P_ALM_ALMACEN      => V_ID,
    P_ALM_ZONA         => '12',
    P_ALM_MUNICIPIO    => 'Mixco',
    P_ALM_DEPARTAMENTO => 'Guatemala',
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT ALM_Almacen, ALM_Zona, ALM_Municipio, ALM_Departamento
  FROM MUE_ALMACEN
 WHERE ALM_Zona = '12'
 ORDER BY ALM_Almacen DESC
 FETCH FIRST 3 ROWS ONLY;

PROMPT === 6) Caso negativo: ID inexistente ===
DECLARE
  V_ZONA VARCHAR2(20);
  V_MUN  VARCHAR2(30);
  V_DEP  VARCHAR2(40);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  PKG_MUE_ALMACEN.PR_ALMACEN_OBTENER(
    P_ALM_ALMACEN      => 99999,
    O_ALM_ZONA         => V_ZONA,
    O_ALM_MUNICIPIO    => V_MUN,
    O_ALM_DEPARTAMENTO => V_DEP,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar almacén de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ALM_Almacen) INTO V_ID FROM MUE_ALMACEN WHERE ALM_Zona = '12' AND ALM_Municipio = 'Mixco';

  PKG_MUE_ALMACEN.PR_ALMACEN_ELIMINAR(
    P_ALM_ALMACEN => V_ID,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_ALMACEN WHERE ALM_Zona = '12' AND ALM_Municipio = 'Mixco';
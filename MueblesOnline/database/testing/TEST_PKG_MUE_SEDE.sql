-- =============================================================================
-- Pruebas manuales — PKG_MUE_SEDE (Docs/EJEMPLO_PKG_MUE_SEDE.sql)
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar sede de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_SEDE.PR_SEDE_INSERTAR(
    P_SED_NOMBRE       => 'Sede Prueba QA',
    P_SED_MUNICIPIO    => 'Guatemala',
    P_SED_DEPARTAMENTO => 'Guatemala',
    P_SED_PAIS         => 'Guatemala',
    P_SED_DIRECCION    => 'Zona 1',
    O_SED_SEDE         => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener última sede insertada (ajustar ID si ejecutas varias veces) ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(50);
  V_MUN  VARCHAR2(40);
  V_DEP  VARCHAR2(40);
  V_PAIS VARCHAR2(40);
  V_DIR  VARCHAR2(50);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(SED_Sede) INTO V_ID FROM MUE_SEDE WHERE SED_Nombre = 'Sede Prueba QA';

  PKG_MUE_SEDE.PR_SEDE_OBTENER(
    P_SED_SEDE         => V_ID,
    O_SED_NOMBRE       => V_NOM,
    O_SED_MUNICIPIO    => V_MUN,
    O_SED_DEPARTAMENTO => V_DEP,
    O_SED_PAIS         => V_PAIS,
    O_SED_DIRECCION    => V_DIR,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' DIR=' || V_DIR);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR SYS_REFCURSOR;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
  V_SID NUMBER;
  V_NOM VARCHAR2(50);
  V_MUN VARCHAR2(40);
  V_DEP VARCHAR2(40);
  V_PAIS VARCHAR2(40);
  V_DIR VARCHAR2(50);
BEGIN
  PKG_MUE_SEDE.PR_SEDE_LISTAR(
    P_FILTRO_NOMBRE => 'Prueba',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_SID, V_NOM, V_MUN, V_DEP, V_PAIS, V_DIR;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_SID || ' ' || V_NOM);
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
  SELECT MAX(SED_Sede) INTO V_ID FROM MUE_SEDE WHERE SED_Nombre = 'Sede Prueba QA';

  PKG_MUE_SEDE.PR_SEDE_ACTUALIZAR(
    P_SED_SEDE         => V_ID,
    P_SED_NOMBRE       => 'Sede Prueba QA (mod)',
    P_SED_MUNICIPIO    => 'Guatemala',
    P_SED_DEPARTAMENTO => 'Guatemala',
    P_SED_PAIS         => 'Guatemala',
    P_SED_DIRECCION    => 'Zona 10',
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT SED_Sede, SED_Nombre, SED_Direccion
  FROM MUE_SEDE
 WHERE SED_Nombre LIKE 'Sede Prueba QA%'
 ORDER BY SED_Sede;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_SEDE.PR_SEDE_INSERTAR(
    P_SED_NOMBRE       => '   ',
    P_SED_MUNICIPIO    => 'X',
    P_SED_DEPARTAMENTO => 'X',
    P_SED_PAIS         => 'X',
    P_SED_DIRECCION    => NULL,
    O_SED_SEDE         => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Eliminar sede de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(SED_Sede) INTO V_ID FROM MUE_SEDE WHERE SED_Nombre LIKE 'Sede Prueba QA%';

  PKG_MUE_SEDE.PR_SEDE_ELIMINAR(
    P_SED_SEDE => V_ID,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con nombre de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_SEDE WHERE SED_Nombre LIKE 'Sede Prueba QA%';

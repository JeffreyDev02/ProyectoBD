-- =============================================================================
-- Pruebas manuales — PKG_MUE_DEPARTAMENTO
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- IMPORTANTE: requiere al menos un MUE_AREA existente.
--             Si aún no hay datos, ejecutar primero TEST_PKG_MUE_AREA.sql
--             y no limpiar el área de prueba, o usar un área real.
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 0) Preparar: insertar área de apoyo para las pruebas ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_AREA.PR_AREA_INSERTAR(
    P_ARE_AREA_FUNCIONAL => 'Área Soporte Depto QA',
    P_ARE_DESCRIPCION    => 'Área temporal para pruebas de departamento',
    O_ARE_AREA           => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('AREA RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 1) Insertar departamento de prueba ===
DECLARE
  V_ID_AREA NUMBER;
  V_ID_DEP  NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID_AREA FROM MUE_AREA WHERE ARE_Area_Funcional = 'Área Soporte Depto QA';

  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_INSERTAR(
    P_DEP_NOMBRE       => 'Depto Prueba QA',
    P_DEP_DESCRIPCION  => 'Departamento creado para pruebas de calidad',
    P_ARE_AREA         => V_ID_AREA,
    O_DEP_DEPARTAMENTO => V_ID_DEP,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID_DEP);
  IF V_RET <> 0 OR V_ID_DEP IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener el departamento recién insertado ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_CAT  TIMESTAMP;
  V_AREA NUMBER;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(DEP_Departamento) INTO V_ID FROM MUE_DEPARTAMENTO WHERE DEP_Nombre = 'Depto Prueba QA';

  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_OBTENER(
    P_DEP_DEPARTAMENTO => V_ID,
    O_DEP_NOMBRE       => V_NOM,
    O_DEP_DESCRIPCION  => V_DESC,
    O_DEP_CREATED_AT   => V_CAT,
    O_ARE_AREA         => V_AREA,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' AREA=' || V_AREA);
END;
/

PROMPT === 3) Listar con filtro por nombre ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_DID  NUMBER;
  V_NOM  VARCHAR2(50);
  V_DESC VARCHAR2(200);
  V_AID  NUMBER;
  V_AFUN VARCHAR2(50);
  V_CAT  TIMESTAMP;
BEGIN
  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_LISTAR(
    P_FILTRO_NOMBRE => 'Prueba',
    P_ARE_AREA      => NULL,
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_DID, V_NOM, V_DESC, V_AID, V_AFUN, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_DID || ' NOM=' || V_NOM || ' AREA=' || V_AFUN);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar departamento ===
DECLARE
  V_ID_AREA NUMBER;
  V_ID_DEP  NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID_AREA FROM MUE_AREA WHERE ARE_Area_Funcional = 'Área Soporte Depto QA';
  SELECT MAX(DEP_Departamento) INTO V_ID_DEP FROM MUE_DEPARTAMENTO WHERE DEP_Nombre = 'Depto Prueba QA';

  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_ACTUALIZAR(
    P_DEP_DEPARTAMENTO => V_ID_DEP,
    P_DEP_NOMBRE       => 'Depto Prueba QA (mod)',
    P_DEP_DESCRIPCION  => 'Descripción actualizada en prueba',
    P_ARE_AREA         => V_ID_AREA,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT D.DEP_Departamento, D.DEP_Nombre, D.DEP_Descripcion, A.ARE_Area_Funcional
  FROM MUE_DEPARTAMENTO D
  JOIN MUE_AREA A ON A.ARE_Area = D.ARE_Area
 WHERE D.DEP_Nombre LIKE 'Depto Prueba QA%'
 ORDER BY D.DEP_Departamento;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID_AREA NUMBER;
  V_ID_DEP  NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID_AREA FROM MUE_AREA WHERE ARE_Area_Funcional = 'Área Soporte Depto QA';

  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_INSERTAR(
    P_DEP_NOMBRE       => '   ',
    P_DEP_DESCRIPCION  => 'No debería insertarse',
    P_ARE_AREA         => V_ID_AREA,
    O_DEP_DEPARTAMENTO => V_ID_DEP,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: área inexistente ===
DECLARE
  V_ID_DEP NUMBER;
  V_RET    NUMBER;
  V_MSG    VARCHAR2(4000);
BEGIN
  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_INSERTAR(
    P_DEP_NOMBRE       => 'Depto Area Invalida',
    P_DEP_DESCRIPCION  => 'No debería insertarse',
    P_ARE_AREA         => -999,
    O_DEP_DEPARTAMENTO => V_ID_DEP,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Eliminar departamento de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(DEP_Departamento) INTO V_ID FROM MUE_DEPARTAMENTO WHERE DEP_Nombre LIKE 'Depto Prueba QA%';

  PKG_MUE_DEPARTAMENTO.PR_DEPARTAMENTO_ELIMINAR(
    P_DEP_DEPARTAMENTO => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 9) Limpiar área de apoyo ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(ARE_Area) INTO V_ID FROM MUE_AREA WHERE ARE_Area_Funcional = 'Área Soporte Depto QA';

  PKG_MUE_AREA.PR_AREA_ELIMINAR(
    P_ARE_AREA => V_ID,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('AREA DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_DEPARTAMENTO WHERE DEP_Nombre LIKE 'Depto Prueba QA%';
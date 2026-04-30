-- =============================================================================
-- Pruebas manuales — PKG_MUE_BODEGA
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- IMPORTANTE: requiere PKG_MUE_SEDE compilado y al menos una sede existente.
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 0) Preparar: insertar sede de apoyo para las pruebas ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_SEDE.PR_SEDE_INSERTAR(
    P_SED_NOMBRE       => 'Sede Soporte Bodega QA',
    P_SED_MUNICIPIO    => 'Guatemala',
    P_SED_DEPARTAMENTO => 'Guatemala',
    P_SED_PAIS         => 'Guatemala',
    P_SED_DIRECCION    => 'Zona 1',
    O_SED_SEDE         => V_ID,
    O_COD_RET          => V_RET,
    O_MSG              => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('SEDE RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
END;
/

PROMPT === 1) Insertar bodega de prueba ===
DECLARE
  V_ID_SEDE NUMBER;
  V_ID_BOD  NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(SED_Sede) INTO V_ID_SEDE FROM MUE_SEDE WHERE SED_Nombre = 'Sede Soporte Bodega QA';

  PKG_MUE_BODEGA.PR_BODEGA_INSERTAR(
    P_BOD_NOMBRE         => 'Bodega Prueba QA',
    P_BOD_DESCRIPCION    => 'Bodega creada para pruebas de calidad',
    P_SED_SEDE           => V_ID_SEDE,
    P_BOD_ACTIVA         => 1,
    P_BOD_CODIGO_INTERNO => 'BOD-QA-001',
    O_BOD_BODEGA         => V_ID_BOD,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID_BOD);
  IF V_RET <> 0 OR V_ID_BOD IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener la bodega recién insertada ===
DECLARE
  V_ID   NUMBER;
  V_NOM  VARCHAR2(120);
  V_DESC VARCHAR2(300);
  V_SEDE NUMBER;
  V_ACT  NUMBER;
  V_COD  VARCHAR2(30);
  V_CAT  TIMESTAMP;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(BOD_Bodega) INTO V_ID FROM MUE_BODEGA WHERE BOD_Nombre = 'Bodega Prueba QA';

  PKG_MUE_BODEGA.PR_BODEGA_OBTENER(
    P_BOD_BODEGA         => V_ID,
    O_BOD_NOMBRE         => V_NOM,
    O_BOD_DESCRIPCION    => V_DESC,
    O_SED_SEDE           => V_SEDE,
    O_BOD_ACTIVA         => V_ACT,
    O_BOD_CODIGO_INTERNO => V_COD,
    O_BOD_CREATED_AT     => V_CAT,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NOM=' || V_NOM || ' SEDE=' || V_SEDE || ' ACTIVA=' || V_ACT);
END;
/

PROMPT === 3) Listar con filtro por nombre ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_BID  NUMBER;
  V_NOM  VARCHAR2(120);
  V_DESC VARCHAR2(300);
  V_SID  NUMBER;
  V_SNOM VARCHAR2(50);
  V_ACT  NUMBER;
  V_COD  VARCHAR2(30);
  V_CAT  TIMESTAMP;
BEGIN
  PKG_MUE_BODEGA.PR_BODEGA_LISTAR(
    P_FILTRO_NOMBRE => 'Prueba',
    P_SED_SEDE      => NULL,
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_BID, V_NOM, V_DESC, V_SID, V_SNOM, V_ACT, V_COD, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_BID || ' NOM=' || V_NOM || ' SEDE=' || V_SNOM);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 4) Actualizar bodega ===
DECLARE
  V_ID_SEDE NUMBER;
  V_ID_BOD  NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(SED_Sede) INTO V_ID_SEDE FROM MUE_SEDE WHERE SED_Nombre = 'Sede Soporte Bodega QA';
  SELECT MAX(BOD_Bodega) INTO V_ID_BOD FROM MUE_BODEGA WHERE BOD_Nombre = 'Bodega Prueba QA';

  PKG_MUE_BODEGA.PR_BODEGA_ACTUALIZAR(
    P_BOD_BODEGA         => V_ID_BOD,
    P_BOD_NOMBRE         => 'Bodega Prueba QA (mod)',
    P_BOD_DESCRIPCION    => 'Descripción actualizada en prueba',
    P_SED_SEDE           => V_ID_SEDE,
    P_BOD_ACTIVA         => 0,
    P_BOD_CODIGO_INTERNO => 'BOD-QA-001-MOD',
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT B.BOD_Bodega, B.BOD_Nombre, B.BOD_Activa, S.SED_Nombre
  FROM MUE_BODEGA B
  JOIN MUE_SEDE S ON S.SED_Sede = B.SED_Sede
 WHERE B.BOD_Nombre LIKE 'Bodega Prueba QA%'
 ORDER BY B.BOD_Bodega;

PROMPT === 6) Caso negativo: nombre vacío ===
DECLARE
  V_ID_SEDE NUMBER;
  V_ID_BOD  NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(SED_Sede) INTO V_ID_SEDE FROM MUE_SEDE WHERE SED_Nombre = 'Sede Soporte Bodega QA';

  PKG_MUE_BODEGA.PR_BODEGA_INSERTAR(
    P_BOD_NOMBRE         => '   ',
    P_BOD_DESCRIPCION    => 'No debería insertarse',
    P_SED_SEDE           => V_ID_SEDE,
    P_BOD_ACTIVA         => 1,
    P_BOD_CODIGO_INTERNO => 'BOD-QA-ERR',
    O_BOD_BODEGA         => V_ID_BOD,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: sede inexistente ===
DECLARE
  V_ID_BOD NUMBER;
  V_RET    NUMBER;
  V_MSG    VARCHAR2(4000);
BEGIN
  PKG_MUE_BODEGA.PR_BODEGA_INSERTAR(
    P_BOD_NOMBRE         => 'Bodega Sede Invalida',
    P_BOD_DESCRIPCION    => 'No debería insertarse',
    P_SED_SEDE           => -999,
    P_BOD_ACTIVA         => 1,
    P_BOD_CODIGO_INTERNO => 'BOD-QA-ERR2',
    O_BOD_BODEGA         => V_ID_BOD,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Eliminar bodega de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(BOD_Bodega) INTO V_ID FROM MUE_BODEGA WHERE BOD_Nombre LIKE 'Bodega Prueba QA%';

  PKG_MUE_BODEGA.PR_BODEGA_ELIMINAR(
    P_BOD_BODEGA => V_ID,
    O_COD_RET    => V_RET,
    O_MSG        => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 9) Limpiar sede de apoyo ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(SED_Sede) INTO V_ID FROM MUE_SEDE WHERE SED_Nombre = 'Sede Soporte Bodega QA';

  PKG_MUE_SEDE.PR_SEDE_ELIMINAR(
    P_SED_SEDE => V_ID,
    O_COD_RET  => V_RET,
    O_MSG      => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('SEDE DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_BODEGA WHERE BOD_Nombre LIKE 'Bodega Prueba QA%';
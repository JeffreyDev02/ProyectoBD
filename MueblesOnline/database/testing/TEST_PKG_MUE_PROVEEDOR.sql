-- =============================================================================
-- Pruebas manuales — PKG_MUE_PROVEEDOR
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 1) Insertar proveedor de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_INSERTAR(
    P_PRV_NIT            => '1234567-8',
    P_PRV_NOMBRE_EMPRESA => 'Proveedor QA',
    P_PRV_EMAIL          => 'qa@proveedor.com',
    P_PRV_ZONA           => '9',
    P_PRV_MUNICIPIO      => 'Guatemala',
    P_PRV_DEPARTAMENTO   => 'Guatemala',
    P_PRV_PAIS           => 'Guatemala',
    P_PRV_TELEFONO       => 55551234,
    O_PRV_PROVEEDOR      => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID);
  IF V_RET <> 0 OR V_ID IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo insertar: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Obtener proveedor insertado ===
DECLARE
  V_ID   NUMBER;
  V_NIT  VARCHAR2(20);
  V_NOM  VARCHAR2(30);
  V_EML  VARCHAR2(40);
  V_ZONA VARCHAR2(40);
  V_MUN  VARCHAR2(40);
  V_DEP  VARCHAR2(40);
  V_PAI  VARCHAR2(40);
  V_TEL  NUMBER;
  V_CAT  TIMESTAMP(6);
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
BEGIN
  SELECT MAX(PRV_Proveedor) INTO V_ID FROM MUE_PROVEEDOR WHERE PRV_Nit = '1234567-8';

  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_OBTENER(
    P_PRV_PROVEEDOR      => V_ID,
    O_PRV_NIT            => V_NIT,
    O_PRV_NOMBRE_EMPRESA => V_NOM,
    O_PRV_EMAIL          => V_EML,
    O_PRV_ZONA           => V_ZONA,
    O_PRV_MUNICIPIO      => V_MUN,
    O_PRV_DEPARTAMENTO   => V_DEP,
    O_PRV_PAIS           => V_PAI,
    O_PRV_TELEFONO       => V_TEL,
    O_PRV_CREATED_AT     => V_CAT,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('RET=' || V_RET || ' NIT=' || V_NIT || ' NOM=' || V_NOM || ' TEL=' || V_TEL);
END;
/

PROMPT === 3) Listar con filtro ===
DECLARE
  V_CUR  SYS_REFCURSOR;
  V_RET  NUMBER;
  V_MSG  VARCHAR2(4000);
  V_PID  NUMBER;
  V_NIT  VARCHAR2(20);
  V_NOM  VARCHAR2(30);
  V_EML  VARCHAR2(40);
  V_ZONA VARCHAR2(40);
  V_MUN  VARCHAR2(40);
  V_DEP  VARCHAR2(40);
  V_PAI  VARCHAR2(40);
  V_TEL  NUMBER;
  V_CAT  TIMESTAMP(6);
BEGIN
  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_LISTAR(
    P_FILTRO_NOMBRE => 'Proveedor',
    O_CURSOR        => V_CUR,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_PID, V_NIT, V_NOM, V_EML, V_ZONA, V_MUN, V_DEP, V_PAI, V_TEL, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ID=' || V_PID || ' NIT=' || V_NIT || ' ' || V_NOM);
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
  SELECT MAX(PRV_Proveedor) INTO V_ID FROM MUE_PROVEEDOR WHERE PRV_Nit = '1234567-8';

  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_ACTUALIZAR(
    P_PRV_PROVEEDOR      => V_ID,
    P_PRV_NIT            => '1234567-8',
    P_PRV_NOMBRE_EMPRESA => 'Proveedor QA (mod)',
    P_PRV_EMAIL          => 'mod@proveedor.com',
    P_PRV_ZONA           => '10',
    P_PRV_MUNICIPIO      => 'Mixco',
    P_PRV_DEPARTAMENTO   => 'Guatemala',
    P_PRV_PAIS           => 'Guatemala',
    P_PRV_TELEFONO       => 55559999,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('UPDATE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === 5) Verificación directa (solo testing; no usar en app) ===
SELECT PRV_Proveedor, PRV_Nit, PRV_Nombre_Empresa, PRV_Email
  FROM MUE_PROVEEDOR
 WHERE PRV_Nit = '1234567-8'
 ORDER BY PRV_Proveedor;

PROMPT === 6) Caso negativo: NIT duplicado ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_INSERTAR(
    P_PRV_NIT            => '1234567-8',   -- NIT ya registrado
    P_PRV_NOMBRE_EMPRESA => 'Duplicado QA',
    P_PRV_EMAIL          => 'dup@test.com',
    P_PRV_ZONA           => NULL,
    P_PRV_MUNICIPIO      => NULL,
    P_PRV_DEPARTAMENTO   => NULL,
    P_PRV_PAIS           => NULL,
    P_PRV_TELEFONO       => 11111111,
    O_PRV_PROVEEDOR      => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Caso negativo: nombre de empresa vacío ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_INSERTAR(
    P_PRV_NIT            => '9999999-9',
    P_PRV_NOMBRE_EMPRESA => '   ',
    P_PRV_EMAIL          => 'x@x.com',
    P_PRV_ZONA           => NULL,
    P_PRV_MUNICIPIO      => NULL,
    P_PRV_DEPARTAMENTO   => NULL,
    P_PRV_PAIS           => NULL,
    P_PRV_TELEFONO       => 99999999,
    O_PRV_PROVEEDOR      => V_ID,
    O_COD_RET            => V_RET,
    O_MSG                => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Eliminar proveedor de prueba ===
DECLARE
  V_ID  NUMBER;
  V_RET NUMBER;
  V_MSG VARCHAR2(4000);
BEGIN
  SELECT MAX(PRV_Proveedor) INTO V_ID FROM MUE_PROVEEDOR WHERE PRV_Nit = '1234567-8';

  PKG_MUE_PROVEEDOR.PR_PROVEEDOR_ELIMINAR(
    P_PRV_PROVEEDOR => V_ID,
    O_COD_RET       => V_RET,
    O_MSG           => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante con NIT de prueba (debe ser 0) ===
SELECT COUNT(1) AS CANT FROM MUE_PROVEEDOR WHERE PRV_Nit = '1234567-8';
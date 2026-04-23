-- =============================================================================
-- Pruebas manuales — PKG_MUE_ROL_PERMISO
-- Ejecutar conectado al mismo esquema donde está compilado el paquete.
-- SQL Developer: habilitar View → Dbms Output y asociar la conexión.
-- SQL*Plus / SQLcl: SET SERVEROUTPUT ON SIZE UNLIMITED
-- IMPORTANTE: requiere PKG_MUE_ROL y PKG_MUE_PERMISO compilados.
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT === 0) Preparar: insertar rol y permiso de apoyo ===
DECLARE
  V_ID_ROL  NUMBER;
  V_ID_PERM NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  PKG_MUE_ROL.PR_ROL_INSERTAR(
    P_ROL_NOMBRE      => 'Rol Soporte RP QA',
    P_ROL_DESCRIPCION => 'Rol temporal para pruebas de rol-permiso',
    O_ROL_ROL         => V_ID_ROL,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('ROL RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID_ROL);

  PKG_MUE_PERMISO.PR_PERMISO_INSERTAR(
    P_PER_CODIGO      => 'PERM_RP_QA_001',
    P_PER_DESCRIPCION => 'Permiso temporal para pruebas de rol-permiso',
    O_PER_PERMISO     => V_ID_PERM,
    O_COD_RET         => V_RET,
    O_MSG             => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('PERMISO RET=' || V_RET || ' MSG=' || V_MSG || ' ID=' || V_ID_PERM);
END;
/

PROMPT === 1) Alta: asignar permiso al rol ===
DECLARE
  V_ID_ROL  NUMBER;
  V_ID_PERM NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol)    INTO V_ID_ROL  FROM MUE_ROL     WHERE ROL_Nombre  = 'Rol Soporte RP QA';
  SELECT MAX(PER_Permiso) INTO V_ID_PERM FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_RP_QA_001';

  PKG_MUE_ROL_PERMISO.PR_ROL_PERMISO_ALTA(
    P_ROL_ROL     => V_ID_ROL,
    P_PER_PERMISO => V_ID_PERM,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('ALTA RET=' || V_RET || ' MSG=' || V_MSG);
  IF V_RET <> 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Fallo alta: ' || V_MSG);
  END IF;
END;
/

PROMPT === 2) Listar permisos del rol ===
DECLARE
  V_ID_ROL  NUMBER;
  V_CUR     SYS_REFCURSOR;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
  V_RID     NUMBER;
  V_RNOM    VARCHAR2(50);
  V_PID     NUMBER;
  V_PCOD    VARCHAR2(30);
  V_PDESC   VARCHAR2(200);
  V_CAT     TIMESTAMP;
BEGIN
  SELECT MAX(ROL_Rol) INTO V_ID_ROL FROM MUE_ROL WHERE ROL_Nombre = 'Rol Soporte RP QA';

  PKG_MUE_ROL_PERMISO.PR_ROL_PERMISO_LISTAR(
    P_ROL_ROL     => V_ID_ROL,
    P_PER_PERMISO => NULL,
    O_CURSOR      => V_CUR,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('LISTAR RET=' || V_RET || ' ' || V_MSG);
  LOOP
    FETCH V_CUR INTO V_RID, V_RNOM, V_PID, V_PCOD, V_PDESC, V_CAT;
    EXIT WHEN V_CUR%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('  Fila: ROL=' || V_RNOM || ' PERMISO=' || V_PCOD);
  END LOOP;
  CLOSE V_CUR;
END;
/

PROMPT === 3) Verificación directa (solo testing; no usar en app) ===
SELECT RP.ROL_Rol, R.ROL_Nombre, RP.PER_Permiso, P.PER_Codigo
  FROM MUE_ROL_PERMISO RP
  JOIN MUE_ROL     R ON R.ROL_Rol     = RP.ROL_Rol
  JOIN MUE_PERMISO P ON P.PER_Permiso = RP.PER_Permiso
 WHERE R.ROL_Nombre = 'Rol Soporte RP QA';

PROMPT === 4) Caso negativo: alta duplicada ===
DECLARE
  V_ID_ROL  NUMBER;
  V_ID_PERM NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol)    INTO V_ID_ROL  FROM MUE_ROL     WHERE ROL_Nombre  = 'Rol Soporte RP QA';
  SELECT MAX(PER_Permiso) INTO V_ID_PERM FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_RP_QA_001';

  PKG_MUE_ROL_PERMISO.PR_ROL_PERMISO_ALTA(
    P_ROL_ROL     => V_ID_ROL,
    P_PER_PERMISO => V_ID_PERM,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET<>0: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 5) Caso negativo: rol inexistente ===
DECLARE
  V_ID_PERM NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(PER_Permiso) INTO V_ID_PERM FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_RP_QA_001';

  PKG_MUE_ROL_PERMISO.PR_ROL_PERMISO_ALTA(
    P_ROL_ROL     => -999,
    P_PER_PERMISO => V_ID_PERM,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 6) Caso negativo: permiso inexistente ===
DECLARE
  V_ID_ROL NUMBER;
  V_RET    NUMBER;
  V_MSG    VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol) INTO V_ID_ROL FROM MUE_ROL WHERE ROL_Nombre = 'Rol Soporte RP QA';

  PKG_MUE_ROL_PERMISO.PR_ROL_PERMISO_ALTA(
    P_ROL_ROL     => V_ID_ROL,
    P_PER_PERMISO => -999,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('Esperado RET=2: RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 7) Baja: remover permiso del rol ===
DECLARE
  V_ID_ROL  NUMBER;
  V_ID_PERM NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol)    INTO V_ID_ROL  FROM MUE_ROL     WHERE ROL_Nombre  = 'Rol Soporte RP QA';
  SELECT MAX(PER_Permiso) INTO V_ID_PERM FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_RP_QA_001';

  PKG_MUE_ROL_PERMISO.PR_ROL_PERMISO_BAJA(
    P_ROL_ROL     => V_ID_ROL,
    P_PER_PERMISO => V_ID_PERM,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('BAJA RET=' || V_RET || ' MSG=' || V_MSG);
END;
/

PROMPT === 8) Limpiar rol y permiso de apoyo ===
DECLARE
  V_ID_ROL  NUMBER;
  V_ID_PERM NUMBER;
  V_RET     NUMBER;
  V_MSG     VARCHAR2(4000);
BEGIN
  SELECT MAX(ROL_Rol)     INTO V_ID_ROL  FROM MUE_ROL     WHERE ROL_Nombre  = 'Rol Soporte RP QA';
  SELECT MAX(PER_Permiso) INTO V_ID_PERM FROM MUE_PERMISO WHERE PER_Codigo = 'PERM_RP_QA_001';

  PKG_MUE_ROL.PR_ROL_ELIMINAR(
    P_ROL_ROL => V_ID_ROL,
    O_COD_RET => V_RET,
    O_MSG     => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('ROL DELETE RET=' || V_RET || ' ' || V_MSG);

  PKG_MUE_PERMISO.PR_PERMISO_ELIMINAR(
    P_PER_PERMISO => V_ID_PERM,
    O_COD_RET     => V_RET,
    O_MSG         => V_MSG
  );
  DBMS_OUTPUT.PUT_LINE('PERMISO DELETE RET=' || V_RET || ' ' || V_MSG);
END;
/

PROMPT === Fin. Conteo restante (debe ser 0) ===
SELECT COUNT(1) AS CANT
  FROM MUE_ROL_PERMISO RP
  JOIN MUE_ROL R ON R.ROL_Rol = RP.ROL_Rol
 WHERE R.ROL_Nombre = 'Rol Soporte RP QA';
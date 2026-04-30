-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_ROL_PERMISO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : Alta, baja y listado de la relación Rol-Permiso.
--             Valida FK a MUE_ROL y MUE_PERMISO antes de operar.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ROL_PERMISO AS
  /**
   * Tabla puente ROL-PERMISO — alta, baja y listado.
   * No tiene "actualizar" porque la PK es compuesta (ROL + PERMISO);
   * para cambiar una relación se elimina y se crea una nueva.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ROL_PERMISO_ALTA (
    P_ROL_ROL     IN  NUMBER,
    P_PER_PERMISO IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ROL_PERMISO_BAJA (
    P_ROL_ROL     IN  NUMBER,
    P_PER_PERMISO IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ROL_PERMISO_LISTAR (
    P_ROL_ROL     IN  NUMBER DEFAULT NULL,
    P_PER_PERMISO IN  NUMBER DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_ROL_PERMISO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ROL_PERMISO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_PERMISO_ALTA (
    P_ROL_ROL     IN  NUMBER,
    P_PER_PERMISO IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    -- Validar parámetros obligatorios
    IF P_ROL_ROL IS NULL THEN
      O_MSG := 'El identificador de rol es obligatorio.';
      RETURN;
    END IF;

    IF P_PER_PERMISO IS NULL THEN
      O_MSG := 'El identificador de permiso es obligatorio.';
      RETURN;
    END IF;

    -- Validar FK: el rol debe existir
    SELECT COUNT(1) INTO V_N FROM MUE_ROL WHERE ROL_Rol = P_ROL_ROL;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El rol indicado no existe.';
      RETURN;
    END IF;

    -- Validar FK: el permiso debe existir
    SELECT COUNT(1) INTO V_N FROM MUE_PERMISO WHERE PER_Permiso = P_PER_PERMISO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El permiso indicado no existe.';
      RETURN;
    END IF;

    -- Validar que la relación no exista ya
    SELECT COUNT(1) INTO V_N
      FROM MUE_ROL_PERMISO
     WHERE ROL_Rol = P_ROL_ROL
       AND PER_Permiso = P_PER_PERMISO;

    IF V_N > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El permiso ya está asignado a ese rol.';
      RETURN;
    END IF;

    INSERT INTO MUE_ROL_PERMISO (
      ROL_Rol,
      PER_Permiso,
      RPE_Created_At
    ) VALUES (
      P_ROL_ROL,
      P_PER_PERMISO,
      SYSTIMESTAMP
    );

    O_COD_RET := C_OK;
    O_MSG     := 'Permiso asignado al rol correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'El permiso ya está asignado a ese rol (restricción de unicidad).';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al asignar permiso al rol: ' || SQLERRM;
  END PR_ROL_PERMISO_ALTA;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_PERMISO_BAJA (
    P_ROL_ROL     IN  NUMBER,
    P_PER_PERMISO IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ROL_ROL IS NULL THEN
      O_MSG := 'El identificador de rol es obligatorio.';
      RETURN;
    END IF;

    IF P_PER_PERMISO IS NULL THEN
      O_MSG := 'El identificador de permiso es obligatorio.';
      RETURN;
    END IF;

    DELETE FROM MUE_ROL_PERMISO
     WHERE ROL_Rol    = P_ROL_ROL
       AND PER_Permiso = P_PER_PERMISO;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La relación rol-permiso no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Permiso removido del rol correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al remover permiso del rol: ' || SQLERRM;
  END PR_ROL_PERMISO_BAJA;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_PERMISO_LISTAR (
    P_ROL_ROL     IN  NUMBER DEFAULT NULL,
    P_PER_PERMISO IN  NUMBER DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT RP.ROL_Rol        AS Rol_Id,
             R.ROL_Nombre      AS Rol_Nombre,
             RP.PER_Permiso    AS Permiso_Id,
             P.PER_Codigo      AS Permiso_Codigo,
             P.PER_Descripcion AS Permiso_Descripcion,
             RP.RPE_Created_At AS Asignado_En
        FROM MUE_ROL_PERMISO RP
        JOIN MUE_ROL     R ON R.ROL_Rol      = RP.ROL_Rol
        JOIN MUE_PERMISO P ON P.PER_Permiso  = RP.PER_Permiso
       WHERE (P_ROL_ROL     IS NULL OR RP.ROL_Rol     = P_ROL_ROL)
         AND (P_PER_PERMISO IS NULL OR RP.PER_Permiso = P_PER_PERMISO)
       ORDER BY R.ROL_Nombre ASC, P.PER_Codigo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar permisos del rol: ' || SQLERRM;
  END PR_ROL_PERMISO_LISTAR;

END PKG_MUE_ROL_PERMISO;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_ROL_PERMISO TO USR_APP_MUEBLERIA;
-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_ROL
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de roles.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ROL AS
  /**
   * Catálogo de roles  operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ROL_INSERTAR (
    P_ROL_NOMBRE      IN  VARCHAR2,
    P_ROL_DESCRIPCION IN  VARCHAR2,
    O_ROL_ROL         OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ROL_ACTUALIZAR (
    P_ROL_ROL         IN  NUMBER,
    P_ROL_NOMBRE      IN  VARCHAR2,
    P_ROL_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ROL_ELIMINAR (
    P_ROL_ROL IN  NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  );

  PROCEDURE PR_ROL_OBTENER (
    P_ROL_ROL         IN  NUMBER,
    O_ROL_NOMBRE      OUT VARCHAR2,
    O_ROL_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_ROL_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_ROL;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ROL AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_INSERTAR (
    P_ROL_NOMBRE      IN  VARCHAR2,
    P_ROL_DESCRIPCION IN  VARCHAR2,
    O_ROL_ROL         OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;
    O_ROL_ROL := NULL;

    IF TRIM(P_ROL_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del rol es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_ROL (
      ROL_Nombre,
      ROL_Descripcion
    ) VALUES (
      TRIM(P_ROL_NOMBRE),
      P_ROL_DESCRIPCION
    )
    RETURNING ROL_Rol INTO O_ROL_ROL;

    O_COD_RET := C_OK;
    O_MSG     := 'Rol registrado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe un rol con ese nombre.';
      O_ROL_ROL := NULL;
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al insertar rol: ' || SQLERRM;
      O_ROL_ROL := NULL;
  END PR_ROL_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_ACTUALIZAR (
    P_ROL_ROL         IN  NUMBER,
    P_ROL_NOMBRE      IN  VARCHAR2,
    P_ROL_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ROL_ROL IS NULL THEN
      O_MSG := 'Identificador de rol inválido.';
      RETURN;
    END IF;

    IF TRIM(P_ROL_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del rol es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ROL WHERE ROL_Rol = P_ROL_ROL;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El rol no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ROL
       SET ROL_Nombre      = TRIM(P_ROL_NOMBRE),
           ROL_Descripcion = P_ROL_DESCRIPCION
     WHERE ROL_Rol = P_ROL_ROL;

    O_COD_RET := C_OK;
    O_MSG     := 'Rol actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar rol: ' || SQLERRM;
  END PR_ROL_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_ELIMINAR (
    P_ROL_ROL IN  NUMBER,
    O_COD_RET OUT NUMBER,
    O_MSG     OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ROL_ROL IS NULL THEN
      O_MSG := 'Identificador de rol inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ROL WHERE ROL_Rol = P_ROL_ROL;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El rol no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Rol eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: registro hijo en MUE_USUARIO o MUE_ROL_PERMISO
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el rol (puede estar referenciado por usuarios o permisos): ' || SQLERRM;
  END PR_ROL_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_OBTENER (
    P_ROL_ROL         IN  NUMBER,
    O_ROL_NOMBRE      OUT VARCHAR2,
    O_ROL_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_ROL_NOMBRE      := NULL;
    O_ROL_DESCRIPCION := NULL;

    IF P_ROL_ROL IS NULL THEN
      O_MSG := 'Identificador de rol inválido.';
      RETURN;
    END IF;

    SELECT R.ROL_Nombre,
           R.ROL_Descripcion
      INTO O_ROL_NOMBRE,
           O_ROL_DESCRIPCION
      FROM MUE_ROL R
     WHERE R.ROL_Rol = P_ROL_ROL;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El rol no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar rol: ' || SQLERRM;
  END PR_ROL_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ROL_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT R.ROL_Rol         AS Rol_Id,
             R.ROL_Nombre      AS Nombre,
             R.ROL_Descripcion AS Descripcion
        FROM MUE_ROL R
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(R.ROL_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY R.ROL_Nombre ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar roles: ' || SQLERRM;
  END PR_ROL_LISTAR;

END PKG_MUE_ROL;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_ROL TO USR_APP_MUEBLERIA;
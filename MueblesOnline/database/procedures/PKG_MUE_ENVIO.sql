-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_ENVIO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de empresas de envío.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ENVIO AS
  /**
   * Catálogo de empresas de envío — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ENVIO_INSERTAR (
    P_ENV_NOMBRE_COMPANIA IN  VARCHAR2,
    P_ENV_TELEFONO        IN  NUMBER,
    O_ENV_ENVIO           OUT NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  );

  PROCEDURE PR_ENVIO_ACTUALIZAR (
    P_ENV_ENVIO           IN  NUMBER,
    P_ENV_NOMBRE_COMPANIA IN  VARCHAR2,
    P_ENV_TELEFONO        IN  NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  );

  PROCEDURE PR_ENVIO_ELIMINAR (
    P_ENV_ENVIO IN  NUMBER,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  );

  PROCEDURE PR_ENVIO_OBTENER (
    P_ENV_ENVIO           IN  NUMBER,
    O_ENV_NOMBRE_COMPANIA OUT VARCHAR2,
    O_ENV_TELEFONO        OUT NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  );

  PROCEDURE PR_ENVIO_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_ENVIO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ENVIO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENVIO_INSERTAR (
    P_ENV_NOMBRE_COMPANIA IN  VARCHAR2,
    P_ENV_TELEFONO        IN  NUMBER,
    O_ENV_ENVIO           OUT NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET   := C_ERR;
    O_MSG       := NULL;
    O_ENV_ENVIO := NULL;

    IF TRIM(P_ENV_NOMBRE_COMPANIA) IS NULL THEN
      O_MSG := 'El nombre de la compañía de envío es obligatorio.';
      RETURN;
    END IF;

    IF P_ENV_TELEFONO IS NULL THEN
      O_MSG := 'El teléfono de la compañía de envío es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_ENVIO (
      ENV_Nombre_Compania,
      ENV_Telefono
    ) VALUES (
      TRIM(P_ENV_NOMBRE_COMPANIA),
      P_ENV_TELEFONO
    )
    RETURNING ENV_Envio INTO O_ENV_ENVIO;

    O_COD_RET := C_OK;
    O_MSG     := 'Empresa de envío registrada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET   := C_ERR;
      O_MSG       := 'Error al insertar empresa de envío: ' || SQLERRM;
      O_ENV_ENVIO := NULL;
  END PR_ENVIO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENVIO_ACTUALIZAR (
    P_ENV_ENVIO           IN  NUMBER,
    P_ENV_NOMBRE_COMPANIA IN  VARCHAR2,
    P_ENV_TELEFONO        IN  NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ENV_ENVIO IS NULL THEN
      O_MSG := 'Identificador de envío inválido.';
      RETURN;
    END IF;

    IF TRIM(P_ENV_NOMBRE_COMPANIA) IS NULL THEN
      O_MSG := 'El nombre de la compañía de envío es obligatorio.';
      RETURN;
    END IF;

    IF P_ENV_TELEFONO IS NULL THEN
      O_MSG := 'El teléfono de la compañía de envío es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ENVIO WHERE ENV_Envio = P_ENV_ENVIO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La empresa de envío no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ENVIO
       SET ENV_Nombre_Compania = TRIM(P_ENV_NOMBRE_COMPANIA),
           ENV_Telefono        = P_ENV_TELEFONO
     WHERE ENV_Envio = P_ENV_ENVIO;

    O_COD_RET := C_OK;
    O_MSG     := 'Empresa de envío actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar empresa de envío: ' || SQLERRM;
  END PR_ENVIO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENVIO_ELIMINAR (
    P_ENV_ENVIO IN  NUMBER,
    O_COD_RET   OUT NUMBER,
    O_MSG       OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ENV_ENVIO IS NULL THEN
      O_MSG := 'Identificador de envío inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ENVIO WHERE ENV_Envio = P_ENV_ENVIO;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La empresa de envío no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Empresa de envío eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: referenciado en MUE_ORDEN_VENTA
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar la empresa de envío (puede estar referenciada en órdenes de venta): ' || SQLERRM;
  END PR_ENVIO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENVIO_OBTENER (
    P_ENV_ENVIO           IN  NUMBER,
    O_ENV_NOMBRE_COMPANIA OUT VARCHAR2,
    O_ENV_TELEFONO        OUT NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET             := C_ERR;
    O_MSG                 := NULL;
    O_ENV_NOMBRE_COMPANIA := NULL;
    O_ENV_TELEFONO        := NULL;

    IF P_ENV_ENVIO IS NULL THEN
      O_MSG := 'Identificador de envío inválido.';
      RETURN;
    END IF;

    SELECT E.ENV_Nombre_Compania,
           E.ENV_Telefono
      INTO O_ENV_NOMBRE_COMPANIA,
           O_ENV_TELEFONO
      FROM MUE_ENVIO E
     WHERE E.ENV_Envio = P_ENV_ENVIO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La empresa de envío no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar empresa de envío: ' || SQLERRM;
  END PR_ENVIO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ENVIO_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT E.ENV_Envio           AS Envio_Id,
             E.ENV_Nombre_Compania AS Nombre_Compania,
             E.ENV_Telefono        AS Telefono
        FROM MUE_ENVIO E
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(E.ENV_Nombre_Compania) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY E.ENV_Nombre_Compania ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar empresas de envío: ' || SQLERRM;
  END PR_ENVIO_LISTAR;

END PKG_MUE_ENVIO;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_ENVIO TO USR_APP_MUEBLERIA;
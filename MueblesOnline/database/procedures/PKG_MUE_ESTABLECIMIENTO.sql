-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_ESTABLECIMIENTO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de establecimientos.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ESTABLECIMIENTO AS
  /**
   * Catálogo de establecimientos — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ESTABLECIMIENTO_INSERTAR (
    P_EST_NOMBRE       IN  VARCHAR2,
    P_EST_MUNICIPIO    IN  VARCHAR2,
    P_EST_DEPARTAMENTO IN  VARCHAR2,
    P_EST_PAIS         IN  VARCHAR2,
    P_EST_DIRECCION    IN  VARCHAR2,
    O_EST_ESTABLECIMIENTO OUT NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_ESTABLECIMIENTO_ACTUALIZAR (
    P_EST_ESTABLECIMIENTO IN  NUMBER,
    P_EST_NOMBRE          IN  VARCHAR2,
    P_EST_MUNICIPIO       IN  VARCHAR2,
    P_EST_DEPARTAMENTO    IN  VARCHAR2,
    P_EST_PAIS            IN  VARCHAR2,
    P_EST_DIRECCION       IN  VARCHAR2,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  );

  PROCEDURE PR_ESTABLECIMIENTO_ELIMINAR (
    P_EST_ESTABLECIMIENTO IN  NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  );

  PROCEDURE PR_ESTABLECIMIENTO_OBTENER (
    P_EST_ESTABLECIMIENTO IN  NUMBER,
    O_EST_NOMBRE          OUT VARCHAR2,
    O_EST_MUNICIPIO       OUT VARCHAR2,
    O_EST_DEPARTAMENTO    OUT VARCHAR2,
    O_EST_PAIS            OUT VARCHAR2,
    O_EST_DIRECCION       OUT VARCHAR2,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  );

  PROCEDURE PR_ESTABLECIMIENTO_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_ESTABLECIMIENTO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ESTABLECIMIENTO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTABLECIMIENTO_INSERTAR (
    P_EST_NOMBRE       IN  VARCHAR2,
    P_EST_MUNICIPIO    IN  VARCHAR2,
    P_EST_DEPARTAMENTO IN  VARCHAR2,
    P_EST_PAIS         IN  VARCHAR2,
    P_EST_DIRECCION    IN  VARCHAR2,
    O_EST_ESTABLECIMIENTO OUT NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET             := C_ERR;
    O_MSG                 := NULL;
    O_EST_ESTABLECIMIENTO := NULL;

    IF TRIM(P_EST_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del establecimiento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_EST_MUNICIPIO) IS NULL THEN
      O_MSG := 'El municipio del establecimiento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_EST_DEPARTAMENTO) IS NULL THEN
      O_MSG := 'El departamento del establecimiento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_EST_PAIS) IS NULL THEN
      O_MSG := 'El país del establecimiento es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_ESTABLECIMIENTO (
      EST_Nombre,
      EST_Municipio,
      EST_Departamento,
      EST_Pais,
      EST_Direccion
    ) VALUES (
      TRIM(P_EST_NOMBRE),
      TRIM(P_EST_MUNICIPIO),
      TRIM(P_EST_DEPARTAMENTO),
      TRIM(P_EST_PAIS),
      P_EST_DIRECCION
    )
    RETURNING EST_Establecimiento INTO O_EST_ESTABLECIMIENTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Establecimiento registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET             := C_ERR;
      O_MSG                 := 'Error al insertar establecimiento: ' || SQLERRM;
      O_EST_ESTABLECIMIENTO := NULL;
  END PR_ESTABLECIMIENTO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTABLECIMIENTO_ACTUALIZAR (
    P_EST_ESTABLECIMIENTO IN  NUMBER,
    P_EST_NOMBRE          IN  VARCHAR2,
    P_EST_MUNICIPIO       IN  VARCHAR2,
    P_EST_DEPARTAMENTO    IN  VARCHAR2,
    P_EST_PAIS            IN  VARCHAR2,
    P_EST_DIRECCION       IN  VARCHAR2,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_EST_ESTABLECIMIENTO IS NULL THEN
      O_MSG := 'Identificador de establecimiento inválido.';
      RETURN;
    END IF;

    IF TRIM(P_EST_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del establecimiento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_EST_MUNICIPIO) IS NULL THEN
      O_MSG := 'El municipio del establecimiento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_EST_DEPARTAMENTO) IS NULL THEN
      O_MSG := 'El departamento del establecimiento es obligatorio.';
      RETURN;
    END IF;

    IF TRIM(P_EST_PAIS) IS NULL THEN
      O_MSG := 'El país del establecimiento es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ESTABLECIMIENTO WHERE EST_Establecimiento = P_EST_ESTABLECIMIENTO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El establecimiento no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ESTABLECIMIENTO
       SET EST_Nombre       = TRIM(P_EST_NOMBRE),
           EST_Municipio    = TRIM(P_EST_MUNICIPIO),
           EST_Departamento = TRIM(P_EST_DEPARTAMENTO),
           EST_Pais         = TRIM(P_EST_PAIS),
           EST_Direccion    = P_EST_DIRECCION
     WHERE EST_Establecimiento = P_EST_ESTABLECIMIENTO;

    O_COD_RET := C_OK;
    O_MSG     := 'Establecimiento actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar establecimiento: ' || SQLERRM;
  END PR_ESTABLECIMIENTO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTABLECIMIENTO_ELIMINAR (
    P_EST_ESTABLECIMIENTO IN  NUMBER,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_EST_ESTABLECIMIENTO IS NULL THEN
      O_MSG := 'Identificador de establecimiento inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ESTABLECIMIENTO WHERE EST_Establecimiento = P_EST_ESTABLECIMIENTO;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El establecimiento no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Establecimiento eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: referenciado en MUE_FACTURA
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el establecimiento (puede estar referenciado en facturas): ' || SQLERRM;
  END PR_ESTABLECIMIENTO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTABLECIMIENTO_OBTENER (
    P_EST_ESTABLECIMIENTO IN  NUMBER,
    O_EST_NOMBRE          OUT VARCHAR2,
    O_EST_MUNICIPIO       OUT VARCHAR2,
    O_EST_DEPARTAMENTO    OUT VARCHAR2,
    O_EST_PAIS            OUT VARCHAR2,
    O_EST_DIRECCION       OUT VARCHAR2,
    O_COD_RET             OUT NUMBER,
    O_MSG                 OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET          := C_ERR;
    O_MSG              := NULL;
    O_EST_NOMBRE       := NULL;
    O_EST_MUNICIPIO    := NULL;
    O_EST_DEPARTAMENTO := NULL;
    O_EST_PAIS         := NULL;
    O_EST_DIRECCION    := NULL;

    IF P_EST_ESTABLECIMIENTO IS NULL THEN
      O_MSG := 'Identificador de establecimiento inválido.';
      RETURN;
    END IF;

    SELECT E.EST_Nombre,
           E.EST_Municipio,
           E.EST_Departamento,
           E.EST_Pais,
           E.EST_Direccion
      INTO O_EST_NOMBRE,
           O_EST_MUNICIPIO,
           O_EST_DEPARTAMENTO,
           O_EST_PAIS,
           O_EST_DIRECCION
      FROM MUE_ESTABLECIMIENTO E
     WHERE E.EST_Establecimiento = P_EST_ESTABLECIMIENTO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El establecimiento no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar establecimiento: ' || SQLERRM;
  END PR_ESTABLECIMIENTO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ESTABLECIMIENTO_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT E.EST_Establecimiento AS Establecimiento_Id,
             E.EST_Nombre          AS Nombre,
             E.EST_Municipio       AS Municipio,
             E.EST_Departamento    AS Departamento,
             E.EST_Pais            AS Pais,
             E.EST_Direccion       AS Direccion
        FROM MUE_ESTABLECIMIENTO E
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(E.EST_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY E.EST_Nombre ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar establecimientos: ' || SQLERRM;
  END PR_ESTABLECIMIENTO_LISTAR;

END PKG_MUE_ESTABLECIMIENTO;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_ESTABLECIMIENTO TO USR_APP_MUEBLERIA;
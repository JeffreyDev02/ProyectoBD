-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_ALMACEN
-- Propósito: CRUD de almacenes de materiales.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_ALMACEN AS
  /**
   * Catálogo de almacenes — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_ALMACEN_INSERTAR (
    P_ALM_ZONA         IN  VARCHAR2,
    P_ALM_MUNICIPIO    IN  VARCHAR2,
    P_ALM_DEPARTAMENTO IN  VARCHAR2,
    O_ALM_ALMACEN      OUT NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_ALMACEN_ACTUALIZAR (
    P_ALM_ALMACEN      IN  NUMBER,
    P_ALM_ZONA         IN  VARCHAR2,
    P_ALM_MUNICIPIO    IN  VARCHAR2,
    P_ALM_DEPARTAMENTO IN  VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_ALMACEN_ELIMINAR (
    P_ALM_ALMACEN IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_ALMACEN_OBTENER (
    P_ALM_ALMACEN      IN  NUMBER,
    O_ALM_ZONA         OUT VARCHAR2,
    O_ALM_MUNICIPIO    OUT VARCHAR2,
    O_ALM_DEPARTAMENTO OUT VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

  PROCEDURE PR_ALMACEN_LISTAR (
    P_FILTRO_MUNICIPIO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR           OUT SYS_REFCURSOR,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

END PKG_MUE_ALMACEN;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_ALMACEN AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ALMACEN_INSERTAR (
    P_ALM_ZONA         IN  VARCHAR2,
    P_ALM_MUNICIPIO    IN  VARCHAR2,
    P_ALM_DEPARTAMENTO IN  VARCHAR2,
    O_ALM_ALMACEN      OUT NUMBER,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET     := C_ERR;
    O_MSG         := NULL;
    O_ALM_ALMACEN := NULL;

    INSERT INTO MUE_ALMACEN (
      ALM_Zona,
      ALM_Municipio,
      ALM_Departamento
    ) VALUES (
      P_ALM_ZONA,
      P_ALM_MUNICIPIO,
      P_ALM_DEPARTAMENTO
    )
    RETURNING ALM_Almacen INTO O_ALM_ALMACEN;

    O_COD_RET := C_OK;
    O_MSG     := 'Almacén registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET     := C_ERR;
      O_MSG         := 'Error al insertar almacén: ' || SQLERRM;
      O_ALM_ALMACEN := NULL;
  END PR_ALMACEN_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ALMACEN_ACTUALIZAR (
    P_ALM_ALMACEN      IN  NUMBER,
    P_ALM_ZONA         IN  VARCHAR2,
    P_ALM_MUNICIPIO    IN  VARCHAR2,
    P_ALM_DEPARTAMENTO IN  VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ALM_ALMACEN IS NULL THEN
      O_MSG := 'Identificador de almacén inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_ALMACEN WHERE ALM_Almacen = P_ALM_ALMACEN;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El almacén no existe.';
      RETURN;
    END IF;

    UPDATE MUE_ALMACEN
       SET ALM_Zona         = P_ALM_ZONA,
           ALM_Municipio    = P_ALM_MUNICIPIO,
           ALM_Departamento = P_ALM_DEPARTAMENTO
     WHERE ALM_Almacen = P_ALM_ALMACEN;

    O_COD_RET := C_OK;
    O_MSG     := 'Almacén actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar almacén: ' || SQLERRM;
  END PR_ALMACEN_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ALMACEN_ELIMINAR (
    P_ALM_ALMACEN IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_ALM_ALMACEN IS NULL THEN
      O_MSG := 'Identificador de almacén inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_ALMACEN WHERE ALM_Almacen = P_ALM_ALMACEN;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El almacén no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Almacén eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_MATERIAL_ALMACEN referencia este almacén
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el almacén (puede estar referenciado): ' || SQLERRM;
  END PR_ALMACEN_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ALMACEN_OBTENER (
    P_ALM_ALMACEN      IN  NUMBER,
    O_ALM_ZONA         OUT VARCHAR2,
    O_ALM_MUNICIPIO    OUT VARCHAR2,
    O_ALM_DEPARTAMENTO OUT VARCHAR2,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET          := C_ERR;
    O_MSG              := NULL;
    O_ALM_ZONA         := NULL;
    O_ALM_MUNICIPIO    := NULL;
    O_ALM_DEPARTAMENTO := NULL;

    IF P_ALM_ALMACEN IS NULL THEN
      O_MSG := 'Identificador de almacén inválido.';
      RETURN;
    END IF;

    SELECT A.ALM_Zona,
           A.ALM_Municipio,
           A.ALM_Departamento
      INTO O_ALM_ZONA,
           O_ALM_MUNICIPIO,
           O_ALM_DEPARTAMENTO
      FROM MUE_ALMACEN A
     WHERE A.ALM_Almacen = P_ALM_ALMACEN;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El almacén no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar almacén: ' || SQLERRM;
  END PR_ALMACEN_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_ALMACEN_LISTAR (
    P_FILTRO_MUNICIPIO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR           OUT SYS_REFCURSOR,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT A.ALM_Almacen      AS Almacen_Id,
             A.ALM_Zona         AS Zona,
             A.ALM_Municipio    AS Municipio,
             A.ALM_Departamento AS Departamento
        FROM MUE_ALMACEN A
       WHERE P_FILTRO_MUNICIPIO IS NULL
          OR UPPER(A.ALM_Municipio) LIKE '%' || UPPER(TRIM(P_FILTRO_MUNICIPIO)) || '%'
       ORDER BY A.ALM_Departamento ASC, A.ALM_Municipio ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar almacenes: ' || SQLERRM;
  END PR_ALMACEN_LISTAR;

END PKG_MUE_ALMACEN;
/

-- GRANT EXECUTE ON PKG_MUE_ALMACEN TO USR_APP_MUEBLERIA;
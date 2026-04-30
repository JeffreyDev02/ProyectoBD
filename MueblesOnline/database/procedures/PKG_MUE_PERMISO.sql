-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_PERMISO
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de permisos.
--             Valida unicidad de PER_Codigo (UK_MUE_PERMISO_CODIGO).
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_PERMISO AS
  /**
   * Catálogo de permisos — operaciones CRUD y listado.
   * PER_Codigo es único; se valida antes de insertar y al actualizar.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_PERMISO_INSERTAR (
    P_PER_CODIGO      IN  VARCHAR2,
    P_PER_DESCRIPCION IN  VARCHAR2,
    O_PER_PERMISO     OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_PERMISO_ACTUALIZAR (
    P_PER_PERMISO     IN  NUMBER,
    P_PER_CODIGO      IN  VARCHAR2,
    P_PER_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_PERMISO_ELIMINAR (
    P_PER_PERMISO IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

  PROCEDURE PR_PERMISO_OBTENER (
    P_PER_PERMISO     IN  NUMBER,
    O_PER_CODIGO      OUT VARCHAR2,
    O_PER_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_PERMISO_LISTAR (
    P_FILTRO_CODIGO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_PERMISO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_PERMISO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PERMISO_INSERTAR (
    P_PER_CODIGO      IN  VARCHAR2,
    P_PER_DESCRIPCION IN  VARCHAR2,
    O_PER_PERMISO     OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET     := C_ERR;
    O_MSG         := NULL;
    O_PER_PERMISO := NULL;

    -- Validar código obligatorio
    IF TRIM(P_PER_CODIGO) IS NULL THEN
      O_MSG := 'El código del permiso es obligatorio.';
      RETURN;
    END IF;

    -- Validar unicidad de PER_Codigo
    SELECT COUNT(1) INTO V_N
      FROM MUE_PERMISO
     WHERE UPPER(PER_Codigo) = UPPER(TRIM(P_PER_CODIGO));

    IF V_N > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe un permiso con el código "' || TRIM(P_PER_CODIGO) || '".';
      RETURN;
    END IF;

    INSERT INTO MUE_PERMISO (
      PER_Codigo,
      PER_Descripcion
    ) VALUES (
      TRIM(P_PER_CODIGO),
      P_PER_DESCRIPCION
    )
    RETURNING PER_Permiso INTO O_PER_PERMISO;

    O_COD_RET := C_OK;
    O_MSG     := 'Permiso registrado correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET     := C_ERR;
      O_MSG         := 'Ya existe un permiso con ese código (restricción de unicidad).';
      O_PER_PERMISO := NULL;
    WHEN OTHERS THEN
      O_COD_RET     := C_ERR;
      O_MSG         := 'Error al insertar permiso: ' || SQLERRM;
      O_PER_PERMISO := NULL;
  END PR_PERMISO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PERMISO_ACTUALIZAR (
    P_PER_PERMISO     IN  NUMBER,
    P_PER_CODIGO      IN  VARCHAR2,
    P_PER_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PER_PERMISO IS NULL THEN
      O_MSG := 'Identificador de permiso inválido.';
      RETURN;
    END IF;

    IF TRIM(P_PER_CODIGO) IS NULL THEN
      O_MSG := 'El código del permiso es obligatorio.';
      RETURN;
    END IF;

    -- Verificar que el permiso exista
    SELECT COUNT(1) INTO V_N FROM MUE_PERMISO WHERE PER_Permiso = P_PER_PERMISO;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El permiso no existe.';
      RETURN;
    END IF;

    -- Validar unicidad del código excluyendo el registro actual
    SELECT COUNT(1) INTO V_N
      FROM MUE_PERMISO
     WHERE UPPER(PER_Codigo) = UPPER(TRIM(P_PER_CODIGO))
       AND PER_Permiso <> P_PER_PERMISO;

    IF V_N > 0 THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Ya existe otro permiso con el código "' || TRIM(P_PER_CODIGO) || '".';
      RETURN;
    END IF;

    UPDATE MUE_PERMISO
       SET PER_Codigo      = TRIM(P_PER_CODIGO),
           PER_Descripcion = P_PER_DESCRIPCION
     WHERE PER_Permiso = P_PER_PERMISO;

    O_COD_RET := C_OK;
    O_MSG     := 'Permiso actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar permiso: ' || SQLERRM;
  END PR_PERMISO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PERMISO_ELIMINAR (
    P_PER_PERMISO IN  NUMBER,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_PER_PERMISO IS NULL THEN
      O_MSG := 'Identificador de permiso inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_PERMISO WHERE PER_Permiso = P_PER_PERMISO;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El permiso no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Permiso eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: registro hijo en MUE_ROL_PERMISO referencia este permiso
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el permiso (puede estar referenciado por roles): ' || SQLERRM;
  END PR_PERMISO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PERMISO_OBTENER (
    P_PER_PERMISO     IN  NUMBER,
    O_PER_CODIGO      OUT VARCHAR2,
    O_PER_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_PER_CODIGO      := NULL;
    O_PER_DESCRIPCION := NULL;

    IF P_PER_PERMISO IS NULL THEN
      O_MSG := 'Identificador de permiso inválido.';
      RETURN;
    END IF;

    SELECT P.PER_Codigo,
           P.PER_Descripcion
      INTO O_PER_CODIGO,
           O_PER_DESCRIPCION
      FROM MUE_PERMISO P
     WHERE P.PER_Permiso = P_PER_PERMISO;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El permiso no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar permiso: ' || SQLERRM;
  END PR_PERMISO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_PERMISO_LISTAR (
    P_FILTRO_CODIGO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT P.PER_Permiso     AS Permiso_Id,
             P.PER_Codigo      AS Codigo,
             P.PER_Descripcion AS Descripcion
        FROM MUE_PERMISO P
       WHERE P_FILTRO_CODIGO IS NULL
          OR UPPER(P.PER_Codigo) LIKE '%' || UPPER(TRIM(P_FILTRO_CODIGO)) || '%'
       ORDER BY P.PER_Codigo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar permisos: ' || SQLERRM;
  END PR_PERMISO_LISTAR;

END PKG_MUE_PERMISO;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_PERMISO TO USR_APP_MUEBLERIA;
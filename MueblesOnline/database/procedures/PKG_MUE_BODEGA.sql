-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_BODEGA
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para bodegas; valida FK a MUE_SEDE.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_BODEGA AS
  /**
   * Catálogo de bodegas — operaciones CRUD y listado.
   * Depende de MUE_SEDE (SED_Sede debe existir antes de insertar).
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_BODEGA_INSERTAR (
    P_BOD_NOMBRE         IN  VARCHAR2,
    P_BOD_DESCRIPCION    IN  VARCHAR2,
    P_SED_SEDE           IN  NUMBER,
    P_BOD_ACTIVA         IN  NUMBER,
    P_BOD_CODIGO_INTERNO IN  VARCHAR2,
    O_BOD_BODEGA         OUT NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_BODEGA_ACTUALIZAR (
    P_BOD_BODEGA         IN  NUMBER,
    P_BOD_NOMBRE         IN  VARCHAR2,
    P_BOD_DESCRIPCION    IN  VARCHAR2,
    P_SED_SEDE           IN  NUMBER,
    P_BOD_ACTIVA         IN  NUMBER,
    P_BOD_CODIGO_INTERNO IN  VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_BODEGA_ELIMINAR (
    P_BOD_BODEGA IN  NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  );

  PROCEDURE PR_BODEGA_OBTENER (
    P_BOD_BODEGA         IN  NUMBER,
    O_BOD_NOMBRE         OUT VARCHAR2,
    O_BOD_DESCRIPCION    OUT VARCHAR2,
    O_SED_SEDE           OUT NUMBER,
    O_BOD_ACTIVA         OUT NUMBER,
    O_BOD_CODIGO_INTERNO OUT VARCHAR2,
    O_BOD_CREATED_AT     OUT TIMESTAMP,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  );

  PROCEDURE PR_BODEGA_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    P_SED_SEDE      IN  NUMBER   DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_BODEGA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_BODEGA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_BODEGA_INSERTAR (
    P_BOD_NOMBRE         IN  VARCHAR2,
    P_BOD_DESCRIPCION    IN  VARCHAR2,
    P_SED_SEDE           IN  NUMBER,
    P_BOD_ACTIVA         IN  NUMBER,
    P_BOD_CODIGO_INTERNO IN  VARCHAR2,
    O_BOD_BODEGA         OUT NUMBER,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_BOD_BODEGA := NULL;

    -- Validar nombre obligatorio
    IF TRIM(P_BOD_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre de la bodega es obligatorio.';
      RETURN;
    END IF;

    -- Validar campo activa
    IF P_BOD_ACTIVA NOT IN (0, 1) THEN
      O_MSG := 'El campo activa debe ser 0 (inactiva) o 1 (activa).';
      RETURN;
    END IF;

    -- Validar FK: la sede debe existir
    IF P_SED_SEDE IS NULL THEN
      O_MSG := 'La sede es obligatoria.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_SEDE WHERE SED_Sede = P_SED_SEDE;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La sede indicada no existe.';
      RETURN;
    END IF;

    INSERT INTO MUE_BODEGA (
      BOD_Nombre,
      BOD_Descripcion,
      SED_Sede,
      BOD_Activa,
      BOD_Codigo_Interno,
      BOD_Created_At
    ) VALUES (
      TRIM(P_BOD_NOMBRE),
      P_BOD_DESCRIPCION,
      P_SED_SEDE,
      P_BOD_ACTIVA,
      P_BOD_CODIGO_INTERNO,
      SYSTIMESTAMP
    )
    RETURNING BOD_Bodega INTO O_BOD_BODEGA;

    O_COD_RET := C_OK;
    O_MSG     := 'Bodega registrada correctamente.';

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      O_COD_RET    := C_ERR;
      O_MSG        := 'Ya existe una bodega con ese código interno.';
      O_BOD_BODEGA := NULL;
    WHEN OTHERS THEN
      O_COD_RET    := C_ERR;
      O_MSG        := 'Error al insertar bodega: ' || SQLERRM;
      O_BOD_BODEGA := NULL;
  END PR_BODEGA_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_BODEGA_ACTUALIZAR (
    P_BOD_BODEGA         IN  NUMBER,
    P_BOD_NOMBRE         IN  VARCHAR2,
    P_BOD_DESCRIPCION    IN  VARCHAR2,
    P_SED_SEDE           IN  NUMBER,
    P_BOD_ACTIVA         IN  NUMBER,
    P_BOD_CODIGO_INTERNO IN  VARCHAR2,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_BOD_BODEGA IS NULL THEN
      O_MSG := 'Identificador de bodega inválido.';
      RETURN;
    END IF;

    IF TRIM(P_BOD_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre de la bodega es obligatorio.';
      RETURN;
    END IF;

    IF P_BOD_ACTIVA NOT IN (0, 1) THEN
      O_MSG := 'El campo activa debe ser 0 (inactiva) o 1 (activa).';
      RETURN;
    END IF;

    -- Verificar que la bodega exista
    SELECT COUNT(1) INTO V_N FROM MUE_BODEGA WHERE BOD_Bodega = P_BOD_BODEGA;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La bodega no existe.';
      RETURN;
    END IF;

    -- Validar FK: la sede debe existir
    IF P_SED_SEDE IS NOT NULL THEN
      SELECT COUNT(1) INTO V_N FROM MUE_SEDE WHERE SED_Sede = P_SED_SEDE;
      IF V_N = 0 THEN
        O_COD_RET := C_NOFND;
        O_MSG     := 'La sede indicada no existe.';
        RETURN;
      END IF;
    END IF;

    UPDATE MUE_BODEGA
       SET BOD_Nombre         = TRIM(P_BOD_NOMBRE),
           BOD_Descripcion    = P_BOD_DESCRIPCION,
           SED_Sede           = P_SED_SEDE,
           BOD_Activa         = P_BOD_ACTIVA,
           BOD_Codigo_Interno = P_BOD_CODIGO_INTERNO
     WHERE BOD_Bodega = P_BOD_BODEGA;

    O_COD_RET := C_OK;
    O_MSG     := 'Bodega actualizada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar bodega: ' || SQLERRM;
  END PR_BODEGA_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_BODEGA_ELIMINAR (
    P_BOD_BODEGA IN  NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_BOD_BODEGA IS NULL THEN
      O_MSG := 'Identificador de bodega inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_BODEGA WHERE BOD_Bodega = P_BOD_BODEGA;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La bodega no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Bodega eliminada correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- ORA-02292: registro hijo en MUE_PRODUCTO_BODEGA referencia esta bodega
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar la bodega (puede estar referenciada por productos): ' || SQLERRM;
  END PR_BODEGA_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_BODEGA_OBTENER (
    P_BOD_BODEGA         IN  NUMBER,
    O_BOD_NOMBRE         OUT VARCHAR2,
    O_BOD_DESCRIPCION    OUT VARCHAR2,
    O_SED_SEDE           OUT NUMBER,
    O_BOD_ACTIVA         OUT NUMBER,
    O_BOD_CODIGO_INTERNO OUT VARCHAR2,
    O_BOD_CREATED_AT     OUT TIMESTAMP,
    O_COD_RET            OUT NUMBER,
    O_MSG                OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET            := C_ERR;
    O_MSG                := NULL;
    O_BOD_NOMBRE         := NULL;
    O_BOD_DESCRIPCION    := NULL;
    O_SED_SEDE           := NULL;
    O_BOD_ACTIVA         := NULL;
    O_BOD_CODIGO_INTERNO := NULL;
    O_BOD_CREATED_AT     := NULL;

    IF P_BOD_BODEGA IS NULL THEN
      O_MSG := 'Identificador de bodega inválido.';
      RETURN;
    END IF;

    SELECT B.BOD_Nombre,
           B.BOD_Descripcion,
           B.SED_Sede,
           B.BOD_Activa,
           B.BOD_Codigo_Interno,
           B.BOD_Created_At
      INTO O_BOD_NOMBRE,
           O_BOD_DESCRIPCION,
           O_SED_SEDE,
           O_BOD_ACTIVA,
           O_BOD_CODIGO_INTERNO,
           O_BOD_CREATED_AT
      FROM MUE_BODEGA B
     WHERE B.BOD_Bodega = P_BOD_BODEGA;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La bodega no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar bodega: ' || SQLERRM;
  END PR_BODEGA_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_BODEGA_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    P_SED_SEDE      IN  NUMBER   DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT B.BOD_Bodega         AS Bodega_Id,
             B.BOD_Nombre         AS Nombre,
             B.BOD_Descripcion    AS Descripcion,
             B.SED_Sede           AS Sede_Id,
             S.SED_Nombre         AS Sede_Nombre,
             B.BOD_Activa         AS Activa,
             B.BOD_Codigo_Interno AS Codigo_Interno,
             B.BOD_Created_At     AS Creado_En
        FROM MUE_BODEGA B
        JOIN MUE_SEDE S ON S.SED_Sede = B.SED_Sede
       WHERE (P_FILTRO_NOMBRE IS NULL
              OR UPPER(B.BOD_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%')
         AND (P_SED_SEDE IS NULL OR B.SED_Sede = P_SED_SEDE)
       ORDER BY B.BOD_Nombre ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar bodegas: ' || SQLERRM;
  END PR_BODEGA_LISTAR;

END PKG_MUE_BODEGA;
/

-- Permisos de ejecución (ajustar usuario de aplicación)
-- GRANT EXECUTE ON PKG_MUE_BODEGA TO USR_APP_MUEBLERIA;
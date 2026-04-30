-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_TALLER_PRODUCCION
-- Propósito: CRUD de talleres de producción de muebles.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_TALLER_PRODUCCION AS
  /**
   * Catálogo de talleres de producción — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_TALLER_INSERTAR (
    P_TPR_DESCRIPCION IN  VARCHAR2,
    P_TPR_ZONA        IN  VARCHAR2,
    P_TPR_MUNICIPIO   IN  VARCHAR2,
    P_TPR_CIUDAD      IN  VARCHAR2,
    O_TPR_TALLER      OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TALLER_ACTUALIZAR (
    P_TPR_TALLER      IN  NUMBER,
    P_TPR_DESCRIPCION IN  VARCHAR2,
    P_TPR_ZONA        IN  VARCHAR2,
    P_TPR_MUNICIPIO   IN  VARCHAR2,
    P_TPR_CIUDAD      IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TALLER_ELIMINAR (
    P_TPR_TALLER IN  NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  );

  PROCEDURE PR_TALLER_OBTENER (
    P_TPR_TALLER      IN  NUMBER,
    O_TPR_DESCRIPCION OUT VARCHAR2,
    O_TPR_ZONA        OUT VARCHAR2,
    O_TPR_MUNICIPIO   OUT VARCHAR2,
    O_TPR_CIUDAD      OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TALLER_LISTAR (
    P_FILTRO_MUNICIPIO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR           OUT SYS_REFCURSOR,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  );

END PKG_MUE_TALLER_PRODUCCION;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_TALLER_PRODUCCION AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TALLER_INSERTAR (
    P_TPR_DESCRIPCION IN  VARCHAR2,
    P_TPR_ZONA        IN  VARCHAR2,
    P_TPR_MUNICIPIO   IN  VARCHAR2,
    P_TPR_CIUDAD      IN  VARCHAR2,
    O_TPR_TALLER      OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_TPR_TALLER := NULL;

    INSERT INTO MUE_TALLER_PRODUCCION (
      TPR_Descripcion,
      TPR_Zona,
      TPR_Municipio,
      TPR_Ciudad
    ) VALUES (
      P_TPR_DESCRIPCION,
      P_TPR_ZONA,
      P_TPR_MUNICIPIO,
      P_TPR_CIUDAD
    )
    RETURNING TPR_Taller_Produccion INTO O_TPR_TALLER;

    O_COD_RET := C_OK;
    O_MSG     := 'Taller de producción registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET    := C_ERR;
      O_MSG        := 'Error al insertar taller de producción: ' || SQLERRM;
      O_TPR_TALLER := NULL;
  END PR_TALLER_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TALLER_ACTUALIZAR (
    P_TPR_TALLER      IN  NUMBER,
    P_TPR_DESCRIPCION IN  VARCHAR2,
    P_TPR_ZONA        IN  VARCHAR2,
    P_TPR_MUNICIPIO   IN  VARCHAR2,
    P_TPR_CIUDAD      IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TPR_TALLER IS NULL THEN
      O_MSG := 'Identificador de taller inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_TALLER_PRODUCCION WHERE TPR_Taller_Produccion = P_TPR_TALLER;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El taller de producción no existe.';
      RETURN;
    END IF;

    UPDATE MUE_TALLER_PRODUCCION
       SET TPR_Descripcion = P_TPR_DESCRIPCION,
           TPR_Zona        = P_TPR_ZONA,
           TPR_Municipio   = P_TPR_MUNICIPIO,
           TPR_Ciudad      = P_TPR_CIUDAD
     WHERE TPR_Taller_Produccion = P_TPR_TALLER;

    O_COD_RET := C_OK;
    O_MSG     := 'Taller de producción actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar taller de producción: ' || SQLERRM;
  END PR_TALLER_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TALLER_ELIMINAR (
    P_TPR_TALLER IN  NUMBER,
    O_COD_RET    OUT NUMBER,
    O_MSG        OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TPR_TALLER IS NULL THEN
      O_MSG := 'Identificador de taller inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_TALLER_PRODUCCION WHERE TPR_Taller_Produccion = P_TPR_TALLER;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El taller de producción no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Taller de producción eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_DETALLE_MATERIAL_PRODUCTO referencia este taller
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el taller (puede estar referenciado): ' || SQLERRM;
  END PR_TALLER_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TALLER_OBTENER (
    P_TPR_TALLER      IN  NUMBER,
    O_TPR_DESCRIPCION OUT VARCHAR2,
    O_TPR_ZONA        OUT VARCHAR2,
    O_TPR_MUNICIPIO   OUT VARCHAR2,
    O_TPR_CIUDAD      OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_TPR_DESCRIPCION := NULL;
    O_TPR_ZONA        := NULL;
    O_TPR_MUNICIPIO   := NULL;
    O_TPR_CIUDAD      := NULL;

    IF P_TPR_TALLER IS NULL THEN
      O_MSG := 'Identificador de taller inválido.';
      RETURN;
    END IF;

    SELECT T.TPR_Descripcion,
           T.TPR_Zona,
           T.TPR_Municipio,
           T.TPR_Ciudad
      INTO O_TPR_DESCRIPCION,
           O_TPR_ZONA,
           O_TPR_MUNICIPIO,
           O_TPR_CIUDAD
      FROM MUE_TALLER_PRODUCCION T
     WHERE T.TPR_Taller_Produccion = P_TPR_TALLER;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El taller de producción no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar taller de producción: ' || SQLERRM;
  END PR_TALLER_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TALLER_LISTAR (
    P_FILTRO_MUNICIPIO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR           OUT SYS_REFCURSOR,
    O_COD_RET          OUT NUMBER,
    O_MSG              OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT T.TPR_Taller_Produccion AS Taller_Id,
             T.TPR_Descripcion       AS Descripcion,
             T.TPR_Zona              AS Zona,
             T.TPR_Municipio         AS Municipio,
             T.TPR_Ciudad            AS Ciudad
        FROM MUE_TALLER_PRODUCCION T
       WHERE P_FILTRO_MUNICIPIO IS NULL
          OR UPPER(T.TPR_Municipio) LIKE '%' || UPPER(TRIM(P_FILTRO_MUNICIPIO)) || '%'
       ORDER BY T.TPR_Ciudad ASC, T.TPR_Municipio ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar talleres de producción: ' || SQLERRM;
  END PR_TALLER_LISTAR;

END PKG_MUE_TALLER_PRODUCCION;
/

-- GRANT EXECUTE ON PKG_MUE_TALLER_PRODUCCION TO USR_APP_MUEBLERIA;
-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_MATERIAL
-- Propósito: CRUD de materiales usados en producción.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_MATERIAL AS
  /**
   * Catálogo de materiales — operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_MATERIAL_INSERTAR (
    P_MAT_NOMBRE      IN  VARCHAR2,
    P_MAT_PRECIO      IN  NUMBER,
    P_MAT_DESCRIPCION IN  VARCHAR2,
    P_MAT_STOCK_TOTAL IN  NUMBER,
    O_MAT_MATERIAL    OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_MATERIAL_ACTUALIZAR (
    P_MAT_MATERIAL    IN  NUMBER,
    P_MAT_NOMBRE      IN  VARCHAR2,
    P_MAT_PRECIO      IN  NUMBER,
    P_MAT_DESCRIPCION IN  VARCHAR2,
    P_MAT_STOCK_TOTAL IN  NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_MATERIAL_ELIMINAR (
    P_MAT_MATERIAL IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_MATERIAL_OBTENER (
    P_MAT_MATERIAL    IN  NUMBER,
    O_MAT_NOMBRE      OUT VARCHAR2,
    O_MAT_PRECIO      OUT NUMBER,
    O_MAT_DESCRIPCION OUT VARCHAR2,
    O_MAT_STOCK_TOTAL OUT NUMBER,
    O_MAT_CREATED_AT  OUT TIMESTAMP,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_MATERIAL_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

END PKG_MUE_MATERIAL;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_MATERIAL AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_MATERIAL_INSERTAR (
    P_MAT_NOMBRE      IN  VARCHAR2,
    P_MAT_PRECIO      IN  NUMBER,
    P_MAT_DESCRIPCION IN  VARCHAR2,
    P_MAT_STOCK_TOTAL IN  NUMBER,
    O_MAT_MATERIAL    OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET      := C_ERR;
    O_MSG          := NULL;
    O_MAT_MATERIAL := NULL;

    IF TRIM(P_MAT_NOMBRE) IS NULL THEN
      O_MSG := 'El nombre del material es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_MATERIAL (
      MAT_Nombre,
      MAT_Precio,
      MAT_Descripcion,
      MAT_Stock_Total,
      MAT_Created_At
    ) VALUES (
      P_MAT_NOMBRE,
      P_MAT_PRECIO,
      P_MAT_DESCRIPCION,
      P_MAT_STOCK_TOTAL,
      SYSTIMESTAMP
    )
    RETURNING MAT_Material INTO O_MAT_MATERIAL;

    O_COD_RET := C_OK;
    O_MSG     := 'Material registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET      := C_ERR;
      O_MSG          := 'Error al insertar material: ' || SQLERRM;
      O_MAT_MATERIAL := NULL;
  END PR_MATERIAL_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_MATERIAL_ACTUALIZAR (
    P_MAT_MATERIAL    IN  NUMBER,
    P_MAT_NOMBRE      IN  VARCHAR2,
    P_MAT_PRECIO      IN  NUMBER,
    P_MAT_DESCRIPCION IN  VARCHAR2,
    P_MAT_STOCK_TOTAL IN  NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_MAT_MATERIAL IS NULL THEN
      O_MSG := 'Identificador de material inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_MATERIAL WHERE MAT_Material = P_MAT_MATERIAL;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El material no existe.';
      RETURN;
    END IF;

    UPDATE MUE_MATERIAL
       SET MAT_Nombre      = P_MAT_NOMBRE,
           MAT_Precio      = P_MAT_PRECIO,
           MAT_Descripcion = P_MAT_DESCRIPCION,
           MAT_Stock_Total = P_MAT_STOCK_TOTAL
     WHERE MAT_Material = P_MAT_MATERIAL;

    O_COD_RET := C_OK;
    O_MSG     := 'Material actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar material: ' || SQLERRM;
  END PR_MATERIAL_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_MATERIAL_ELIMINAR (
    P_MAT_MATERIAL IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_MAT_MATERIAL IS NULL THEN
      O_MSG := 'Identificador de material inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_MATERIAL WHERE MAT_Material = P_MAT_MATERIAL;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El material no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Material eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_MATERIAL_ALMACEN o MUE_DETALLE_MATERIAL_PRODUCTO
      --      referencian este material
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el material (puede estar referenciado): ' || SQLERRM;
  END PR_MATERIAL_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_MATERIAL_OBTENER (
    P_MAT_MATERIAL    IN  NUMBER,
    O_MAT_NOMBRE      OUT VARCHAR2,
    O_MAT_PRECIO      OUT NUMBER,
    O_MAT_DESCRIPCION OUT VARCHAR2,
    O_MAT_STOCK_TOTAL OUT NUMBER,
    O_MAT_CREATED_AT  OUT TIMESTAMP,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_MAT_NOMBRE      := NULL;
    O_MAT_PRECIO      := NULL;
    O_MAT_DESCRIPCION := NULL;
    O_MAT_STOCK_TOTAL := NULL;
    O_MAT_CREATED_AT  := NULL;

    IF P_MAT_MATERIAL IS NULL THEN
      O_MSG := 'Identificador de material inválido.';
      RETURN;
    END IF;

    SELECT M.MAT_Nombre,
           M.MAT_Precio,
           M.MAT_Descripcion,
           M.MAT_Stock_Total,
           M.MAT_Created_At
      INTO O_MAT_NOMBRE,
           O_MAT_PRECIO,
           O_MAT_DESCRIPCION,
           O_MAT_STOCK_TOTAL,
           O_MAT_CREATED_AT
      FROM MUE_MATERIAL M
     WHERE M.MAT_Material = P_MAT_MATERIAL;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El material no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar material: ' || SQLERRM;
  END PR_MATERIAL_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_MATERIAL_LISTAR (
    P_FILTRO_NOMBRE IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR        OUT SYS_REFCURSOR,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT M.MAT_Material    AS Material_Id,
             M.MAT_Nombre      AS Nombre,
             M.MAT_Precio      AS Precio,
             M.MAT_Descripcion AS Descripcion,
             M.MAT_Stock_Total AS Stock_Total,
             M.MAT_Created_At  AS Creado_En
        FROM MUE_MATERIAL M
       WHERE P_FILTRO_NOMBRE IS NULL
          OR UPPER(M.MAT_Nombre) LIKE '%' || UPPER(TRIM(P_FILTRO_NOMBRE)) || '%'
       ORDER BY M.MAT_Nombre ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar materiales: ' || SQLERRM;
  END PR_MATERIAL_LISTAR;

END PKG_MUE_MATERIAL;
/

-- GRANT EXECUTE ON PKG_MUE_MATERIAL TO USR_APP_MUEBLERIA;
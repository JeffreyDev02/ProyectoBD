-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_TIPO_MOVIMIENTO_PRODUCTO
-- Propósito: CRUD de tipos de movimiento de producto terminado en bodega.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO AS
  /**
   * Catálogo de tipos de movimiento de producto  operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_TIPO_MOV_PRO_INSERTAR (
    P_TMP_TIPO        IN  VARCHAR2,
    P_TMP_DESCRIPCION IN  VARCHAR2,
    O_TMP_TIPO_MOV    OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_PRO_ACTUALIZAR (
    P_TMP_TIPO_MOV    IN  NUMBER,
    P_TMP_TIPO        IN  VARCHAR2,
    P_TMP_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_PRO_ELIMINAR (
    P_TMP_TIPO_MOV IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_PRO_OBTENER (
    P_TMP_TIPO_MOV    IN  NUMBER,
    O_TMP_TIPO        OUT VARCHAR2,
    O_TMP_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_PRO_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_PRO_INSERTAR (
    P_TMP_TIPO        IN  VARCHAR2,
    P_TMP_DESCRIPCION IN  VARCHAR2,
    O_TMP_TIPO_MOV    OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET      := C_ERR;
    O_MSG          := NULL;
    O_TMP_TIPO_MOV := NULL;

    IF TRIM(P_TMP_TIPO) IS NULL THEN
      O_MSG := 'El tipo de movimiento de producto es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_TIPO_MOVIMIENTO_PRODUCTO (
      TMP_Tipo,
      TMP_Descripcion
    ) VALUES (
      P_TMP_TIPO,
      P_TMP_DESCRIPCION
    )
    RETURNING TMP_Tipo_Movimiento_Producto INTO O_TMP_TIPO_MOV;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de movimiento de producto registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET      := C_ERR;
      O_MSG          := 'Error al insertar tipo de movimiento de producto: ' || SQLERRM;
      O_TMP_TIPO_MOV := NULL;
  END PR_TIPO_MOV_PRO_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_PRO_ACTUALIZAR (
    P_TMP_TIPO_MOV    IN  NUMBER,
    P_TMP_TIPO        IN  VARCHAR2,
    P_TMP_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TMP_TIPO_MOV IS NULL THEN
      O_MSG := 'Identificador de tipo de movimiento inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N
      FROM MUE_TIPO_MOVIMIENTO_PRODUCTO
     WHERE TMP_Tipo_Movimiento_Producto = P_TMP_TIPO_MOV;

    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de movimiento de producto no existe.';
      RETURN;
    END IF;

    UPDATE MUE_TIPO_MOVIMIENTO_PRODUCTO
       SET TMP_Tipo        = P_TMP_TIPO,
           TMP_Descripcion = P_TMP_DESCRIPCION
     WHERE TMP_Tipo_Movimiento_Producto = P_TMP_TIPO_MOV;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de movimiento de producto actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar tipo de movimiento de producto: ' || SQLERRM;
  END PR_TIPO_MOV_PRO_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_PRO_ELIMINAR (
    P_TMP_TIPO_MOV IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TMP_TIPO_MOV IS NULL THEN
      O_MSG := 'Identificador de tipo de movimiento inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_TIPO_MOVIMIENTO_PRODUCTO
     WHERE TMP_Tipo_Movimiento_Producto = P_TMP_TIPO_MOV;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de movimiento de producto no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de movimiento de producto eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_MOVIMIENTO_INVENTARIO_PRODUCTO referencia este tipo
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el tipo de movimiento (puede estar referenciado): ' || SQLERRM;
  END PR_TIPO_MOV_PRO_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_PRO_OBTENER (
    P_TMP_TIPO_MOV    IN  NUMBER,
    O_TMP_TIPO        OUT VARCHAR2,
    O_TMP_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_TMP_TIPO        := NULL;
    O_TMP_DESCRIPCION := NULL;

    IF P_TMP_TIPO_MOV IS NULL THEN
      O_MSG := 'Identificador de tipo de movimiento inválido.';
      RETURN;
    END IF;

    SELECT T.TMP_Tipo,
           T.TMP_Descripcion
      INTO O_TMP_TIPO,
           O_TMP_DESCRIPCION
      FROM MUE_TIPO_MOVIMIENTO_PRODUCTO T
     WHERE T.TMP_Tipo_Movimiento_Producto = P_TMP_TIPO_MOV;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de movimiento de producto no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar tipo de movimiento de producto: ' || SQLERRM;
  END PR_TIPO_MOV_PRO_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_PRO_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT T.TMP_Tipo_Movimiento_Producto AS Tipo_Mov_Pro_Id,
             T.TMP_Tipo                     AS Tipo,
             T.TMP_Descripcion              AS Descripcion
        FROM MUE_TIPO_MOVIMIENTO_PRODUCTO T
       WHERE P_FILTRO_TIPO IS NULL
          OR UPPER(T.TMP_Tipo) LIKE '%' || UPPER(TRIM(P_FILTRO_TIPO)) || '%'
       ORDER BY T.TMP_Tipo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar tipos de movimiento de producto: ' || SQLERRM;
  END PR_TIPO_MOV_PRO_LISTAR;

END PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO;
/

-- GRANT EXECUTE ON PKG_MUE_TIPO_MOVIMIENTO_PRODUCTO TO USR_APP_MUEBLERIA;
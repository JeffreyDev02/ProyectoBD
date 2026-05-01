-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad  : MUE_TIPO_MOVIMIENTO_MATERIAL
-- Propósito: CRUD de tipos de movimiento de material en almacén.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_TIPO_MOVIMIENTO_MATERIAL AS
  /**
   * Catálogo de tipos de movimiento de material  operaciones CRUD y listado.
   * Convención de retorno: O_COD_RET = 0 éxito; distinto de 0 error controlado.
   */

  PROCEDURE PR_TIPO_MOV_MAT_INSERTAR (
    P_TMM_TIPO        IN  VARCHAR2,
    P_TMM_DESCRIPCION IN  VARCHAR2,
    O_TMM_TIPO_MOV    OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_MAT_ACTUALIZAR (
    P_TMM_TIPO_MOV    IN  NUMBER,
    P_TMM_TIPO        IN  VARCHAR2,
    P_TMM_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_MAT_ELIMINAR (
    P_TMM_TIPO_MOV IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_MAT_OBTENER (
    P_TMM_TIPO_MOV    IN  NUMBER,
    O_TMM_TIPO        OUT VARCHAR2,
    O_TMM_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  );

  PROCEDURE PR_TIPO_MOV_MAT_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_TIPO_MOVIMIENTO_MATERIAL;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_TIPO_MOVIMIENTO_MATERIAL AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_MAT_INSERTAR (
    P_TMM_TIPO        IN  VARCHAR2,
    P_TMM_DESCRIPCION IN  VARCHAR2,
    O_TMM_TIPO_MOV    OUT NUMBER,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET      := C_ERR;
    O_MSG          := NULL;
    O_TMM_TIPO_MOV := NULL;

    IF TRIM(P_TMM_TIPO) IS NULL THEN
      O_MSG := 'El tipo de movimiento de material es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_TIPO_MOVIMIENTO_MATERIAL (
      TMM_Tipo,
      TMM_Descripcion
    ) VALUES (
      P_TMM_TIPO,
      P_TMM_DESCRIPCION
    )
    RETURNING TMM_Tipo_Movimiento_Material INTO O_TMM_TIPO_MOV;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de movimiento de material registrado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET      := C_ERR;
      O_MSG          := 'Error al insertar tipo de movimiento de material: ' || SQLERRM;
      O_TMM_TIPO_MOV := NULL;
  END PR_TIPO_MOV_MAT_INSERTAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_MAT_ACTUALIZAR (
    P_TMM_TIPO_MOV    IN  NUMBER,
    P_TMM_TIPO        IN  VARCHAR2,
    P_TMM_DESCRIPCION IN  VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TMM_TIPO_MOV IS NULL THEN
      O_MSG := 'Identificador de tipo de movimiento inválido.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N
      FROM MUE_TIPO_MOVIMIENTO_MATERIAL
     WHERE TMM_Tipo_Movimiento_Material = P_TMM_TIPO_MOV;

    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de movimiento de material no existe.';
      RETURN;
    END IF;

    UPDATE MUE_TIPO_MOVIMIENTO_MATERIAL
       SET TMM_Tipo        = P_TMM_TIPO,
           TMM_Descripcion = P_TMM_DESCRIPCION
     WHERE TMM_Tipo_Movimiento_Material = P_TMM_TIPO_MOV;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de movimiento de material actualizado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar tipo de movimiento de material: ' || SQLERRM;
  END PR_TIPO_MOV_MAT_ACTUALIZAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_MAT_ELIMINAR (
    P_TMM_TIPO_MOV IN  NUMBER,
    O_COD_RET      OUT NUMBER,
    O_MSG          OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_TMM_TIPO_MOV IS NULL THEN
      O_MSG := 'Identificador de tipo de movimiento inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_TIPO_MOVIMIENTO_MATERIAL
     WHERE TMM_Tipo_Movimiento_Material = P_TMM_TIPO_MOV;

    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de movimiento de material no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Tipo de movimiento de material eliminado correctamente.';

  EXCEPTION
    WHEN OTHERS THEN
      -- Ej.: ORA-02292 si MUE_MOVIMIENTO_INVENTARIO_MATERIAL referencia este tipo
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar el tipo de movimiento (puede estar referenciado): ' || SQLERRM;
  END PR_TIPO_MOV_MAT_ELIMINAR;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_MAT_OBTENER (
    P_TMM_TIPO_MOV    IN  NUMBER,
    O_TMM_TIPO        OUT VARCHAR2,
    O_TMM_DESCRIPCION OUT VARCHAR2,
    O_COD_RET         OUT NUMBER,
    O_MSG             OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET         := C_ERR;
    O_MSG             := NULL;
    O_TMM_TIPO        := NULL;
    O_TMM_DESCRIPCION := NULL;

    IF P_TMM_TIPO_MOV IS NULL THEN
      O_MSG := 'Identificador de tipo de movimiento inválido.';
      RETURN;
    END IF;

    SELECT T.TMM_Tipo,
           T.TMM_Descripcion
      INTO O_TMM_TIPO,
           O_TMM_DESCRIPCION
      FROM MUE_TIPO_MOVIMIENTO_MATERIAL T
     WHERE T.TMM_Tipo_Movimiento_Material = P_TMM_TIPO_MOV;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'El tipo de movimiento de material no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar tipo de movimiento de material: ' || SQLERRM;
  END PR_TIPO_MOV_MAT_OBTENER;

  -- ---------------------------------------------------------------------------
  PROCEDURE PR_TIPO_MOV_MAT_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT T.TMM_Tipo_Movimiento_Material AS Tipo_Mov_Mat_Id,
             T.TMM_Tipo                     AS Tipo,
             T.TMM_Descripcion              AS Descripcion
        FROM MUE_TIPO_MOVIMIENTO_MATERIAL T
       WHERE P_FILTRO_TIPO IS NULL
          OR UPPER(T.TMM_Tipo) LIKE '%' || UPPER(TRIM(P_FILTRO_TIPO)) || '%'
       ORDER BY T.TMM_Tipo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar tipos de movimiento de material: ' || SQLERRM;
  END PR_TIPO_MOV_MAT_LISTAR;

END PKG_MUE_TIPO_MOVIMIENTO_MATERIAL;
/

-- GRANT EXECUTE ON PKG_MUE_TIPO_MOVIMIENTO_MATERIAL TO USR_APP_MUEBLERIA;
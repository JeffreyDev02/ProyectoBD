-- =============================================================================
-- Paquete PL/SQL (Oracle 21c)
-- Entidad   : MUE_CATEGORIA
-- Referencia: Docs/DDL_MUEBLERIA.sql
-- Propósito : CRUD completo para el catálogo de categorías de producto.
-- Ejecutar conectado al esquema MUEBLERIA.
-- =============================================================================

CREATE OR REPLACE PACKAGE PKG_MUE_CATEGORIA AS

  PROCEDURE PR_CATEGORIA_INSERTAR (
    P_CAT_TIPO      IN  VARCHAR2,
    P_CAT_NOMBRE    IN  VARCHAR2,
    O_CAT_CATEGORIA OUT NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_CATEGORIA_ACTUALIZAR (
    P_CAT_CATEGORIA IN  NUMBER,
    P_CAT_TIPO      IN  VARCHAR2,
    P_CAT_NOMBRE    IN  VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_CATEGORIA_ELIMINAR (
    P_CAT_CATEGORIA IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_CATEGORIA_OBTENER (
    P_CAT_CATEGORIA IN  NUMBER,
    O_CAT_TIPO      OUT VARCHAR2,
    O_CAT_NOMBRE    OUT VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  );

  PROCEDURE PR_CATEGORIA_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  );

END PKG_MUE_CATEGORIA;
/

CREATE OR REPLACE PACKAGE BODY PKG_MUE_CATEGORIA AS

  C_OK    CONSTANT NUMBER := 0;
  C_ERR   CONSTANT NUMBER := 1;
  C_NOFND CONSTANT NUMBER := 2;

  PROCEDURE PR_CATEGORIA_INSERTAR (
    P_CAT_TIPO      IN  VARCHAR2,
    P_CAT_NOMBRE    IN  VARCHAR2,
    O_CAT_CATEGORIA OUT NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET       := C_ERR;
    O_MSG           := NULL;
    O_CAT_CATEGORIA := NULL;

    IF TRIM(P_CAT_TIPO) IS NULL THEN
      O_MSG := 'El tipo de categoría es obligatorio.';
      RETURN;
    END IF;

    INSERT INTO MUE_CATEGORIA (CAT_Tipo, CAT_Nombre)
    VALUES (TRIM(P_CAT_TIPO), TRIM(P_CAT_NOMBRE))
    RETURNING CAT_Categoria INTO O_CAT_CATEGORIA;

    O_COD_RET := C_OK;
    O_MSG     := 'Categoría registrada correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET       := C_ERR;
      O_MSG           := 'Error al insertar categoría: ' || SQLERRM;
      O_CAT_CATEGORIA := NULL;
  END PR_CATEGORIA_INSERTAR;

  PROCEDURE PR_CATEGORIA_ACTUALIZAR (
    P_CAT_CATEGORIA IN  NUMBER,
    P_CAT_TIPO      IN  VARCHAR2,
    P_CAT_NOMBRE    IN  VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
    V_N NUMBER;
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_CAT_CATEGORIA IS NULL THEN
      O_MSG := 'Identificador de categoría inválido.';
      RETURN;
    END IF;

    IF TRIM(P_CAT_TIPO) IS NULL THEN
      O_MSG := 'El tipo de categoría es obligatorio.';
      RETURN;
    END IF;

    SELECT COUNT(1) INTO V_N FROM MUE_CATEGORIA WHERE CAT_Categoria = P_CAT_CATEGORIA;
    IF V_N = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La categoría no existe.';
      RETURN;
    END IF;

    UPDATE MUE_CATEGORIA
       SET CAT_Tipo   = TRIM(P_CAT_TIPO),
           CAT_Nombre = TRIM(P_CAT_NOMBRE)
     WHERE CAT_Categoria = P_CAT_CATEGORIA;

    O_COD_RET := C_OK;
    O_MSG     := 'Categoría actualizada correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al actualizar categoría: ' || SQLERRM;
  END PR_CATEGORIA_ACTUALIZAR;

  PROCEDURE PR_CATEGORIA_ELIMINAR (
    P_CAT_CATEGORIA IN  NUMBER,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    IF P_CAT_CATEGORIA IS NULL THEN
      O_MSG := 'Identificador de categoría inválido.';
      RETURN;
    END IF;

    DELETE FROM MUE_CATEGORIA WHERE CAT_Categoria = P_CAT_CATEGORIA;
    IF SQL%ROWCOUNT = 0 THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La categoría no existe.';
      RETURN;
    END IF;

    O_COD_RET := C_OK;
    O_MSG     := 'Categoría eliminada correctamente.';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'No se puede eliminar la categoría (puede estar referenciada en productos): ' || SQLERRM;
  END PR_CATEGORIA_ELIMINAR;

  PROCEDURE PR_CATEGORIA_OBTENER (
    P_CAT_CATEGORIA IN  NUMBER,
    O_CAT_TIPO      OUT VARCHAR2,
    O_CAT_NOMBRE    OUT VARCHAR2,
    O_COD_RET       OUT NUMBER,
    O_MSG           OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET    := C_ERR;
    O_MSG        := NULL;
    O_CAT_TIPO   := NULL;
    O_CAT_NOMBRE := NULL;

    IF P_CAT_CATEGORIA IS NULL THEN
      O_MSG := 'Identificador de categoría inválido.';
      RETURN;
    END IF;

    SELECT C.CAT_Tipo, C.CAT_Nombre
      INTO O_CAT_TIPO, O_CAT_NOMBRE
      FROM MUE_CATEGORIA C
     WHERE C.CAT_Categoria = P_CAT_CATEGORIA;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      O_COD_RET := C_NOFND;
      O_MSG     := 'La categoría no existe.';
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al consultar categoría: ' || SQLERRM;
  END PR_CATEGORIA_OBTENER;

  PROCEDURE PR_CATEGORIA_LISTAR (
    P_FILTRO_TIPO IN  VARCHAR2 DEFAULT NULL,
    O_CURSOR      OUT SYS_REFCURSOR,
    O_COD_RET     OUT NUMBER,
    O_MSG         OUT VARCHAR2
  ) IS
  BEGIN
    O_COD_RET := C_ERR;
    O_MSG     := NULL;

    OPEN O_CURSOR FOR
      SELECT C.CAT_Categoria AS Categoria_Id,
             C.CAT_Tipo      AS Tipo,
             C.CAT_Nombre    AS Nombre
        FROM MUE_CATEGORIA C
       WHERE P_FILTRO_TIPO IS NULL
          OR UPPER(C.CAT_Tipo) LIKE '%' || UPPER(TRIM(P_FILTRO_TIPO)) || '%'
       ORDER BY C.CAT_Tipo ASC;

    O_COD_RET := C_OK;
    O_MSG     := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
      O_COD_RET := C_ERR;
      O_MSG     := 'Error al listar categorías: ' || SQLERRM;
  END PR_CATEGORIA_LISTAR;

END PKG_MUE_CATEGORIA;
/

-- GRANT EXECUTE ON PKG_MUE_CATEGORIA TO USR_APP_MUEBLERIA;